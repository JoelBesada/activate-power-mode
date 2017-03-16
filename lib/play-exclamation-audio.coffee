#inspired in code-champion
path = require "path"

module.exports =
  audioExclamation: null
  fileName: ""
  superExclamationLapse: null
  isPlaying: false

  setup: (combo) ->
    @superExclamationLapse = (@getConfig "superExclamation.lapse")

    if (@getConfig "exclamations.type") is "killerInstint"
      pathtoaudio = path.join(__dirname, "../audioclips/Exclamations/")
      @fileName = @selectExclamationAudio(combo)
      @audioExclamation = new Audio(pathtoaudio + @fileName + ".wav")
    else
      if (@getConfig "exclamations.exclamationPath") is "../audioclips/exclamations/"
        customPath = path.join(__dirname, "../audioclips/Exclamations/")
      else
        customPath = @getConfig "exclamations.exclamationPath"
      @fileName = @selecCustomExclamationAudio(customPath)
      @audioExclamation = new Audio(customPath + @fileName)
      @fileName = @fileName.substr(0, @fileName.indexOf('.'))

  play: (combo) ->
    @setup(combo)

    if (@superExclamationLapse[0]) != 0
      return @playSuperExclamation()

    @isPlaying = false if (@audioExclamation.paused)
    return null if (@isPlaying or combo is 0)

    @audioExclamation.volume = @getConfig "exclamations.exclamationVolume"
    @isPlaying = true
    @audioExclamation.play()
    return (@fileName + "!")

  selecCustomExclamationAudio: (customPath) ->
    pathtoaudio = path.join(customPath)
    audioFiles = fs.readdirSync(pathtoaudio.toString())

    maxIndex = audioFiles.length - 1
    minIndex = 0
    randomIndex = Math.floor(Math.random() * (maxIndex - minIndex + 1) + minIndex)

    fileName = (audioFiles[randomIndex])

  selectExclamationAudio: (combo) ->
    return fileName = ("Triple Combo") if combo is 3
    return fileName = ("Super Combo") if combo > 3 and combo < 6
    return fileName = ("Hyper Combo") if combo > 5 and combo < 9
    return fileName = ("Brutal Combo") if combo > 8 and combo < 12
    return fileName = ("Master Combo") if combo > 11 and combo < 15
    return fileName = ("Blaster Combo") if combo > 14 and combo < 18
    return fileName = ("Awesome Combo") if combo > 17 and combo < 21
    return fileName = ("Monster Combo") if combo > 20 and combo < 24
    return fileName = ("King Combo") if combo > 23 and combo < 27
    return fileName = ("Killer Combo") if combo > 26 and combo < 30
    return fileName = ("Ultra Combo") if combo >= 30
    fileName = null

  playSuperExclamation: ->
    exclamationFoP = @getConfig "superExclamation.texts"
    pattern = new RegExp(/^.*[\\\/]/, '')

    if (pattern.text(exclamationFoP))
      pathtoaudio = exclamationFoP.substring(0, exclamationFoP.lastIndexOf("/"));
      filename = exclamationFoP.replace(/^.*[\\\/]/, '')
      ispath = true

    if (@getConfig "exclamations.type") is "onlyText"
      retur "Yes oh my God.wav" if (ispath)
    else if (@getConfigE "exclamations.type") is "onlyAudio"
      retur "Yes oh my God.wav"
    else
      return 0

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
