# Import all the useful stuff...
s = require './stuff.coffee'

# Play a song from the queue (queue pop, history push)
module.exports.play = (req, res, next) ->
  console.log "play called for jukebox id %s", req.params.id
  s.db.collection 'queue', (err, collection) ->
    collection.find(
      jukebox_id: new s.BSON.ObjectID(req.params.id)
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
  
  # Set up the pagination params
  if not req.query.limit
    limit = 20
  else
    limit = req.query.limit
  if not req.query.offset
    offset = 0
  else
    offset = req.query.offset
  
  s.db.collection 'songs', (err, collection) ->
    collection.find(
      jukebox_id: new s.BSON.ObjectID(req.params.id)
    ,
      limit: limit
      skip: offset
    ).toArray (err, items) ->
      res.send
        status: 'success'
        items: items

# Load a list of available addresses
addresses = require './addresses.coffee'

# Add an address to an existing song
addPaymentAddress = (collection, object) ->
  object.btc_play_address = addresses.pop()
  collection.update
    _id: object._id
  ,
    object
  ,
    {}
  ,
    (err, result) ->
      if err
        console.err "Error adding payment address for song id %s and address %s", object._id, object.btc_play_address
      else
        console.log "Added payment address for song id %s and address %s", object._id, object.btc_play_address

# Put a song into the library
insertSong = (item, reqOpts, collection) ->
  
  # Try to find the song, and if it doesn't exist, create it
  collection.findAndModify
    song_identifier: item.song_identifier
  ,
    []
  ,
    $set: item
  ,
    upsert: true
    new: true
  ,
    (err, object) ->
      if err
        console.warn "Error inserting / updating song %s with object %s.", err, object
      else
        
        # If the song doesn't have a payment address, add one now
        if not object.btc_play_address
          console.log "Adding payment address for song id %s", object._id
          addPaymentAddress(collection, object)

# Insert many songs into the library
module.exports.putSongs = (req, res, next) ->
  #res.send
  #  status: 'success'
  s.db.collection 'jukeboxes', (err, collection) ->
    collection.findOne _id: new s.BSON.ObjectID(req.params.id), (err, jukebox) ->
      s.db.collection 'songs', (err, collection) ->
        reqOpts =
          uri: 'http://eye.beatcoin.org/wallets/' + jukebox.btc_wallet_id + '/addresses'
          method: 'POST'
          headers:
            'content-type': 'application/json'
        console.log "For jukebox %s items to insert %s", jukebox._id, JSON.stringify(req.params.items)
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
  s.db.collection 'songs', (err, collection) ->
    collection.findOne(
      btc_pay_address: req.params.address
      , (err, item) ->
        if not item
          res.send 404, 'Does not exist'
          return next()
        # Now we've got the item, push it into the queue
        item.queue = req.params
        delete item._id
        s.db.collection 'queue', (err, collection) ->
          collection.insert item
          res.send 200
    )

# Create a new jukebox, called by the client on first contact
module.exports.jukebox = (req, res, next) ->
  console.log 'Creating a new jukebox'
  s.db.collection 'jukeboxes', (err, collection) ->
    jukebox =
      key: require('crypto').randomBytes(64).toString('hex')
      subdomain: req.params.subdomain
      email: req.params.email
    collection.insert jukebox, (err, inserted) ->
      console.log "Just inserted jukebox %s", JSON.stringify(inserted)
      res.send
        status: "success"
        items: [jukebox]
