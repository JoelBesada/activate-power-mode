{CompositeDisposable} = require "atom"

module.exports =
  enabled: false
  pluginSubscriptions: []
  plugins: []
  corePlugins: []
  enabledPlugins: []

  init: (configSchema, api) ->
    @config = configSchema
    @api = api

  enable: ->
    @enabled = true

    for code, plugin of @corePlugins
      @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

    for code, plugin of @plugins
      key = "activate-power-mode.plugins.#{code}"
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

  disable: ->
    @enabled = false
    for code, subs in @pluginSubscriptions
      subs.dispose()
    @pluginSubscriptions = []

  addCorePlugin: (code, plugin) ->
    @corePlugins[code] = plugin

  addPlugin: (code, plugin) ->
    key = "activate-power-mode.plugins.#{code}"
    @plugins[code] = plugin

    if @enabled
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

  removePlugin: (code) ->
    key = "activate-power-mode.plugins.#{code}"

    if @enabled
      @unobservePlugin code
      @removeConfigForPlugin code

    delete @plugins[code]
    if @enabledPlugins[code]?
      @enabledPlugins[code].disable?()
      delete @enabledPlugins[code]

  addConfigForPlugin: (code, plugin, key) ->
    @config.plugins.properties[code] =
      type: 'boolean',
      title: plugin.title,
      description: plugin.description,
      default: true

    if atom.config.get(key) == undefined
      atom.config.set key, @config.plugins.properties[code].default

  removeConfigForPlugin: (code) ->
    delete @config.plugins.properties[code]

  observePlugin: (code, plugin, key) ->
    @pluginSubscriptions[code] = atom.config.observe(
      key, (isEnabled) =>
        if isEnabled
          plugin.enable?(@api)
          @enabledPlugins[code] = plugin
        else
          plugin.disable?()
          delete @enabledPlugins[code]
    )

  unobservePlugin: (code) ->
    @pluginSubscriptions[code]?.dispose()
    delete @pluginSubscriptions[code]

  onEnabled: (callback) ->
    for code, plugin of @enabledPlugins
      continue if callback code, plugin
