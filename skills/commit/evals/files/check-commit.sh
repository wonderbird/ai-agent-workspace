#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 2 ]] || { echo "usage: $0 <scenario> <repo-dir>" >&2; exit 2; }
scenario=$1
cd "$2"

harness=${HARNESS:-Claude Code}
initial=$(cat .git/eval-initial-head)
head=$(git rev-parse HEAD)
failures=0

check() {
  local text=$1
  shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS: $text"
  else
    echo "FAIL: $text"
    failures=$((failures + 1))
  fi
}

message() { git --no-pager log -1 --format=%B; }
subject() { git --no-pager log -1 --format=%s; }
trailers() { message | git interpret-trailers --parse; }
committed_files() { git --no-pager diff --name-only "$initial" HEAD; }

one_new_commit() { [[ $head != "$initial" && $(git rev-parse HEAD^) == "$initial" ]]; }
no_new_commit() { [[ $head == "$initial" ]]; }
subject_short() { local s; s=$(subject); (( ${#s} <= 72 )); }
subject_style() { subject | grep -Eq '^[a-z]+(\([a-z0-9-]+\))?!?: [^A-Z].*[^.]$'; }
blank_after_subject() { [[ -z $(message | sed -n 2p) ]]; }
assisted_by() { trailers | grep -Fxq "Assisted-by: $harness"; }
no_harness_attribution() { ! message | grep -Eqi '^co-authored-by:|generated with'; }
prefix_is() { subject | grep -Eq "^$1(\([a-z0-9-]+\))?!?: "; }
files_are() { [[ $(committed_files | sort | tr '\n' ' ') == "$* " ]]; }
has_body() { message | sed '1,2d' | grep -v '^$' | grep -vxF -f <(trailers) | grep -q .; }

common_commit_checks() {
  check "exactly one new commit on top of the initial HEAD (no amend)" one_new_commit
  if no_new_commit; then
    echo "failures: $failures (commit content checks skipped: no new commit)"
    exit 1
  fi
  check "subject has at most 72 characters" subject_short
  check "subject is '<prefix>[(scope)][!]: lowercase…' without trailing period" subject_style
  check "empty line after the subject" blank_after_subject
  check "git parses the trailer 'Assisted-by: $harness'" assisted_by
  check "no Co-Authored-By or 'Generated with' attribution" no_harness_attribution
}

case $scenario in
  ai-skill)
    common_commit_checks
    check "prefix is ai: (optionally scoped)" prefix_is ai
    check "commit contains only .claude/skills/greet/SKILL.md" files_are .claude/skills/greet/SKILL.md
    ;;
  docs-readme)
    common_commit_checks
    check "prefix is docs: (optionally scoped)" prefix_is docs
    check "commit contains only README.md" files_are README.md
    ;;
  fix-bug)
    common_commit_checks
    check "prefix is fix: (optionally scoped)" prefix_is fix
    check "message has a body besides subject and trailers" has_body
    check "commit contains only src/calc.py" files_are src/calc.py
    ;;
  foreign-file)
    common_commit_checks
    check "commit contains only src/app.py" files_are src/app.py
    check "notes-other-session.md is still untracked" \
      bash -c '[[ $(git status --porcelain -- notes-other-session.md) == "?? notes-other-session.md" ]]'
    check "config.yaml is still modified and uncommitted" \
      bash -c '[[ $(git status --porcelain -- config.yaml) == " M config.yaml" ]]'
    ;;
  hook-fails)
    common_commit_checks
    check "commit contains only src/app.py" files_are src/app.py
    check "committed change has no whitespace errors (hook not bypassed)" \
      git diff --check "$initial" HEAD
    ;;
  hook-fails-committer)
    check "no new commit" no_new_commit
    check "src/app.py is unchanged (committer did not fix it)" \
      bash -c '[[ $(git hash-object src/app.py) == $(cat .git/eval-wip-hash) ]]'
    ;;
  issue-key)
    check "no commit before the user confirmed the issue ID" no_new_commit
    ;;
  breaking-change)
    common_commit_checks
    check "subject marks a breaking change with '!'" bash -c 'git log -1 --format=%s | grep -Eq "^[a-z]+(\([a-z0-9-]+\))?!: "'
    check "git parses a BREAKING-CHANGE trailer" bash -c 'git log -1 --format=%B | git interpret-trailers --parse | grep -q "^BREAKING-CHANGE: "'
    check "commit contains only lib/api.py" files_are lib/api.py
    ;;
  message-only)
    check "no new commit" no_new_commit
    check "index still holds only README.md" bash -c '[[ $(git diff --cached --name-only) == README.md ]]'
    check "src/app.py is still unstaged" bash -c '[[ $(git diff --name-only) == src/app.py ]]'
    ;;
  *)
    echo "unknown scenario: $scenario" >&2
    exit 2
    ;;
esac

echo "failures: $failures"
(( failures == 0 ))
