inputHandler = require "./input-handler"

module.exports =
  inputHandler: inputHandler

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

  setPluginManager: (pluginManager) ->
    @pluginManager = pluginManager

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

    @editorElement = @editor.getElement()

    @inputSubscription = @editor.getBuffer().onDidChange @handleInput.bind(this)
    @cursorSubscription = @editor.observeCursors @handleCursor.bind(this)

    @pluginManager.runOnChangePane @editor, @editorElement

  handleCursor: (cursor) ->
    @pluginManager.runOnNewCursor cursor

  handleInput: (e) ->
    requestIdleCallback =>
      @inputHandler.handle e
      return if @inputHandler.isGhost()

      screenPos = @editor.screenPositionForBufferPosition @inputHandler.getPosition()
      cursor = @editor.getCursorAtScreenPosition screenPos
      return unless cursor

      @pluginManager.runOnInput cursor, screenPos, @inputHandler

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
