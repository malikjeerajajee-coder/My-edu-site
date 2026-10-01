#!/bin/sh
# preview.sh — serve dist/ without triggering Vite's networkInterfaces crash
set -e
cd "$(dirname "$0")"

[ -d dist ] || { echo "ERROR: dist/ not found. Run 'npm run build' first."; exit 1; }

PORT="${PORT:-4321}"

# --- detect base from astro.config.mjs ---
BASE=$(grep -oE "base:\s*['\"][^'\"]*['\"]" astro.config.mjs 2>/dev/null | head -1 \
       | sed "s/base:[[:space:]]*['\"]//;s/['\"]//")
[ -z "$BASE" ] && BASE="/"

echo "==> base path: $BASE"

# --- build a wrapper dir so <base>/ resolves correctly ---
WRAP=".preview-root"
rm -rf "$WRAP"
mkdir -p "$WRAP"

case "$BASE" in
  /|"")
    cp -r dist/* "$WRAP"/
    URLPATH="/"
    ;;
  *)
    case "$BASE" in /*) ;; *) BASE="/$BASE" ;; esac
    case "$BASE" in */) ;; *) BASE="$BASE/" ;; esac
    mkdir -p "$WRAP$BASE"
    cp -r dist/* "$WRAP$BASE"/
    URLPATH="$BASE"
    ;;
esac

echo "==> Serving http://127.0.0.1:$PORT$URLPATH"
echo "    Press Ctrl+C to stop"
echo

cd "$WRAP"

if busybox --list 2>/dev/null | grep -qx httpd; then
  exec busybox httpd -f -p "$PORT" -h .
elif command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT" --bind 127.0.0.1
elif command -v php >/dev/null 2>&1; then
  exec php -S 127.0.0.1:"$PORT"
else
  echo "ERROR: no static server found (need busybox httpd, python3, or php)"
  exit 1
fi