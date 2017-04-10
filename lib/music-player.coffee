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
    if (@getConfig "musicPath") != "../audioclips/backgroundmusics/"
      @pathtoMusic = @getConfig "musicPath"
    else
      @pathtoMusic = path.join(__dirname, @getConfig "musicPath")

    @musicFiles = fs.readdirSync(@pathtoMusic.toString())
    @music = new Audio(@pathtoMusic + @musicFiles[0])
    @music.volume = @getConfig "musicVolume"

    @actionObserver?.dispose()
    @actionObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.actions.command', (value) =>
      @action = value[0]
      @execution = value[1]
      if @execution is "duringStreak"
        @actionLapseType = value[2]
        lapseValue = value.map(Number)
        if(lapseValue[3] >= 10) and (lapseValue[3] <= 100)
          @actionLapse = lapseValue[3]
        else
          @actionLapse = 10 if(lapseValue[3] < 10)
          @actionLapse = 100 if(lapseValue[3] > 100)
        if @actionLapseType is "time"
          @timeLapse = @actionLapse * 1000
          @debouncedActionDuringStreak?.cancel()
          @debouncedActionDuringStreak = debounce @actionDuringStreak.bind(this), @timeLapse
          @debouncedActionDuringStreak()
      else
        @debouncedActionDuringStreak?.cancel()
        @debouncedActionDuringStreak = null
        @actionLapseType = ""
        @actionLapse = 0
        @music.onended = =>
          @actionDuringStreak()

    @isSetup = true

  destroy: ->
    if(@music != null) and (@isSetup is true)
      @stop()
      @streakTimeoutObserver?.dispose()
      @actionObserver?.dispose()
      @debouncedActionDuringStreak?.cancel()
      @debouncedActionDuringStreak = null
      @isSetup = false
      @music = null
      @musicFiles = null

  play: (streak) ->
    @setup() if !@isSetup
    if @execution is "duringStreak"
      @actionDuringStreak(streak)

    @isPlaying = false if (@music.paused)
    return null if (@isPlaying) or (@isMute)

    if @execution is "duringStreak" and @actionLapseType is "time"
      @debouncedActionDuringStreak()

    if @execution != "endStreak"
      @music.onended = =>
        @music.play()

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
    if @execution != "endStreak"
      @music.onended = =>
        @music.play()

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

  actionDuringStreak: (streak = 0) ->
    if streak is 0
      if @actionLapse != 0 and @actionLapseType is "time"
        @stop() if @action is "repit"
        @next() if @action is "change"
        @autoPlay()
        return @debouncedActionDuringStreak()
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
