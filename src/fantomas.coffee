program = require 'commander'
fs = require 'fs'
nconf = require 'nconf'
prompt = require 'prompt'

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
          pattern: /(production|development)/
          description: 'Environment (production, development)'
          message: 'Environment must be only production or development'
          type: 'string'
          default: 'development'
        port: 
          pattern: /[0-9]{4}/
          description: 'Port'
          message: 'Port must be Number 3000, 8000'
          type: 'number'
          default: 3000
        storage: 
          pattern: /(memory|s3|redis)/
          description: 'Storage (memory, s3, redis)'
          message: 'Storage engine must be only memory, s3 or redis'
          type: 'string'
          default: 'memory'

    prompt.start()
    prompt.get schema, (err, options) ->
      environment = options.environment || 'development'
      port = options.port || 3000
      storage = options.storage || 'memory'
      
      nconf.argv()
        .env(environment)
        .file { file: 'config/locale.json' }
      
      nconf.set 'environment', environment
      nconf.set 'port', port
      nconf.set 'storage', storage

      nconf.save (err) ->
        fs.readFile 'config/locale.json', (err, data) ->
          console.dir JSON.parse(data.toString())

program.parse process.argv