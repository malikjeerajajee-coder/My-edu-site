#!/usr/bin/env python3
import http.server
import socketserver
import os

BASE = "/My-edu-site"
PORT = 4321

class Handler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        if path.startswith(BASE + "/"):
            path = path[len(BASE):]
        elif path == BASE:
            path = "/"
        return super().translate_path(path)

os.chdir("dist")
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
    print(f"Open: http://localhost:{PORT}{BASE}/")
    print("Stop: Ctrl+C")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("Stopped.")
