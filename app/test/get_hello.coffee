restify = require 'restify'

client = restify.createJsonClient
  version: '*'
  url: 'http://127.0.0.1:8080'

describe 'service: hello', () ->
  
  # Test 1
  describe '200 response check', () ->
    it 'should get a 200 response', (done) ->
      client.get '/hello', (err, req, res, data) ->
        if err
          throw err
        else
          if res.statusCode != 200
            console.log "data"
            console.log res
            throw new Error 'Invalid response from /hello'
          done()
  