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
      isPackage = if plugin.name? then true else false
      continue if isPackage and @registedPlugins[code] is plugin.name
      @registedPlugins[code] = plugin.name if isPackage
      @addConfigForPlugin code, plugin, key
      if isPackage
        @observePackagePlugin code, plugin, key
        continue
      @observePlugin code, plugin, key

    @observePackage() if @plugins != null

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
      @observePackagePlugin code, plugin, key

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

  observePackagePlugin: (code, plugin, key) ->
    @subscriptions.add atom.config.observe(
      key, (isEnabled) =>
        console.log "El plugin observer " + plugin.name + "se ha invocado " + ++@count
        if plugin.name? and atom.packages.isPackageDisabled(plugin.name)
            console.error "Yo me invoque jejeje XD"
            return atom.config.set(key, false) if isEnabled

        if isEnabled
          plugin.enable?(@api)
          @enabledPlugins[code] = plugin
        else
          plugin.disable?()
          delete @enabledPlugins[code]
    )

  observePackage: ->
    @subscriptions.add atom.packages.onDidActivatePackage (packages) =>
      for code, name of @registedPlugins
        if name is packages.name
          atom.config.set("activate-power-mode.plugins.#{code}", true) if !@isActive(code)

    @subscriptions.add atom.packages.onDidDeactivatePackage (packages) =>
      for code, name of @registedPlugins
        if name is packages.name
          atom.config.set("activate-power-mode.plugins.#{code}", false) if @isActive(code)

  onEnabled: (callback) ->
    for code, plugin of @enabledPlugins
      continue if callback code, plugin

  isActive: (code) ->
    atom.config.get "activate-power-mode.plugins.#{code}"
