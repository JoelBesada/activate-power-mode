throttle = require "lodash.throttle"
random = require "lodash.random"

{CompositeDisposable} = require "atom"

configSchema = require "./config-schema"
screenShake = require './screen-shake'
powerCanvas = require './power-canvas'

module.exports = ActivatePowerMode =
  config: configSchema
  screenShake: screenShake
  powerCanvas: powerCanvas
  subscriptions: null
  active: false

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle": => @toggle()

    @activeItemSubscription = atom.workspace.onDidStopChangingActivePaneItem =>
      @subscribeToActiveTextEditor()

    if @getConfig "autoToggle"
      @toggle()

  deactivate: ->
    @editorChangeSubscription?.dispose()
    @activeItemSubscription?.dispose()
    @subscriptions?.dispose()
    @subscriptions = null
    @active = false
    @canvas?.parentNode.removeChild @canvas
    @canvas = null

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"

  subscribeToActiveTextEditor: ->
    @throttledShake = throttle @screenShake.shake.bind(@screenShake), 100, trailing: false
    @throttledSpawnParticles = throttle @powerCanvas.spawnParticles.bind(@powerCanvas), 25, trailing: false

    @powerCanvas.resetCanvas()

    @editor = atom.workspace.getActiveTextEditor()
    return unless @editor

    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @editorChangeSubscription?.dispose()
    @editorChangeSubscription = @editor.getBuffer().onDidChange @onChange.bind(this)

    @powerCanvas.setupCanvas @editor, @editorElement

  onChange: (e) ->
    return if not @active
    spawnParticles = true
    if e.newText
      spawnParticles = e.newText isnt "\n"
      range = e.newRange.end
    else
      range = e.newRange.start

    if spawnParticles and @getConfig "particles.enabled"
      @throttledSpawnParticles range
    if @getConfig "screenShake.enabled"
      @throttledShake(@editorElement)

  toggle: ->
    @active = not @active
    @powerCanvas.activate(@active)
