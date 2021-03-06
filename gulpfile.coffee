gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'

paths = [
  ["./src/*.coffee", "./"]
  ["./src/test/*.coffee", "./test"]
  ["./src/app/helpers/*.coffee", "./app/helpers"]
  ["./src/app/commands/*.coffee", "./app/commands"]
  ["./src/app/storages/*.coffee", "./app/storages"]
  ["./src/app/routes/*.coffee", "./app/routes"]
  ["./src/bin/*.coffee", "./bin"]
]

gulp.task "coffee", ->
  errFn = (err)->
    console.log err.toString()
    gulp.src err.filename
      .pipe notify err.toString()

  for path in paths
    gulp.src(path[0])
      .pipe(coffee({bare: true}).on('error', errFn))
      .pipe(gulp.dest(path[1]))


# Rerun the task when a file changes
gulp.task "watch", ->
  for path in paths
    gulp.watch path[0], ["coffee"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["coffee"]