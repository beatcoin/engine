# A collection of bits and pieces needed everywhere

# Mongo db...
module.exports.db = require('./mongo.coffee').db
module.exports.BSON = require('./mongo.coffee').BSON

# We need to make HTTP requests
request = require 'request'
