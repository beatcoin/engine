# Restify ======================================================================
# The core upon which this API is built
restify = require "restify"
server = restify.createServer()
# Enable parsing of requests
server.use restify.bodyParser()

endpoints = require './endpoints.coffee'

server.get '/jukebox/:id/queue', endpoints.getQueue

server.get '/jukebox/:id/play', endpoints.play

server.get '/jukebox/:id/songs', endpoints.listSongs

server.post '/jukebox/:id/songs', endpoints.putSongs

server.post '/notifeye', endpoints.notifeye

server.post '/jukebox', endpoints.jukebox

server.listen 8080, ->
  console.log "%s listening at %s", server.name, server.url
