fs = require 'fs'
nconf = require 'nconf'
hashids = require 'hashids'
U = require './../helpers/utils'
colors = require 'colors'
path = require 'path'
config = path.resolve './config/locale.json'


exports.commandGet = (program, messages, regexs) ->
  program
    .command 'config:get'
    .description 'Get all configuration'
    .option '-T, --test', 'Active test hook'
    .option '-C, --nocolors', 'Disable colors'
    .action (options)->
      colors.mode = 'none' if options.nocolors
      config = path.resolve('./config/locale_test.json') if options.test

      fs.readFile config, (err, data) ->
        console.log 'Currently configuration: '.green
        conf = JSON.parse data.toString()
        console.log U.format('{0}: {1}', [k.white, v]) for k, v of conf


exports.commandSet = (program, messages, regexs) ->
  program
    .command 'config:set <key> <value>'
    .description 'Set configuration'
    .option '-T, --test', 'Active test hook'
    .option '-C, --nocolors', 'Disable colors'
    .action (key, value, options)->
      colors.mode = 'none' if options.nocolors
      config = path.resolve('./config/locale_test.json') if options.test
      nconf.argv().env().file {file: config}

      keys = [
        'port',
        'sitemaps'
        'storage'
        'homepage'
        'apiKey'
        'redisPort'
        'redisHost'
        's3KeyId'
        's3SecretKey'
        's3Region'
        's3Bucket'
      ]

      if key not in keys
        console.log U.format('{0} key isn\'t available, keys availables ({1})', [key, keys.join ', ']).red
        process.exit 1


      if key is 'port' and not value.match regexs.port
        console.log messages.port.red
        process.exit 1

      if key is 'redisPort' and not value.match regexs.port
        console.log messages.port.red
        process.exit 1

      if key is 'storage' and not value.match regexs.storage
        console.log messages.storage.red
        process.exit 1

      if key is 'homepage' and not value.match regexs.homepage
        console.log messages.homepage.red
        process.exit 1

      if key is 'redisHost' and not value.match regexs.redisHost
        console.log messages.redisHost.red
        process.exit 1

      if key is 'storage' and value is 'redis'
        if (not nconf.get 'redisPort') or (not nconf.get 'redisHost')
          console.log 'You must configure the port and host for redis!'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set redisPort 6379'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set redisHost localhost'.yellow

      if key is 'storage' and value is 's3'
        if (not nconf.get 's3KeyId') or (not nconf.get 's3SecretKey') or (not nconf.get 's3Region') or (not nconf.get 's3Bucket')
          console.log 'You must configure the keyId, secretKey, region and bucket for s3'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set s3KeyId akid'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set s3SecretKey secret'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set s3Region us-west-2'.yellow
          console.log '-> '.bold.yellow + 'node fantomas config:set s3Bucket myBucket'.yellow

      value = value.split ',' if key is 'sitemaps'
      value = Number value if key is 'port'
      value = Number value if key is 'redisPort'


      nconf.set key, value
      nconf.save (err) ->
        fs.readFile path.resolve(config), (err, data) ->
          console.log 'New configuration: '.green
          conf = JSON.parse data.toString()
          console.log U.format('{0}: {1}', [k.white, v]) for k, v of conf
