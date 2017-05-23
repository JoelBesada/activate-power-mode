Api = require "./api"
ParticlesEffect = require "./effect/particles"
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
defaultEffect = require "./effect/default"
defaultFlow = require "./flow/default"
userFileFlow = require "./flow/user-file"
switcher = require "./switcher"

module.exports =
  comboRenderer: comboRenderer
  canvasRenderer: canvasRenderer
  switcher: switcher
  defaultEffect: defaultEffect
  defaultFlow: defaultFlow
  userFileFlow: userFileFlow
  editorRegistry: editorRegistry
  screenShaker: screenShaker
  audioPlayer: audioPlayer
  screenShake: screenShake
  playAudio: playAudio
  comboMode: comboMode
  powerCanvas: powerCanvas

  init: (config, pluginRegistry, flowRegistry, effectRegistry) ->
    @pluginRegistry = pluginRegistry
    @flowRegistry = flowRegistry
    @effectRegistry = effectRegistry
    @initApi()
    pluginRegistry.init config, @api
    @initCoreFlows()
    @initCoreEffects()
    @initCorePlugins()

  initApi: ->
    @comboRenderer.setPluginManager this
    @comboApi = new ComboApi(@comboRenderer)
    @canvasRenderer.setEffectRegistry @effectRegistry
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
    @flowRegistry.addFlow 'user-file', @userFileFlow

  initCoreEffects: ->
    effect = new ParticlesEffect(defaultEffect)
    @effectRegistry.setDefaultEffect effect

  enable: ->
    @pluginRegistry.enable @api
    @flowRegistry.enable()
    @effectRegistry.enable()

  disable: ->
    @screenShaker.disable()
    @audioPlayer.disable()
    @flowRegistry.disable()
    @effectRegistry.disable()

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
