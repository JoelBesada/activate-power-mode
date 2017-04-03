screenShaker = require "./service/screen-shaker"
audioPlayer = require "./service/audio-player"

module.exports = class Api
  screenShaker: screenShaker
  audioPlayer: audioPlayer

  constructor: (editorRegistry) ->
    @editorRegistry = editorRegistry
    @screenShaker.init()

  shakeScreen: ->
    @screenShaker.shake @editorRegistry.getEditorElement()

  playAudio: ->
    audioPlayer.play()

  getEditor: ->
    @editorRegistry.getEditor()

  getEditorElement: ->
    @editorRegistry.getEditorElement()
