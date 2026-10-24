#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <scenario> <target-dir>" >&2
  echo "scenarios: ai-skill docs-readme fix-bug foreign-file hook-fails" >&2
  echo "           hook-fails-committer issue-key breaking-change message-only" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
scenario=$1
dir=$2

[[ ! -e $dir ]] || { echo "target exists: $dir" >&2; exit 1; }
mkdir -p "$dir"
cd "$dir"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false

commit() {
  git add -- "$@"
  git commit -q -F -
}

write_app() {
  mkdir -p src
  cat > src/app.py <<'EOF'
def greet(name):
    return f"Hello, {name}!"
EOF
}

write_app_with_validation() {
  cat > src/app.py <<'EOF'
def greet(name):
    if not name:
        raise ValueError("name must not be empty")
    return f"Hello, {name}!"
EOF
}

base_history() {
  printf '# Greeter\n\nPrints greetings.\n' > README.md
  commit README.md <<'EOF'
docs: describe the greeter
EOF
  write_app
  commit src/app.py <<'EOF'
feat: greet a person by name
EOF
}

case $scenario in
  ai-skill)
    base_history
    mkdir -p .claude/skills/greet
    cat > .claude/skills/greet/SKILL.md <<'EOF'
---
name: greet
description: Write greeting messages for the greeter app.
---
Greetings start with "Hello".
EOF
    commit .claude/skills/greet/SKILL.md <<'EOF'
ai(skills): add greet skill
EOF
    cat >> .claude/skills/greet/SKILL.md <<'EOF'

Greetings never exceed one sentence. Never use exclamation marks twice.
EOF
    ;;
  docs-readme|message-only)
    base_history
    cat > README.md <<'EOF'
# Greeter

Greeter prints a friendly greeting for a given name.

## Usage

Call `greet("Ada")` to get `Hello, Ada!`.
EOF
    if [[ $scenario == message-only ]]; then
      git add README.md
      printf '\n\ndef farewell(name):\n    return f"Bye, {name}!"\n' >> src/app.py
    fi
    ;;
  fix-bug)
    base_history
    cat > src/calc.py <<'EOF'
def sum_to(n):
    return sum(range(1, n))
EOF
    commit src/calc.py <<'EOF'
feat: sum all numbers up to n
EOF
    cat > src/calc.py <<'EOF'
def sum_to(n):
    return sum(range(1, n + 1))
EOF
    ;;
  foreign-file)
    base_history
    printf 'greeting: Hello\n' > config.yaml
    commit config.yaml <<'EOF'
feat: configure the greeting word
EOF
    write_app_with_validation
    printf 'greeting: Hi\n' > config.yaml
    printf 'Notes of another agent session. Not ready to commit.\n' > notes-other-session.md
    ;;
  hook-fails|hook-fails-committer)
    base_history
    cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
# Reject staged whitespace errors, e.g. trailing spaces.
exec git diff --cached --check
EOF
    chmod +x .git/hooks/pre-commit
    write_app_with_validation
    sed -i 's/raise ValueError("name must not be empty")/& /' src/app.py
    git hash-object src/app.py > .git/eval-wip-hash
    ;;
  issue-key)
    printf '# Greeter\n\nPrints greetings.\n' > README.md
    commit README.md <<'EOF'
docs: describe the greeter

relates-to: #60071
EOF
    write_app
    commit src/app.py <<'EOF'
feat: greet a person by name

relates-to: #60071
EOF
    write_app_with_validation
    ;;
  breaking-change)
    base_history
    mkdir -p lib
    cat > lib/api.py <<'EOF'
def get_user(user_id):
    return {"id": user_id}


def get_user_v1(user_id):
    return get_user(user_id)["id"]
EOF
    commit lib/api.py <<'EOF'
feat: look up users by id
EOF
    cat > lib/api.py <<'EOF'
def get_user(user_id):
    return {"id": user_id}
EOF
    ;;
  *)
    usage
    ;;
esac

git rev-parse HEAD > .git/eval-initial-head
