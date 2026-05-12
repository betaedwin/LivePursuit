#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:3000"
NAVIGATOR_ID="user-1"
DESTINATION_ID="simulated-destination"
NAVIGATOR_NAME="You"
DESTINATION_NAME="Simulated Destination"

require_backend() {
  local resp
  resp=$(curl -sS "$BASE_URL/sessions" || true)
  if [ -z "$resp" ]; then
    echo "Backend not responding at $BASE_URL" >&2
    exit 1
  fi
}

create_session() {
  local resp
  resp=$(curl -sS -X POST "$BASE_URL/sessions" \
    -H 'Content-Type: application/json' \
    -d "{\"navigatorUserId\":\"$NAVIGATOR_ID\",\"destinationUserId\":\"$DESTINATION_ID\",\"navigatorDisplayName\":\"$NAVIGATOR_NAME\",\"destinationDisplayName\":\"$DESTINATION_NAME\"}" || true)
  if [ -z "$resp" ]; then
    echo "Failed to create session (empty response)" >&2
    exit 1
  fi
  python3 -c 'import json,sys; print(json.loads(sys.argv[1])["data"]["id"])' "$resp"
}

start_simulation() {
  local session_id="$1"
  local script_id="$2"
  curl -s -X POST "$BASE_URL/sessions/$session_id/simulation/start" \
    -H 'Content-Type: application/json' \
    -d "{\"scriptId\":\"$script_id\"}" >/dev/null
}

poll_reroute_checks() {
  local session_id="$1"
  local max_seconds="$2"
  local start_ts
  start_ts=$(date +%s)
  while true; do
    local now
    now=$(date +%s)
    local elapsed=$((now - start_ts))
    if [ "$elapsed" -ge "$max_seconds" ]; then
      break
    fi

    curl -sS -X POST "$BASE_URL/sessions/$session_id/reroute-check" \
      -H 'Content-Type: application/json' \
      -d '{"userId":"user-1","currentEtaSeconds":900,"candidateEtaSeconds":600}' >/dev/null

    local status
    status=$(curl -sS "$BASE_URL/sessions/$session_id" | python3 -c 'import json,sys; print((json.load(sys.stdin)["data"].get("simulation") or {}).get("status", ""))' 2>/dev/null || true)
    if [ "$status" = "completed" ]; then
      break
    fi

    sleep 5
  done
}

assert_logs() {
  local session_id="$1"
  local expect_reroute="$2"
  local label="$3"

  local resp
  resp=$(curl -sS "$BASE_URL/sessions/$session_id/logs" || true)
  if [ -z "$resp" ]; then
    echo "$label: missing logs response" >&2
    exit 1
  fi
  python3 -c 'import json,sys
j=json.loads(sys.argv[1])
entries=j.get("data", [])
completed=any(e.get("type") == "simulation_completed" for e in entries)
if not completed:
    raise SystemExit(f"{sys.argv[2]}: missing simulation_completed")
triggered=sum(1 for e in entries if e.get("type") == "reroute_triggered")
expect = sys.argv[3]
if expect == "true" and triggered == 0:
    raise SystemExit(f"{sys.argv[2]}: expected at least one reroute_triggered")
if expect == "false" and triggered > 0:
    raise SystemExit(f"{sys.argv[2]}: expected zero reroute_triggered, got {triggered}")
print(f"{sys.argv[2]}: PASS (reroute_triggered={triggered})")
' "$resp" "$label" "$expect_reroute"
}

run_scenario() {
  local script_id="$1"
  local max_seconds="$2"
  local expect_reroute="$3"
  local label="$4"

  local session_id
  session_id=$(create_session)
  start_simulation "$session_id" "$script_id"
  poll_reroute_checks "$session_id" "$max_seconds"
  assert_logs "$session_id" "$expect_reroute" "$label"
}

main() {
  require_backend
  run_scenario "normal-driving" 100 true "Normal Driving"
  run_scenario "gps-jitter" 60 false "GPS Jitter"
  run_scenario "network-interruption" 90 any "Network Interruption"
}

main "$@"
