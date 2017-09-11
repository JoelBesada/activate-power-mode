{CompositeDisposable} = require "atom"

module.exports =
  enabled: false
  subscriptions: null
  pluginSubscriptions: []
  plugins: []
  corePlugins: []
  enabledPlugins: []
  key: 'activate-power-mode.plugins'

  init: (configSchema, api) ->
    @config = configSchema
    @api = api

  enable: ->
    @subscriptions = new CompositeDisposable
    @enabled = true

    for code, plugin of @corePlugins
      @observePlugin code, plugin, "activate-power-mode.#{code}.enabled"

    for code, plugin of @plugins
      key = "#{@key}.#{code}"
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

    @initList()

  disable: ->
    @enabled = false
    @subscriptions?.dispose()
    for code, subs in @pluginSubscriptions
      subs.dispose()
    @pluginSubscriptions = []
    @pluginList?.dispose()
    @pluginList = null

  addCorePlugin: (code, plugin) ->
    @corePlugins[code] = plugin

  addPlugin: (code, plugin) ->
    key = "#{@key}.#{code}"
    @plugins[code] = plugin

    if @enabled
      @addConfigForPlugin code, plugin, key
      @observePlugin code, plugin, key

  removePlugin: (code) ->
    key = "#{@key}.#{code}"

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

  togglePlugin: (code) ->
    isEnabled = atom.config.get "#{@key}.#{code}"
    atom.config.set "#{@key}.#{code}", !isEnabled

  initList: ->
    return if @pluginList?

    @pluginList = require "./plugin-list"
    @pluginList.init this

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:select-plugin": =>
        @pluginList.toggle()
