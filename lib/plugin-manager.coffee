screenShake = require "./screen-shake"
playAudio = require "./play-audio"
powerCanvas = require "./power-canvas"
comboMode = require "./combo-mode"

module.exports =
  plugins: [comboMode, powerCanvas, screenShake, playAudio]

  enable: ->
    for plugin in @plugins
      plugin.enable?()

  disable: ->
    for plugin in @plugins
      plugin.disable?()

  runOnChangePane: (editor = null, editorElement = null) ->
    for plugin in @plugins
      plugin.onChangePane?(editor, editorElement)

  runOnNewCursor: (cursor) ->
    for plugin in @plugins
      plugin.onNewCursor?(cursor)

  runOnInput: (editor, editorElement, cursor) ->
    for plugin in @plugins
      plugin.onInput?(editor, editorElement, cursor)
