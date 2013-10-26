# Restify ======================================================================
# The core upon which this API is built
restify = require "restify"
server = restify.createServer()
# Enable parsing of requests
server.use restify.bodyParser()

endpoints = require './endpoints.coffee'

server.get '/jukebox/:id/play', (req, res, next) ->
  res.send
    status: 'success'
    items: [
      file_identifier: '1683152235880559633'
      meta:
        title: 'foo'
    ]

server.get '/jukebox/:id/songs', endpoints.listSongs

server.post '/jukebox/:id/songs', (req, res, next) ->
  console.log "Received post data %s", JSON.stringify(req.params)
  res.send
    status: 'success'

server.post '/notifeye', endpoints.notifeye

server.get '/jukebox/:id/play', endpoints.play

server.listen 8080, ->
  console.log "%s listening at %s", server.name, server.url
