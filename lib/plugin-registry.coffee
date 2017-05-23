{CompositeDisposable} = require "atom"

module.exports =
  enabled: false
  subscriptions: null
  plugins: []
  corePlugins: []
  enabledPlugins: []

  init: (configSchema, api) ->
    @config = configSchema
    @api = api

  enable: ->
    @subscriptions = new CompositeDisposable
    @enabled = true

    for code, plugin of @corePlugins
      @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

    for code, plugin of @plugins
      key = "activate-power-mode.plugins.#{code}"
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

  disable: ->
    @enabled = false
    @subscriptions?.dispose()

  addCorePlugin: (code, plugin) ->
    @corePlugins[code] = plugin

  addPlugin: (code, plugin) ->
    key = "activate-power-mode.plugins.#{code}"
    @plugins[code] = plugin

    if @enabled
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

  addConfigForPlugin: (code, plugin, key) ->
    @config.plugins.properties[code] =
      type: 'boolean',
      title: plugin.title,
      description: plugin.description,
      default: true

    if atom.config.get(key) == undefined
      atom.config.set key, @config.plugins.properties[code].default

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

  onEnabled: (callback) ->
    for code, plugin of @enabledPlugins
      continue if callback code, plugin
