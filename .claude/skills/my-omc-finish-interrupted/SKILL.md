---
name: my-omc-finish-interrupted
description: >
  Finish an interrupted OMC session. Use when a previous OMC session was
  unexpectedly interrupted (e.g. context window overflow, system crash, network
  failure) and needs to be resumed. Invoke when user says "finish interrupted
  session", "resume previous OMC", or similar.
---
The previous session was interrupted. Find out where it left off and finish the
implementation of the open tasks.

Use the ralph skill to finish the session properly.

If more than one beads task were implemented in parallel, use the
"my-omc-parallel-work" skill to connect to the previous session.

Ask me up to 3 questions, one by one, to understand the situation, goals and
required tasks.
