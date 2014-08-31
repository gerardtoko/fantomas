fs = require 'fs'
nconf = require 'nconf'
prompt = require 'prompt'
path = require 'path'
colors = require 'colors'
Q = require 'Q'
config = path.resolve './config/locale.json'

exports.command = (program, messages, regexs) ->
  program
    .command 'init'
    .description 'Init configuration'
    .option '-T, --test', 'Active test hook'
    .option '-C, --nocolors', 'Disable colors'
    .action (options) ->
      colors.mode = 'none' if options.nocolors
      config = path.resolve('./config/locale_test.json') if options.test
      nconf.argv().env().file {file: config}

      Q()
      .then ->
        deferred = Q.defer()
        prompt.message = ''
        prompt.delimiter = ''
        schema =
          properties:
            storage:
              pattern: regexs.storage
              description: 'Storage (memory, s3, redis)'.white
              message: messages.storage
              default: 'memory'
              required: false

        prompt.start()
        prompt.get schema, deferred.makeNodeResolver()
        deferred.promise

      .then (options) ->
        deferred = Q.defer()
        if options

          schema =
            properties:
              port:
                pattern: regexs.port
                description: 'Port'.white
                message: messages.port
                type: 'number'
                default: 3000
              homepage:
                pattern: regexs.homepage
                description: 'Homepage for the crawling'.white
                message: messages.homepage
                required: true
              sitemaps:
                description: 'Sitemaps separate by comma'.white
                default: 'sitemap.xml'
              generateAPIKey:
                pattern: /^(yes|no)$/
                description: 'Generate API Key ? (yes, no)'.white
                message: 'answer must be yes or no'
                default: 'yes'

          nconf.set 'storage', options.storage

          if options.storage is 'memory'
            prompt.start()
            prompt.get schema, deferred.makeNodeResolver()

          if options.storage is 'redis'
            schemaRedis =
              properties:
                port:
                  pattern: regexs.port
                  description: 'Redis port'.white
                  type: 'number'
                  default: 6379
                host:
                  pattern: regexs.redisHost
                  description: 'Redis host'.white
                  default: '127.0.0.1'
            prompt.start()
            prompt.get schemaRedis, (err, options) ->
              if options
                nconf.set 'redisPort', options.port
                nconf.set 'redisHost', options.host
                prompt.start()
                prompt.get schema, deferred.makeNodeResolver()
              else
                deferred.reject()

          if options.storage is 's3'
            schemaRedis =
              properties:
                s3KeyId:
                  description: 'S3 accessKeyId'.white
                  require: true
                s3SecretKey:
                  description: 'S3 secretAccessKey'.white
                  require: true
                s3Region:
                  description: 'S3 region'.white
                  require: true
                s3Bucket:
                  description: 'S3 bucket'.white
                  require: true
            prompt.start()
            prompt.get schemaRedis, (err, options) ->
              if options
                nconf.set 's3KeyId', options.port
                nconf.set 's3SecretKey', options.host
                nconf.set 's3Region', options.port
                nconf.set 's3Bucket', options.host
                prompt.start()
                prompt.get schema, deferred.makeNodeResolver()
              else
                deferred.reject()

        else
          deferred.reject()
        deferred.promise

      .then (options) ->
        deferred = Q.defer()
        if options
          nconf.set 'port', options.port
          nconf.set 'homepage', options.homepage
          nconf.set 'sitemaps', options.sitemaps.split ','

          if options.generateAPIKey is 'yes'
            deferred.resolve(options.homepage.hash())
          else
            Q()
            .then ->
              _deferred = Q.defer()
              prompt.start()
              schema =
                properties:
                  APIKey:
                    description: 'Entry API Key'.white
                    message: 'You must add the apiKey'
                    hidden: true
                    required: true

              prompt.get schema, _deferred.makeNodeResolver()
              _deferred.promise

            .then (options) ->
              if options
                deferred.resolve(options.APIKey)

            .fail (err) ->
              deferred.reject()
            .done()
        else
          deferred.reject()
        deferred.promise

      .then (APIKey) ->
        deferred = Q.defer()
        nconf.set 'apiKey', APIKey
        nconf.save deferred.makeNodeResolver()
        deferred.promise

      .then ->
        deferred = Q.defer()
        fs.readFile config, deferred.makeNodeResolver()
        deferred.promise

      .then (data) ->
        console.log 'Config file was created!'.green
        conf = JSON.parse data.toString()
        console.log U.format('{0}: {1}', [k.white, v]) for k, v of conf

      .fail (err) ->
        console.log err.message.red if err
        process.exit 1
      .done()