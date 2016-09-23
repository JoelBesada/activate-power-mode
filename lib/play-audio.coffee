path = require "path"

module.exports =
  play: ->
    pathtoaudio = path.join(__dirname, '../audioclips/gun.wav')
    audio = new Audio(pathtoaudio);
    audio.currentTime = 0;
    audio.volume = @getConfig "volume"
    audio.play();

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playAudio.#{config}"
