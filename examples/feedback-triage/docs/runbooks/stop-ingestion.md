---
id: runbook-stop-ingestion
title: Stop ingestion safely
status: active
owner: priya
last-verified: 2026-08-28
---

# Stop ingestion safely

Use this when items disappear, counts diverge, or routing behavior looks unsafe.
Stopping is reversible: upstream items queue until ingestion resumes.

The application source and deployment are not included in this documentation
snapshot. This is the command recorded by the fictional project:

```bash
npm run ingestion:pause
```

## Verify

1. The dashboard reports ingestion as `paused` for all three sources.
2. The pending count rises while the processed count stops.
3. Record the time and symptom in [`../STATE.md`](../STATE.md).
4. Do not resume until the owner named in `STATE.md` confirms the raw counts.

Never delete queued or raw items while investigating.

Tested by: sam (support lead), 2026-08-22, from a laptop, without asking anyone.
That is the test that matters — a runbook only its author can follow is not a
runbook.
