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
  console.log "play called for jukebox id %s", req.params.id
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
    collection.find({}, limit: 20).toArray (err, items) ->
      res.send
        status: 'success'
        items: items

insertSong = (item, reqOpts, collection) ->
  request.post reqOpts, (err, client, response) ->
    resp = JSON.parse client.body
    item.btc_pay_address = resp.addresses[0]
    collection.insert item, (err, result) ->
      if err
        console.log "Error inserting for jukebox id %s with result %s", item.jukebox_id, JSON.stringify(result)
      else
        console.log "Successfully inserted song for jukebox id %s, result was %s", item.jukebox_id, JSON.stringify(result)

module.exports.putSongs = (req, res, next) ->
  res.send
    status: 'success'
  return next()
  db.collection 'jukeboxes', (err, collection) ->
    collection.findOne _id: new BSON.ObjectID(req.params.id), (err, jukebox) ->
      db.collection 'songs', (err, collection) ->
        reqOpts =
          uri: 'http://eye.beatcoin.org/wallets/' + jukebox.btc_wallet_id + '/addresses'
          method: 'POST'
          headers:
            'content-type': 'application/json'
        for item in req.params.items
          item.jukebox_id = jukebox._id
          insertSong item, reqOpts, collection
        res.send
          status: 'success'

module.exports.notifeye = (req, res, next) ->
  console.log 'notifeye called'
  console.log req.params
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
