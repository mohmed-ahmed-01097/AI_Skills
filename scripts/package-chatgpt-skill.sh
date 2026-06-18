#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT_DIR/skills/engineering/mbd-sdlc"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR/skill.zip"
(cd "$SKILL_DIR/.." && zip -qr "$DIST_DIR/skill.zip" mbd-sdlc)

echo "Created $DIST_DIR/skill.zip"
