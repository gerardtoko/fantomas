fs = require 'fs'
nconf = require 'nconf'
path = require 'path'
colors = require 'colors'
Q = require 'Q'
request = require 'request'
U = require './../helpers/utils'
async = require 'async'
phantom = require 'phantom'
config = path.resolve './config/locale.json'
parser = require 'xml2json'


exports.crawleSitemap = (program, messages, regexs) ->
  program
    .command 'crawle:sitemap'
    .description 'Load, parse sitemaps and add into storage engine'
    .option '-T, --test', 'test hook'
    .action (options) ->

      time = new Date()

      Q()
      .then ->
        deferred = Q.defer()
        config = path.resolve('./config/locale_test.json') if options.test
        nconf.argv().env().file {file: config}
        sitemaps = nconf.get "sitemaps"

        sitemapsfn = []
        for sitemap in sitemaps
          ((sitemap) ->
            sitemapsfn.push (callback) ->
              console.log "Use sitemap {0}.".format([sitemap]).green
              homepage = nconf.get("homepage").trimRight "/"
              url = if not sitemap.match(regexs.homepage) then "{0}/{1}".format([homepage, sitemap]) else sitemap

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
                      console.log "Total URL: {0}".format([String(urls.length).green])
                      urlsfn = []
                      for url in urls
                        ((url) ->
                          urlsfn.push (callback) ->
                            Q()
                            .then ->
                              pdeferred = Q.defer()
                              console.log("{0}: {1}...".format(["Fetch URL".green, url]))
                              phantom.create '--load-images=no', '--local-to-remote-url-access=yes', (ph) ->
                                ph.createPage (page) ->
                                  page.open url, (status) ->
                                    if status is "success"
                                      page.evaluate (-> document.getElementsByTagName('html')[0].innerHTML), (result) ->
                                        ph.exit()
                                        pdeferred.resolve(result)
                                    else
                                      console.log "Error crawling: {0}".format([url]).red
                                      ph.exit()
                                      pdeferred.resolve()
                              pdeferred.promise
                            .then (result) ->
                              callback null, result
                            .fail (err) ->
                              if err instanceof Error
                                console.log err.message.red
                                console.log err.stack
                              else
                                console.log err.red
                              callback(null, null)
                            .done()
                        )(url.loc)

                      async.series urlsfn, sdeferred.makeNodeResolver()
                    else
                      sdeferred.resolve()
                  else
                    sdeferred.resolve()

                else
                  sdeferred.reject("Error loading sitemap: {0}".format([url]).red)
                sdeferred.promise

              .then (results)->
                callback(null, sitemap)

              .fail (err) ->
                if err instanceof Error
                  console.log err.message.red
                  console.log err.stack
                else
                  console.log err.red
              .done()
          )(sitemap)

        async.series sitemapsfn, deferred.makeNodeResolver()
        deferred.promise

      .then ->
        console.log "Crawling finish.".green
        console.log "Time processing ({0}s).".format([(new Date() - time)/ 1000]).green

      .fail (err) ->
        console.log err.message.red if err
        process.exit 1
      .done()