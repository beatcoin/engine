mongo = require 'mongodb'

mongoServerInterface = mongo.Server
mongoDb = mongo.Db
BSON = mongo.BSONPure

mongoServer = new mongoServerInterface( 'localhost', 27017,
  auto_reconnect: true
)

db = new mongoDb 'beatcoin_test', mongoServer

crypto = require 'crypto'

# A helper to create jukeboxes
insertJukebox = (collection, jukebox) ->
  collection.insert jukebox, (err, result) ->
    console.log "Created jukebox with error %s and result %s", err, result

# A helper to create songs
insertSong = (collection, song) ->
  collection.insert song, (err, result) ->
    console.log "Inserted song with error %s and result %s", err, result

jukeboxes = [
  _id: new BSON.ObjectID('5278d382d6be67d801000001')
  subdomain: "demo"
  email: "test-demo@beatcoin.org"
  wallet: "demo123"
  meta: {}
,
  _id: new BSON.ObjectID('5278d382d6be67d801000002')
  subdomain: "android"
  email: "test-arndoi@beatcoin.org"
  wallet: "android123"
  meta: {}
,
  _id: new BSON.ObjectID('5278d382d6be67d801000003')
  subdomain: "ios"
  email: "test-ios@beatcoin.org"
  wallet: "ios123"
  meta: {}
]

songs = [
  _id: new BSON.ObjectID('4448d382d6be67d801000001')
  btc_play_address: "abc123"
  identifier: "Some_song.mp3"
  meta:
    title: "Some song"
,
  btc_play_address: "abc234"
  identifier: "Madonna.mp3"
  meta:
    title: "Madonna"
,
  btc_play_address: "abc345"
  identifier: "Afroman - Colt 45.mp3"
  meta:
    title: "Afroman - Colt 45"
,
  btc_play_address: "abc456"
  identifier: "Whatever.mp3"
  meta:
    title: "Whatever"
]

db.open (err, db) ->
  if not err
    console.log 'Conencted to beatcoin database'
    
    # Jukeboxes
    db.collection 'jukeboxes', (err, collection) ->
      
      # Delete the existing jukeboxes
      collection.remove()
      
      # Insert jukeboxes
      for jukebox in jukeboxes
        collection.insert jukebox, (err, result) ->
          console.log "Created jukebox with error %s and result %s", err, result
      
      # Insert some random jukeboxes
      for i in [1..10]
        collection.insert
          subdomain: crypto.randomBytes(4).toString('hex')
          email: 'test-' + crypto.randomBytes(4).toString('hex') + '@beatcoin.org'
          key: crypto.randomBytes(64).toString('hex')
      
      # Retrieve all the jukeboxes
      collection.find().toArray (err, js) ->
      
        # Songs
        db.collection 'songs', (err, collection) ->
          
          # Delete the existing songs
          collection.remove()
          
          # Insert songs
          for song in songs
            song.jukebox_id = jukeboxes[0]._id
            collection.insert song, (err, result) ->
              console.log "Created song with error %s and result %s", err, result
        
          # Insert some random songs
          for j in js
            for i in [1..100]
              songId = crypto.randomBytes(12).toString('hex')
              collection.insert
                jukebox_id: j._id
                song_identifier: songId + '.mp3'
                btc_play_address: crypto.randomBytes(8).toString('hex')
                meta:
                  title: songId
              ,
                (err, result) ->
                  if err
                    console.err err
                    
          
          # Queue
          db.collection 'queue', (err, collection) ->
            
            collection.remove()
            
            item = songs[0]
            item.queue =
              address: songs[0].btc_play_address
              amount: 0.1
              time: 1382820585
            
            item2 = songs[1]
            item2.queue =
              address: songs[1].btc_play_address
              amount: 0.1
              time: 138282000
            
            item3 = songs[3]
            item3.queue =
              address: songs[3].btc_play_address
              amount: 0.2
              time: 1382820900
            
            items = [item, item2, item3]
            
            for item in items
              collection.insert item, (err, result) ->
                console.log "Created queue item with error %s and result %s", err, result
