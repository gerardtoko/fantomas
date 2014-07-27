program = require 'commander'
initCommand = require './app/commands/init'
configCommand = require './app/commands/config'
crawleCommand = require './app/commands/crawle'

messages =
  port: 'Port must be a number, Example: 3000 or 8000'
  storage: 'Storage engine must be only memory or redis'
  homepage: 'Your homepage must be valid url, Example: http://example.com'
  redis_host: 'Invalid host for Redis host'

regexs =
  port: /^[0-9]{4}$/
  storage: /^(memory|redis)$/
  homepage: /^((http|https):\/\/)(www[.])?([a-zA-Z0-9]|-)+([.][a-zA-Z0-9(-|\/|=|?)?]+)+$/
  redis_host: /^[a-zA-Z0-9.-]{1,}$/

program
  .version '0.0.1'
  .option '-T, --no-tests', 'ignore test hook'

#Commands
initCommand.command program, messages, regexs
configCommand.commandGet program, messages, regexs
configCommand.commandSet program, messages, regexs
crawleCommand.crawleSitemap program, messages, regexs

program.parse process.argv
