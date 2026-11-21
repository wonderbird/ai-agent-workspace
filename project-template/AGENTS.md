# Project Instructions for AI Agents

<!-- markdownlint-disable MD013 MD022 MD025 MD031 MD032 MD034 --><!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:1105d646 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/core-concepts/sync-concepts.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->
<!-- markdownlint-enable MD013 MD022 MD025 MD031 MD032 MD034 -->

## Session Completion: Repository Steps

Run these steps as part of the Session Completion checklist above, after
step 3 (update issue status) and before step 4 (git/sync). They live outside
the managed Beads block because bd may regenerate that block and drop local
edits.

1. **Check for memories** - `bd memories` must report none. Otherwise follow
   "Durable knowledge lives in tracked files, not in bd memories" below.
2. **Export beads** - run `bd export --all -o .beads/issues.jsonl`, then
   check that `git status --short .beads/` lists no path other than
   `.beads/issues.jsonl`, `.beads/config.yaml` and `.beads/metadata.json`.

## Beads: Data Safety and Workflow Rules

### `.beads/issues.jsonl` is git-tracked

`.beads/issues.jsonl` is tracked in git through a whitelist in the root
`.gitignore`: `.beads/*` with `!.beads/issues.jsonl`,
`!.beads/config.yaml` and `!.beads/metadata.json` negations. The pattern is
`.beads/*`, not `.beads/`, because a directory-pattern ignore blocks any later
negation from any ignore file. This makes the file survive across clones even
without a Dolt remote sync.

`.beads/metadata.json` holds the beads `project_id` and the Dolt database
name. Tracking it keeps both identical in every clone.

The same rule cuts the other way: `bd init --stealth` writes the directory
pattern `.beads/` into the clone-local `.git/info/exclude`, and git then
never reads the `.gitignore` negations. The human who initializes beads in a
clone removes that line and checks the result:

```bash
sed -i '/^\.beads\/$/d' .git/info/exclude
git check-ignore .beads/issues.jsonl .beads/config.yaml .beads/metadata.json
echo $?   # 1 and no output = none of the files ignored
```

