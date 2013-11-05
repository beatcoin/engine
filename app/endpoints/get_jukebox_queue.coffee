# Import all the useful stuff...
s = require '../stuff.coffee'

# Get the songs in the current queue
module.exports = (req, res, next) ->
  if not req.params.id
    res.send 404, 'Does not exist'
    return next()
  s.db.collection 'queue', (err, collection) ->
    collection.find({jukebox_id: new s.BSON.ObjectID(req.params.id)}).toArray (err, items) ->
      res.send
        status: 'success'
        items: items
