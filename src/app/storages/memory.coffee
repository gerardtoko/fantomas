_ = require 'lodash'
colors = require 'colors'
cache = require 'memory-cache'

module.exports = (->
  instance = null;
  storage =
    init: -> console.log "->".bold.magenta + " Init Memory storage"
    get: (url) -> cache.get url
    set: (url, html) -> cache.put url, html

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()