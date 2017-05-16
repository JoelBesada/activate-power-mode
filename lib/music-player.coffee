path = require "path"
fs = require "fs"
debounce = require "lodash.debounce"

module.exports =
  music: null
  isPlayin: false
  isSetup: false
  pathtoMusic: ""
  musicFiles: null
  currentMusic: 0
  action: ""
  execution: ""
  actionLapseType: ""
  actionLapse: 0

  setup: ->
    @musicPathObserver?.dispose()
    @musicPathObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.musicPath', (value) =>
      if value is "../audioclips/backgroundmusics/"
        @pathtoMusic = path.join(__dirname, value)
      else
        @pathtoMusic = value

      @musicFiles = @getAudioFiles()
      @music = new Audio(@pathtoMusic + @musicFiles[0])
      @music.volume = @getConfig "musicVolume"

    @musicEnabledObserver?.dispose()
    @musicEnabledObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.enabled', (enabled) =>
      if not enabled
        @destroy()

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
          @debouncedActionDuringStreak = debounce @action.bind(this), @timeLapse
          @debouncedActionDuringStreakDuringStreak()
      else
        @debouncedActionDuringStreak?.cancel()
        @debouncedActionDuringStreak = null
        @actionLapseType = ""
        @actionLapse = 0
        @music.onended = =>
          @actionDuringStreak()

    @isSetup = true

  getAudioFiles: ->
    allFiles = fs.readdirSync(@pathtoMusic.toString())
    file = 0
    while(allFiles[file])
      fileName = allFiles[file++]
      fileExtencion = fileName.split('.').pop();
      continue if(fileExtencion is "mp3") or (fileExtencion is "MP3")
      continue if(fileExtencion is "wav") or (fileExtencion is "WAV")
      continue if(fileExtencion is "3gp") or (fileExtencion is "3GP")
      continue if(fileExtencion is "m4a") or (fileExtencion is "M4A")
      continue if(fileExtencion is "webm") or (fileExtencion is "WEBM")
      allFiles.splice(--file, 1)
      break if file is allFiles.length

    return allFiles

  destroy: ->
    if(@music != null) and (@isSetup is true)
      @stop()
      @musicPathObserver?.dispose()
      @musicEnabledObserver?.dispose()
      @actionObserver?.dispose()
      @debouncedActionDuringStreak?.cancel()
      @debouncedActionDuringStreak = null
      @isSetup = false
      @music = null
      @musicFiles = null
      isPlayin = false
      currentMusic = 0

  play: (streak) ->
    @setup() if !@isSetup
    if @execution is "duringStreak"
      @actionDuringStreak(streak)

    @isPlaying = false if (@music.paused)
    return null if @isPlaying

    if @execution is "duringStreak" and @actionLapseType is "time"
      @debouncedActionDuringStreakDuringStreak()


    if @execution is "endMusic"
      @music.onended = =>
        @actionDuringStreak()
    else
      @music.onended = =>
        @autoPlay()

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
    if @execution is "endMusic"
      @music.onended = =>
        @actionDuringStreak()
    else
      @music.onended = =>
        @autoPlay()

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
        @stop() if @action is "repeat"
        @next() if @action is "change"
        @autoPlay()
        return @debouncedActionDuringStreakDuringStreak()
      if(@execution is "endMusic")
        @stop() if @action is "repeat"
        @next() if @action is "change"
        return @autoPlay()
    else
      if(streak % @actionLapse is 0 and @actionLapseType is "streak")
        @stop() if @action is "repeat"
        @next() if @action is "change"
        return @autoPlay()

  actionEndStreak: ->
    @debouncedActionDuringStreak?.cancel()
    return @stop() if(@action is "repeat") and (@execution is "endStreak")
    return @next() if(@action is "change")  and (@execution is "endStreak")
    @pause()

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playBackgroundMusic.#{config}"
