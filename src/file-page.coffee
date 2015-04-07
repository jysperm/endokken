fs = require 'fs'
path = require 'path'

module.exports = (Template) ->
  # Public: Used to render a documentation file like `README.md`.
  return class FilePage extends Template
    ###
    Section: Simplified Interface

    Used to simply render the content in one step.
    ###

    # Public: Renders the file stored at `filePath`.
    #
    # * `filePath` {String} containing the path to the file to be rendered.
    #
    # Returns a {String} containing the rendered content.
    @render: (filePath) ->
      new this(filePath).render()

    ###
    Section: Customizable Interface
    ###

    # Public: Constructs a new `FilePage` for the `filePath`.
    #
    # * `filePath` {String} containing the path to the file to be rendered.
    constructor: (@filePath) ->

    # Public: Renders the file.
    #
    # Returns a {String} containing the rendered content.
    render: ->
      console.log("File: #{path.basename(@filePath, path.extname(@filePath))}")
      @markdownify(fs.readFileSync(@filePath).toString())
