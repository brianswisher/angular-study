express     = require 'express'
bodyParser  = require 'body-parser'
path        = require 'path'

env       = process.env.NODE_ENV || 'development'
port      = process.env.PORT || 8080
outputDir = "build/#{env}"

app = express()
app.use express.static(outputDir)
app.use bodyParser()
app.set 'views', 'app/views'
app.set 'view engine', 'jade'

if env is 'development'
  browserSync = require 'browser-sync'
  errorhandler = require 'errorhandler'

  app.use require('connect-browser-sync') browserSync.init [
      'assets/*.css'
      'assets/*.js'
    ], {
    proxy: "localhost:#{port}"
  }

  app.use errorhandler({ dumpExceptions: true, showStack: true })

  app.use noCache = (req, res, next) ->
    if req.url.indexOf '/scripts/' is 0
      res.header 'Cache-Control', 'no-cache, no-store, must-revalidate'
      res.header 'Pragma', 'no-cache'
      res.header 'Expires', 0
    next()

app.listen port
