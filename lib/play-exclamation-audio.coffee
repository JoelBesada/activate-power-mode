#inspired in code-champion
path = require "path"

module.exports =
  audioExclamation: null
  fileName: ""
  lapseType: ""
  lapse: 0
  isPlaying: false

  setup: (combo=0) ->

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

  play: (combo, type="exclamation") ->
    @setup(combo)

    if (type is "Time" or type is "time")
      fileName = @getSuperExclamation()
      return fileName

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

  getSuperExclamation: ->
    exclamationFoP = @getConfig "superExclamation.texts"
    if (exclamationFoP.indexOf('/') > -1)  or (exclamationFoP.indexOf("\\") > -1)
      ispath = true
    else
      ispath = false

    if (ispath)
      pathtoaudio = exclamationFoP.substring(0, exclamationFoP.lastIndexOf("/") + 1)
      pathtoaudio = path.join(__dirname, pathtoaudio)
      fileName = exclamationFoP.replace(/^.*[\\\/]/, '')
    else
      return exclamationFoP

    if (@getConfig "exclamations.type") is "onlyText"
      return (fileName + "!")
    else
      @audioExclamation = new Audio(pathtoaudio + fileName)
      @audioExclamation.volume = 1
      @isPlaying = true
      @audioExclamation.play()
      fileName = fileName.substr(0, fileName.indexOf('.')) if (@getConfig "exclamations.type") != "onlyAudio"
      return (fileName + "!")

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
