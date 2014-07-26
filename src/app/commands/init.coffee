fs = require 'fs'
nconf = require 'nconf'
prompt = require 'prompt'
hashids = require 'hashids'
path = require 'path'
colors = require 'colors'
config = path.resolve './config/locale.json'

exports.command = (program, messages, regexs) ->
  program
    .command 'init'
    .description 'Init configuration'
    .option '-T, --test', 'test hook'
    .action (options) ->
      config = path.resolve('./config/locale_test.json') if options.test

      prompt.message = ""
      prompt.delimiter = ""

      schema =
        properties:
          environment:
            pattern: regexs.environment
            description: 'Environment (production, development)'.white
            message: messages.environment
            type: 'string'
            default: 'development'
          port:
            pattern: regexs.port
            description: 'Port'.white
            message: messages.port
            type: 'number'
            default: 3000
          storage:
            pattern: regexs.storage
            description: 'Storage (memory)'.white
            message: messages.storage
            type: 'string'
            default: 'memory'
          homepage:
            pattern: regexs.homepage
            description: 'Homepage for the crawling'.white
            message: messages.homepage
            type: 'string'
            required: true
          sitemaps:
            description: 'Sitemaps separate by comma'.white
            type: 'string'
            default: 'sitemap.xml'
          generateAPIKey:
            pattern: /(yes|no)/
            description: 'Generate API Key ? (yes, no)'.white
            message: 'answer must be yes or no'
            type: 'string'
            default: 'yes'

      prompt.start()
      prompt.get schema, (err, options) ->
        if options
          nconf.argv()
            .env()
            .file {file: config}

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
              fs.readFile config, (err, data) ->
                console.log "Config file was created: ".green
                console.dir JSON.parse(data.toString())
          else
            prompt.start()
            schema =
              properties:
                APIKey:
                  description: 'Entry API Key'.white
                  message: 'You must add the apiKey'
                  type: 'string'
                  hidden: true
                  required: true

            prompt.get schema, (err, options) ->
              if options
                nconf.set 'APIKey', options.APIKey
                nconf.save (err) ->
                  fs.readFile config, (err, data) ->
                    console.log "Config file was created: ".green
                    console.dir JSON.parse(data.toString())

