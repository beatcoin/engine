mongo = require 'mongodb'

mongoServerInterface = mongo.Server
mongoDb = mongo.Db
BSON = mongo.BSONPure

mongoServer = new mongoServerInterface( 'localhost', 27017,
  auto_reconnect: true
)

db = new mongoDb 'beatcoin_test', mongoServer

db.open (err, db) ->
  if not err
    console.log 'Conencted to beatcoin database'
    db.collection 'jukeboxes', {strict: true}, (err, collection) ->
      if err
        console.log 'jukeboxes collection does not exist, exiting now'
        process.exit()

module.exports.listSongs = (req, res, next) ->
  db.collection 'songs', (err, collection) ->
    collection.find().toArray (err, items) ->
      res.send
        status: 'success'
        items: items

module.exports.notifeye = (req, res, next) ->
  if not req.params.address
    return res.send 400, 'Invalid address'
  db.collection 'songs', (err, collection) ->
    collection.findOne(
      btc_pay_address: req.params.address
      , (err, item) ->
        # Now we've got the item, push it into the queue
        item.queue = req.params
        db.collection 'queue', (err, collection) ->
          collection.insert item
          res.send 200
    )

module.exports.play = (req, res, next) ->
  db.collection 'queue', (err, collection) ->
    collection.findAndModify(jukebox_id: new BSON.ObjectID(req.params.id), {'queue.amount': -1, 'queue.times': 1}, {}, {remove: true}, (err, item)->
      console.log item
    )