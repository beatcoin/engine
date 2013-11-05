restify = require 'restify'
assert = require 'assert'

before (done) ->
  engine = require('../engine.coffee')
  engine()
  done()