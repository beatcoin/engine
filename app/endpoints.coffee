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

# We need to make HTTP requests
request = require 'request'

module.exports.play = (req, res, next) ->
  db.collection 'queue', (err, collection) ->
    collection.findOne
      jukebox_id: new BSON.ObjectID(req.params.id)
    ,
      sort:
        'query.amount': -1
        'query.time': 1
    ,
      (err, item) ->
        if not item
          res.send
            status: 'success'
            items: []
        else
          console.log 'find'
          console.log item
          collection.remove _id: item._id, (err, removed) ->
            console.log 'just removed'
            console.log removed
            res.send
              status: 'success'
              items: [item]

module.exports.listSongs = (req, res, next) ->
  db.collection 'songs', (err, collection) ->
    collection.find().toArray (err, items) ->
      res.send
        status: 'success'
        items: items

insertItem = (item, reqOpts) ->
  request.post reqOpts, (err, client, response) ->
    resp = JSON.parse client.body
    item.btc_pay_address = resp.addresses[0]
    console.log item

module.exports.putSongs = (req, res, next) ->
  db.collection 'jukeboxes', (err, collection) ->
    collection.findOne _id: new BSON.ObjectID(req.params.id), (err, jukebox) ->
      db.collection 'songs', (err, collection) ->
        reqOpts =
          uri: 'http://eye.beatcoin.org/wallets/' + jukebox.btc_wallet_id + '/addresses'
          method: 'POST'
          headers:
            'content-type': 'application/x-www-form-urlencoded'
        for item in req.params.items
          item.jukebox_id = jukebox._id
          insertItem item, reqOpts
        res.send
          status: 'success'

module.exports.notifeye = (req, res, next) ->
  if not req.params.address
    return res.send 400, 'Invalid address'
  db.collection 'songs', (err, collection) ->
    collection.findOne(
      btc_pay_address: req.params.address
      , (err, item) ->
        # Now we've got the item, push it into the queue
        item.queue = req.params
        delete item._id
        db.collection 'queue', (err, collection) ->
          collection.insert item
          res.send 200
    )
