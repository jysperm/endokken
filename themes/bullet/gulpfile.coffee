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
flatten = require 'gulp-flatten'

PATHS = {
  scripts:
    src: 'source/*.coffee'
    dest: 'static/'
  styles:
    src: 'source/*.less'
    dest: 'static/'
  fonts:
    dest: 'static/'
}

gulp.task 'vendor', ->
  jsFilter = gulpFilter("**/*.js")
  cssFilter = gulpFilter(["**/*.scss","**/*.css"])
  fontFilter = gulpFilter(["**/*.eot","**/*.svg","**/*.ttf","**/*.woff"])
  otherFilter = gulpFilter(["**/*.swf", "!**/*.css", "!**/*.scss", "!**/*.js", "!**/*.eot","!**/*.svg","!**/*.ttf","!**/*.woff"])

  gulp.src bower()
    .pipe flatten()
    .pipe jsFilter

    .pipe gulp_concat 'vendor.js'
    .pipe minifyJs()
    .pipe gulp.dest PATHS.scripts.dest
    .pipe jsFilter.restore()

    .pipe cssFilter
    .pipe gulp_sass().on 'error', gulp_util.log
    .pipe gulp_concat 'vendor.css'
    .pipe minifyCSS()
    .pipe gulp.dest PATHS.styles.dest
    .pipe cssFilter.restore()

    .pipe fontFilter
    .pipe gulp.dest PATHS.fonts.dest
    .pipe fontFilter.restore()

gulp.task 'scripts', ->
  gulp.src PATHS.scripts.src
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe gulp_concat 'bullet.js'
    .pipe minifyJs()
    .pipe gulp.dest PATHS.scripts.dest

gulp.task 'styles', ->
  gulp.src PATHS.styles.src
    .pipe gulp_less().on 'error', gulp_util.log
    .pipe gulp_concat 'bullet.css'
    .pipe minifyCSS()
    .pipe gulp.dest PATHS.styles.dest

gulp.task 'watch', ->
  gulp.watch PATHS.scripts.src, ['scripts']
  gulp.watch PATHS.styles.src, ['styles']

gulp.task 'build', ['vendor', 'scripts', 'styles']
