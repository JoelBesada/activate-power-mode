path = require "path"
fs = require "fs"

module.exports =
  pathtoaudio: null
  audio: null
  isPlaying: false

  setup: ->
    if (@getConfig "Musicclip") is "customAudioclip"
      @pathtoaudio = @getConfig "customMusicclip"
    else
      @pathtoaudio = path.join(__dirname, @getConfig "Musicclip")
      
    @audio = new Audio(@pathtoaudio)
    isPlaying: false

  #Stop audio wend streakTimeout
  stop: ->
      @audio.pause() if @audio != null
      @audio.currentTime = 0 if @getConfig "repeat"
      @isPlaying = false

  play: ->

    if (@audio.paused)
      @isPlaying = false

    if (@isPlaying)
      return null

    @audio.volume = @getConfig "backgroundvolume"
    @isPlaying = true
    @audio.play()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playBackgroundMusic.#{config}"
