fs = require 'fs'
path = require 'path'

donna = require 'donna'
tello = require 'tello'

Resolver = require './resolver'
Template = require './template'

# Public: Used to provide the command-line interface for the tool.
#
# ## Examples
#
# ```coffee
# cli = new Cli
# cli.run()
# ```
class Cli
  # Public: Parses the command-line arguments.
  constructor: ->
    packagePath = path.join(path.dirname(__dirname), 'package.json')
    packageInfo = JSON.parse(fs.readFileSync(packagePath).toString())
    @version = packageInfo.version
    @parseArguments()

    @Template = Template.fromTheme @args.theme
    @ClassPage = require('./class-page') @Template
    @FilePage = require('./file-page') @Template

  # Public: Executes the program.
  run: ->
    @generateMetadata()
    @generateDocumentation()

  parseArguments: ->
    @args = require('yargs')
    @args = @args.options 'extension',
              alias: 'e'
              default: ''
              describe: 'File extension to give to generated documentation files'
    @args = @args.options 'metadata',
              alias: 'm'
              default: false
              describe: 'Dump metadata to a file or api.json if no filename given'
    @args = @args.options 'title',
              default: path.basename process.cwd()
              describe: 'Title for index page'
    @args = @args.options 'theme',
              default: 'default'
    @args = @args.options 'dest',
              default: './docs'
    @args = @args.help('help').alias('help', '?')
    @args = @args.argv

  ###
  Section: Helpers
  ###

  # Public: Gets the path to the directory where documentation should be stored.
  #
  # * `subpath` (optional) {String} to join to the docs directory.
  # * `extension` (optional) {String} to append as a file extension to the generated path.
  #
  # Returns a {String} containing the absolute path to the documentation directory with optional
  #   subpath.
  docsDirectory: (subpath, extension) ->
    @docsDir ?= path.resolve @args.dest
    if subpath
      subpath = subpath + @normalizeExtension(extension) if extension
      path.join(@docsDir, subpath)
    else
      @docsDir

  normalizeExtension: (extension) ->
    extension = ".#{extension}" unless extension.match(/^\./)
    extension

  # Public: Gets the path to the root Endokken code directory.
  #
  # * `subpath` (optional) {String} to join to the source directory.
  #
  # Returns a {String} containing the absolute path to the root Endokken code directory with
  #   optional subpath.
  sourceDirectory: (subpath) ->
    @sourceDir ?= path.dirname(path.resolve(__dirname))
    if subpath
      path.join(@sourceDir, subpath)
    else
      @sourceDir

  ###
  Section: Metadata
  ###

  generateMetadata: ->
    rootPath = path.resolve('.')

    @metadata = donna.generateMetadata([rootPath])
    @digestedMetadata = tello.digest(@metadata)
    @dumpMetadata() if @args.metadata

  dumpMetadata: ->
    switch @args.metadata
      when true then @writeMetadata('api.json', @digestedMetadata)
      else @writeMetadata(@args.metadata, @digestedMetadata)

  writeMetadata: (fileName, metadata) ->
    text = JSON.stringify(metadata, null, 2)
    fs.writeFileSync(fileName, text)

  ###
  Section: Documentation
  ###

  buildDocsDirectory: ->
    fs.mkdirSync(@docsDirectory()) unless fs.existsSync(@docsDirectory())

    staticPath = @sourceDirectory("themes/#{@args.theme}/static")
    for source in fs.readdirSync(staticPath)
      @copyFile(path.join(staticPath, source.toString()), @docsDirectory())

  copyFile: (source, dir) ->
    destination = path.join(dir, path.basename(source))
    fs.writeFileSync(destination, fs.readFileSync(source))

  generateDocumentation: ->
    @buildDocsDirectory()

    Resolver.setMetadata(@digestedMetadata)
    @getNavItems(@digestedMetadata)
    @renderClass(klass) for _, klass of @digestedMetadata.classes
    @renderFile(file) for file in @docFiles()

  docFiles: ->
    (file for file in fs.readdirSync('.') when file.match(/\.md$/))

  getNavClasses: (metadata) ->
    navItems = (name for name, _ of metadata.classes)
    items = (@Template.render('nav-item', name: item, url: item) for item in navItems).join('\n')
    @Template.render('navigation', title: 'Classes', items: items)

  getNavFiles: (pathName) ->
    files = (path.basename(file, path.extname(file)) for file in @docFiles())
    items = (@Template.render('nav-item', name: file, url: file) for file in files).join('\n')
    @Template.render('navigation', title: 'Files', items: items)

  getNavItems: (metadata) ->
    classes = @getNavClasses(metadata)
    files = @getNavFiles('.')
    @navigation = "#{classes}\n#{files}"

  render: (content, filePath) ->
    doc = @Template.render 'layout',
                          content: content
                          title: @args.title
                          navigation: @navigation
                          version: @version
    fs.writeFileSync(filePath, doc)

  renderFile: (file) ->
    @render(@FilePage.render(file), @docsDirectory(path.basename(file, path.extname(file)), @args.extension))

  renderClass: (klass) ->
    @render(@ClassPage.render(klass), @docsDirectory(klass.name, @args.extension))

module.exports = Cli
