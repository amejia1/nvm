// A minimal HTTP server for testing nvm's Authorization header support
// (see the "nvm_download" slow tests). It requires no dependencies beyond
// Node.js core modules.
//
// Usage: node mock-server.js <port-file>
//
// - Listens on 127.0.0.1 on an OS-assigned free port (port 0) and writes
//   the assigned port to <port-file> once the listener is bound, so the
//   test can discover it.
// - Serves the endpoints the tests previously took from a local httpbin
//   container:
//   - /bearer: 200 when the request's Authorization header is exactly
//     "Bearer test-token", 401 otherwise.
//   - /get: 200 with a JSON body describing the request.
//   - any other path: 404.

'use strict';

const fs = require('fs');
const http = require('http');

const [portFile] = process.argv.slice(2);
if (!portFile) {
  console.error('usage: node mock-server.js <port-file>');
  process.exit(2);
}

const server = http.createServer((req, res) => {
  if (req.url === '/bearer') {
    if (req.headers['authorization'] === 'Bearer test-token') {
      res.writeHead(200);
      res.end();
    } else {
      res.writeHead(401, { 'WWW-Authenticate': 'Bearer' });
      res.end();
    }
  } else if (req.url === '/get') {
    const body = JSON.stringify({ url: req.url, headers: req.headers });
    res.writeHead(200, { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) });
    res.end(body);
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.on('clientError', (err, socket) => {
  console.error(`mock server: client error: ${err.message}`);
  socket.end('HTTP/1.1 400 Bad Request\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
});

server.on('error', (err) => {
  console.error(`mock server: ${err.message}`);
  process.exit(1);
});

server.listen(0, '127.0.0.1', () => {
  const port = server.address().port;
  fs.writeFileSync(portFile, `${port}\n`);
  console.log(`mock server listening on port ${port}`);
});
