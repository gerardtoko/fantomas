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
    .option '-T, --test', 'test hook'
    .action (options)->
      config = path.resolve('./config/locale_test.json') if options.test

      fs.readFile config, (err, data) ->
        console.dir JSON.parse(data.toString())


exports.commandSet = (program, messages, regexs) ->
  program
    .command 'config:set <key> <value>'
    .description 'Set configuration'
    .option '-T, --test', 'test hook'
    .action (key, value, options)->

      config = path.resolve('./config/locale_test.json') if options.test

      keys = ["port","sitemaps","environment","storage","homepage","APIKey"]

      if key not in keys
        console.log U.format("{0} key isn't available, keys availables ({1})", [key, keys.join ", "]).red
        process.exit 1


      if key is "port" and not value.match regexs.port
        console.log messages.port.red
        process.exit 1

      if key is "environment" and not value.match regexs.environment
        console.log messages.environment.red
        process.exit 1

      if key is "storage" and not value.match regexs.storage
        console.log messages.storage.red
        process.exit 1

      if key is "homepage" and not value.match regexs.homepage
        console.log messages.homepage.red
        process.exit 1

      value = value.split "," if key is "sitemaps"
      value = Number value if key is "port"

      nconf.argv()
        .env()
        .file {file: config}

      nconf.set key, value
      nconf.save (err) ->
        fs.readFile path.resolve(config), (err, data) ->
          console.dir JSON.parse(data.toString())
