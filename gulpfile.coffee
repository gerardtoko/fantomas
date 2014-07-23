gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'

paths = [
	"./src/*.coffee"
]

gulp.task "coffee", ->
	gulp.src("./src/*.coffee")
	  .pipe(coffee({bare: true}).on("error", gutil.log))
	  .pipe(gulp.dest("./"))


# Rerun the task when a file changes
gulp.task "watch", ->
  gulp.watch(paths, ["coffee"])

# The default task (called when you run `gulp` from cli)
gulp.task("default", ["coffee"]);