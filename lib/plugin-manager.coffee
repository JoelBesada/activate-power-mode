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
effect = require "./effect/default"
flow = require "./flow/default"
switcher = require "./switcher"

module.exports =
  subscriptions: null
  comboRenderer: comboRenderer
  canvasRenderer: canvasRenderer
  effect: effect
  switcher: switcher
  flow: flow
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
    @comboRenderer.setPluginManager this
    @comboApi = new ComboApi(@comboRenderer)
    @canvasRenderer.setEffect @effect
    @screenShaker.init()
    @audioPlayer.init()
    @api = new Api(@editorRegistry, @comboApi, @screenShaker, @audioPlayer)

  initCorePlugins: ->
    @comboMode.setComboRenderer @comboRenderer
    @powerCanvas.setCanvasRenderer @canvasRenderer
    @addCorePlugin 'particles', @powerCanvas
    @addCorePlugin 'comboMode', @comboMode
    @addPlugin 'screenShake', @screenShake
    @addPlugin 'playAudio', @playAudio

  addCorePlugin: (code, plugin) ->
    @plugins[code] = plugin
    @corePlugins[code] = plugin
    @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

  addPlugin: (code, plugin) ->
    info = plugin.info

    key = "activate-power-mode.plugins.#{code}"
    @plugins[code] = plugin
    @config.plugins.properties[code] =
      type: 'boolean',
      title: info.title,
      description: info.description,
      default: true

    if atom.config.get(key) == undefined
      atom.config.set key, @config.plugins.properties[code].default

    @observePlugin code, plugin, key

  observePlugin: (code, plugin, key) ->
    @subscriptions.add atom.config.observe(
      key, (isEnabled) =>
        if isEnabled
          plugin.enable?(@api)
          @enabledPlugins[code] = plugin
        else
          plugin.disable?()
          delete @enabledPlugins[code]
    )

  disable: ->
    @subscriptions.dispose()
    @screenShaker.disable()
    @audioPlayer.disable()

    for code, plugin of @enabledPlugins
      plugin.disable?()

  runOnChangePane: (editor = null, editorElement = null) ->
    @editorRegistry.setEditor editor
    @editorRegistry.setEditorElement editorElement

    for code, plugin of @enabledPlugins
      plugin.onChangePane?(editor, editorElement)

  runOnNewCursor: (cursor) ->
    for code, plugin of @enabledPlugins
      plugin.onNewCursor?(cursor)

  runOnInput: (cursor, screenPosition, input) ->
    @switcher.reset()
    @flow.handle input, @switcher, @comboApi.getLevel()

    for code, plugin of @enabledPlugins
      continue if @switcher.isOff code
      plugin.onInput?(cursor, screenPosition, input, @switcher.getData code)

  runOnComboStartStreak: ->
    for code, plugin of @enabledPlugins
      plugin.onComboStartStreak?()

  runOnComboLevelChange: (newLvl, oldLvl) ->
    for code, plugin of @enabledPlugins
      plugin.onComboLevelChange?(newLvl, oldLvl)

  runOnComboEndStreak: ->
    for code, plugin of @enabledPlugins
      plugin.onComboEndStreak?()

  runOnComboExclamation: (text) ->
    for code, plugin of @enabledPlugins
      plugin.onComboExclamation?(text)

  runOnComboMaxStreak: (maxStreak) ->
    for code, plugin of @enabledPlugins
      plugin.onComboMaxStreak?(maxStreak)
