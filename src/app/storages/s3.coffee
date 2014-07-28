_ = require 'lodash'
colors = require 'colors'
U = require './../helpers/utils'
path = require 'path'
nconf = require 'nconf'
AWS = require 'aws-sdk'
config = path.resolve './config/locale.json'

module.exports = (->
  instance = null;
  storage =
    init: ->
      console.log "->".bold.magenta + " Init S3 storage"
      nconf.argv().env().file {file: config}
      AWS.config {
        "accessKeyId": nconf.get("s3KeyId"),
        "secretAccessKey": nconf.get("s3SecretKey"),
        "region": nconf.get("s3Region"),
      }
      @s3 = new AWS.S3()
      nconf.argv().env().file {file: config}
      @bucket = nconf.get "s3Bucket"

    get: (url, callback = ->) ->
      params = {Bucket: @bucket, Key: url.hash()}
      @s3.getObject params, (err, html) ->
        if err
          callback err
        else
          callback null, html


    set: (url, html, callback = ->) ->
      params = {Bucket: @bucket, Key: url.hash(), Body: html}
      @s3.putObject params, (err, data) ->
        if err
          callback err
        else
          callback null, data

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()