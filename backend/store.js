const { CONFIG } = require('./config');

const sessions = new Map();

function nowMs() {
  return Date.now();
}

function generateId() {
  return Math.random().toString(36).slice(2, 10);
}

function buildSession({ navigatorUserId, destinationUserId, navigatorDisplayName, destinationDisplayName }) {
  const createdAt = nowMs();
  return {
    id: generateId(),
    navigatorUserId,
    destinationUserId,
    navigatorDisplayName: navigatorDisplayName || navigatorUserId,
    destinationDisplayName: destinationDisplayName || destinationUserId,
    state: 'active',
    consentState: 'active',
    endReason: null,
    endLogged: false,
    createdAt,
    lastActivityAt: createdAt,
    expiresAt: createdAt + CONFIG.SESSION_INACTIVITY_TTL_MS,
    lastRerouteAt: 0,
    lastRerouteLocation: null,
    lastStableLocation: null,
    rerouteTimestamps: [],
    latestLocation: null,
    lastLocationUpdateAt: 0,
    logs: [],
    simulation: null,
    lastRerouteDecision: null,
  };
}

function touchSession(session) {
  const now = nowMs();
  session.lastActivityAt = now;
  session.expiresAt = now + CONFIG.SESSION_INACTIVITY_TTL_MS;
}

function isExpired(session) {
  return session.state !== 'ended' && nowMs() > session.expiresAt;
}

function expireIfNeeded(session) {
  if (isExpired(session)) {
    session.state = 'ended';
    session.consentState = 'revoked';
    if (!session.endReason) {
      session.endReason = 'expired';
    }
  }
}

function createSession(payload) {
  const session = buildSession(payload);
  sessions.set(session.id, session);
  return session;
}

function listSessions(filter = {}) {
  const results = [];
  for (const session of sessions.values()) {
    expireIfNeeded(session);
    if (filter.navigatorUserId && session.navigatorUserId !== filter.navigatorUserId) continue;
    if (filter.destinationUserId && session.destinationUserId !== filter.destinationUserId) continue;
    if (filter.state && session.state !== filter.state) continue;
    results.push(session);
  }
  return results;
}

function getSession(id) {
  const session = sessions.get(id);
  if (!session) return null;
  expireIfNeeded(session);
  return session;
}

function updateSession(session) {
  touchSession(session);
  sessions.set(session.id, session);
  return session;
}

function setLatestLocation(session, location) {
  session.latestLocation = location;
  touchSession(session);
  sessions.set(session.id, session);
}

module.exports = {
  createSession,
  getSession,
  listSessions,
  updateSession,
  setLatestLocation,
};
