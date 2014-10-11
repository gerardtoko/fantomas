_ = require 'lodash'
colors = require 'colors'
cache = require 'memory-cache'

module.exports = (->
  instance = null;
  storage =
    init: -> console.log '->'.bold.magenta + ' Init Memory storage'
    get: (url, callback = ->) -> callback null, cache.get url
    set: (url, html, callback = ->) ->
      cache.put url, html
      callback null

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()