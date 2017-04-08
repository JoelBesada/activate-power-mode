module.exports = class Api
  constructor: (editorRegistry, comboApi, screenShaker, audioPlayer) ->
    @editorRegistry = editorRegistry
    @screenShaker = screenShaker
    @audioPlayer = audioPlayer
    @combo = comboApi

  shakeScreen: ->
    @screenShaker.shake @editorRegistry.getEditorElement()

  playAudio: ->
    @audioPlayer.play()

  getEditor: ->
    @editorRegistry.getEditor()

  getEditorElement: ->
    @editorRegistry.getEditorElement()
