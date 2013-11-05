# Import all the useful stuff...
s = require '../stuff.coffee'

# Insert a payment into the engine
module.exports = (req, res, next) ->
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
