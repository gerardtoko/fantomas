program = require 'commander'
fs = require 'fs'
nconf = require 'nconf'

program
  .version '0.0.1'
  .option '-T, --no-tests', 'ignore test hook'

program
  .command 'init' 
  .description 'Set locale settings file'
  .option '-e, --environment <environment>', 'Set environment (dev or prod)'
  .option '-p, --port <port>', 'Port listining'
  .option '-s, --storage <storage>', 'Enable storage engine (memory, s3, redis)'
  .action (options) ->
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