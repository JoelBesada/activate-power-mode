module.exports = class Api
  constructor: (editorRegistry, screenShaker, audioPlayer) ->
    @editorRegistry = editorRegistry
    @screenShaker = screenShaker
    @audioPlayer = audioPlayer

  shakeScreen: ->
    @screenShaker.shake @editorRegistry.getEditorElement()

  playAudio: ->
    @audioPlayer.play()

  getEditor: ->
    @editorRegistry.getEditor()

  getEditorElement: ->
    @editorRegistry.getEditorElement()
