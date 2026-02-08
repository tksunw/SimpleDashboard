#!/usr/bin/env bash
#
# Scans the backgrounds/ directory and writes backgrounds.json
# Usage: ./update-backgrounds.sh [path-to-web-root]
#   Default path: /var/www/html (falls back to script directory)

set -euo pipefail

if [ -n "${1:-}" ]; then
    TARGET_DIR="$1"
elif [ -d "/var/www/html/backgrounds" ]; then
    TARGET_DIR="/var/www/html"
else
    TARGET_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
BG_DIR="$TARGET_DIR/backgrounds"

if [ ! -d "$BG_DIR" ]; then
    echo "No backgrounds/ directory found at $TARGET_DIR"
    echo "Create it and add image files, then re-run this script."
    exit 1
fi

# Collect image files (common web-safe formats), sorted for deterministic output
MANIFEST="$TARGET_DIR/backgrounds.json"
FILES=$(find "$BG_DIR" -maxdepth 1 -type f \( \
    -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
    -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.avif' \
    \) -exec basename {} \; | sort)

# Build JSON array
echo -n '[' > "$MANIFEST"
FIRST=true
while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo -n ',' >> "$MANIFEST"
    fi
    echo -n "\"$f\"" >> "$MANIFEST"
done <<< "$FILES"
echo ']' >> "$MANIFEST"

COUNT=$(echo "$FILES" | grep -c . || true)
echo "backgrounds.json updated: $COUNT image(s) found."
