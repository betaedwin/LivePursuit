const { getScript } = require('./simulationScripts');
const { logSessionEvent } = require('./telemetry');

const activeSimulations = new Map();

function nowMs() {
  return Date.now();
}

function stopSimulation(sessionId) {
  const existing = activeSimulations.get(sessionId);
  if (!existing) return null;
  existing.timers.forEach(clearTimeout);
  activeSimulations.delete(sessionId);
  return existing;
}

function getElapsedSeconds(simulation, now = nowMs()) {
  if (!simulation) return 0;
  const baseElapsed = simulation.elapsedSeconds || 0;
  if (simulation.status !== 'running' || !simulation.startedAt) {
    return baseElapsed;
  }
  const speed = simulation.speedMultiplier || 1;
  return baseElapsed + ((now - simulation.startedAt) / 1000) * speed;
}

function scheduleSimulation({ session, script, startAtSeconds, speedMultiplier, ingestLocation }) {
  stopSimulation(session.id);

  const timers = [];
  const remaining = script.points.filter((point) => point.offsetSeconds >= startAtSeconds - 0.001);
  if (remaining.length === 0) {
    session.simulation.status = 'completed';
    session.simulation.completedAt = nowMs();
    logSessionEvent(session, 'simulation_completed', { scriptId: script.id });
    return;
  }

  remaining.forEach((point, index) => {
    const delaySeconds = Math.max(0, (point.offsetSeconds - startAtSeconds) / speedMultiplier);
    const timer = setTimeout(() => {
      if (session.state !== 'active') {
        return;
      }
      if (!session.simulation || session.simulation.status !== 'running') {
        return;
      }
      logSessionEvent(session, 'destination_simulation_position_update', {
        scriptId: script.id,
        latitude: point.latitude,
        longitude: point.longitude,
        speed: point.speed,
        accuracy: point.accuracy,
        offsetSeconds: point.offsetSeconds,
      });
      const location = {
        latitude: point.latitude,
        longitude: point.longitude,
        timestamp: nowMs(),
        speed: point.speed,
        accuracy: point.accuracy,
      };
      ingestLocation(session, location, { source: 'simulation' });
      session.simulation.lastEventAt = nowMs();
      if (index === remaining.length - 1) {
        session.simulation.status = 'completed';
        session.simulation.completedAt = nowMs();
        logSessionEvent(session, 'simulation_completed', { scriptId: script.id });
        stopSimulation(session.id);
      }
    }, delaySeconds * 1000);
    timers.push(timer);
  });

  activeSimulations.set(session.id, {
    sessionId: session.id,
    scriptId: script.id,
    timers,
    startedAt: session.simulation.startedAt,
  });
}

function startSimulation({ session, scriptId, ingestLocation, forceLocation, speedMultiplier = 1 }) {
  const script = getScript(scriptId);
  if (!script) {
    return { error: `Unknown scriptId: ${scriptId}` };
  }

  stopSimulation(session.id);

  const startedAt = nowMs();
  session.simulation = {
    scriptId,
    status: 'running',
    startedAt,
    completedAt: null,
    lastEventAt: null,
    speedMultiplier,
    elapsedSeconds: 0,
  };

  logSessionEvent(session, 'simulation_started', { scriptId });
  if (scriptId === 'pursuit-police' || scriptId === 'pursuit-police-follow') {
    logSessionEvent(session, 'pursuit_profile_enabled', { scriptId });
    logSessionEvent(session, 'pursuit_simulation_started', { scriptId });
  }

  if (script.points.length && typeof forceLocation === 'function') {
    const first = script.points[0];
    forceLocation(session, {
      latitude: first.latitude,
      longitude: first.longitude,
      timestamp: nowMs(),
      speed: first.speed,
      accuracy: first.accuracy,
    });
  }

  scheduleSimulation({
    session,
    script,
    startAtSeconds: 0,
    speedMultiplier,
    ingestLocation,
  });

  return { data: session.simulation };
}

function pauseSimulation({ session }) {
  if (!session.simulation || session.simulation.status !== 'running') {
    return { error: 'Simulation is not running' };
  }
  const elapsedSeconds = getElapsedSeconds(session.simulation);
  session.simulation.elapsedSeconds = elapsedSeconds;
  session.simulation.status = 'paused';
  session.simulation.startedAt = null;
  stopSimulation(session.id);
  logSessionEvent(session, 'simulation_paused', { scriptId: session.simulation.scriptId });
  return { data: session.simulation };
}

function resumeSimulation({ session, ingestLocation }) {
  if (!session.simulation || session.simulation.status !== 'paused') {
    return { error: 'Simulation is not paused' };
  }
  const script = getScript(session.simulation.scriptId);
  if (!script) {
    return { error: `Unknown scriptId: ${session.simulation.scriptId}` };
  }
  session.simulation.status = 'running';
  session.simulation.startedAt = nowMs();
  logSessionEvent(session, 'simulation_resumed', { scriptId: session.simulation.scriptId });
  scheduleSimulation({
    session,
    script,
    startAtSeconds: session.simulation.elapsedSeconds || 0,
    speedMultiplier: session.simulation.speedMultiplier || 1,
    ingestLocation,
  });
  return { data: session.simulation };
}

function restartSimulation({ session, ingestLocation, forceLocation }) {
  if (!session.simulation) {
    return { error: 'Simulation has not been started' };
  }
  const script = getScript(session.simulation.scriptId);
  if (!script) {
    return { error: `Unknown scriptId: ${session.simulation.scriptId}` };
  }
  session.simulation.status = 'running';
  session.simulation.startedAt = nowMs();
  session.simulation.completedAt = null;
  session.simulation.lastEventAt = null;
  session.simulation.elapsedSeconds = 0;
  logSessionEvent(session, 'simulation_started', { scriptId: session.simulation.scriptId, reason: 'restart' });

  if (script.points.length && typeof forceLocation === 'function') {
    const first = script.points[0];
    forceLocation(session, {
      latitude: first.latitude,
      longitude: first.longitude,
      timestamp: nowMs(),
      speed: first.speed,
      accuracy: first.accuracy,
    });
  }

  scheduleSimulation({
    session,
    script,
    startAtSeconds: 0,
    speedMultiplier: session.simulation.speedMultiplier || 1,
    ingestLocation,
  });
  return { data: session.simulation };
}

function setSimulationSpeed({ session, speedMultiplier, ingestLocation }) {
  if (!session.simulation) {
    return { error: 'Simulation has not been started' };
  }
  const script = getScript(session.simulation.scriptId);
  if (!script) {
    return { error: `Unknown scriptId: ${session.simulation.scriptId}` };
  }
  const elapsedSeconds = getElapsedSeconds(session.simulation);
  session.simulation.elapsedSeconds = elapsedSeconds;
  session.simulation.speedMultiplier = speedMultiplier;

  if (session.simulation.status === 'running') {
    session.simulation.startedAt = nowMs();
    scheduleSimulation({
      session,
      script,
      startAtSeconds: elapsedSeconds,
      speedMultiplier,
      ingestLocation,
    });
  }

  return { data: session.simulation };
}

function replaySimulation({ session, scriptId, ingestLocation, forceLocation, speedMultiplier }) {
  return startSimulation({ session, scriptId, ingestLocation, forceLocation, speedMultiplier });
}

function getSimulation(sessionId) {
  return activeSimulations.get(sessionId) || null;
}

module.exports = {
  startSimulation,
  stopSimulation,
  replaySimulation,
  pauseSimulation,
  resumeSimulation,
  restartSimulation,
  setSimulationSpeed,
  getSimulation,
  getElapsedSeconds,
};
