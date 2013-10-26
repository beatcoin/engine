mongo = require 'mongodb'

mongoServerInterface = mongo.Server
mongoDb = mongo.Db
BSON = mongo.BSONPure

mongoServer = new(mongoServerInterface 'localhost', 27017,
  auto_reconnect: true
)

db = new mongoDb 'beatcoin_test', mongoServer

db.open (err, db) ->
  if not err
    console.log 'Conencted to beatcoin database'
    db.collection 'jukeboxes', {strict: true}, (err, collection) ->
      if err
        console.log 'jukeboxes collection does not exist, exiting now'
        process.exit
