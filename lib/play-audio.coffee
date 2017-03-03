path = require "path"

module.exports =
  play: ->
    if (@getConfig "audioclip") is "customAudioclip"
      pathtoaudio = @getConfig "customAudioclip"
    else
      pathtoaudio = path.join(__dirname, @getConfig "audioclip")
    audio = new Audio(pathtoaudio)
    audio.currentTime = 0
    audio.volume = @getConfig "volume"
    audio.play()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playAudio.#{config}"
