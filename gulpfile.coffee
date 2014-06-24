gulp        = require 'gulp'
jade        = require 'gulp-jade'
coffeelint  = require 'gulp-coffeelint'
browserify  = require 'gulp-browserify'
rename      = require 'gulp-rename'
uglify      = require 'gulp-uglify'
sass        = require 'gulp-sass'
open        = require 'gulp-open'
gulpif      = require 'gulp-if'
browserSync = require 'browser-sync'

env       = process.env.NODE_ENV || 'development'
port      = process.env.PORT || 8080
outputDir = "build/#{env}"

gulp.task 'lint', ->
  gulp.src [
    './**/*.coffee'
    '!./node_modules/**'
  ]
  .pipe( coffeelint() )
  .pipe( coffeelint.reporter() )

gulp.task 'coffee', ->
  gulp.src [
    'app/assets/scripts/**/*.coffee'
    '!app/assets/scripts/**/*_module.coffee'
    '!app/assets/scripts/**/modules/*.coffee'
    '!app/assets/scripts/**/_*.coffee'
  ], { read: false }
  .pipe(browserify({
    debug: env is 'development'
    transform: ['coffeeify']
    extensions: ['.coffee']
  }))
  .pipe( rename {extname: ".js"} )
  .pipe( gulpif( env is 'production', uglify() ))
  .pipe( gulp.dest "#{outputDir}/assets" )
  .pipe( gulpif( env is 'development', browserSync.reload {stream:true} ))

gulp.task 'jade', ->
  gulp.src [
    'app/templates/**/*.jade'
    '!app/templates/**/_*.jade'
    '!app/templates/**/partials/*.jade'
  ]
  .pipe( jade() )
  .pipe( gulp.dest outputDir )
  .pipe( gulpif( env is 'development', browserSync.reload {stream:true} ))

gulp.task 'sass', ->
  config                = {}
  config.sourceMap      = 'scss' if env is 'development'
  config.sourceComments = 'map' if env is 'development'
  config.outputStyle    = 'compressed' if env is 'production'
  config.includePaths   = require('node-bourbon').includePaths

  gulp.src [
    'app/assets/stylesheets/**/*.scss'
    '!app/assets/stylesheets/**/_*.scss'
    '!app/assets/stylesheets/**/partials/*.scss'
  ]
  .pipe( sass config )
  .pipe( gulp.dest "#{outputDir}/assets" )
  .pipe( gulpif( env is 'development', browserSync.reload {stream:true} ))

gulp.task 'watch', ->
  gulp.watch 'app/**/*.jade', ['jade']
  gulp.watch 'app/assets/scripts/**/*.coffee', [
    'lint'
    'coffee'
  ]
  gulp.watch 'app/assets/stylesheets/**/*.scss', ['sass']

gulp.task 'browser-sync', ->
  browserSync.init ["assets/*.css", "assets/*.js"], {
    server: {
      baseDir: outputDir
    }
  }

gulp.task 'open', ->
  gulp.src("#{outputDir}/index.html")
  .pipe( open '', {url: "http://0.0.0.0:#{port}"} )

gulp.task 'default', [
  'lint'
  'coffee'
  'jade'
  'sass'
], ->
  require './server'
  if env is 'development'
    gulp.start 'watch'
