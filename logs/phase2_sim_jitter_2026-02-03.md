# Phase 2 Simulation Log — GPS Jitter

Date: 2026-02-03
Scenario: gps-jitter
Session ID: hhyg8im9
Backend PID: 69774

## Summary
- Simulation started and completed without reroute triggers.
- All reroute decisions were suppressed due to DISTANCE or JITTER.
- This validates jitter suppression for Phase 2.

## Evidence (Selected Log Events)
- simulation_started (scriptId: gps-jitter)
- simulation_completed (scriptId: gps-jitter)
- Multiple reroute_suppressed with reason_code: DISTANCE
- Multiple reroute_suppressed with reason_code: JITTER

## Notes
- Baseline reset on simulation start to prevent cross-scenario jumps.

## Raw Logs


## Raw Logs
```json
{
  "data": [
    {
      "id": "861wv5xm",
      "type": "session_started",
      "timestamp": 1770189053433,
      "details": {
        "navigatorUserId": "user-1",
        "destinationUserId": "simulated-destination"
      }
    },
    {
      "id": "30ipah3a",
      "type": "simulation_started",
      "timestamp": 1770189053461,
      "details": {
        "scriptId": "normal-driving"
      }
    },
    {
      "id": "m7in7tyo",
      "type": "reroute_suppressed",
      "timestamp": 1770189058586,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "3vrx118g",
      "type": "simulation_started",
      "timestamp": 1770189060348,
      "details": {
        "scriptId": "normal-driving"
      }
    },
    {
      "id": "mtju4246",
      "type": "reroute_suppressed",
      "timestamp": 1770189063584,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "xgm3vu63",
      "type": "reroute_suppressed",
      "timestamp": 1770189068577,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "z4wdhca1",
      "type": "simulation_started",
      "timestamp": 1770189070084,
      "details": {
        "scriptId": "gps-jitter"
      }
    },
    {
      "id": "9r17s2i8",
      "type": "reroute_suppressed",
      "timestamp": 1770189073578,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "ebsfbb5n",
      "type": "reroute_suppressed",
      "timestamp": 1770189078591,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "4346ai6n",
      "type": "reroute_suppressed",
      "timestamp": 1770189083588,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "oopv16zo",
      "type": "reroute_suppressed",
      "timestamp": 1770189088583,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "hf31s95q",
      "type": "reroute_suppressed",
      "timestamp": 1770189093586,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "DISTANCE"
      }
    },
    {
      "id": "k0kjcjvo",
      "type": "reroute_suppressed",
      "timestamp": 1770189098579,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "1eooad5v",
      "type": "simulation_completed",
      "timestamp": 1770189100086,
      "details": {
        "scriptId": "gps-jitter"
      }
    },
    {
      "id": "ylnuica6",
      "type": "reroute_suppressed",
      "timestamp": 1770189103632,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "57c608t5",
      "type": "reroute_suppressed",
      "timestamp": 1770189108578,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "nvmjmwab",
      "type": "reroute_suppressed",
      "timestamp": 1770189113606,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "rfvgv6h2",
      "type": "reroute_suppressed",
      "timestamp": 1770189118577,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "0m4rmyyn",
      "type": "reroute_suppressed",
      "timestamp": 1770189123573,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "ofmt2h1u",
      "type": "reroute_suppressed",
      "timestamp": 1770189128579,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "pmlv0xmz",
      "type": "reroute_suppressed",
      "timestamp": 1770189133580,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "h0v3puhy",
      "type": "reroute_suppressed",
      "timestamp": 1770189138576,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "iylyg4na",
      "type": "reroute_suppressed",
      "timestamp": 1770189143578,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "7rr8a8tq",
      "type": "reroute_suppressed",
      "timestamp": 1770189148586,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "2exmedlt",
      "type": "reroute_suppressed",
      "timestamp": 1770189153570,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "xirbb5mn",
      "type": "reroute_suppressed",
      "timestamp": 1770189158722,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "c4ke2nn3",
      "type": "reroute_suppressed",
      "timestamp": 1770189163573,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "ut1dsgo5",
      "type": "reroute_suppressed",
      "timestamp": 1770189168590,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "dj1vbmgv",
      "type": "reroute_suppressed",
      "timestamp": 1770189173578,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "d2i0xba5",
      "type": "reroute_suppressed",
      "timestamp": 1770189178593,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "fiiag9au",
      "type": "reroute_suppressed",
      "timestamp": 1770189183574,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "oqrgz5px",
      "type": "reroute_suppressed",
      "timestamp": 1770189188573,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "6jk7wwj4",
      "type": "reroute_suppressed",
      "timestamp": 1770189193575,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "34j308lh",
      "type": "reroute_suppressed",
      "timestamp": 1770189198580,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "fhxtmg8z",
      "type": "reroute_suppressed",
      "timestamp": 1770189203591,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "qe0r84al",
      "type": "reroute_suppressed",
      "timestamp": 1770189208589,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "e066ay2i",
      "type": "reroute_suppressed",
      "timestamp": 1770189213588,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "70umzczb",
      "type": "reroute_suppressed",
      "timestamp": 1770189218576,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "7ap89udc",
      "type": "reroute_suppressed",
      "timestamp": 1770189223570,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "gp4q6jot",
      "type": "reroute_suppressed",
      "timestamp": 1770189228586,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "llniw297",
      "type": "reroute_suppressed",
      "timestamp": 1770189233586,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "dt8bxe29",
      "type": "reroute_suppressed",
      "timestamp": 1770189238584,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "sm2p4lt7",
      "type": "reroute_suppressed",
      "timestamp": 1770189243583,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "csmkwhe3",
      "type": "reroute_suppressed",
      "timestamp": 1770189248576,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "sgvwz706",
      "type": "reroute_suppressed",
      "timestamp": 1770189253574,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "kshnhpwe",
      "type": "reroute_suppressed",
      "timestamp": 1770189258555,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "g20tqvju",
      "type": "reroute_suppressed",
      "timestamp": 1770189263566,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "a79szgcw",
      "type": "reroute_suppressed",
      "timestamp": 1770189268570,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "3sfl94bq",
      "type": "reroute_suppressed",
      "timestamp": 1770189273563,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "zho3caif",
      "type": "reroute_suppressed",
      "timestamp": 1770189278553,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "x4mmb4ad",
      "type": "reroute_suppressed",
      "timestamp": 1770189283557,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "grmjev9g",
      "type": "reroute_suppressed",
      "timestamp": 1770189288562,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "5d4kg0gp",
      "type": "reroute_suppressed",
      "timestamp": 1770189293544,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "awfq9b3c",
      "type": "reroute_suppressed",
      "timestamp": 1770189298559,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "yxlvlgvp",
      "type": "reroute_suppressed",
      "timestamp": 1770189303563,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "odtwda75",
      "type": "reroute_suppressed",
      "timestamp": 1770189308561,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "3z8k1595",
      "type": "reroute_suppressed",
      "timestamp": 1770189313557,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "4q233ap6",
      "type": "reroute_suppressed",
      "timestamp": 1770189318557,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "oi1hf4mv",
      "type": "reroute_suppressed",
      "timestamp": 1770189323560,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "5xdm133u",
      "type": "reroute_suppressed",
      "timestamp": 1770189328561,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "irqtcu40",
      "type": "reroute_suppressed",
      "timestamp": 1770189333551,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "ea3rftq3",
      "type": "reroute_suppressed",
      "timestamp": 1770189338556,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "uxp1yteu",
      "type": "reroute_suppressed",
      "timestamp": 1770189343553,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "f256m9ih",
      "type": "reroute_suppressed",
      "timestamp": 1770189348549,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "nn33jtz6",
      "type": "reroute_suppressed",
      "timestamp": 1770189353542,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "ayavvhii",
      "type": "reroute_suppressed",
      "timestamp": 1770189358556,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    },
    {
      "id": "ki6ybty1",
      "type": "reroute_suppressed",
      "timestamp": 1770189363562,
      "details": {
        "movement_delta": 0,
        "eta_delta": 0,
        "cooldown_state": false,
        "cap_state": false,
        "threshold_values_used": {
          "movementMeters": 100,
          "etaDeltaSeconds": 120,
          "jitterRadiusMeters": 30
        },
        "reason_code": "JITTER"
      }
    }
  ]
}

```
