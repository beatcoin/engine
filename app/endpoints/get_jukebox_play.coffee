# Import all the useful stuff...
s = require '../stuff.coffee'

# Play a song from the queue (queue pop, history push)
module.exports = (req, res, next) ->
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
