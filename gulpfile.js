/*global -$ */
'use strict';
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var browserSync = require('browser-sync');
var reload = browserSync.reload;
var modRewrite = require('connect-modrewrite');

var nodeEnv = process.env.NODE_ENV || "development";

gulp.task('styles', function () {
  return gulp.src('app/styles/main.sass')
    .pipe($.sourcemaps.init())
    .pipe($.sass({
      outputStyle: 'nested', // libsass doesn't support expanded yet
      precision: 10,
      includePaths: ['.'],
      indentedSyntax: true,
      onError: console.error.bind(console, 'Sass error:')
    }))
    .pipe($.postcss([
      require('autoprefixer-core')({browsers: ['last 1 version']})
    ]))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('.tmp/styles'))
    .pipe(reload({stream: true}));
});

gulp.task('scripts', function () {
  return gulp.src('app/scripts/**/*.coffee')
    .pipe($.coffee())
    .pipe($.ngAnnotate())
    .pipe(gulp.dest('.tmp/scripts'));
});

gulp.task('jshint', function () {
  return gulp.src('app/scripts/**/*.js')
    .pipe(reload({stream: true, once: true}))
    .pipe($.jshint())
    .pipe($.jshint.reporter('jshint-stylish'))
    .pipe($.if(!browserSync.active, $.jshint.reporter('fail')));
});

gulp.task('html', ['injector:js', 'styles', 'scripts', 'templates'], function () {
  var assets = $.useref.assets({searchPath: ['.tmp', 'app', '.']});

  return gulp.src('.tmp/*.html')
    .pipe(assets)
    .pipe($.if('*.js', $.uglify()))
    .pipe($.if('*.css', $.csso()))
    .pipe(assets.restore())
    .pipe($.useref())
    .pipe($.if('*.html', $.minifyHtml({conditionals: true, loose: true})))
    .pipe(gulp.dest('dist'));
});

gulp.task('images', function () {
  return gulp.src('app/images/**/*')
    .pipe($.cache($.imagemin({
      progressive: true,
      interlaced: true,
      // don't remove IDs from SVGs, they are often used
      // as hooks for embedding and styling
      svgoPlugins: [{cleanupIDs: false}]
    })))
    .pipe(gulp.dest('dist/images'));
});

gulp.task('fonts', function () {
  return gulp.src(require('main-bower-files')({
    filter: '**/*.{eot,svg,ttf,woff,woff2}'
  }).concat('app/fonts/**/*'))
    .pipe(gulp.dest('.tmp/fonts'))
    .pipe(gulp.dest('dist/fonts'));
});

gulp.task('extras', function () {
  return gulp.src([
    'app/*.*',
    '!app/*.html',
  ], {
    dot: true
  }).pipe(gulp.dest('dist'));
});

gulp.task('ngconfig', function(){
	return gulp.src(['app/config/' + nodeEnv + '.json'])
		.pipe($.ngConfig("env"))
		.pipe(gulp.dest(".tmp/scripts"));
});

gulp.task('injector:js', ['ngconfig'], function(){
	return gulp.src(['app/index.html'])
		.pipe($.inject(
			gulp.src(['.tmp/scripts/' + nodeEnv + '.js']),
			{ignorePath: ['src', '.tmp'], addRootSlash: false}
		))
		.pipe(gulp.dest(".tmp"))
});

gulp.task('templates', function(){
  return gulp.src('app/scripts/**/*.html')
    .pipe($.angularTemplatecache("templates.js", {module: "app"}))
    .pipe(gulp.dest(".tmp/scripts"))
});

gulp.task('deploy', ['build'], function(){
  return gulp.src('dist/**/*')
    .pipe($.ghPages());
});

gulp.task('clean', require('del').bind(null, ['.tmp', 'dist']));

gulp.task('serve', ['styles', 'scripts', 'injector:js', 'templates', 'fonts'], function () {
  browserSync({
    notify: false,
    port: 9000,
    server: {
      baseDir: ['.tmp', 'app'],
      routes: {
        '/bower_components': 'bower_components'
      },
      middleware: [
        modRewrite([
          '!\\.\\w+$ /index.html [L]' 
        ])
      ]
    }
  });

  // watch for changes
  gulp.watch([
    '.tmp/*.html',
    'app/scripts/**/*.js',
    '.tmp/scripts/**/*.js',
    'app/images/**/*',
    '.tmp/fonts/**/*'
  ]).on('change', reload);

  gulp.watch('app/styles/**/*.css', ['styles']);
  gulp.watch('app/scripts/**/*.html', ['templates']);
  gulp.watch('app/scripts/**/*.coffee', ['scripts']);
  gulp.watch('app/index.html', ['injector:js']);
  gulp.watch('app/config/*.json', ['injector:js']);
  gulp.watch('app/fonts/**/*', ['fonts']);
  gulp.watch('bower.json', ['wiredep', 'fonts']);
});

// inject bower components
gulp.task('wiredep', function () {
  var wiredep = require('wiredep').stream;

  gulp.src('app/*.html')
    .pipe(wiredep({
      ignorePath: /^(\.\.\/)*\.\./
    }))
    .pipe(gulp.dest('app'));
});

gulp.task('build', ['jshint', 'html', 'images', 'fonts', 'extras'], function () {
  return gulp.src('dist/**/*').pipe($.size({title: 'build', gzip: true}));
});

gulp.task('default', ['clean'], function () {
  gulp.start('build');
});
