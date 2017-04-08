Api = require "./api"
comboRenderer = require "./combo-renderer"
canvasRenderer = require "./canvas-renderer"
editorRegistry = require "./service/editor-registry"
ComboApi = require "./service/combo-api"
screenShaker = require "./service/screen-shaker"
audioPlayer = require "./service/audio-player"
screenShake = require "./plugin/screen-shake"
playAudio = require "./plugin/play-audio"
powerCanvas = require "./plugin/power-canvas"
comboMode = require "./plugin/combo-mode"
effect = require "./default-effect"

module.exports =
  comboRenderer: comboRenderer
  canvasRenderer: canvasRenderer
  effect: effect
  editorRegistry: editorRegistry
  screenShaker: screenShaker
  audioPlayer: audioPlayer
  comboMode: comboMode
  powerCanvas: powerCanvas
  plugins: [comboMode, powerCanvas, screenShake, playAudio]

  enable: ->
    @comboApi = new ComboApi(@comboRenderer)
    @comboMode.setComboRenderer @comboRenderer
    @canvasRenderer.setEffect @effect
    @powerCanvas.setCanvasRenderer @canvasRenderer
    @screenShaker.init()
    @audioPlayer.init()
    @api = new Api(@editorRegistry, @comboApi, @screenShaker, @audioPlayer)

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
