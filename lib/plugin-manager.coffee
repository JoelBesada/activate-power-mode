Api = require "./api"
editorRegistry = require "./service/editor-registry"
screenShake = require "./plugin/screen-shake"
playAudio = require "./plugin/play-audio"
powerCanvas = require "./plugin/power-canvas"
comboMode = require "./plugin/combo-mode"

module.exports =
  editorRegistry: editorRegistry
  plugins: [comboMode, powerCanvas, screenShake, playAudio]

  enable: ->
    @api = new Api(@editorRegistry)
    for plugin in @plugins
      plugin.enable?(@api)

  disable: ->
    for plugin in @plugins
      plugin.disable?()

  runOnChangePane: (editor = null, editorElement = null) ->
    @editorRegistry.setEditor editor
    @editorRegistry.setEditorElement editorElement

    for plugin in @plugins
      plugin.onChangePane?(editor, editorElement)

  runOnNewCursor: (cursor) ->
    for plugin in @plugins
      plugin.onNewCursor?(cursor)

  runOnInput: (cursor) ->
    for plugin in @plugins
      plugin.onInput?(cursor)
