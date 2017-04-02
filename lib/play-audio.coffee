throttle = require "lodash.throttle"
path = require "path"

module.exports =
  enable: ->
    @throttledPlayAudio = throttle @play.bind(this), 100, trailing: false

  onInput: (editor, editorElement, cursor) ->
    @throttledPlayAudio()

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
