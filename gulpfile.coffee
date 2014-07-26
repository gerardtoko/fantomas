gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'

paths = [
  ["./src/*.coffee", "./"],
  ["./src/test/*.coffee", "./test"],
  ["./src/app/helpers/*.coffee", "./app/helpers"],
  ["./src/app/commands/*.coffee", "./app/commands"],
]

gulp.task "coffee", ->
  for path in paths
    gulp.src(path[0])
      .pipe(coffee({bare: true}).on("error", gutil.log))
      .pipe(gulp.dest(path[1]))


# Rerun the task when a file changes
gulp.task "watch", ->
  for path in paths
    gulp.watch path[0], ["coffee"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["coffee"]