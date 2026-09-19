#!/bin/bash
# Copy this whole block into a file called start-server.sh in your project root

cat > /tmp/thserver.py <<'PYEOF'
import http.server
import socketserver
import os

BASE = '/My-edu-site'
PORT = 4321

class Handler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        if path.startswith(BASE + '/'):
            path = path[len(BASE):]
        elif path == BASE:
            path = '/'
        return super().translate_path(path)
    def log_message(self, *args):
        pass  # silent

os.chdir('dist')
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    print(f"")
    print(f"  Open: http://localhost:{PORT}{BASE}/")
    print(f"  Stop: Ctrl+C")
    print(f"")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n  Stopped.\n")
PYEOF

python3 /tmp/thserver.py