{CompositeDisposable} = require "atom"

configSchema = require "./config-schema"
powerEditor = require "./power-editor"

module.exports = ActivatePowerMode =
  config: configSchema
  subscriptions: null
  active: false
  powerEditor: powerEditor

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle":  => @toggle()
      "activate-power-mode:enable":  => @enable()
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
