Api = require "./api"
editorRegistry = require "./service/editor-registry"
screenShaker = require "./service/screen-shaker"
audioPlayer = require "./service/audio-player"
screenShake = require "./plugin/screen-shake"
playAudio = require "./plugin/play-audio"
powerCanvas = require "./plugin/power-canvas"
comboMode = require "./plugin/combo-mode"

module.exports =
  editorRegistry: editorRegistry
  screenShaker: screenShaker
  audioPlayer: audioPlayer
  plugins: [comboMode, powerCanvas, screenShake, playAudio]

  enable: ->
    @screenShaker.init()
    @audioPlayer.init()
    @api = new Api(@editorRegistry, @screenShaker, @audioPlayer)

    for plugin in @plugins
      plugin.enable?(@api)

  disable: ->
    @screenShaker.disable()
    @audioPlayer.disable()

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

  runOnInput: (cursor, screenPosition) ->
    for plugin in @plugins
      plugin.onInput?(cursor, screenPosition)
