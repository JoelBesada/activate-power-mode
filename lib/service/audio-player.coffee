{CompositeDisposable} = require "atom"
path = require "path"

module.exports =
  enabled: false
  subscriptions: null
  conf: []

  init: ->
    @enableSubscription = atom.config.observe(
      'activate-power-mode.playAudio.enabled', (value) =>
        @enabled = value
        if @enabled
          @enable()
        else
          @disable()
    )

  destroy: ->
    @enableSubscription.dispose()
    @disable()

  enable: ->
    @initConfigSubscribers()

  disable: ->
    @subscriptions?.dispose()

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
      pathtoaudio = path.join("#{__dirname}/..", @conf['audioclip'])
    @audio = new Audio(pathtoaudio)

    pathtoaudio2 = pathtoaudio + "-enter";
    @audio2 = new Audio(pathtoaudio2)

  play: (audio, input) ->
    return if not @enabled

    if not audio
      debugger
      if input.isNewLine()
        audio = @audio2;
      else
        audio = @audio;

    audio.currentTime = 0
    audio.volume = @conf['volume']
    audio.play()
