assert = require 'assert'
fs = require 'fs'
path = require 'path'
nconf = require 'nconf'
config = path.resolve './config/locale_test.json'
shell = require 'shelljs'

describe 'test command config:crawle', ->
  this.timeout 1500000
  it 'use cache memory', (done) ->
    nconf.argv().env().file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'sitemaps', ['http://jimmyfairly.com/sitemap.xml']
    nconf.set 'APIKey', "VWC1I0uyU"

    nconf.save (err) ->
      assert.equal shell.exec("node bin/fantomas crawle:sitemap -T").code, 0
      shell.rm('-rf', config)
      done()

  it 'use cache redis', (done) ->
    nconf.argv().env().file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "redis"
    nconf.set 'sitemaps', ['http://jimmyfairly.com/sitemap.xml']
    nconf.set 'APIKey', "VWC1I0uyU"
    nconf.set 'redisPort', 6379
    nconf.set 'redisHost', "localhost"

    nconf.save (err) ->
      assert.equal shell.exec("node bin/fantomas crawle:sitemap -T").code, 0
      shell.rm('-rf', config)
      done()