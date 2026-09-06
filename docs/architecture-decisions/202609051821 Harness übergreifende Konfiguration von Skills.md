---
tags:
  - moc
aliases:
  - "202609051821"
---
Siehe [ADR 002: Centralizing Skills Across Coding Agents](https://github.com/wonderbird/ai-agent-workspace/blob/skill-chooser/docs/architecture-decisions/002-skill-manager-tool-selection.md)  in [[202511220646 $ 72.16-ai-agent-workspace]]

## omrikais Skill Manager und vercel-labs skills parallel verwenden

Da [vercel-labs/skills](https://github.com/vercel-labs/skills) [[qu2026]] Skills so gut suchen kann, möchte ich das Tool verwenden, um Skills zu identifizieren:

```shell
npx skills find
npx skills find "skill-name"
```

Dann kann die gefundene Skill mit dem [omrikais/skill-manager](https://github.com/omrikais/skill-manager) [[kaisari2026]] installiert und verwaltet werden:

>[!warning] Repo Namen müssen eindeutig sein
>
>Zur Unterscheidung der Skill-Repositories wird nur der Name des Repositories, nicht der Name des Owners verwendet.

```shell
# Eine mit `npx skills find` gefundene Skill kann aus dem Git Repo
# installiert werden - hier am Beispiel des "deploy-to-vercel" Skill.
sm install vercel-labs/agent-skills "deploy-to-vercel"

# Dies Quelle landet dann in
vi ~/.skill-manager/sources.json

# und die geklonte(n) Skill(s) in
ls -la ~/.skill-manager/sources/<slug>/
```

Nun muss man den Skill via `sm` ins Projekt oder global verlinken.

Anschließend kann man die `.skills.json` Datei neu schreiben:

```shell
rm -f .skills.json && sm init --from-current
```

>[!important] npx skills müssen später erneut mit `sm install` installiert werden
>Wenn die `~/.skill-manager/sources.json` und der Ordner `~/.skill-manager/sources/` nicht existieren, dann muss ein fremder Skill erst mit dem `sm install` Befehl von oben installiert werden.

## omrikais Skill Manager (sm)

[omrikais/skill-manager](https://github.com/omrikais/skill-manager) [[kaisari2026]]

### Fazit: Skill Manager erfüllt meine Bedürfnisse sowohl für lokale als auch globale Skills

Skill Manager entspricht ziemlich genau meinem Wunsch. Ich kann meine eigenen Skills damit verwalten und lokal bzw global in den `.claude` und / oder den `.agents` Ordner installieren. Damit werden sie u.a. auch für OpenCode nutzbar - [[qu2026]] enthält eine Liste vieler Harnesses, die Skills aus `.agents/skills` laden.

Skill Pakete können als GitHub Repository erstellt und weitergegeben werden.

Das Tool ermöglicht es, Profile anzulegen, die dann wie eine Projektvorlage genutzt werden können.

Project Manifest Dateien `.skills.json` definieren die Skills, die in einem Projekt verwendet werden. Diese Skills können dann mit `sm install` installiert werden.

### Bedienung

>[!warning] `sm install` installiert auch  globale Skills aus dem Manifest
>
>Das ist eigentlich sehr gut, weil dann stets alle benötigten Skills verlinkt werden.
>
>Ggf. möchte man aber alle Projekt-Skills lokal haben - dann kann man das in der .skills.json Datei einfach anpassen.

>[!note] `sm install` löscht nicht
>
>`sm install` fügt nur Skills aus dem Manifest `.skills.json` hinzu (global und lokal).
>
>Wenn nur die Skills aus dem Manifest installiert werden sollen, dann lösche einfach vorher die Symlinks in den entsprechenden Skill Verzeichnissen:
>
>```shell
>rm -rv .claude/skills/*; \
>rm -rv .agents/skills/*
>```

```shell
# Skill Manager TUI aufrufen
sm

# Hier können Skills global und / oder ins aktuelle Projekt
# installiert werden.

# Die folgende Datei enthält die maschinenweite Konfiguration:
vi ~/.skill-manager/state.json

# Nach der Installation der Skills kann die Konfiguration unter
# .skills.json im Projekt-Ordner gespeichert werden:
sm init --from-current

# Für ein Update der .skills.json löscht man die aktuelle Datei
# und erstellt sie dann neu.
rm -f .skills.json && sm init --from-current

# Dadurch werden die im Projekt verfügbaren globalen und lokalen
# Skills in die Datei .skills.json geschrieben
vi .skills.json

# Diese kann dann in Git aufgenommen werden
git add .skills.json && git commit -m "ai: configure project skills (skill-manager sm)"

# Die .agents und .claude Ordner müssen nicht in Git aufgenommen
# werden. Sie können nach dem klonen wie folgt wiederhergestellt werden:
#
# HINWEISE:
# - sm install installiert auch die globalen Skills!
# - sm install fügt nur hinzu und deaktiviert nicht.
sm install
```

## vercel-labs skills

[vercel-labs/skills](https://github.com/vercel-labs/skills) [[qu2026]]

### Fazit: Suchen von Skills ist toll, aber Wiederherstellen der Skills ist ungenügend

Insgesamt fühlt sich das Tool gut an. Die Community scheint es ebenfalls gerne zu benutzen [[pocock2026]].

Skills können aus verschiedenen Quellen heraus installiert werden:

- Git Repositories
- Lokale Ordner

Skills können ins lokale Projekt oder global installiert werden. Die mit `npx skill add` installierten Skills werden in einer Konfigurationsdatei gespeichert.

>[!note] Nur `npx skill add` aktualisiert die Konfigurationsdatei

>[!warning] Wiederherstellen der Skills ist noch lückenhaft
>
>Leider werden Skills bisher nur im `.agents` Ordner wiederhergestellt. Die Symlinks in den anderen Ordnern werden (noch) nicht angelegt.
>
>Das Feature zur Wiederherstellung der Projekt Skills ist als "experimental" gekennzeichnet.
>
>Globale Skills werden (noch) nicht wiederhergestellt.

### Risiken

- Nur ein einziger Maintainer merged Pull Requests. Im Juli - September 2026 gab es keine Merges.

### Lücken

- Das Wiederherstellen von Skills im Projekt ist "experimentell" und berücksichtigt nur den `.agents` Ordner. Skills werden nicht zu `.claude` hinzugefügt. Es gibt allerdings offene Feature Requests (Issues) und Pull Requests zum Thema.

- Globale Skills können nicht wiederhergestellt werden. Die global installierten Skills werden zwar in der globalen Lock-Datei geführt, aber nicht neu verlinkt. Auch hier gibt es Feature Requests und Pull Requests.

### Bedienung

Die [AGENTS.md](https://github.com/vercel-labs/skills/blob/main/AGENTS.md) enthält eine detailliertere Dokumentation des CLI.

Leider ist die Doku nicht ausreichend, um mit dem Tool warm zu werden. Deshalb klont man das Repository [vercel-labs/skills](https://github.com/vercel-labs/skills) am besten und lässt sich von einem LLM beraten.

Im Projekt aktivierte Skills werden in `./skill-lock.json` gespeichert.

>[!note] Anderer Dateiname für globale Skills - `.skill-lock.json`
>
>Globale Skills werden im XDG_STATE_HOME Config Ordner abgelegt, unter Linux also in `~/.config/skills/.skill-lock.json`. Wenn diese Datei nicht existiert, dann wird per Default unter `~/.agents/.skill-lock.json` gespeichert.

```shell
# npx skills find ohne Parameter öffnet einfach ein Suchfenster
# Damit lassen sich Skills suchen
npx skills find

# Man benötigt den folgenden Befehl, um die genaue Provider URL
# zu bekommen, wenn man den Namen der Skill kennt
npx skills find "deploy-to-vercel"

# Anschließend installiert man den Skill - nur der npx skills add
# Befehl schreibt den Skill in die lokale skill-lock.json bzw. in die
# globale ~/.agents/.skills-lock.json Datei.
#
# Die Skill wird im Original in .agents/skills/<slug>/ abgelegt.
# In den anderen Ordner, z.B. .claude/skills/ wird dann ein Symlink
# erstellt. Die "Installation Summary" beschreibt das vor der
# Installation.
npx skills add vercel-labs/agent-skills@deploy-to-vercel

# Danach erscheint der Skill im lokalen skills-lock.json File
vi skills-lock.json

# Durch den -g (--global) Parameter installiert man Skills global
npx skills add --global vercel-labs/agent-skills@deploy-to-vercel

# Danach erscheint der Skill im globalen .skill-lock.json File
#
# ACHTUNG: Dateiname weicht vom lokalen Dateinamen ab!
vi ~/.agents/.skill-lock.json

# Lokal installierte Skills löscht man mit
npx skills remove "deploy-to-vercel"

# Genauso für global installierte Skills:
npx skills remove --global "deploy-to-vercel"

# Die .agents und .claude Ordner müssen nicht in Git aufgenommen
# werden. Sie können nach dem klonen wie folgt wiederhergestellt werden:
#
# HINWEIS:
# - Skills werden nur in den .agents/skills Ordner wiederhergestellt.
npx skills experimental_install
```

Das folgende Skript kann die Links in `.claude` anhand der Skills in `.agents/skills` wiederherstellen:

```bash
#!/usr/bin/env bash
#
# Restore links in .claude/skills from existing skills in .agents/skills
#
# USAGE: ./restore-claude-skills
#
set -euo pipefail

canon=".agents/skills"
dest=".claude/skills"
mkdir -p "$dest"

shopt -s nullglob
for d in "$canon"/*/; do
name=$(basename "$d")
[ -f "$d/SKILL.md" ] || continue                 # real skills only
link="$dest/$name"
want="../../$canon/$name"

if [ -L "$link" ]; then
  # already a symlink: keep if it resolves to this canonical skill
  if [ "$(readlink -f "$link")" = "$(readlink -f "$d")" ]; then
    continue
  fi
  rm -f "$link"                                  # wrong/broken link → replace
elif [ -e "$link" ]; then
  echo "skip $name: real directory in $dest, left untouched" >&2
  continue                                       # never clobber real data
fi

ln -s "$want" "$link"
echo "linked $name"
done
```
