# Import all the useful stuff...
s = require '../stuff.coffee'

# Get a list of all the songs in the library
module.exports = (req, res, next) ->
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