The removal is needed even after both files are committed. With `.beads/`
excluded, git still shows changes to the committed files, but
`git add .beads/issues.jsonl` prints an "ignored by one of your .gitignore
files" hint and exits 1 (verified with bd 1.3.4). If `git add
.beads/issues.jsonl` reports the file as ignored, the clone is misconfigured:
report it to the user.

Never stage the file with `git add -f` to work around this: the clone stays
misconfigured, and the next agent hits the same refusal.

bd's fork protection is deliberately overridden. When `bd init` detects a
fork, it writes `.beads/issues.jsonl` into `.git/info/exclude`, so that a
contributor's pull request does not carry the upstream issue export. The root
`.gitignore` negation `!.beads/issues.jsonl` takes precedence over
`.git/info/exclude` (verified), so that exclude has no effect here. This
repository tracks the file on purpose. Do not change the negation to restore
the protection.

`.beads/config.yaml` sets `issue-prefix`, because bd otherwise derives the
prefix of new issues from the clone's directory name. bd rewrites the file
with `issue-prefix` as its first key; keep it there, or every `bd init` leaves
the tracked file modified.

`.beads/config.yaml` also keeps beads out of git's way: `no-git-ops: true`, so bd
runs no git operation of its own, and no auto-export is configured. bd's
auto-export hardcodes memories, infra, templates, and gates out of every
write (`includeMemories=false`, unconditionally — GH#3650: memories may hold
private agent context that must not land in git history via the automatic
path), and no config key widens that scope. The findings gates of the
`record-findings` skill must be captured, and a stray memory must stay visible
to the pre-commit check in "Durable knowledge lives in tracked files" below.
The export is therefore manual and full:

```bash
bd export --all -o .beads/issues.jsonl   # after the last bd mutation
```

Run the export in every response that mutates bd, once, after all bd
operations in that response are done — not after each individual `bd`
command. This saves `bd` invocations without letting the file fall behind.

**Always use `--all`, never plain `bd export` and never re-enable
`export.auto`, on this file.** A narrower-scope write loses records without
warning: with bd 1.3.4, a plain `bd export -o .beads/issues.jsonl` after an
`--all` export rewrote the file without its memory records.

Staging and committing the file still follow the normal Agent Context
Profile git policy above (Conservative default: report status, do not
commit without being asked).

**This overrides the managed Beads block above.** That block calls
`.beads/issues.jsonl` a passive export and names `refs/dolt/data` as the sync
path. In this repository, the tracked, `--all`-exported JSONL is the primary
durability path: issues and gates are recoverable from a plain git clone
without ever needing `bd dolt pull`. bd's Dolt-backed sync
(`refs/dolt/data`) remains available as a secondary mechanism only.

### Durable knowledge lives in tracked files, not in bd memories

**This overrides the managed Beads block above and the text that `bd prime`
injects.** Both say to use `bd remember` for persistent knowledge. In this
repository, do not use it.

- Record a durable insight in a tracked file in the same response that
  discovers it: agent rules and workflow conventions in `CLAUDE.md`, project
  knowledge under `docs/`. Reason: a tracked file is reviewed in diffs and
  survives the loss of this machine once it is pushed.
- Do not use `bd remember` or Claude Code's file-based auto memory under
  `~/.claude/projects/`. Both live only on this machine and are lost when the
  virtual machine is destroyed.
- At commit time, `.beads/issues.jsonl` holds no memory records. Check before
  every commit:

  ```bash
  bd memories                                         # must report no memories
  grep -c '"_type":"memory"' .beads/issues.jsonl      # must print 0
  ```

  If a memory exists, move its content into a tracked file, remove it with
  `bd forget <key>`, and run the export again.
- Knowledge in the working tree is still lost with the machine until it is
  committed and pushed. Under the Conservative profile, agents do not commit
  or push on their own. At handoff, name every knowledge file that changed
  and state that it is not yet pushed.

### bd's git hooks stay uninstalled

bd offers git hooks that would drive this synchronisation automatically. They
are deliberately not installed, so `bd info` reports its git hooks as missing
and advises `bd hooks install`. That warning is expected here and is not a
task.

Installing them restores the automatic export path, whose scope is the defect
the manual `--all` export exists to avoid, and adds a `prepare-commit-msg`
hook that writes trailers of its own into every commit message — the `commit`
skill is this repository's only authority on commit format.

### Never run `bd list --all`

**NEVER run `bd list --all`.** In another repository with ~350 issues
(bd v1.0.x), it entered an unbounded output loop that wrote 5.6 GB at 100% CPU
and nearly filled the disk before it was killed. The current bd version has
not been re-tested. For bulk reads, query `.beads/issues.jsonl` directly with
`grep`/`jq`. For live queries use only scoped commands: `bd ready`,
`bd list --status <s>`, `bd list --priority <p>`, `bd show <id>`. If
unavoidable, bound it: `timeout 20 bd list --all`.

### Findings are always tied to WIP

A finding discovered during implementation must be filed as an issue and
connected to the active WIP (`in_progress` issue or current branch). A finding
not tied to active WIP must be converted to a normal feature request: its
headline must **not** contain the word "Finding", though the description may
note provenance.

### Findings gates are closed by humans only

The user-level `record-findings` skill defines findings gates and their
lifecycle; invoke it to record findings.

**AI agents MUST NOT close a findings gate.** A findings gate is a human
review checkpoint — it signals that a set of findings has been collected and
is awaiting human sign-off. Only the human reviewer closes it after confirming
each child finding has been addressed. This applies regardless of how many
child tasks have been closed.

## Beads: Description Formatting

Beads issue descriptions render in the beads viewer (`bv`). Write them as
structured Markdown so they are readable there, not as one unbroken blob:

- Use `##` headings to separate sections (e.g. Source, Problem, Fix,
  Developer view).
- Separate paragraphs with blank lines; use `-` bullet or numbered lists for
  enumerations.
- Pass real newlines when setting the field. A single-line
  `--description "…"` stores zero line breaks and renders as a blob; instead
  feed a here-doc, e.g.
  `bd update <id> --description "$(cat <<'EOF' … EOF)"`.
- To change an existing description, start from its raw text:
  `bd show <id> --json` returns a list, so read `.[0].description`. Plain
  `bd show` drops backticks, turns `-` bullets into `•` and re-wraps lines;
  text copied from it damages the description when written back.

This applies to every `bd create` / `bd update` description, including gate and
finding bodies.

## Beads: Issue Types and Dependency Rules

### Issue Types

Built-in types and when to use each:

