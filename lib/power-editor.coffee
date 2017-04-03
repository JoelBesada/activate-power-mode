pluginManager = require "./plugin-manager"

module.exports =
  pluginManager: pluginManager

  enable: ->
    @pluginManager.enable()
    @changePaneSubscription = atom.workspace.onDidStopChangingActivePaneItem =>
      @setupPane()

    @setupPane()

  disable: ->
    @changePaneSubscription?.dispose()
    @inputSubscription?.dispose()
    @cursorSubscription?.dispose()
    @pluginManager.disable()

  isExcludedFile: ->
    excluded = @getConfig "excludedFileTypes.excluded"
    @editor.getPath()?.split('.').pop() in excluded

  setupPane: ->
    @inputSubscription?.dispose()
    @cursorSubscription?.dispose()
    @editor = atom.workspace.getActiveTextEditor()

    if not @editor or @isExcludedFile()
      @pluginManager.runOnChangePane()
      return

    @editorElement = atom.views.getView @editor
    @inputSubscription = @editor.getBuffer().onDidChange @handleInput.bind(this)
    @cursorSubscription = @editor.observeCursors @handleCursor.bind(this)

    @pluginManager.runOnChangePane @editor, @editorElement

  handleCursor: (cursor) ->
    @pluginManager.runOnNewCursor cursor

  handleInput: (e) ->
    spawnParticles = true
    if e.newText
      spawnParticles = e.newText isnt "\n"
      range = e.newRange.end
    else
      range = e.newRange.start

    screenPos = @editor.screenPositionForBufferPosition range
    cursor = @editor.getCursorAtScreenPosition screenPos
    return unless cursor

    @pluginManager.runOnInput cursor

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
