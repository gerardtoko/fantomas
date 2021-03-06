fs = require 'fs'
nconf = require 'nconf'
path = require 'path'
colors = require 'colors'
Q = require 'Q'
request = require 'request'
U = require './../helpers/utils'
storageBase = require './../storages/base'
async = require 'async'
phantom = require 'phantom'
config = path.resolve './config/locale.json'
parser = require 'xml2json'
_ = require 'lodash'
_.str = require 'underscore.string'


exports.sitemap = (program, messages, regexs) ->
  program
    .command 'crawle:sitemap'
    .description 'Load, parse sitemaps and add into storage engine'
    .option '-T, --test', 'Active test hook'
    .option '-C, --nocolors', 'Disable colors'
    .action (options) ->
      time = new Date()
      colors.mode = 'none' if options.nocolors
      console.log 'Init crawling.'.green
      config = path.resolve('./config/locale_test.json') if options.test

      Q()
      .then ->
        deferred = Q.defer()
        nconf.argv().env().file {file: config}
        sitemaps = nconf.get 'sitemaps'

        sitemapsfn = (sitemap, callback) ->
          console.log U.format('{0} Use {1}', ['->'.bold.green, sitemap])
          Q()
          .then ->
            sdeferred = Q.defer()
            request sitemap, sdeferred.makeNodeResolver()
            sdeferred.promise

          .then (data) ->
            sdeferred = Q.defer()
            if data[0].statusCode is 200
              json = JSON.parse(parser.toJson(data[1]))

              if json.urlset
                if json.urlset.url
                  urls = json.urlset.url
                  urls = [urls[0]] if options.test
                  urls = [urls[0]]

                  console.log U.format 'Total URL: {0}', [String(urls.length).green]
                  urlsfn = (url, callback) ->
                    url = url.loc
                    Q()
                    .then ->
                      pdeferred = Q.defer()
                      console.log U.format 'Fetch URL: {0}...', [url]
                      phantom.create '--load-images=no', '--local-to-remote-url-access=yes', (ph) ->
                        ph.createPage (page) ->
                          page.open url, (status) ->
                            if status is 'success'
                              page.evaluate (-> document.getElementsByTagName('html')[0].innerHTML), (result) ->
                                ph.exit()
                                pdeferred.resolve result
                            else
                              console.log U.format('{0} crawling: {1}', ['X'.bold, url]).red
                              ph.exit()
                              pdeferred.resolve()
                      pdeferred.promise
                    .then (result) ->
                      callback null, {url: url, html: result}
                    .fail (err) ->
                      if err instanceof Error
                        console.log err.message.red
                        console.log err.stack
                      else
                        console.log err.red
                      callback null
                    .done()
                  async.mapSeries urls, urlsfn, sdeferred.makeNodeResolver()
                else
                  sdeferred.resolve()
              else
                sdeferred.resolve()

            else
              sdeferred.reject(U.format('{0} Sitemap: {1}', ['X'.bold, url]).red)
            sdeferred.promise

          .then (results)->
            nconf.argv().env().file {file: config}
            storageName = nconf.get 'storage'
            storage = storageBase.get storageName
            storage.set result.url, result.html for result in results when result isnt null
            console.log U.format('{0} Data inserted in {1} storage', ['✓'.bold.magenta, storageName])
            callback null, sitemap

          .fail (err) ->
            if err instanceof Error
              console.log err.message.red
              console.log err.stack
            else
              console.log err.red
            callback null
          .done()

        async.eachSeries sitemaps, sitemapsfn, deferred.makeNodeResolver()
        deferred.promise

      .then ->
        nconf.argv().env().file {file: config}
        s = nconf.get 'storage'
        storageBase.get(s).close() if storageBase.get(s).close
        console.log 'Crawling finish.'.green
        console.log U.format('Time processing ({0}s).', [(new Date() - time)/ 1000])

      .fail (err) ->
        console.log err.message.red if err
        console.log err.stack
        process.exit 1
      .done()

exports.url = (program, messages, regexs) ->
  program
    .command 'crawle:url <url>'
    .description 'Load, parse url and add into storage engine'
    .option '-T, --test', 'Active test hook'
    .option '-C, --nocolors', 'Disable colors'
    .action (url, options) ->
      time = new Date()
      colors.mode = 'none' if options.nocolors
      console.log 'Init crawling.'.green
      config = path.resolve('./config/locale_test.json') if options.test

      if String(url).match regexs.url
        Q()
        .then ->
          deferred = Q.defer()
          console.log U.format 'Fetch URL: {0}...', [url]
          phantom.create '--load-images=no', '--local-to-remote-url-access=yes', (ph) ->
            ph.createPage (page) ->
              page.open url, (status) ->
                if status is 'success'
                  page.evaluate (-> document.getElementsByTagName('html')[0].innerHTML), (result) ->
                    ph.exit()
                    deferred.resolve result
                else
                  ph.exit()
                  deferred.reject(U.format('{0} crawling: {1}', ['X'.bold, url]))
          deferred.promise

        .then (html)->
          deferred = Q.defer()
          nconf.argv().env().file {file: config}
          storage = storageBase.get nconf.get 'storage'
          storage.set url, html, deferred.makeNodeResolver()
          deferred.promise

        .then ->
          nconf.argv().env().file {file: config}
          s = nconf.get 'storage'
          console.log U.format('{0} Data inserted in {1} storage', ['✓'.bold.magenta, s])
          storageBase.get(s).close() if storageBase.get(s).close
          console.log 'Crawling finish.'.green
          console.log U.format('Time processing ({0}s).', [(new Date() - time)/ 1000])

        .fail (err) ->
          if err instanceof Error
            console.log err.message.red
            console.log err.stack
          else
            console.log err.red
        .done()
      else
        console.log messages.url.red
        process.exit 1
