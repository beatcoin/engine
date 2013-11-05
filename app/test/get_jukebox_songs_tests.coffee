restify = require 'restify'

client = restify.createJsonClient
  version: '*'
  url: 'http://127.0.0.1:8080'

describe 'service: jukebox/songs', () ->
  
  # Test 1
  describe '200 response check', () ->
    it 'should get a 200 response', (done) ->
      client.get '/jukebox/5278d382d6be67d801000001/songs', (err, req, res, data) ->
        if err
          throw err
        else
          
          # The status code should be 200
          if res.statusCode != 200
            throw new Error 'Invalid response from /jukebox/5278d382d6be67d801000001/songs'
          
          # There should be some data
          if not data.items?.length # For some reason other tests seem to fail
            throw new Error 'There was no data returned from /jukebox/5278d382d6be67d801000001/songs'
          console.log "data on 200 test"
          console.log data
          console.log "data ended"
          done()
  
  
  # Test 2 id too short
  # Should return a 404 because the jukebox does not exist
  describe '404 response check', () ->
    it 'should get a 404 response', (done) ->
      client.get '/jukebox/5278d382d6be67d80100000/songs', (err, req, res, data) ->
        if err
          throw err
        else
          if res.statusCode != 404
            throw new Error 'Invalid response for id too short'
          done()


  # Test 3 id too long
  # Should return a 404 because the jukebox does not exist
  describe '404 response check', () ->
    it 'should get a 404 response', (done) ->
      client.get '/jukebox/5278d382d6be67d80100000000000000/songs', (err, req, res, data) ->
        if err
          throw err
        else
          if res.statusCode != 404
            throw new Error 'Invalid response for id too long'
          done()


  # Test 4 id does not exist
  # Should return a 404 because the jukebox does not exist
  describe '404 response check', () ->
    it 'should get a 404 response', (done) ->
      client.get '/jukebox/5278d382d6be67d801000000/songs', (err, req, res, data) ->
        if err
          throw err
        else
          if res.statusCode != 404
            throw new Error 'Invalid response for id does not exist'
          done()
