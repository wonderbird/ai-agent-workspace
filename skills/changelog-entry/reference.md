# Changelog Reference

Format rules, the category decision table, and worked examples for the
`changelog-entry` skill. Source: [Keep a Changelog
2.0.0](https://keepachangelog.com/en/2.0.0/).

## Principles

- The changelog is written for humans, not for machines.
- Every version gets an entry; identical kinds of change are grouped.
- Newest first: `## [Unreleased]` on top, then versions in descending order.
- Dates use ISO 8601 (`yyyy-mm-dd`), which removes regional ambiguity.
- Versions and sections are linkable.
- A raw commit log is not a changelog: merge commits and internal subjects
  hide the changes a reader cares about.
- Deprecations are announced before the removal, so a reader can upgrade to
  the version that deprecates a feature, migrate off it, then upgrade to the
  version that removes it.

## File template

Use this when `CHANGELOG.md` does not exist yet. Fill the first category and
entry in the same change — do not commit an empty skeleton (Principle XIII).

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/2.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- <entry>

[Unreleased]: https://github.com/wonderbird/ansible-all-my-things/commits/main
```

Once the first release tag exists, the link definition becomes a comparison:

```markdown
[Unreleased]: https://github.com/wonderbird/ansible-all-my-things/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/wonderbird/ansible-all-my-things/releases/tag/v1.0.0
```

## Categories

| Category     | Use for                                                        |
|--------------|----------------------------------------------------------------|
| `Added`      | A new capability: role, playbook, profile, provider, variable. |
| `Changed`    | Different behaviour or a different interface for what exists.  |
| `Deprecated` | Still works, will be removed; name the replacement.            |
| `Removed`    | Gone in this change; name what a user must stop relying on.    |
| `Fixed`      | A defect that produced wrong or failing behaviour.             |
| `Security`   | A vulnerability closed, or a hardening of an exposed path.     |

Ambiguous cases in this repository:

- A role that starts installing a tool it never installed: `Added`.
- A version pin bumped by the update-versions playbook: `Changed`, and only
  when the new version changes what the operator gets.
- A role gaining a required variable: `Changed`, with the migration step.
- Tightened SSH host-key verification, or a secret moved into Vault:
  `Security`.
- A Molecule scenario made to fail loudly on a real defect: `Fixed` if the
  defect itself is fixed in the same change; otherwise no entry.

## What gets no entry

Changes no reader of the changelog can observe:

- Test-only changes: Molecule scenarios, verify assertions, test fixtures.
- Issue-tracker bookkeeping, including `.beads/issues.jsonl` exports.
- `.omc/` scratch, agent rules files, and skill definitions.
- Refactors, renames, and formatting with no behavioural effect.
- Documentation edits, unless the documented procedure itself changed.
- Specs and plans under `specs/`, which describe work rather than deliver it.

## Entry style

State the new behaviour and stop. Ten to fifteen words; two wrapped lines is
the hard ceiling.

- Present tense, active voice, terminal period.
- Name the role, playbook, or profile the operator invokes.
- A second sentence is allowed only for a migration step, never for
  explanation.
- Omit tracker IDs. They carry nothing for a human reader, and the Principle X
  strip test then passes trivially.

Cut these — they are what makes an entry long:

- **The previous behaviour** as a contrast clause: `instead of …`,
  `rather than …`, `used to …`. The reader is upgrading from it and has it
  already. A `Fixed` entry naming the defect is exempt: there the defect *is*
  the change, not a contrast.
- **The reason or benefit**: `so that …`, `which means …`, `to avoid …`. That
  belongs in the commit body, the concept document, or the ADR.
- **The mechanism**: module names, task names, variable derivations, and file
  paths the operator never types.
- **Counts and component enumerations** (Documentation Standards).

## Breaking changes and CVEs

Two entries carry a required prefix.

A change that breaks an existing workflow stays in the category it belongs to
and gains a `**Breaking:**` marker, so a reader scanning for migration work
finds it without reading every entry. Name the interface that breaks:

```markdown
### Changed

- **Breaking:** `configure-profile.yml` requires `login_users` in inventory.
```

A `Security` entry that has a CVE identifier leads with it, so readers and
security tooling can match the entry to the advisory:

```markdown
### Security

- CVE-2024-12345: out-of-bounds read when parsing malformed input.
```

Weak, because it describes the diff and hides the substance behind a tracker:

```markdown
- Refactored `roles/docker/tasks/main.yml` to use a loop, see beads-abc1
```

Same change, verbose then compact:

```markdown
- Every role that configures per-user state fails with a message naming
  `login_user_names` when that variable is undefined or empty, instead of
  reporting a generic Ansible error at an arbitrary task or completing green
  with nothing done.
```

```markdown
- Roles that configure per-user state fail when `login_user_names` is
  undefined or empty.
```

More compact entries:

```markdown
- Windows Server 2025 targets provision from the AWS Windows profile.
- `configure-profile.yml` fails at preflight when a host's login user name
  does not match its inventory entry.
- `podman` role default `login_user_names: []` — callers must supply at least
  one user name.
```

## Yanked releases

A release pulled after publication keeps its section and is marked loudly, so
readers cannot miss it:

```markdown
## [0.0.5] - 2014-12-13 [YANKED]
```

## Cutting a release

Not yet done in this repository — it has no version tags. When it starts:

1. Replace `## [Unreleased]` with `## [X.Y.Z] - yyyy-mm-dd` and open a fresh
   empty `## [Unreleased]` above it.
2. Add the link definition for the new version and repoint `[Unreleased]` to
   compare the new tag against `HEAD`.
3. Tag the release commit `vX.Y.Z`.

A one- or two-sentence summary may precede the typed sections of a release,
where the release has a theme worth naming. It is optional and never replaces
an entry.

A human chooses the version number. An agent never does.
