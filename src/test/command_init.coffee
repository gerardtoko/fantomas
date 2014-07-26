assert = require 'assert'
fs = require 'fs'
path = require 'path'
nconf = require 'nconf'
config = path.resolve './config/locale_test.json'
shell = require 'shelljs'

describe 'test command init', ->
  this.timeout 1500000
  it 'init app with error', (done) ->
    # assert.equal shell.exec("node fantomas -T init").code, 0
    done()
