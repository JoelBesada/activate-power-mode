{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  plugins: []
  corePlugins: []
  enabledPlugins: []

  init: (configSchema, api) ->
    @config = configSchema
    @api = api

  enable: ->
    @subscriptions = new CompositeDisposable

    for code, plugin of @corePlugins
      @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

    for code, plugin of @plugins
      @observePlugin code, plugin, "activate-power-mode.plugins.#{code}"

  disable: ->
    @subscriptions?.dispose()

  addCorePlugin: (code, plugin) ->
    @corePlugins[code] = plugin

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
