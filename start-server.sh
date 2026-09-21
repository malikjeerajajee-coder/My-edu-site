#!/bin/bash
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

cat > /tmp/thserver.py <<'PYEOF'
import http.server
import socketserver
import os
import sys

BASE = '/My-edu-site'
PORT = 4321

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        if path.startswith(BASE + '/'):
            path = path[len(BASE):]
        elif path == BASE:
            path = '/'
        return super().translate_path(path)

    def log_message(self, *args):
        pass  # silence

    def handle_one_request(self):
        try:
            super().handle_one_request()
        except (BrokenPipeError, ConnectionResetError):
            # Browser closed early — harmless on mobile
            self.close_connection = True

    def copyfile(self, source, outputfile):
        try:
            super().copyfile(source, outputfile)
        except (BrokenPipeError, ConnectionResetError):
            pass

os.chdir('dist')
socketserver.TCPServer.allow_reuse_address = True
socketserver.TCPServer.request_queue_size = 20

class ThreadedServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True

with ThreadedServer(("0.0.0.0", PORT), QuietHandler) as httpd:
    print("")
    print(f"  Open: http://localhost:{PORT}{BASE}/")
    print(f"  Stop: Ctrl+C")
    print("")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n  Stopped.\n")
PYEOF

python3 /tmp/thserver.py
