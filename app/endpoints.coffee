# Import all the useful stuff...
s = require './stuff.coffee'

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
