const http = require('http');
http.createServer((_, res) => {
  res.end("Hello from DevOps Project");
}).listen(3000);
