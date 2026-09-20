# Handover

Read this when your own context passes roughly 70 per cent, when an agent
reports its context running low, or when the user asks to close the session.

Start it early enough that you can still think clearly. A handover written with
the last few thousand tokens is worse than one written a little too soon.

## What to hand over

The successor needs what it cannot derive:

- **Where the work stands** and what is left to do on it.
- **What was verified, and by which evidence** — and, just as important, what
  was not verified.
- **Decisions the user made, with their reasons.** Without the reason, the
  successor reopens a settled question.
- **Facts that cost real effort to establish** — measured behaviour of a tool,
  a version-specific quirk, a technique that proved something. These are the
  expensive part of a session.
- **What only the user may do,** and what is currently waiting on them.

## The phase

1. **Secure anything that exists in only one place.** Files outside version
   control die with the machine. Ask the user before committing anything they
   did not ask for; offer to copy it out instead.
2. **Persist durable facts in beads memory,** one fact per entry, phrased so it
   is still true next month. Prefer it over a file in an ignored directory: the
   export rides into git, a scratch file does not.
3. **Have the working agent write its own handoff** while it still has context:
   the branch and change under way, the commits and what each carries, what is
   verified with which evidence, what is not, the facts a successor would
   otherwise rediscover the hard way, and what remains. Plain language, for a
   human and an agent alike.
4. **Delete nothing that is merely old.** Remove a memory or a note only when
   you can say why it is now wrong. Scaffolding written for a handover may be
   deleted once the work it describes has landed — not before, and not by
   assumption.
5. **Write a start prompt for the successor.** Always — it is cheap while the
   context is still there and expensive to reconstruct afterwards, and the user
   can discard it. It must:
   - restate the working mode, including which checkpoints are the user's;
   - point at the memory store, the handoff and the change under review;
   - **tell the successor to derive current state itself** and treat any
     snapshot in the prompt as a hint that may already be false. Between
     writing the prompt and using it, the user may have merged, closed or
     changed everything it asserts.
6. **Stop the agents** and tell the user, in order, what they should do next.
