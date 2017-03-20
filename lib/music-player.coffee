path = require "path"
fs = require "fs"
debounce = require "lodash.debounce"

module.exports =
  pathtoMusic: null
  musicFiles: null
  currentFile: 0
  music: null
  isPlaying: false
  isSilent: false
  silentLapse: 0
  lapseType: ""
  timeLapse: 0
  streakLapse: 0

  setup: ->
    if (@getConfig "musicPath") != "../audioclips/backgroundmusics/"
      @pathtoMusic = @getConfig "musicPath"
    else
      @pathtoMusic = path.join(__dirname, @getConfig "musicPath")

    @musicFiles = fs.readdirSync(@pathtoMusic.toString())
    @music = new Audio(@pathtoMusic + @getFileName(0))

    @reproductionActionLapse?.dispose()
    @reproductionActionLapse = atom.config.observe 'activate-power-mode.playBackgroundMusic.lapse', (value) =>
      @actionLapse = value
      @lapseType = @actionLapse[0]
      lapse = @actionLapse.map(Number)
      if (@lapseType is "Time") or (@lapseType is "time")
        @timeLapse = lapse[1]  * 1000
        @debouncedChangeOrRepitMusic?.cancel()
        @debouncedChangeOrRepitMusic = debounce @changeOrRepitMusic.bind(this), @timeLapse
      if (@lapseType is "Streak") or (@lapseType is "streak")
        @streakLapse = lapse[1]

    @superExclamationLapse?.dispose()
    @superExclamationLapse = atom.config.observe 'activate-power-mode.superExclamation.exclamationLapse', (value) =>
      @sExclamationLapse = value
      @sElapseType = @sExclamationLapse[0]
      @lapse = @sExclamationLapse[1] * 1000
      @debouncedPause?.cancel()
      @debouncedPause = debounce @timePause.bind(this), @lapse

    @silentLapse = 5000
    @debouncedContinue?.cancel()
    @debouncedContinue = debounce @continue.bind(this), @silentLapse

  destroy: ->
    stop()
    @streakTimeoutObserver?.dispose()
    @debouncedChangeOrRepitMusic?.cancel()
    @debouncedContinue?.cancel()
    @reproductionActionLapse?.dispose()

  stop: ->
    @debouncedChangeOrRepitMusic?.cancel()
    @music.pause() if @music != null
    if (@getConfig "reproductionSetting") is "repit"
      @music.currentTime = 0
    @isPlaying = false
    if (@getConfig "reproductionSetting") is "custom"
      @changeOrRepitMusic() if (@isPlaying is "changeEndStreak")
      @music.currentTime = 0 if (@isPlaying is "repitEndStreak")

  play: (combo) ->

    @changeOrRepit(combo)

    @isPlaying = false if (@music.paused)
    return null if (@isPlaying) or (@isSilent)

    @music.volume = @getConfig "musicVolume"
    @isPlaying = true
    @music.play()

  pause: (type, lapse) ->
    if (type is "Time") or (type is "time")
      @silentLapse = lapse
      @debouncedPause()
    else
      @silentLapse = lapse
      @strikePause()

  changeOrRepit: (combo) ->
    if (@timeLapse != 0)
      @debouncedChangeOrRepitMusic()

    if (@music.ended) and (@getConfig "reproductionSetting") is "custom"
      @changeOrRepitMusic() if (@isPlaying is "changeEndMusic")
      @music.currentTime = 0 if (@isPlaying is "repitEndMusic")

    if (combo % @streakLapse) is 0
      @changeOrRepitMusic() if (@getConfig "reproductionSetting") is "change"
      @music.currentTime = 0 if (@getConfig "reproductionSetting") is "repit"

  strikePause: ->
    @isSilent = true
    @isPlaying = false
    @music.pause() if @music != null
    @debouncedContinue()

  timePause: ->
    @isSilent = true
    @isPlaying = false
    @music.pause() if @music != null
    @debouncedContinue()

  continue: ->
    @isSilent = false
    @isPlaying = true
    @music.volume = @getConfig "musicVolume"
    @isPlaying = true
    @music.play()

  changeOrRepitMusic: ->
    @music.pause() if (@isPlaying)
    @music = new Audio(@pathtoMusic + @getFileName())

  getFileName: (index = null) ->
    maxIndex = @musicFiles.length - 1
    if (index != null)
      @currentFile = index
      return fileName = (@musicFiles[index])
    else if (maxIndex > @currentFile)
      @currentFile++
      return fileName = (@musicFiles[@currentFile])
    else
      @currentFile = 0
      return fileName = (@musicFiles[@currentFile])


  getConfig: (config) ->
    atom.config.get "activate-power-mode.playBackgroundMusic.#{config}"
