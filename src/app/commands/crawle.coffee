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


exports.crawleSitemap = (program, messages, regexs) ->
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
      nconf.argv().env().file {file: config}

      Q()
      .then ->
        deferred = Q.defer()
        sitemaps = nconf.get 'sitemaps'

        sitemapsfn = []
        for sitemap in sitemaps
          ((sitemap) ->
            sitemapsfn.push (callback) ->
              console.log U.format('{0} Use {1}', ['->'.bold.green, sitemap])
              homepage = _.str.rtrim nconf.get('homepage'), '/'
              url = if not sitemap.match(regexs.homepage) then U.format('{0}/{1}', [homepage, sitemap]) else sitemap

              Q()
              .then ->
                sdeferred = Q.defer()
                request url, sdeferred.makeNodeResolver()
                sdeferred.promise

              .then (data) ->
                sdeferred = Q.defer()
                if data[0].statusCode is 200
                  json = JSON.parse(parser.toJson(data[1]))

                  if json.urlset
                    if json.urlset.url
                      urls = json.urlset.url
                      console.log 'Total URL: #{urls.length}'
                      urlsfn = []

                      # urls = [urls[0]]
                      # urls[0].loc = 'https://www.google.com'
                      for url in urls
                        ((url) ->
                          urlsfn.push (callback) ->
                            Q()
                            .then ->
                              pdeferred = Q.defer()
                              console.log 'Fetch URL: #{url}...'
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
                        )(url.loc)

                      async.series urlsfn, sdeferred.makeNodeResolver()
                    else
                      sdeferred.resolve()
                  else
                    sdeferred.resolve()

                else
                  sdeferred.reject(U.format('{0} Sitemap: {1}', ['X'.bold, url]).red)
                sdeferred.promise

              .then (results)->
                storage = storageBase.get nconf.get 'storage'
                storage.set result.url, result.html for result in results when result isnt null
                console.log U.format('{0} Data inserted in storage', ['✓'.bold.magenta])
                callback null, sitemap

              .fail (err) ->
                if err instanceof Error
                  console.log err.message.red
                  console.log err.stack
                else
                  console.log err.red
                callback null
              .done()
          )(sitemap)

        async.series sitemapsfn, deferred.makeNodeResolver()
        deferred.promise

      .then ->
        s = nconf.get 'storage'
        storageBase.get(s).close() if storageBase.get(s).close
        console.log 'Crawling finish.'.green
        console.log U.format('Time processing ({0}s).', [(new Date() - time)/ 1000])

      .fail (err) ->
        console.log err.message.red if err
        process.exit 1
      .done()