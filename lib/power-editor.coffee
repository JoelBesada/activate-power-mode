throttle = require "lodash.throttle"
screenShake = require "./screen-shake"
playAudio = require "./play-audio"
powerCanvas = require "./power-canvas"
comboMode = require "./combo-mode"

module.exports =
  screenShake: screenShake
  playAudio: playAudio
  powerCanvas: powerCanvas
  comboMode: comboMode

  enable: ->
    @throttledShake = throttle @screenShake.shake.bind(@screenShake), 100, trailing: false
    @throttledPlayAudio = throttle @playAudio.play.bind(@playAudio), 100, trailing: false

    @activeItemSubscription = atom.workspace.onDidStopChangingActivePaneItem =>
      @subscribeToActiveTextEditor()

    @comboModeEnabledSubscription = atom.config.observe 'activate-power-mode.comboMode.enabled', (value) =>
      @isComboMode = value
      if @isComboMode and @editorElement
        @comboMode.setup @editorElement
      else
        @comboMode.destroy()

    @subscribeToActiveTextEditor()

  disable: ->
    @activeItemSubscription?.dispose()
    @editorChangeSubscription?.dispose()
    @comboModeEnabledSubscription?.dispose()
    @editorAddCursor?.dispose()
    @powerCanvas.destroy()
    @comboMode.destroy()
    @isComboMode = false

  subscribeToActiveTextEditor: ->
    @powerCanvas.resetCanvas()
    @comboMode.reset() if @isComboMode
    @prepareEditor()

  prepareEditor: ->
    @editorChangeSubscription?.dispose()
    @editorAddCursor?.dispose()
    @editor = atom.workspace.getActiveTextEditor()
    return unless @editor
    return if @editor.getPath()?.split('.').pop() in @getConfig "excludedFileTypes.excluded"

    @editorElement = atom.views.getView @editor

    @powerCanvas.setupCanvas @editor, @editorElement
    @comboMode.setup @editorElement if @isComboMode

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

    screenPosition = @editor.screenPositionForBufferPosition range
    cursor = @editor.getCursorAtScreenPosition screenPosition
    return unless cursor

    if @isComboMode
      @comboMode.increaseStreak()
      return unless @comboMode.hasReached()

    if spawnParticles and @getConfig "particles.enabled"
      cursor.throttleSpawnParticles screenPosition
    if @getConfig "screenShake.enabled"
      @throttledShake @editorElement
    if @getConfig "playAudio.enabled"
      @throttledPlayAudio()


  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
