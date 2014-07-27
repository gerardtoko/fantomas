_ = require 'lodash'
colors = require 'colors'
cache = require 'memory-cache'

module.exports = (->
  instance = null;
  storage =
    init: ->
      console.log "->".bold.magenta + " Init storage memory"
    set: (url, html) ->
      cache.put url, html
      cache.get url

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()