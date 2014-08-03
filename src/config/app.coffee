express = require 'express'
path = require 'path'
favicon = require 'static-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'

routes = require '../app/routes/index'

app = express()

app.use favicon()
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()
app.use express.static(path.join(__dirname, 'public'))

app.use '/', routes

app.use (req, res, next) ->
  var err = new Error('Not Found');
  err.status = 404;
  next(err);

if app.get('env') is 'development'
  app.use (err, req, res, next) ->
    res.status err.status || 500
    res.render 'error', {
        message: err.message
        error: err
    }

app.use function(err, req, res, next) ->
  res.status err.status || 500
  res.render 'error', {
      message: err.message
      error: {}
  }

module.exports = app;
