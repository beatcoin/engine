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

# Get the songs in the current queue
module.exports.getQueue = (req, res, next) ->
  if not req.params.id
    res.send 404, 'Does not exist'
    return next()
  db.collection 'queue', (err, collection) ->
    collection.find({jukebox_id: new BSON.ObjectID(req.params.id)}).toArray (err, items) ->
      res.send
        status: 'success'
        items: items

# Play a song from the queue (queue pop, history push)
module.exports.play = (req, res, next) ->
  console.log "play called for jukebox id %s", req.params.id
  db.collection 'queue', (err, collection) ->
    collection.find(
      jukebox_id: new BSON.ObjectID(req.params.id)
    ,
      sort:
        'queue.amount': -1
        'queue.time': 1
      limit: 1
    ).toArray (err, items) ->
      if not items.length # Other tests fail here, not sure why
        res.send
          status: 'success'
          items: []
      else
        console.log 'found items %s', JSON.stringify(items)
        item = items[0]
        console.log item
        collection.remove _id: item._id, (err, removed) ->
          console.log 'just removed'
          console.log removed
          res.send
            status: 'success'
            items: [item]

# Get a list of all the songs in the library
module.exports.listSongs = (req, res, next) ->
  if not req.params.id
    res.send 404, 'Does not exist'
    return next()
  db.collection 'songs', (err, collection) ->
    collection.find(
      jukebox_id: new BSON.ObjectID(req.params.id)
    ,
      limit: 20
    ).toArray (err, items) ->
      res.send
        status: 'success'
        items: items

# Put a song into the library
insertSong = (item, reqOpts, collection) ->
  request.post reqOpts, (err, client, response) ->
    if client.body
      resp = JSON.parse client.body
      item.btc_pay_address = resp.addresses[0]
      collection.insert item, (err, result) ->
        if err
          console.log "Error inserting for jukebox id %s with result %s", item.jukebox_id, JSON.stringify(result)
        else
          console.log "Successfully inserted song for jukebox id %s, result was %s", item.jukebox_id, JSON.stringify(result)

# Insert many songs into the library
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

# Insert a payment into the engine
module.exports.notifeye = (req, res, next) ->
  console.log 'notifeye called'
  console.log req.params
  if not req.params.address
    return res.send 400, 'Invalid address'
  db.collection 'songs', (err, collection) ->
    collection.findOne(
      btc_pay_address: req.params.address
      , (err, item) ->
        if not item
          res.send 404, 'Does not exist'
          return next()
        # Now we've got the item, push it into the queue
        item.queue = req.params
        delete item._id
        db.collection 'queue', (err, collection) ->
          collection.insert item
          res.send 200
    )
