program = require 'commander'
fs = require 'fs'
nconf = require 'nconf'
prompt = require 'prompt'
hashids = require 'hashids'
colors = require 'colors'
U = require './app/helpers/utils'

messages =
  environment: "Environment must be only production or development"
  port: 'Port must be a number, Example: 3000 or 8000'
  storage: 'Storage engine must be only memory'
  homepage: 'Your homepage must be valid url, Example: http://example.com'

regexs =
  environment: /^(production|development)$/
  port: /^[0-9]{4}$/
  storage: /^(memory)$/
  homepage: /^((http|https):\/\/)(www[.])?([a-zA-Z0-9]|-)+([.][a-zA-Z0-9(-|\/|=|?)?]+)+$/

program
  .version '0.0.1'
  .option '-T, --no-tests', 'ignore test hook'

program
  .command 'init'
  .description 'Init configuration'
  .action ->
    schema =
      properties:
        environment:
          pattern: regexs.environment
          description: 'Environment choice (production, development)'
          message: messages.environment
          type: 'string'
          default: 'development'
        port:
          pattern: regexs.port
          description: 'Port'
          message: messages.port
          type: 'number'
          default: 3000
        storage:
          pattern: regexs.storage
          description: 'Storage choice (memory)'
          message: messages.storage
          type: 'string'
          default: 'memory'
        homepage:
          pattern: regexs.homepage
          description: 'Homepage for the crawling'
          message: messages.homepage
          type: 'string'
          required: true
        sitemaps:
          description: 'Sitemaps separate by comma'
          type: 'string'
          default: 'sitemap.xml'
        generateAPIKey:
          pattern: /(yes|no)/
          description: 'Generate API Key choice (yes, no)'
          message: 'answer must be yes or no'
          type: 'string'
          default: 'yes'

    prompt.start()
    prompt.get schema, (err, options) ->
      if options
        nconf.argv()
          .env()
          .file {file: 'config/locale.json'}

        nconf.set 'environment', options.environment
        nconf.set 'port', options.port
        nconf.set 'storage', options.storage
        nconf.set 'homepage', options.homepage
        nconf.set 'sitemaps', options.sitemaps.split ","

        if options.generateAPIKey is 'yes'
          hashid = new hashids options.homepage
          APIKey = hashid.encrypt 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
          nconf.set 'APIKey', APIKey
          nconf.save (err) ->
            fs.readFile 'config/locale.json', (err, data) ->
              console.dir JSON.parse(data.toString())
        else
          prompt.start()
          schema =
            properties:
              APIKey:
                description: 'API Key'
                message: 'You must add the apiKey'
                type: 'string'
                hidden: true
                required: true

          prompt.get schema, (err, options) ->
            if options
              nconf.set 'APIKey', options.APIKey
              nconf.save (err) ->
                fs.readFile 'config/locale.json', (err, data) ->
                  console.dir JSON.parse(data.toString())


program
  .command 'config:set <key> <value>'
  .description 'Set configuration'
  .action (key, value)->
    keys = ["port","sitemaps","environment","storage","homepage","APIKey"]

    if key not in keys
      return console.log U.format("{0} key isn't available, keys availables ({1})", [key, keys.join ", "]).red


    if key is "port" and not value.match regexs.port
      return console.log messages.port.red

    if key is "environment" and not value.match regexs.environment
      return console.log messages.environment.red

    if key is "storage" and not value.match regexs.storage
      return console.log messages.storage.red

    if key is "homepage" and not value.match regexs.homepage
      return console.log messages.homepage.red

    value = value.split "," if key is "sitemaps"
    value = Number value if key is "port"

    nconf.argv()
      .env()
      .file {file: 'config/locale.json'}

    nconf.set key, value
    nconf.save (err) ->
      fs.readFile 'config/locale.json', (err, data) ->
        console.dir JSON.parse(data.toString())

program.parse process.argv
