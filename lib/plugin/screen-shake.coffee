module.exports =
  enable: (api) ->
    @api = api

  onChangePane: (editor, editorElement) ->
    @editorElement = editorElement

  onInput: ->
    @api.shakeScreen @editorElement