| Type        | Use when                                              |
|-------------|-------------------------------------------------------|
| `task`      | Default. General work item. (default when omitted)    |
| `bug`       | Something broken that must be fixed.                  |
| `feature`   | New user-facing capability.                           |
| `chore`     | Maintenance, cleanup, non-functional work.            |
| `epic`      | Large body of work grouping child issues.             |
| `spike`     | Timeboxed investigation to reduce uncertainty.        |
| `story`     | User story (user-centric feature description).        |
| `decision`  | Architectural or design decision to document.         |
| `milestone` | Marks completion of a set of related issues.          |
| `gate`      | Async coordination checkpoint (blocks until cleared). |
| `molecule`  | Beads work template (`bd mol`).                       |

`bd create --help` omits `gate` and `molecule` from its `--type` list, but
bd 1.3.4 accepts both (verified). `bd create --type gate` leaves the gate's
await type empty. `bd gate create --type=human --blocks <id>` sets it to
`human`; `bd gate check` never resolves a human gate.

### Attaching Issues to Epics (an epic stays ready while children are open)

Verified with bd 1.3.4:

- `--parent` attaches a child for display/scope only. It does NOT gate
  readiness and does NOT exclude the parent from `bd ready`.
- An issue cannot be blocked by its own descendant: `bd dep add <epic-id>
  <child-id>` is rejected, because the block would cascade to the child.
- Otherwise `bd dep add` connects any pair of issue types, epics included.

```shell
bd update <child-id> --parent <epic-id>
```

An epic with open children therefore REMAINS in `bd ready`. Do not rely on
`bd ready` exclusion to track epic scope — read the epic's CHILDREN section
via `bd show <epic-id>` instead.

### Beads Dependency Wiring — Cross-Epic Follow-Ups

When a policy or review decision constrains in-flight work under another
epic, wire the blocking dep **immediately**:
`bd dep add <in-flight-issue> <follow-up>` (in-flight depends on follow-up).

**Signal the next action for the next session**: after wiring the deps, claim
both the blocked issue and the immediate actionable follow-up:

```bash
bd update <blocked-issue> --claim   # signals "this goal is in flight"
bd update <follow-up> --claim       # signals "work on this next"
```

`bd ready` excludes claimed (`in_progress`) issues, so the next session finds
both with `bd list --status in_progress`.

## Collaboration with the User

- **Language**: English throughout.
- **One question at a time**: when asking the user a question, ask one
  question at a time so they can focus.
- **Avoid ambiguity**: if instructions are unclear, contradictory, or
  conflict with rules or earlier instructions, describe the situation and
  ask clarifying questions before proceeding.
- **Issue IDs carry their goal**: never mention a beads issue ID without its
  goal. If the surrounding text does not already make the goal clear, add it
  in a few words in parentheses right after the ID, e.g.
  `<id> (retry on rate-limited download)`. This
  applies to chat, summaries, status reports, and every list of issues. A bare
  ID forces the reader to look it up before they can follow the text.
- **Label evidence in reports**: in a status report, review, or handoff, mark
  every factual claim about code, tool behaviour, or system state as VERIFIED
  (you ran it and read the output) or INFERRED (reasoned, predicted, or
  reported by another agent). Never present another agent's assurance as
  evidence. Re-verify a claim on the exact branch or state where it will be
  used. An unlabelled claim makes the reader trust a guess as much as a test
  result.
- **Hidden files**: the LS tool does not show hidden files; use
  `ls -la <path>` via Bash to check for hidden files or directories.

## Mandatory skill invocations

Skills whose invocation is mandatory, and the rule that makes it so. The agent
runtime injects the full skill catalog (names + descriptions) each session;
only the mandatory bindings are restated here.

| Skill | Invoke when |
| --- | --- |
| `commit` | before creating any commit |
| `fix-problem` | before fixing any unexpected obstacle |
| `format-markdown` | at task close, after all Markdown finalized |

Skills are managed with skill-manager and listed in `.skills.json`. Their
content lives outside this repository and is not pinned by it, so the rules
they carry can change without review here. Skills are authored by the
repository owner. Adopting a skill from another author changes the trust
boundary and is a decision to take deliberately.

## Documentation

**No version history in documents**: never add version or author history
to documents, e.g. revision tables, "last updated" dates, or change logs
of a document's edits. Git is the trusted source of this information.
