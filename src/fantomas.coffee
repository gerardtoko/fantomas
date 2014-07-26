program = require 'commander'
initCommand = require './app/commands/init'
configCommand = require './app/commands/config'

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


initCommand.command program, messages, regexs
configCommand.commandGet program, messages, regexs
configCommand.commandSet program, messages, regexs

program.parse process.argv