#!/bin/bash

echo "🔧 Repairing PriceSpy build on Alpine Linux..."

# Move to project folder
cd ~/Phones/nova-pricespy || { echo "❌ Project folder not found"; exit 1; }

# Remove the broken glibc binary
rm -f tailwindcss

# Install Node.js and npm (needed for Tailwind)
echo "📦 Installing Node.js & npm via apk (this takes ~30s)..."
apk add --no-cache nodejs npm

# Initialize npm project (silent)
npm init -y > /dev/null 2>&1

# Install Tailwind CSS v3 (matches our config)
echo "📥 Installing Tailwind CSS v3..."
npm install -D tailwindcss@3.4.1

# Compile the CSS
echo "🎨 Compiling CSS..."
npx tailwindcss -i ./css/input.css -o ./css/style.css --minify

# Verify
if [ -f ./css/style.css ]; then
    SIZE=$(wc -c < ./css/style.css)
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "  ✅ SUCCESS! style.css compiled ($SIZE bytes)"
    echo "  📂 Open: ~/Phones/nova-pricespy/index.html"
    echo "════════════════════════════════════════════════════"
else
    echo "❌ Compilation failed. Check errors above."
fi
