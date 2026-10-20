#!/bin/sh
# Install gh-skills by symlinking skills/<name> into agent skill directories.
# Never copies the markdown. Never uses sudo.
set -eu

REPO_URL="${GH_SKILLS_REPO:-https://github.com/odykyi/gh-skills.git}"
AGENT=""
SCOPE="project"

usage() {
  echo "usage: install.sh [--agent claude|codex|opencode|openclaw|cursor|agents] [--global|--project]" >&2
  echo "" >&2
  echo "  --agent   which agent directory to link into" >&2
  echo "  --global  install into the user home directory (default: project)" >&2
  echo "" >&2
  echo "Without --agent the skills are linked into .agents/skills and .claude/skills." >&2
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) [ $# -ge 2 ] || usage; AGENT="$2"; shift 2 ;;
    --global) SCOPE="global"; shift ;;
    --project) SCOPE="project"; shift ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

case "$AGENT" in ""|claude|codex|opencode|openclaw|cursor|agents) ;; *) usage ;; esac

# Source: this checkout if run from one, otherwise a cached clone.
SELF_DIR=""
if [ -f "$0" ]; then SELF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || SELF_DIR=""; fi
if [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/skills" ]; then
  SRC="$SELF_DIR/skills"
else
  CACHE="${XDG_DATA_HOME:-$HOME/.local/share}/gh-skills"
  if [ -d "$CACHE/.git" ]; then
    git -C "$CACHE" pull --ff-only --quiet || {
      echo "cannot update $CACHE (local changes or diverged history); remove it and re-run: rm -rf \"$CACHE\"" >&2
      exit 1
    }
  else
    git clone --depth 1 --quiet "$REPO_URL" "$CACHE"
  fi
  SRC="$CACHE/skills"
fi

if [ "$SCOPE" = "global" ]; then BASE="$HOME"; else BASE="$(pwd)"; fi

# Linking into the skills repo itself would rewrite its tracked symlinks.
if [ "$BASE" = "$(dirname "$SRC")" ]; then
  echo "refusing to install into the gh-skills checkout itself; run from your project (or use --global)" >&2
  exit 1
fi

agent_dir() {
  case "$1:$SCOPE" in
    agents:*|codex:*) echo ".agents/skills" ;;
    claude:*)         echo ".claude/skills" ;;
    cursor:*)         echo ".cursor/skills" ;;
    openclaw:*)       echo ".openclaw/skills" ;;
    opencode:global)  echo ".config/opencode/skills" ;;
    opencode:project) echo ".opencode/skills" ;;
  esac
}

link_all() {
  dest="$BASE/$1"
  mkdir -p "$dest" || { echo "cannot create $dest; create it manually and re-run" >&2; exit 1; }
  # Drop links we created earlier whose skill no longer exists in the source.
  for l in "$dest"/*; do
    [ -L "$l" ] || continue
    case "$(readlink "$l")" in "$SRC"/*) [ -e "$l" ] || { rm "$l"; echo "removed stale $l"; } ;; esac
  done
  for d in "$SRC"/*/; do
    name="$(basename "$d")"
    target="$dest/$name"
    if [ -L "$target" ]; then rm "$target"
    elif [ -e "$target" ]; then echo "skip $target (exists, not a symlink)" >&2; continue; fi
    ln -s "${d%/}" "$target"
    echo "linked $target -> ${d%/}"
  done
}

link_all ".agents/skills"
if [ -n "$AGENT" ]; then
  dir="$(agent_dir "$AGENT")"
  [ "$dir" = ".agents/skills" ] || link_all "$dir"
fi

echo ""
echo "Installed $(ls -1 "$SRC" | wc -l | tr -d ' ') skills into $BASE."
echo "Open your agent in this directory and ask it to open a PR, review a PR, or manage a queue."
