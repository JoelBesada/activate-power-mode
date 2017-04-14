module.exports = class Api
  constructor: (editorRegistry, comboApi, screenShaker, audioPlayer) ->
    @editorRegistry = editorRegistry
    @screenShaker = screenShaker
    @audioPlayer = audioPlayer
    @combo = comboApi

  shakeScreen: (intensity = null) ->
    @screenShaker.shake @editorRegistry.getEditorElement(), intensity

  playAudio: ->
    @audioPlayer.play()

  getEditor: ->
    @editorRegistry.getEditor()

  getEditorElement: ->
    @editorRegistry.getEditorElement()
