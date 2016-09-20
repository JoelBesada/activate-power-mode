throttle = require "lodash.throttle"
screenShake = require "./screen-shake"
powerCanvas = require "./power-canvas"
rageMeter = require "./rage-meter"

module.exports =
  screenShake: screenShake
  powerCanvas: powerCanvas
  rageMeter: rageMeter

  enable: ->
    @throttledShake = throttle @screenShake.shake.bind(@screenShake), 100, trailing: false

    @activeItemSubscription = atom.workspace.onDidStopChangingActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  disable: ->
    @activeItemSubscription?.dispose()
    @editorChangeSubscription?.dispose()
    @editorAddCursor?.dispose()
    @powerCanvas.destroy()

  subscribeToActiveTextEditor: ->
    @powerCanvas.resetCanvas()
    @prepareEditor()

  prepareEditor: ->
    @editorChangeSubscription?.dispose()
    @editorAddCursor?.dispose()
    @editor = atom.workspace.getActiveTextEditor()
    return unless @editor
    return if @editor.getPath()?.split('.').pop() in @getConfig "excludedFileTypes.excluded"

    @editorElement = atom.views.getView @editor

    @powerCanvas.setupCanvas @editor, @editorElement

    @editorChangeSubscription = @editor.getBuffer().onDidChange @onChange.bind(this)
    @editorAddCursor = @editor.observeCursors @handleCursor.bind(this)

  handleCursor: (cursor) ->
    cursor.throttleSpawnParticles = throttle @powerCanvas.spawnParticles.bind(@powerCanvas), 25, trailing: false

  onChange: (e) ->
    spawnParticles = true
    if e.newText
      spawnParticles = e.newText isnt "\n"
      range = e.newRange.end
    else
      range = e.newRange.start

    if e.oldText != ""
      rageMeter.addRage()

    screenPosition = @editor.screenPositionForBufferPosition range
    cursor = @editor.getCursorAtScreenPosition screenPosition
    return unless cursor

    if spawnParticles and @getConfig "particles.enabled"
      cursor.throttleSpawnParticles screenPosition
    if @getConfig "screenShake.enabled"
      @throttledShake @editorElement

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
