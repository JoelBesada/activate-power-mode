{CompositeDisposable} = require "atom"
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
  subscriptions: null
  comboRenderer: comboRenderer
  canvasRenderer: canvasRenderer
  effect: effect
  editorRegistry: editorRegistry
  screenShaker: screenShaker
  audioPlayer: audioPlayer
  screenShake: screenShake
  playAudio: playAudio
  comboMode: comboMode
  powerCanvas: powerCanvas
  plugins: []
  corePlugins: []
  enabledPlugins: []

  enable: ->
    @subscriptions = new CompositeDisposable
    @initApi()
    @initCorePlugins()

  setConfigSchema: (configSchema) ->
    @config = configSchema

  initApi: ->
    @comboApi = new ComboApi(@comboRenderer)
    @canvasRenderer.setEffect @effect
    @screenShaker.init()
    @audioPlayer.init()
    @api = new Api(@editorRegistry, @comboApi, @screenShaker, @audioPlayer)

  initCorePlugins: ->
    @comboMode.setComboRenderer @comboRenderer
    @powerCanvas.setCanvasRenderer @canvasRenderer
    @addCorePlugin @powerCanvas, 'particles'
    @addCorePlugin @comboMode, 'comboMode'
    @addPlugin @screenShake, 'screenShake'
    @addPlugin @playAudio, 'playAudio'

  addCorePlugin: (plugin, code) ->
    @plugins.push plugin
    @corePlugins.push plugin
    @observePlugin plugin, "activate-power-mode.#{code}.enabled"

  addPlugin: (plugin, code) ->
    info = plugin.info

    key = "activate-power-mode.plugins.#{code}"
    @plugins.push plugin
    @config.plugins.properties[code] =
      type: 'boolean',
      title: info.title,
      description: info.description,
      default: true

    if atom.config.get == undefined
      atom.config.set key, @config.plugins.properties[code].default

    @observePlugin plugin, key

  observePlugin: (plugin, key) ->
    @subscriptions.add atom.config.observe(
      key, (isEnabled) =>
        if isEnabled
          @enabledPlugins.push plugin
          plugin.enable?(@api)
        else
          index = @enabledPlugins.indexOf(plugin)
          if index >= 0
            @enabledPlugins.splice(index, 1)
            plugin.disable?()
    )

  disable: ->
    @subscriptions.dispose()
    @screenShaker.disable()
    @audioPlayer.disable()

    for plugin in @enabledPlugins
      plugin.disable?()

  runOnChangePane: (editor = null, editorElement = null) ->
    @editorRegistry.setEditor editor
    @editorRegistry.setEditorElement editorElement

    for plugin in @enabledPlugins
      plugin.onChangePane?(editor, editorElement)

  runOnNewCursor: (cursor) ->
    for plugin in @enabledPlugins
      plugin.onNewCursor?(cursor)

  runOnInput: (cursor, screenPosition) ->
    for plugin in @enabledPlugins
      plugin.onInput?(cursor, screenPosition)
