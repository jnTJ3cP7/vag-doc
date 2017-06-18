var mocky = require('mocky');

mocky.createServer([{
  // simple GET route without request body to match
  url: '/someurl1?a=b&c=d',
  method: 'get',
  res: 'response for GET request'
}, {
  // POST route with request body to match and respose with status, headers and body
  url: '/someurl2?a=b&c=d',
  method: 'post',
  req: 'POST request body to match',
  res: {
    status: 202,
    headers: { 'Content-type': 'text/html' },
    body: '<div>response to return to client</div>'
  }
}, {
  // PUT route with dynamic response body
  url: '/someurl3?a=b&c=d',
  method: 'put',
  req: 'PUT request body to match',
  res: function (req, res) {
    return 'PUT response body';
  }
}, {
  // GET route with regexp url and async response with status, headers and body
  url: /\/someurl4\?a=\d+/,
  method: 'get',
  res: function (req, res, callback) {
    setTimeout(function () {
      callback(null, {
        status: 202,
        headers: { 'Content-type': 'text/plain' },
        body: 'async response body'
      });
    }, 1000);
  }
}]).listen(4321);
