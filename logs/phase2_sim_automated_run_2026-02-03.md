# Phase 2 Automated Simulation Run

Date: 2026-02-03
Script: scripts/qa/run_phase2_sim_tests.sh
Backend: http://localhost:3000

## Results
- Normal Driving: PASS (reroute_triggered=3)
- GPS Jitter: PASS (reroute_triggered=0)
- Network Interruption: PASS (reroute_triggered=2)

## Notes
- Network interruption allows reroute decisions as long as the simulation completes.
