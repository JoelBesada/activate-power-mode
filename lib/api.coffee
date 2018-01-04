module.exports = class Api
  constructor: (editorRegistry, comboApi, screenShaker, audioPlayer) ->
    @editorRegistry = editorRegistry
    @screenShaker = screenShaker
    @audioPlayer = audioPlayer
    @combo = comboApi

  shakeScreen: (intensity = null) ->
    @screenShaker.shake @editorRegistry.getScrollView(), intensity

  playAudio: (audio, input) ->
    @audioPlayer.play(audio, input)

  getEditor: ->
    @editorRegistry.getEditor()

  getEditorElement: ->
    @editorRegistry.getEditorElement()

  getCombo: ->
    @combo
