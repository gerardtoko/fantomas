program = require 'commander'
initCommand = require './../app/commands/init'
configCommand = require './../app/commands/config'
crawleCommand = require './../app/commands/crawle'

messages =
  port: 'Port must be a number, Example: 3000 or 8000'
  storage: 'Storage engine must be only memory, redis or s3'
  sitemap: 'Your sitemaps must be valid url, Example: http://example.com/sitemap.xml'
  url: 'Your url must be valid url, Example: http://example.com/product/9'
  redisHost: 'Invalid host for Redis host'

regexs =
  port: /^[0-9]{4}$/
  storage: /^(memory|redis|s3)$/
  sitemap: /^((http|https):\/\/)(www[.])?([a-zA-Z0-9]|-)+([.][a-zA-Z0-9(-|\/|=|?)?]+)+$/
  url: /^((http|https):\/\/)(www[.])?([a-zA-Z0-9]|-)+([.][a-zA-Z0-9(-|\/|=|?)?]+)+$/
  redisHost: /^[a-zA-Z0-9.-]{1,}$/

program
  .version '0.0.1'

#Commands
initCommand.command program, messages, regexs
configCommand.commandGet program, messages, regexs
configCommand.commandSet program, messages, regexs
crawleCommand.sitemap program, messages, regexs
crawleCommand.url program, messages, regexs

program.parse process.argv
