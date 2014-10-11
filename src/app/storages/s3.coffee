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
      console.log '->'.bold.magenta + ' Init S3 storage'
      nconf.argv().env().file {file: config}
      AWS.config.update {
        'accessKeyId': nconf.get 's3KeyId'
        'secretAccessKey': nconf.get 's3SecretKey'
        'region': nconf.get 's3Region'
      }
      @s3 = new AWS.S3()
      @bucket = nconf.get 's3Bucket'

    get: (url, callback = ->) ->
      params = Bucket: @bucket, Key: U.hash(url)
      @s3.getObject params, (err, data) -> callback err, data

    set: (url, html, callback = ->) ->
      params = Bucket: @bucket, Key: U.hash(url), Body: html
      @s3.putObject params, (err, data) -> callback err, data

  getInstance: ->
    if instance is null
      instance = _.clone storage
      instance.init()
    instance
)()