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
effect = require "./effect/default"
defaultFlow = require "./flow/default"
switcher = require "./switcher"

module.exports =
  comboRenderer: comboRenderer
  canvasRenderer: canvasRenderer
  effect: effect
  switcher: switcher
  defaultFlow: defaultFlow
  editorRegistry: editorRegistry
  screenShaker: screenShaker
  audioPlayer: audioPlayer
  screenShake: screenShake
  playAudio: playAudio
  comboMode: comboMode
  powerCanvas: powerCanvas

  init: (config, pluginRegistry, flowRegistry) ->
    @pluginRegistry = pluginRegistry
    @flowRegistry = flowRegistry
    @initApi()
    pluginRegistry.init config, @api
    @initCorePlugins()
    @initCoreFlows()

  initApi: ->
    @comboRenderer.setPluginManager this
    @comboApi = new ComboApi(@comboRenderer)
    @canvasRenderer.setEffect @effect
    @screenShaker.init()
    @audioPlayer.init()
    @api = new Api(@editorRegistry, @comboApi, @screenShaker, @audioPlayer)

  initCorePlugins: ->
    @comboMode.setComboRenderer @comboRenderer
    @powerCanvas.setCanvasRenderer @canvasRenderer
    @pluginRegistry.addCorePlugin 'particles', @powerCanvas
    @pluginRegistry.addCorePlugin 'comboMode', @comboMode
    @pluginRegistry.addPlugin 'screenShake', @screenShake
    @pluginRegistry.addPlugin 'playAudio', @playAudio

  initCoreFlows: ->
    @flowRegistry.setDefaultFlow @defaultFlow

  enable: ->
    @pluginRegistry.enable @api
    @flowRegistry.enable()

  disable: ->
    @screenShaker.disable()
    @audioPlayer.disable()
    @flowRegistry.disable()

    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.disable?()
    )
    @pluginRegistry.disable()

  runOnChangePane: (editor = null, editorElement = null) ->
    @editorRegistry.setEditor editor
    @editorRegistry.setEditorElement editorElement

    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onChangePane?(editor, editorElement)
    )

  runOnNewCursor: (cursor) ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onNewCursor?(cursor)
    )

  runOnInput: (cursor, screenPosition, input) ->
    @switcher.reset()
    @flowRegistry.flow.handle input, @switcher, @comboApi.getLevel()

    @pluginRegistry.onEnabled(
      (code, plugin) =>
        return true if @switcher.isOff code
        plugin.onInput?(cursor, screenPosition, input, @switcher.getData code)
    )

  runOnComboStartStreak: ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onComboStartStreak?()
    )

  runOnComboLevelChange: (newLvl, oldLvl) ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onComboLevelChange?(newLvl, oldLvl)
    )

  runOnComboEndStreak: ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onComboEndStreak?()
    )

  runOnComboExclamation: (text) ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onComboExclamation?(text)
    )

  runOnComboMaxStreak: (maxStreak) ->
    @pluginRegistry.onEnabled(
      (code, plugin) -> plugin.onComboMaxStreak?(maxStreak)
    )
