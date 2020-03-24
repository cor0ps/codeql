var fs = require('fs'),
    http = require('http'),
    url = require('url'),
    sanitize = require('sanitize-filename'),
    pathModule = require('path')
    ;

var server = http.createServer(function(req, res) {
  let path = url.parse(req.url, true).query.path;
  // BAD: taint is preserved
  res.write(fs.readFileSync(['public', path].join('/')));
  // BAD: taint is preserved
  let parts = ['public', path];
  parts = parts.map(x => x.toLowerCase());
  res.write(fs.readFileSync(parts.join('/')));
});

server.listen();
