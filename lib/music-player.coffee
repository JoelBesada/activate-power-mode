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
    if !@isSetup
      if (@getConfig "musicPath") != "../audioclips/backgroundmusics/"
        @pathtoMusic = @getConfig "musicPath"
      else
        @pathtoMusic = path.join(__dirname, @getConfig "musicPath")

      @musicFiles = fs.readdirSync(@pathtoMusic.toString())
      @music = new Audio(@pathtoMusic + @musicFiles[0])
      @music.volume = @getConfig "musicVolume"

    @streakTimeoutObserver?.dispose()
    @streakTimeoutObserver = atom.config.observe 'activate-power-mode.comboMode.streakTimeout', (value) =>
      @streakTimeout = value * 1000
      @debouncedActionEndStreak?.cancel()
      @debouncedActionEndStreak = debounce @actionEndStreak.bind(this), @streakTimeout

    @actionObserver?.dispose()
    @actionObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.actions.command', (value) =>
      @action = value[0]
      @execution = value[1]
      if(@execution is "duringStreak")
        @actionLapseType = value[2]
        lapseValue = value.map(Number)
        @actionLapse = lapseValue[3] if(lapseValue[3] >= 10)
        @actionLapse = 10 if(lapseValue[3] < 10)
      else
        @actionLapseType = ""
        @actionLapse = 0

    if(@actionLapseType is "time" and !@isSetup)
      timeLapse = @actionLapse * 1000
      @debouncedPause?.cancel()
      @debouncedActionDuringStreak = debounce @actionDuringStreak.bind(this), timeLapse
    else if(@execution is "endMusic")
      @remainingTime = (@music.duration - @music.currentTime)
      @debouncedActionDuringStreak?.cancel()
      @debouncedActionDuringStreak = debounce @actionDuringStreak.bind(this), @remainingTime

    @debouncedMuteToggle?.cancel()
    @debouncedMuteToggle = debounce @muteToggle.bind(this), 5000
    @isSetup = true

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
    if(@execution is "duringStreak")
      @actionDuringStreak(streak)
    #@debouncedActionEndStreak()

    @isPlaying = false if (@music.paused)
    return null if (@isPlaying) or (@isMute)

    if(@actionLapseType is "time") or (@execution is "endMusic")
      @debouncedActionDuringStreak() #endMusic doesn't work

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
    @isPlaying = true
    @music.play()

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

  actionDuringStreak: (streak = 0) -> #endMusic doesn't work
    if streak is 0
      if @actionLapse != 0 and @actionLapseType is "time"
        @stop() if @action is "repit"
        @next() if @action is "change"
        return @autoPlay()
      if(@music.paused and @execution is "endMusic")
        @stop() if @action is "repit"
        @next() if @action is "change"
        return @autoPlay()
    else
      if(streak % @actionLapse is 0 and @actionLapseType is "streak")
        @stop() if @action is "repit"
        @next() if @action is "change"
        return @autoPlay()

  actionEndStreak: ->
    @debouncedActionDuringStreak?.cancel()
    return @stop() if(@action is "repit") and (@execution is "endStreak")
    return @next() if(@action is "change")  and (@execution is "endStreak")
    @pause()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playBackgroundMusic.#{config}"
