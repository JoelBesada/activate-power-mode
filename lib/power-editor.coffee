throttle = require "lodash.throttle"
screenShake = require "./screen-shake"
powerCanvas = require "./power-canvas"

module.exports =
  screenShake: screenShake
  powerCanvas: powerCanvas

  enable: ->
    @throttledShake = throttle @screenShake.shake.bind(@screenShake), 100, trailing: false
    @throttledSpawnParticles = throttle @powerCanvas.spawnParticles.bind(@powerCanvas), 25, trailing: false

    @activeItemSubscription = atom.workspace.onDidStopChangingActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  disable: ->
    @activeItemSubscription?.dispose()
    @editorChangeSubscription?.dispose()
    @powerCanvas.destroy()

  subscribeToActiveTextEditor: ->
    @powerCanvas.resetCanvas()
    @prepareEditor()

  prepareEditor: ->
    @editorChangeSubscription?.dispose()
    @editor = atom.workspace.getActiveTextEditor()
    return unless @editor

    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @powerCanvas.setupCanvas @editor, @editorElement

    @editorChangeSubscription = @editor.getBuffer().onDidChange @onChange.bind(this)

  onChange: (e) ->
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

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
