#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$PROJECT_DIR/src"
DIST_DIR="$PROJECT_DIR/dist"
VENV_DIR="$PROJECT_DIR/venv"
BUILD_DIR="$PROJECT_DIR/build/tmp"

PYTHON="$VENV_DIR/bin/python3"
NUITKA="$VENV_DIR/bin/nuitka"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

echo ""
echo "  OpenCode-Roblox Build"
echo "  ─────────────────────"

echo ""
echo "  [1/3] Compiling server.py → binary (Nuitka)..."
$NUITKA --standalone --onefile \
  --output-dir="$DIST_DIR" \
  --remove-output \
  --quiet \
  "$SRC_DIR/server.py" -o "opencode-server"
echo "    ✓ opencode-server built"

echo ""
echo "  [2/3] Compiling cli.py → binary (Nuitka)..."
$NUITKA --standalone --onefile \
  --output-dir="$DIST_DIR" \
  --remove-output \
  --quiet \
  "$SRC_DIR/cli.py" -o "opencode-cli"
echo "    ✓ opencode-cli built"

echo ""
echo "  [3/3] Compiling Lua scripts → bytecode..."
for f in "$SRC_DIR"/plugin*.lua; do
  base=$(basename "$f" .lua)
  luac -o "$DIST_DIR/$base.luac" "$f"
  echo "    ✓ $base.luac"
done

echo ""
echo "  Build complete!"
echo "  ─────────────────────"
ls -lh "$DIST_DIR"/* | awk '{print "    " $NF "  (" $5 ")"}'
echo ""
