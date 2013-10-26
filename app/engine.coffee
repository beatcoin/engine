# Restify ======================================================================
# The core upon which this API is built
restify = require "restify"
server = restify.createServer()
# Enable parsing of requests
server.use restify.bodyParser()

server.get '/jukebox/:id/play', (req, res, next) ->
  res.send
    status: 'success'
    id: req.params.id
