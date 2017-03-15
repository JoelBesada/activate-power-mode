path = require "path"
fs = require "fs"
debounce = require "lodash.debounce"

module.exports =
  pathtoMusic: null
  musicFiles: null
  currentFile: 0
  music: null
  isPlaying: false

  setup: ->
    if (@getConfig "musicPath") != "../audioclips/backgroundmusics/"
      @pathtoMusic = @getConfig "musicPath"
    else
      @pathtoMusic = path.join(__dirname, @getConfig "musicPath")

    @musicFiles = fs.readdirSync(@pathtoMusic.toString())
    @music = new Audio(@pathtoMusic + @getFileName(0))

    @musicChangeTimeObserver?.dispose()
    @musicChangeTimeObserver = atom.config.observe 'activate-power-mode.playBackgroundMusic.musicChangeTime', (value) =>
      @musicChangeTime = value * 1000
      @debouncedChangeMusic?.cancel()
      @debouncedChangeMusic = debounce @changeMusic.bind(this), @musicChangeTime

  destroy: ->
    stop()
    @streakTimeoutObserver?.dispose()
    @debouncedChangeMusic?.cancel()
    @debouncedChangeMusic = null
    @musicChangeTimeObserver?.dispose()

  stop: ->
    if (@getConfig "reproductionSetting") is "custom" and  (@getConfig "musicChangeTime") != 0
      @debouncedChangeMusic()
    @music.pause() if @music != null
    if (@getConfig "reproductionSetting") is "repitEndStreak"
      @music.currentTime = 0
    @isPlaying = false

  play: ->

    @isPlaying = false if (@music.paused)
    return null if (@isPlaying)

    if (@music.onended)
      @music.currentTime = 0 if (@getConfig "reproductionSetting") is "repitEndMusic"
      @changeMusic() if (@getConfig "reproductionSetting") is "repitEndMusic"

    @music.volume = @getConfig "musicVolume"
    @isPlaying = true
    @music.play()

  changeMusic: ->
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
