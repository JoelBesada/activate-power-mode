{CompositeDisposable} = require "atom"
path = require "path"

module.exports =
  subscriptions: null
  conf: []

  init: ->
    @initConfigSubscribers()

  disable: ->
    @subscriptions.dispose()

  observe: (key, loadAudio = true) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.playAudio.#{key}", (value) =>
        @conf[key] = value
        @loadAudio() if loadAudio
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'audioclip'
    @observe 'customAudioclip'
    @observe 'volume', false

  loadAudio: ->
    if @conf['audioclip'] is 'customAudioclip' and @conf['customAudioclip']
      pathtoaudio = @conf['customAudioclip']
    else
      pathtoaudio = path.join(__dirname, @conf['audioclip'])
    @audio = new Audio(pathtoaudio)

  play: ->
    @audio.currentTime = 0
    @audio.volume = @conf['volume']
    @audio.play()
