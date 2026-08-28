# Start here

**For anyone new to this project — engineer or not.** Ten minutes. After this you
know what is being built, what you are allowed to do, and what to do when
something looks wrong.

## What this is

Customer feedback arrives in three places: the in-app widget, the support inbox,
and the app store reviews. This service collects all three, notices when the same
complaint arrives twice, and sends each one to the team that can actually fix it.

Before it existed, that routing was done by hand every morning and took about an
hour. The point of the project is that hour.

## Three things that matter most for you

### 1. If it is misrouting, stop the ingestion — you do not need permission

One command, written down here: [`docs/runbooks/stop-ingestion.md`](docs/runbooks/stop-ingestion.md).
Stopping it is safe. Nothing is lost; items queue up and are processed when it
restarts.

### 2. Counts are only real if they come out of the dashboard

If you hear a number in chat that is not on the dashboard, treat it as
unverified — not because anyone is lying, but because counts computed by hand
across three channels are almost always wrong in the same direction.

### 3. If something looks off, say so — even if you are not sure

"This looks weird to me" is a useful contribution. The most expensive failure
this project has had so far was silent: no error, no alarm, just tickets
quietly disappearing for nine days.
See [`docs/lessons/silent-dedupe-dropped-real-tickets.md`](docs/lessons/silent-dedupe-dropped-real-tickets.md).

## Map

| You want to… | Open |
|---|---|
| stop it | [`docs/runbooks/stop-ingestion.md`](docs/runbooks/stop-ingestion.md) |
| know what a term means | [`docs/GLOSSARY.md`](docs/GLOSSARY.md) |
| know how the team works | [`docs/HOW-WE-WORK.md`](docs/HOW-WE-WORK.md) |
| know where the work stands | [`docs/STATE.md`](docs/STATE.md) |
| know why something is the way it is | [`docs/decisions/`](docs/decisions/) |
| see every document | [`docs/README.md`](docs/README.md) |

## If you want something built

Do not ask in chat and hope someone remembers. Write it as a **fragment** —
[`docs/HOW-WE-WORK.md`](docs/HOW-WE-WORK.md) explains how. You do not need to
write code to write one. Just say what you want and how you will know it is done.
