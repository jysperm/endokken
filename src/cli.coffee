fs = require 'fs'
path = require 'path'

donna = require 'donna'
tello = require 'tello'

ClassPage = require './class-page'
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
  constructor: ->
    @parseArguments()

  run: ->
    @generateMetadata()
    @generateDocumentation()

  buildDocsDirectory: ->
    fs.mkdirSync('./docs') unless fs.existsSync('./docs')

    staticPath = path.join(__dirname, '../static')
    for source in fs.readdirSync(staticPath)
      @copyFile(path.join(staticPath, source.toString()), './docs')

  copyFile: (source, dir) ->
    destination = path.join(dir, path.basename(source))
    fs.writeFileSync(destination, fs.readFileSync(source))

  generateDocumentation: ->
    @buildDocsDirectory()

    Resolver.setMetadata(@metadata)
    @renderClass(klass) for _, klass of @metadata.classes

  ###
  Section: Handling Metadata
  ###

  generateMetadata: ->
    rootPath = path.resolve('.')

    @metadata = tello.digest(donna.generateMetadata([rootPath]))
    @dumpMetadata() if @args.metadata

  dumpMetadata: ->
    switch @args.metadata
      when true then @writeMetadata('api.json')
      else @writeMetadata(@args.metadata)

  writeMetadata: (fileName) ->
    text = JSON.stringify(@metadata, null, 2)
    fs.writeFileSync(fileName, text)

  parseArguments: ->
    @args = require('yargs')
    @args = @args.options 'metadata',
              alias: 'm'
              default: false
              describe: 'Dump metadata to a file or api.json if no filename given'
    @args = @args.help('help').alias('help', '?')
    @args = @args.argv

  renderClass: (klass) ->
    doc = Template.render('layout', content: ClassPage.render(klass), title: 'Endokken')
    fs.writeFileSync("./docs/#{klass.name}.html", doc)

module.exports = Cli
