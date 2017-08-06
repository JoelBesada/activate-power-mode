throttle = require "lodash.throttle"

module.exports =
  api: null

  setCanvasRenderer: (canvasRenderer) ->
    @canvas = canvasRenderer

  enable: (api) ->
    @api = api
    @canvas.enable(api)

  disable: ->
    @api = null
    @canvas.destroy()

  onChangePane: (editor, editorElement) ->
    @canvas.resetCanvas()
    @canvas.setupCanvas editor, editorElement if editor
    @canvas.getEffect().onChangePane?(editor, editorElement)

  onNewCursor: (cursor, screenPosition, input, data) ->
    cursor.spawn = throttle @canvas.spawn.bind(@canvas), 25, trailing: false
    @canvas.getEffect().onNewCursor?(cursor, screenPosition, input, data)

  onInput: (cursor, screenPosition, input, data) ->
    cursor.spawn cursor, screenPosition, input, data['size']
    @canvas.getEffect().onInput?(cursor, screenPosition, input, data)

  onComboStartStreak: ->
    @canvas.getEffect().onComboStartStreak?()

  onComboLevelChange: (newLvl, oldLvl) ->
    @canvas.getEffect().onComboLevelChange?(newLvl, oldLvl)

  onComboEndStreak: ->
    @canvas.getEffect().onComboEndStreak?()

  onComboExclamation: (text) ->
    @canvas.getEffect().onComboExclamation?(text)

  onComboMaxStreak: (maxStreak) ->
    @canvas.getEffect().onComboMaxStreak?(maxStreak)
