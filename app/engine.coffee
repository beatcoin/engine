# Restify ======================================================================
# The core upon which this API is built
restify = require "restify"
server = restify.createServer()
# Enable parsing of requests
server.use restify.bodyParser()
server.use restify.queryParser()

endpoints = require './endpoints.coffee'

server.get '/jukebox/:id/queue', require './endpoints/get_jukebox_queue.coffee'

server.get '/jukebox/:id/play', require './endpoints/get_jukebox_play.coffee'

server.get '/jukebox/:id/songs', require './endpoints/get_jukebox_songs.coffee'

server.post '/jukebox/:id/songs', endpoints.putSongs

server.post '/notifeye', endpoints.notifeye

server.post '/jukebox', endpoints.jukebox

server.listen 8080, ->
  console.log "%s listening at %s", server.name, server.url
