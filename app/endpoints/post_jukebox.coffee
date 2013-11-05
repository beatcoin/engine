# Import all the useful stuff...
s = require '../stuff.coffee'

# Create a new jukebox, called by the client on first contact
module.exports = (req, res, next) ->
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
