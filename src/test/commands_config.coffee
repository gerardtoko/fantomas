assert = require 'assert'
fs = require 'fs'
path = require 'path'
nconf = require 'nconf'
config = path.resolve './config/locale_test.json'
shell = require 'shelljs'

describe 'test command config:set', ->
  this.timeout 1500000
  it 'set config value with error', (done) ->
    nconf.argv().env().file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'APIKey', "VWC1I0uyU"
    nconf.set 'redisPort', 6379
    nconf.set 'redisHost', "127.0.0.1"

    nconf.save (err) ->
      assert.equal shell.exec("node bin/fantomas config:set porte 80 -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set storage memories -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set for bar -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set homepag https://example.com -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set homepage example.com -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set apikey bar -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set redisPort 3000a -T").code, 1
      assert.equal shell.exec("node bin/fantomas config:set redisHost @ddz -T").code, 1
      shell.rm('-rf', config)
      done()

  it 'set config value without error: inset', (done) ->
    nconf.argv().env().file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'apiKey', "VWC1I0uyU"
    nconf.set 'redisPort', 6379
    nconf.set 'redisHost', "127.0.0.1"

    nconf.save (err) ->
      assert.equal shell.exec("node bin/fantomas config:set port 8000 -T").code, 0
      assert.equal shell.exec("node bin/fantomas config:set storage memory -T").code, 0
      assert.equal shell.exec("node bin/fantomas config:set homepage https://example.com -T").code, 0
      assert.equal shell.exec("node bin/fantomas config:set apiKey bar -T").code, 0
      done()

    it 'set value config without error:control', (done) ->
      nconf.argv().env().file {file: config}
      assert.equal nconf.get("port"), 8000
      assert.equal nconf.get("storage"), "memory"
      assert.equal nconf.get("homepage"), "https://example.com"
      assert.equal nconf.get("apiKey"), "bar"
      assert.equal nconf.get("redisPort"), 6379
      assert.equal nconf.get("redisHost"), "127.0.0.1"
      shell.rm('-rf', config)
      done()


describe 'test command config:get', ->
  this.timeout 1500000
  it 'get config value without error', (done) ->
    nconf.argv().env().file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'apiKey', "VWC1I0uyU"
    nconf.set 'redisPort', 6379
    nconf.set 'redisHost', "127.0.0.1"

    nconf.save (err) ->
      assert.equal shell.exec("node bin/fantomas config:get -T ").code, 0
      shell.rm('-rf', config)
      done()
