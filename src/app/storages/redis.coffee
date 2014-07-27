_ = require 'lodash'
colors = require 'colors'
redis = require 'redis'
U = require './../helpers/utils'
path = require 'path'
nconf = require 'nconf'
config = path.resolve './config/locale.json'

module.exports = (->
  instance = null;
  storage =
    init: ->
      console.log "->".bold.magenta + " Init Redis storage"
      nconf.argv().env().file {file: config}
      @client = redis.createClient(nconf.get("redis_port"), nconf.get("redis_host"))

    get: (url) ->
      @client.get url, (err, html) ->
        if err
          return console.log "x".bold.red + " retrieving {0} into Redis".format([url]).red
        html.toString()

    set: (url, html) -> @client.set url, html
    close: -> @client.end()

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()