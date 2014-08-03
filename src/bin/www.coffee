#!/usr/bin/env node
cluster = require 'cluster'
app = require '../config/app'
nconf = require 'nconf'
config = path.resolve '../config/locale.json'

nconf.argv().env().file {file: config}
app.set 'port', nconf.get 'port'

server = app.listen app.get 'port' , ->
	console.log "Fantomas listening on port", app.get 'port'