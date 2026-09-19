#!/bin/bash
set -e

# Kill any running server
pkill -f "http.server 4321" 2>/dev/null || true
sleep 1

# Ensure build exists
if [ ! -d "dist" ]; then
  echo "Building first..."
  npm run build
fi

# Create a preview folder with the right structure
rm -rf .preview
mkdir -p .preview

# Symlink dist → .preview/My-edu-site
ln -sfn "$(pwd)/dist" .preview/My-edu-site

echo ""
echo "════════════════════════════════════════════"
echo "  Preview server starting"
echo "════════════════════════════════════════════"
echo ""
echo "  Open this URL in your browser:"
echo "    http://localhost:4321/My-edu-site/"
echo ""
echo "  Press Ctrl+C to stop the server."
echo "════════════════════════════════════════════"
echo ""

cd .preview
python3 -m http.server 4321