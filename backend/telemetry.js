function logSessionEvent(session, type, details = {}) {
  const entry = {
    id: Math.random().toString(36).slice(2, 10),
    type,
    timestamp: Date.now(),
    details,
  };
  session.logs = session.logs || [];
  session.logs.push(entry);
  if (session.logs.length > 200) {
    session.logs.shift();
  }
  console.log(JSON.stringify({ sessionId: session.id, ...entry }));
  return entry;
}

function listSessionLogs(session) {
  return session.logs || [];
}

module.exports = { logSessionEvent, listSessionLogs };
