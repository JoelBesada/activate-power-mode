path = require "path"
fs = require "fs"
debounce = require "lodash.debounce"

module.exports =
  music: null
  remainingTime: 0
  isPlayin: false
  isSetup: false
  isMute: false
  pathtoMusic: ""
  musicFiles: null
  currentMusic: 0
  action: ""
  execution: ""
  actionLapseType: ""
  actionLapse: 0

  setup: ->
    if(!@isSetup)
      if (@getConfig "musicPath") != "../audioclips/backgroundmusics/"
        @pathtoMusic = @getConfig "musicPath"
      else
        @pathtoMusic = path.join(__dirname, @getConfig "musicPath")

      @musicFiles = fs.readdirSync(@pathtoMusic.toString())
      @music = new Audio(@pathtoMusic + @musicFiles[0])
      @music.volume = @getConfig "musicVolume"
      @isSetup = true

    @streakTimeoutObserver?.dispose()
    @streakTimeoutObserver = atom.config.observe 'activate-power-mode.comboMode.streakTimeout', (value) =>
      @streakTimeout = value * 1000
      @debouncedActionEndStreak?.cancel()
      @debouncedActionEndStreak = debounce @actionEndStreak.bind(this), @streakTimeout

    @actionObserver?.dispose()
    @actionObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.action', (value) =>
      @action = value[0]
      @execution = value[1]
      if(@execution is "duringStreak")
        @actionLapseType = value[2]
        lapseValue = value.map(Number)
        @actionLapse = lapseValue[3]
      else
        @actionLapseType = ""
        @actionLapse = 0

    if(@actionLapseType is "time")
      timeLapse = @actionLapse * 1000
      @debouncedPause?.cancel()
      @debouncedActionDuringStreak = debounce @actionDuringStreak.bind(this), timeLapse

    if(@execution is "endMusic")
      @remainingTime = (@music.duration - @music.currentTime)
      @debouncedActionDuringStreak?.cancel()
      @debouncedActionDuringStreak = debounce @actionDuringStreak.bind(this), @remainingTime

    @debouncedMuteToggle?.cancel()
    @debouncedMuteToggle = debounce @muteToggle.bind(this), 5000

  destroy: ->
    if(@music != null) and (@isSetup is true)
      @stop()
      @streakTimeoutObserver?.dispose()
      @debouncedActionEndStreak?.cancel()
      @debouncedActionEndStreak = null
      @actionObserver?.dispose()
      @debouncedActionDuringStreak?.cancel()
      @debouncedActionDuringStreak = null
      @debouncedMuteToggle?.cancel()
      @debouncedMuteToggle = null
      @isSetup = false
      @music = null
      @musicFiles = null

  play: (streak) ->
    @setup()
    @remainingTime = (@music.duration - @music.currentTime)
    if(@execution is "duringStreak") or (@execution is "endMusic")
      @actionDuringStreak(streak)
    @debouncedActionEndStreak()

    @isPlaying = false if (@music.paused)
    return null if (@isPlaying) or (@isMute)

    @debouncedActionDuringStreak() if(@actionLapseType is "time")

    @isPlaying = true
    @music.play()

  pause: ->
    @isPlaying = false
    @music.pause()

  stop: ->
    @isPlaying = false
    @music.pause()
    @music.currentTime = 0

  autoPlay: ->
    @music.play() if @music.paused

  next: ->
    @stop()
    maxIndex = @musicFiles.length - 1
    if (maxIndex > @currentMusic)
      @currentMusic++
    else
      @currentMusic = 0

    @music = new Audio(@pathtoMusic + @musicFiles[@currentMusic])
    @music.volume = @getConfig "musicVolume"

  muteToggle: (type) ->
    if(!@isMute)
      @isMute = true
      @music.volume = 0
      @debouncedMuteToggle() if(type is "temporary")
    if(@isMute)
      @isMute = false
      @music.volume = @getConfig "musicVolume"

  actionDuringStreak: (streak = 0) ->
    if(streak is 0 and @actionLapse != 0)
      @stop() if @action is "repit"
      @next() if @action is "change"
      return null

    if(streak % @actionLapse is 0) and (streak != 0)
      @stop() if @action is "repit"
      @next() if @action is "change"
      return null

    if(@music.ended)
      @stop() if @action is "repit"
      @next() if @action is "change"
      @autoPlay()

  actionEndStreak: ->
    @debouncedActionDuringStreak?.cancel()
    return @stop() if @action is "repit"
    return @pause() if @action is "pause"
    @pause()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playBackgroundMusic.#{config}"
