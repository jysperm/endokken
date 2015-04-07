gulp = require 'gulp'
gulp_if = require 'gulp-if'
gulp_util = require 'gulp-util'
gulp_concat = require 'gulp-concat'
gulp_coffee = require 'gulp-coffee'
gulp_less = require 'gulp-less'
gulp_sass = require 'gulp-sass'
minifyJs = require 'gulp-uglify'
minifyCSS = require 'gulp-minify-css'
gulp_runSequence = require 'run-sequence'
bower = require 'main-bower-files'
gulpFilter = require 'gulp-filter'

PATHS = {
  scripts:
    src: 'scripts/*.coffee'
    dest: 'statics/scripts/'
  styles:
    src: 'styles/*.less'
    dest: '../../docs/'
}

gulp.task "bower_js", ->
  jsFilter = gulpFilter("**/*.js")
  gulp.src bower()
    .pipe(jsFilter)
    .pipe gulp_concat 'vendor.js'
    .pipe minifyJs()
    .pipe gulp.dest PATHS.scripts.dest

gulp.task "bower_css", ->
  cssFilter = gulpFilter(["**/*.scss","**/*.css"])
  gulp.src bower()
    .pipe(cssFilter)
    .pipe gulp_sass().on 'error', gulp_util.log
    .pipe gulp_concat 'vendor.css'
    .pipe minifyCSS()
    .pipe gulp.dest PATHS.styles.dest

gulp.task 'scripts', ->
  gulp.src PATHS.scripts.src
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat 'app.js'
    .pipe minifyJs()
    .pipe gulp.dest PATHS.scripts.dest

gulp.task 'styles', ->
  gulp.src PATHS.styles.src
    .pipe gulp_less().on 'error', gulp_util.log
    .pipe gulp_concat 'app.css'
    .pipe minifyCSS()
    .pipe gulp.dest PATHS.styles.dest

gulp.task 'watch', ->
  gulp.watch PATHS.scripts.src, ['scripts']
  gulp.watch PATHS.styles.src, ['styles']

gulp.task 'build', ['bower_js', 'bower_css', 'scripts', 'styles']

gulp.task 'default', (cb) ->
  gulp_runSequence 'build', 'watch', cb
  