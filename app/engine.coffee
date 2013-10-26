# Restify ======================================================================
# The core upon which this API is built
restify = require "restify"
server = restify.createServer()
# Enable parsing of requests
server.use restify.bodyParser()

server.get '/jukebox/:id/play', (req, res, next) ->
  res.send
    status: 'success'
    items: [
      file_identifier: '1683152235880559633'
      meta:
        title: 'foo'
    ]
    id: req.params.id

server.listen 8080, ->
  console.log "%s listening at %s", server.name, server.url
