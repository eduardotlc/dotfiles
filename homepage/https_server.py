#!/usr/bin/env python3
import http.server
import os
import ssl

PORT = 8001
DIRECTORY = "/home/eduardotc/Programming/html_css/homepage/"

# Change to the directory you want to serve
os.chdir(DIRECTORY)

handler = http.server.SimpleHTTPRequestHandler
httpd = http.server.HTTPServer(("127.0.0.1", PORT), handler)

# Create SSL context
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(
    certfile="/home/eduardotc/Programming/html_css/homepage/.certs/localhost.pem",
    keyfile="/home/eduardotc/Programming/html_css/homepage/.certs/localhost-key.pem",
)

# Wrap the socket
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Serving HTTPS on https://127.0.0.1:{PORT}")
httpd.serve_forever()
