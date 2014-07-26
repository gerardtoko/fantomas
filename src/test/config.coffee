assert = require 'assert'
fs = require 'fs'
path = require 'path'
nconf = require 'nconf'
config = path.resolve './config/locale_test.json'
shell = require 'shelljs'

describe 'test command config:set', ->
  this.timeout 1500000
  it 'set config value with error', (done) ->
    nconf.argv()
      .env()
      .file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'APIKey', "VWC1I0uyU"

    nconf.save (err) ->
      assert.equal shell.exec("node fantomas -T config:set porte 80").code, 1
      assert.equal shell.exec("node fantomas -T config:set storage memories").code, 1
      assert.equal shell.exec("node fantomas -T config:set for bar").code, 1
      assert.equal shell.exec("node fantomas -T config:set homepag https://example.com").code, 1
      assert.equal shell.exec("node fantomas -T config:set homepage example.com").code, 1
      assert.equal shell.exec("node fantomas -T config:set apikey bar").code, 1
      shell.rm('-rf', config)
      done()

  it 'set config value without error: inset', (done) ->
    nconf.argv()
      .env()
      .file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'APIKey', "VWC1I0uyU"

    nconf.save (err) ->
      assert.equal shell.exec("node fantomas config:set port 8000").code, 0
      assert.equal shell.exec("node fantomas config:set storage memory").code, 0
      assert.equal shell.exec("node fantomas config:set homepage https://example.com").code, 0
      assert.equal shell.exec("node fantomas config:set APIKey bar").code, 0
      done()

    it 'set value config without error:control', (done) ->
      nconf.argv()
        .env()
        .file {file: config}
        assert.equal nconf.get("port"), 8000
        assert.equal nconf.get("storage"), "memory"
        assert.equal nconf.get("homepage"), "https://example.com"
        assert.equal nconf.get("APIKey"), "bar"
        shell.rm('-rf', config)
        done()


describe 'test command config:get', ->
  this.timeout 1500000
  it 'get config value without error', (done) ->
    nconf.argv()
      .env()
      .file {file: config}

    nconf.set 'environment', "development"
    nconf.set 'port', 3000
    nconf.set 'storage', "memory"
    nconf.set 'homepage', "https://github.com"
    nconf.set 'sitemaps', [ 'sitemap.xml', 'sitemapfr.xml', 'sitemapfr.xml' ]
    nconf.set 'APIKey', "VWC1I0uyU"

    nconf.save (err) ->
      assert.equal shell.exec("node fantomas -T config:get").code, 0
      shell.rm('-rf', config)
      done()