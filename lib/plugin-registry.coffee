{CompositeDisposable} = require "atom"

module.exports =
  enabled: false
  subscriptions: null
  plugins: []
  corePlugins: []
  enabledPlugins: []
  registedPlugins: []

  init: (configSchema, api) ->
    @config = configSchema
    @api = api

  enable: ->
    @count = 0
    @subscriptions = new CompositeDisposable
    @enabled = true

    for code, plugin of @corePlugins
      @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

    for code, plugin of @plugins
      key = "activate-power-mode.plugins.#{code}"
      continue if plugin.name? and plugin.name is @registedPlugins[code]
      @registedPlugins[code] = plugin.name if plugin.name?

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
      return null if plugin.name? and @registedPlugins[code] is plugin.name
      @registedPlugins[code] = plugin.name if plugin.name?
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
        if plugin.name? and atom.packages.isPackageDisabled(plugin.name) and isEnabled
            return atom.config.set(key, false)

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

  isActive: (code) ->
    atom.config.get "activate-power-mode.plugins.#{code}"
