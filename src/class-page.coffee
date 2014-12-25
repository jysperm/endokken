marked = require 'marked'

Template = require './template'

# Public: Renders a page for a class.
module.exports =
class ClassPage extends Template
  constructor: (@object) ->
    locals = @object
    locals.classMethodDetailsSection = @classMethodDetailsSection()
    locals.classMethodSummarySection = @classMethodSummarySection()
    locals.descriptionSection = @descriptionSection()
    locals.instanceMethodDetailsSection = @instanceMethodDetailsSection()
    locals.instanceMethodSummarySection = @instanceMethodSummarySection()

    @title = @object.name

    super('class-page', locals)

  classMethodDetailsSection: ->

  classMethodSummarySection: ->

  descriptionSection: ->
    if @object.description
      new Template('description-section', description: marked(@object.description)).render()

  instanceMethodDetails: (method) ->
    method.signature = @signature(method)
    method.parameterBlock = if method.arguments then @parameterBlock(method) else ''
    method.returnValueBlock = if method.returnValues then @returnValueBlock(method) else ''
    new Template('instance-method-details', method).render()

  instanceMethodDetailsSection: ->
    methods = (@instanceMethodDetails(method) for method in @object.instanceMethods)
    if methods?.length > 0
      new Template('instance-method-detail-section', content: methods.join('\n')).render()

  instanceMethodSummary: (method) ->
    method.signature = @signature(method)
    new Template('instance-method-summary', method).render()

  instanceMethodSummarySection: ->
    methods = (@instanceMethodSummary(method) for method in @object.instanceMethods)
    if methods?.length > 0
      new Template('instance-method-summary-section', content: methods.join('\n')).render()

  signature: (method) ->
    parameters = if method.arguments then @parameters(method) else ''
    returnValues = if method.returnValues then @returnValues(method) else ''
    "#{method.name}(#{parameters})#{returnValues}"

  parameterBlock: (method) ->
    rows = (@parameterRow(parameter) for parameter in method.arguments)
    new Template('parameter-block-table', rows: rows.join('\n')).render()

  parameterRow: (parameter) ->
    new Template('parameter-block-row', parameter).render()

  returnValueBlock: (method) ->

  parameters: (method) ->
    names = (name for {name} in method.arguments)
    names.join(', ')

  returnValues: (method) ->
    types = (type for {type} in method.returnValues)
    if types.length is 1
      " &rArr; #{types[0]}"
    else
      " &rArr; [#{types.join(', ')}]"
