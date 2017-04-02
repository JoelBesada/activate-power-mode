screenShaker = require "./service/screen-shaker"
audioPlayer = require "./service/audio-player"

module.exports =
  screenShaker: screenShaker
  audioPlayer: audioPlayer

  init: ->
    @screenShaker.init()

  shakeScreen: (element) ->
    @screenShaker.shake element

  playAudio: ->
    audioPlayer.play()
