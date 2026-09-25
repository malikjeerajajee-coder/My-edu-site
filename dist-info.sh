#!/bin/bash
cd ~/my-edu-site

echo "▸ dist/ summary"
echo "  Files: $(find dist -type f | wc -l)"
echo "  Size:  $(du -sh dist | cut -f1)"
echo ""

echo "▸ Largest 10 files in dist/"
find dist -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10
echo ""

echo "▸ Any single file over 25MB? (Cloudflare rejects these)"
find dist -type f -size +25M -exec ls -lh {} \; 2>/dev/null | head -10
echo "  (none listed above = good)"
echo ""

echo "▸ Free space on this device"
df -h ~ 2>/dev/null | tail -2
echo ""

echo "▸ Weird filenames (spaces, non-ascii) that break upload protocols"
find dist -type f \( -name '* *' -o -name '*[^[:print:]]*' \) 2>/dev/null | head -5
echo "  (none listed above = good)"