throttle = require "lodash.throttle"

module.exports =
  setCanvasRenderer: (canvasRenderer) ->
    @canvas = canvasRenderer

  enable:  ->
    @canvas.enable()

  disable: ->
    @canvas.destroy()

  onChangePane: (editor, editorElement) ->
    @canvas.resetCanvas()
    @canvas.setupCanvas editor, editorElement if editor

  onNewCursor: (cursor) ->
    cursor.spawn = throttle @canvas.spawn.bind(@canvas), 25, trailing: false

  onInput: (cursor, screenPosition, input, data) ->
    cursor.spawn cursor, screenPosition, input, data['size']
