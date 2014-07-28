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
      @client = redis.createClient(nconf.get("redisPort"), nconf.get("redisHost"))

    get: (url, callback = ->) ->
      @client.get url, (err, html) ->
        if err
          callback err
        else
          callback null, html

    set: (url, html, callback = ->) ->
      @client.set url, html
      callback null

    close: -> @client.end()

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()