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
      "activate-power-mode:toggle": => @toggle()

    if @getConfig "autoToggle"
      @toggle()

  deactivate: ->
    @subscriptions?.dispose()
    @active = false
    @powerEditor.disable()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"

  toggle: ->
    @active = not @active
    if @active then @powerEditor.enable() else @powerEditor.disable()
