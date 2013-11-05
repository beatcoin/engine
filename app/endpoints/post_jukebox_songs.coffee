# Import all the useful stuff...
s = require '../stuff.coffee'

# Load a list of available addresses
addresses = require '../addresses.coffee'

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
module.exports = (req, res, next) ->
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
