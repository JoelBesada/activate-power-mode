{CompositeDisposable} = require "atom"
configSchema = require "./config-schema"

module.exports = ActivatePowerMode =
  config: configSchema
  subscriptions: null
  active: false

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @powerEditor = require "./power-editor"
    @pluginManager = require "./plugin-manager"
    @pluginRegistry = require "./plugin-registry"
    @flowRegistry = require "./flow-registry"
    @effectRegistry = require "./effect-registry"
    @powerEditor.setPluginManager @pluginManager
    @pluginManager.init @config, @pluginRegistry, @flowRegistry, @effectRegistry

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle": => @toggle()
      "activate-power-mode:enable": => @enable()
      "activate-power-mode:disable": => @disable()

    if @getConfig "autoToggle"
      @toggle()

  deactivate: ->
    @subscriptions?.dispose()
    @active = false
    @powerEditor.disable()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"

  toggle: ->
    if @active then @disable() else @enable()

  enable: ->
    @active = true
    @powerEditor.enable()

  disable: ->
    @active = false
    @powerEditor.disable()

  provideServiceV1: ->
    if not @service
      Service = require "./service"
      @service = new Service(@pluginRegistry, @flowRegistry, @effectRegistry)
    @service
