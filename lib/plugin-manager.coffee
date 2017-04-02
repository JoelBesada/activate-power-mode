api = require "./api"
screenShake = require "./plugin/screen-shake"
playAudio = require "./plugin/play-audio"
powerCanvas = require "./plugin/power-canvas"
comboMode = require "./plugin/combo-mode"

module.exports =
  api: api
  plugins: [comboMode, powerCanvas, screenShake, playAudio]

  enable: ->
    @api.init()
    for plugin in @plugins
      plugin.enable?(@api)

  disable: ->
    for plugin in @plugins
      plugin.disable?()

  runOnChangePane: (editor = null, editorElement = null) ->
    for plugin in @plugins
      plugin.onChangePane?(editor, editorElement)

  runOnNewCursor: (cursor) ->
    for plugin in @plugins
      plugin.onNewCursor?(cursor)

  runOnInput: (cursor) ->
    for plugin in @plugins
      plugin.onInput?(editor, editorElement, cursor)
