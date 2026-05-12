const http = require('http');
const { CONFIG } = require('./config');
const { createSession, getSession, listSessions, updateSession, setLatestLocation } = require('./store');
const { haversineDistanceMeters } = require('./geo');
const { logSessionEvent, listSessionLogs } = require('./telemetry');
const {
  startSimulation,
  stopSimulation,
  replaySimulation,
  pauseSimulation,
  resumeSimulation,
  restartSimulation,
  setSimulationSpeed,
  getElapsedSeconds,
} = require('./simulationEngine');
const { listScripts } = require('./simulationScripts');

function jsonResponse(res, status, payload) {
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  });
  res.end(JSON.stringify(payload));
}

function errorResponse(res, status, code, message, details = []) {
  jsonResponse(res, status, { error: { code, message, details } });
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
    });
    req.on('end', () => {
      if (!data) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(data));
      } catch (err) {
        reject(err);
      }
    });
  });
}

function requireField(value, field) {
  if (value === undefined || value === null || value === '') {
    return `${field} is required`;
  }
  return null;
}

function parseNumber(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function validateLocation(payload) {
  const errors = [];
  const latitude = parseNumber(payload.latitude);
  const longitude = parseNumber(payload.longitude);
  const accuracy = parseNumber(payload.accuracy);
  const speed = parseNumber(payload.speed);
  if (latitude === null || latitude < -90 || latitude > 90) {
    errors.push({ field: 'latitude', message: 'must be a valid latitude' });
  }
  if (longitude === null || longitude < -180 || longitude > 180) {
    errors.push({ field: 'longitude', message: 'must be a valid longitude' });
  }
  if (accuracy !== null && accuracy < 0) {
    errors.push({ field: 'accuracy', message: 'must be a positive number' });
  }
  if (speed !== null && speed < 0) {
    errors.push({ field: 'speed', message: 'must be a positive number' });
  }
  return { latitude, longitude, accuracy, speed, errors };
}

function isSessionActive(session) {
  return session.state === 'active' && session.consentState === 'active';
}

function logExpirationIfNeeded(session) {
  if (session.state === 'ended' && session.endReason === 'expired' && !session.endLogged) {
    session.endLogged = true;
    logSessionEvent(session, 'session_ended', { reason: 'expired' });
  }
}

function speedBucket(speed) {
  if (speed === null || speed === undefined || !Number.isFinite(speed)) {
    return 'stationary';
  }
  if (speed <= CONFIG.THROTTLE_SPEED_MPS.STATIONARY_MAX) return 'stationary';
  if (speed <= CONFIG.THROTTLE_SPEED_MPS.WALKING_MAX) return 'walking';
  return 'driving';
}

function accuracyBucket(accuracy) {
  if (accuracy === null || accuracy === undefined || !Number.isFinite(accuracy)) {
    return 'medium';
  }
  if (accuracy <= CONFIG.THROTTLE_ACCURACY_METERS.GOOD_MAX) return 'good';
  if (accuracy <= CONFIG.THROTTLE_ACCURACY_METERS.MEDIUM_MAX) return 'medium';
  return 'poor';
}

function calculateSpeedFromHistory(session, location) {
  const last = session.latestLocation;
  if (!last) return location.speed;
  const timeDeltaSeconds = (location.timestamp - last.timestamp) / 1000;
  if (!Number.isFinite(timeDeltaSeconds) || timeDeltaSeconds <= 0) return location.speed;
  const distance = haversineDistanceMeters(last, location);
  return distance / timeDeltaSeconds;
}

function evaluateThrottle(session, location) {
  const calculatedSpeed = calculateSpeedFromHistory(session, location);
  const speedValue = Number.isFinite(location.speed) ? location.speed : calculatedSpeed;
  const speedTier = speedBucket(speedValue);
  const accuracyTier = accuracyBucket(location.accuracy);
  const baseInterval =
    CONFIG.THROTTLE_INTERVAL_SECONDS[speedTier.toUpperCase()] ??
    CONFIG.THROTTLE_INTERVAL_SECONDS.WALKING;
  const accuracyMultiplier =
    CONFIG.THROTTLE_ACCURACY_MULTIPLIER[accuracyTier.toUpperCase()] ??
    CONFIG.THROTTLE_ACCURACY_MULTIPLIER.MEDIUM;
  const intervalSeconds = Math.max(1, baseInterval * accuracyMultiplier);
  return {
    intervalSeconds,
    speedBucket: speedTier,
    accuracyBucket: accuracyTier,
  };
}

function updateStableLocation(session, location) {
  const stable = session.lastStableLocation;
  if (!stable) {
    session.lastStableLocation = location;
    return;
  }
  const delta = haversineDistanceMeters(stable, location);
  if (delta >= CONFIG.JITTER_RADIUS_METERS) {
    session.lastStableLocation = location;
  }
}

function ingestLocation(session, location, { source }) {
  const now = Date.now();
  const throttle = evaluateThrottle(session, location);
  const lastUpdate = session.lastLocationUpdateAt || 0;
  const nextAllowedAt = lastUpdate ? lastUpdate + throttle.intervalSeconds * 1000 : now;
  if (now < nextAllowedAt) {
    return {
      accepted: false,
      nextAllowedAt,
      throttle,
    };
  }

  session.lastLocationUpdateAt = now;
  session.latestLocation = location;
  updateStableLocation(session, location);
  if (!session.lastRerouteLocation) {
    session.lastRerouteLocation = session.lastStableLocation || location;
  }
  setLatestLocation(session, location);
  return {
    accepted: true,
    nextAllowedAt: now + throttle.intervalSeconds * 1000,
    throttle,
  };
}

function forceLocation(session, location) {
  const now = Date.now();
  session.lastLocationUpdateAt = now;
  session.latestLocation = location;
  session.lastStableLocation = location;
  session.lastRerouteLocation = location;
  setLatestLocation(session, location);
}

function evaluateReroute(session, currentEtaSeconds, candidateEtaSeconds) {
  const now = Date.now();
  const latest = session.latestLocation;
  const baseThresholds = {
    movementMeters: CONFIG.REROUTE_DISTANCE_METERS,
    etaDeltaSeconds: CONFIG.REROUTE_ETA_DELTA_SECONDS,
    jitterRadiusMeters: CONFIG.JITTER_RADIUS_METERS,
  };
  const timeSinceLast = session.lastRerouteAt ? now - session.lastRerouteAt : Number.POSITIVE_INFINITY;
  const cooldownRemainingSeconds = session.lastRerouteAt
    ? Math.max(0, (CONFIG.REROUTE_MIN_INTERVAL_MS - timeSinceLast) / 1000)
    : 0;

  const finalizeDecision = (payload) => {
    const decision = { cooldownRemainingSeconds, ...payload };
    session.lastRerouteDecision = decision;
    return decision;
  };

  if (!latest) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'NO_LOCATION',
      etaDeltaSeconds: 0,
      movementDeltaMeters: 0,
      cooldownActive: false,
      capActive: false,
      thresholdValuesUsed: baseThresholds,
    });
  }

  if (!isSessionActive(session)) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'SESSION_INACTIVE',
      etaDeltaSeconds: 0,
      movementDeltaMeters: 0,
      cooldownActive: false,
      capActive: false,
      thresholdValuesUsed: baseThresholds,
    });
  }

  const cooldownActive = timeSinceLast < CONFIG.REROUTE_MIN_INTERVAL_MS;
  if (cooldownActive) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'MIN_INTERVAL',
      etaDeltaSeconds: 0,
      movementDeltaMeters: 0,
      cooldownActive,
      capActive: false,
      thresholdValuesUsed: baseThresholds,
    });
  }

  session.rerouteTimestamps = session.rerouteTimestamps.filter(
    (timestamp) => now - timestamp <= 60 * 1000
  );
  const capActive = session.rerouteTimestamps.length >= CONFIG.REROUTE_MAX_PER_MINUTE;
  if (capActive) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'RATE_LIMIT',
      etaDeltaSeconds: 0,
      movementDeltaMeters: 0,
      cooldownActive,
      capActive,
      thresholdValuesUsed: baseThresholds,
    });
  }

  const stableLocation = session.lastStableLocation || latest;
  const jitterDelta = haversineDistanceMeters(stableLocation, latest);
  if (jitterDelta > 0 && jitterDelta < CONFIG.JITTER_RADIUS_METERS) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'JITTER',
      etaDeltaSeconds: 0,
      movementDeltaMeters: 0,
      cooldownActive,
      capActive,
      thresholdValuesUsed: baseThresholds,
    });
  }

  const referenceLocation = session.lastRerouteLocation || stableLocation;
  const movementDelta = haversineDistanceMeters(referenceLocation, stableLocation);

  const inHysteresis = session.lastRerouteAt && now - session.lastRerouteAt < CONFIG.REROUTE_HYSTERESIS_WINDOW_MS;
  const hysteresisMultiplier = inHysteresis ? CONFIG.REROUTE_HYSTERESIS_MULTIPLIER : 1;
  const distanceThreshold = CONFIG.REROUTE_DISTANCE_METERS * hysteresisMultiplier;
  const etaThreshold = CONFIG.REROUTE_ETA_DELTA_SECONDS * hysteresisMultiplier;
  const thresholdValuesUsed = {
    movementMeters: distanceThreshold,
    etaDeltaSeconds: etaThreshold,
    jitterRadiusMeters: CONFIG.JITTER_RADIUS_METERS,
  };

  if (movementDelta < distanceThreshold) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'DISTANCE',
      etaDeltaSeconds: 0,
      movementDeltaMeters: movementDelta,
      cooldownActive,
      capActive,
      thresholdValuesUsed,
    });
  }

  const etaDeltaSeconds = Math.abs(candidateEtaSeconds - currentEtaSeconds);
  const etaUnreliable =
    !Number.isFinite(currentEtaSeconds) ||
    !Number.isFinite(candidateEtaSeconds) ||
    currentEtaSeconds <= 0 ||
    candidateEtaSeconds <= 0;

  if (!etaUnreliable && etaDeltaSeconds < etaThreshold) {
    return finalizeDecision({
      shouldReroute: false,
      reason: 'ETA_DELTA',
      etaDeltaSeconds,
      movementDeltaMeters: movementDelta,
      cooldownActive,
      capActive,
      thresholdValuesUsed,
    });
  }

  session.lastRerouteAt = now;
  session.lastRerouteLocation = stableLocation;
  session.rerouteTimestamps.push(now);
  return finalizeDecision({
    shouldReroute: true,
    reason: etaUnreliable ? 'FALLBACK_DISTANCE' : 'THRESHOLD_MET',
    etaDeltaSeconds: etaUnreliable ? 0 : etaDeltaSeconds,
    movementDeltaMeters: movementDelta,
    cooldownActive,
    capActive,
    thresholdValuesUsed,
  });
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);
  const segments = url.pathname.split('/').filter(Boolean);

  try {
    if (segments.length === 1 && segments[0] === 'healthz' && req.method === 'GET') {
      jsonResponse(res, 200, { ok: true });
      return;
    }

    if (segments.length === 1 && segments[0] === 'simulation-scripts' && req.method === 'GET') {
      jsonResponse(res, 200, { data: listScripts() });
      return;
    }

    if (segments.length === 1 && segments[0] === 'sessions' && req.method === 'GET') {
      const navigatorUserId = url.searchParams.get('navigatorUserId') || undefined;
      const destinationUserId = url.searchParams.get('destinationUserId') || undefined;
      const state = url.searchParams.get('state') || undefined;
      const sessions = listSessions({ navigatorUserId, destinationUserId, state });
      sessions.forEach(logExpirationIfNeeded);
      jsonResponse(res, 200, { data: sessions });
      return;
    }

    if (segments.length === 1 && segments[0] === 'sessions' && req.method === 'POST') {
      const payload = await readJsonBody(req);
      const errors = [];
      const navigatorUserIdError = requireField(payload.navigatorUserId, 'navigatorUserId');
      const destinationUserIdError = requireField(payload.destinationUserId, 'destinationUserId');
      if (navigatorUserIdError) errors.push({ field: 'navigatorUserId', message: navigatorUserIdError });
      if (destinationUserIdError) errors.push({ field: 'destinationUserId', message: destinationUserIdError });
      if (errors.length) {
        errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid session payload', errors);
        return;
      }

      const session = createSession({
        navigatorUserId: payload.navigatorUserId,
        destinationUserId: payload.destinationUserId,
        navigatorDisplayName: payload.navigatorDisplayName,
        destinationDisplayName: payload.destinationDisplayName,
      });
      logSessionEvent(session, 'session_started', {
        navigatorUserId: session.navigatorUserId,
        destinationUserId: session.destinationUserId,
      });
      jsonResponse(res, 201, { data: session });
      return;
    }

    if (segments.length === 2 && segments[0] === 'sessions' && req.method === 'GET') {
      const session = getSession(segments[1]);
      if (!session) {
        errorResponse(res, 404, 'NOT_FOUND', 'Session not found');
        return;
      }
      logExpirationIfNeeded(session);
      jsonResponse(res, 200, { data: session });
      return;
    }

    if (segments.length === 3 && segments[0] === 'sessions') {
      const sessionId = segments[1];
      const action = segments[2];
      const session = getSession(sessionId);
      if (!session) {
        errorResponse(res, 404, 'NOT_FOUND', 'Session not found');
        return;
      }
      logExpirationIfNeeded(session);
      logExpirationIfNeeded(session);

      if (req.method === 'POST' && action === 'events') {
        const payload = await readJsonBody(req);
        const typeError = requireField(payload.type, 'type');
        if (typeError) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid request', [
            { field: 'type', message: typeError },
          ]);
          return;
        }
        const entry = logSessionEvent(session, payload.type, payload.details || {});
        updateSession(session);
        jsonResponse(res, 200, { data: entry });
        return;
      }

      if (req.method === 'GET' && action === 'logs') {
        jsonResponse(res, 200, { data: listSessionLogs(session) });
        return;
      }

      if (req.method === 'POST' && ['pause', 'resume', 'stop'].includes(action)) {
        const payload = await readJsonBody(req);
        const userIdError = requireField(payload.userId, 'userId');
        if (userIdError) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid request', [
            { field: 'userId', message: userIdError },
          ]);
          return;
        }
        const isDestination = payload.userId === session.destinationUserId;
        const isNavigator = payload.userId === session.navigatorUserId;
        if (action !== 'stop' && !isDestination) {
          errorResponse(res, 403, 'FORBIDDEN', 'Only destination can pause or resume navigation');
          return;
        }
        if (action === 'stop' && !(isDestination || isNavigator)) {
          errorResponse(res, 403, 'FORBIDDEN', 'Only navigator or destination can stop navigation');
          return;
        }

        if (action === 'pause') {
          session.state = 'paused';
          logSessionEvent(session, 'session_paused', { userId: payload.userId });
        } else if (action === 'resume') {
          session.state = 'active';
          logSessionEvent(session, 'session_resumed', { userId: payload.userId });
        } else if (action === 'stop') {
          session.state = 'ended';
          session.consentState = 'revoked';
          session.endReason = payload.userId === session.destinationUserId ? 'stopped_by_destination' : 'stopped_by_navigator';
          logSessionEvent(session, 'session_ended', { userId: payload.userId, reason: session.endReason });
          session.endLogged = true;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session });
        return;
      }

      if (req.method === 'POST' && action === 'location') {
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const payload = await readJsonBody(req);
        const userIdError = requireField(payload.userId, 'userId');
        if (userIdError) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid request', [
            { field: 'userId', message: userIdError },
          ]);
          return;
        }
        if (payload.userId !== session.destinationUserId) {
          errorResponse(res, 403, 'FORBIDDEN', 'Only destination can update location');
          return;
        }

        const { latitude, longitude, accuracy, speed, errors } = validateLocation(payload);
        if (errors.length) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid location payload', errors);
          return;
        }

        const timestamp = parseNumber(payload.timestamp) || Date.now();
        const location = { latitude, longitude, timestamp, accuracy, speed };
        const ingestResult = ingestLocation(session, location, { source: 'device' });
        if (ingestResult.accepted && !session.lastRerouteLocation) {
          session.lastRerouteLocation = session.lastStableLocation || location;
        }
        updateSession(session);
        jsonResponse(res, 200, {
          data: {
            latestLocation: session.latestLocation,
            accepted: ingestResult.accepted,
            nextAllowedAt: ingestResult.nextAllowedAt,
            throttle: ingestResult.throttle,
          },
        });
        return;
      }

      if (req.method === 'GET' && action === 'target-location') {
        const userId = url.searchParams.get('userId');
        if (!userId) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'userId is required', [
            { field: 'userId', message: 'userId is required' },
          ]);
          return;
        }
        if (userId !== session.navigatorUserId) {
          errorResponse(res, 403, 'FORBIDDEN', 'Only navigator can fetch target location');
          return;
        }

        const latest = session.latestLocation;
        const stale = latest ? Date.now() - latest.timestamp > CONFIG.LOCATION_STALE_MS : true;
        const simulation = session.simulation
          ? {
              scriptId: session.simulation.scriptId,
              status: session.simulation.status,
              speedMultiplier: session.simulation.speedMultiplier || 1,
              elapsedSeconds: getElapsedSeconds(session.simulation),
              startedAt: session.simulation.startedAt || null,
              lastEventAt: session.simulation.lastEventAt || null,
              completedAt: session.simulation.completedAt || null,
            }
          : null;
        const cooldownRemainingSeconds = session.lastRerouteAt
          ? Math.max(0, (CONFIG.REROUTE_MIN_INTERVAL_MS - (Date.now() - session.lastRerouteAt)) / 1000)
          : 0;
        jsonResponse(res, 200, {
          data: {
            sessionState: session.state,
            consentState: session.consentState,
            navigatorDisplayName: session.navigatorDisplayName,
            destinationDisplayName: session.destinationDisplayName,
            endReason: session.endReason,
            latestLocation: latest,
            stale,
            simulation,
            cooldownRemainingSeconds,
            lastRerouteDecision: session.lastRerouteDecision,
          },
        });
        return;
      }

      if (req.method === 'POST' && action === 'reroute-check') {
        const payload = await readJsonBody(req);
        const userIdError = requireField(payload.userId, 'userId');
        if (userIdError) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid request', [
            { field: 'userId', message: userIdError },
          ]);
          return;
        }
        if (payload.userId !== session.navigatorUserId) {
          errorResponse(res, 403, 'FORBIDDEN', 'Only navigator can request reroute evaluation');
          return;
        }

        const currentEtaSeconds = parseNumber(payload.currentEtaSeconds);
        const candidateEtaSeconds = parseNumber(payload.candidateEtaSeconds);
        if (currentEtaSeconds === null || candidateEtaSeconds === null) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'ETA values are required', [
            { field: 'currentEtaSeconds', message: 'must be a number' },
            { field: 'candidateEtaSeconds', message: 'must be a number' },
          ]);
          return;
        }

        const decision = evaluateReroute(session, currentEtaSeconds, candidateEtaSeconds);
        const logPayload = {
          movement_delta: decision.movementDeltaMeters || 0,
          eta_delta: decision.etaDeltaSeconds || 0,
          cooldown_state: !!decision.cooldownActive,
          cap_state: !!decision.capActive,
          threshold_values_used: decision.thresholdValuesUsed || {
            movementMeters: CONFIG.REROUTE_DISTANCE_METERS,
            etaDeltaSeconds: CONFIG.REROUTE_ETA_DELTA_SECONDS,
            jitterRadiusMeters: CONFIG.JITTER_RADIUS_METERS,
          },
          reason_code: decision.reason,
        };
        logSessionEvent(session, decision.shouldReroute ? 'reroute_triggered' : 'reroute_suppressed', logPayload);
        updateSession(session);
        jsonResponse(res, 200, { data: decision });
        return;
      }
    }

    if (segments.length === 4 && segments[0] === 'sessions' && segments[2] === 'simulation') {
      const sessionId = segments[1];
      const action = segments[3];
      const session = getSession(sessionId);
      if (!session) {
        errorResponse(res, 404, 'NOT_FOUND', 'Session not found');
        return;
      }

      if (req.method === 'POST' && action === 'start') {
        const payload = await readJsonBody(req);
        const scriptIdError = requireField(payload.scriptId, 'scriptId');
        if (scriptIdError) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'Invalid request', [
            { field: 'scriptId', message: scriptIdError },
          ]);
          return;
        }
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const speedMultiplier = parseNumber(payload.speedMultiplier) || 1;
        const result = startSimulation({
          session,
          scriptId: payload.scriptId,
          ingestLocation,
          forceLocation,
          speedMultiplier,
        });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'stop') {
        stopSimulation(session.id);
        if (!session.simulation) {
          session.simulation = {
            scriptId: 'unknown',
            status: 'stopped',
            startedAt: null,
            lastEventAt: null,
            completedAt: Date.now(),
            speedMultiplier: 1,
            elapsedSeconds: 0,
          };
        } else {
          session.simulation.status = 'stopped';
          session.simulation.completedAt = Date.now();
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'pause') {
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const result = pauseSimulation({ session });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'resume') {
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const result = resumeSimulation({ session, ingestLocation });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'restart') {
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const result = restartSimulation({ session, ingestLocation, forceLocation });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'speed') {
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const payload = await readJsonBody(req);
        const speedMultiplier = parseNumber(payload.speedMultiplier);
        if (speedMultiplier === null || speedMultiplier <= 0) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'speedMultiplier must be a positive number', [
            { field: 'speedMultiplier', message: 'must be a positive number' },
          ]);
          return;
        }
        const result = setSimulationSpeed({ session, speedMultiplier, ingestLocation });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }

      if (req.method === 'POST' && action === 'replay') {
        const payload = await readJsonBody(req);
        const scriptId = payload.scriptId || session.simulation?.scriptId;
        if (!scriptId) {
          errorResponse(res, 400, 'VALIDATION_ERROR', 'scriptId is required', [
            { field: 'scriptId', message: 'scriptId is required' },
          ]);
          return;
        }
        if (session.state !== 'active') {
          errorResponse(res, 409, 'SESSION_INACTIVE', 'Session is not active');
          return;
        }
        const speedMultiplier = parseNumber(payload.speedMultiplier) || 1;
        const result = replaySimulation({
          session,
          scriptId,
          ingestLocation,
          forceLocation,
          speedMultiplier,
        });
        if (result.error) {
          errorResponse(res, 400, 'VALIDATION_ERROR', result.error);
          return;
        }
        updateSession(session);
        jsonResponse(res, 200, { data: session.simulation });
        return;
      }
    }

    errorResponse(res, 404, 'NOT_FOUND', 'Route not found');
  } catch (err) {
    errorResponse(res, 500, 'SERVER_ERROR', 'Unexpected server error', [
      { message: err.message },
    ]);
  }
});

server.listen(CONFIG.PORT, () => {
  console.log(`Live Pursuit backend listening on :${CONFIG.PORT}`);
});
