#!/bin/bash
cd "$(dirname "$0")"
if [ ! -d dist ]; then
  echo "No dist/ — running build first..."
  npm run build
fi
cd dist
echo ""
echo "  → http://localhost:4321/"
echo "  → http://localhost:4321/books/"
echo "  → http://localhost:4321/boards/"
echo "  → http://localhost:4321/class/9/"
echo "  Stop: Ctrl+C"
echo ""
python3 -m http.server 4321
