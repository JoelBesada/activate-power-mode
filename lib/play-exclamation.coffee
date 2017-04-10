#inspired in code-champion
path = require "path"

module.exports =
  audio: null
  fileName: ""

  setup: (combo,style) ->
    if style is "killerInstinct"
      pathtoaudio = path.join(__dirname, "../audioclips/Exclamations/")
      @fileName = @killerInstinctAudio(combo)
      @audio = new Audio(pathtoaudio + @fileName + ".wav")
    else
      exclamationPath = @getConfig "customExclamations.textsOrPath"
      if exclamationPath[0] is "../audioclips/Exclamations/"
        customPath = path.join(__dirname, exclamationPath[0])
      else
        customPath = exclamationPath[0]
      @fileName = @customAudio(customPath)
      @audio = new Audio(customPath + @fileName)
      @fileName = @fileName.substr(0, @fileName.indexOf('.'))

  play: (combo,style) ->
    @setup(combo,style)

    @audio.volume = @getConfig "exclamationVolume"
    @audio.play()
    return (@fileName + "!")

  killerInstinctAudio: (combo) ->
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

  customAudio: (customPath) ->
    pathtoaudio = path.join(customPath)
    audioFiles = fs.readdirSync(pathtoaudio.toString())

    maxIndex = audioFiles.length - 1
    minIndex = 0
    randomIndex = Math.floor(Math.random() * (maxIndex - minIndex + 1) + minIndex)

    fileName = (audioFiles[randomIndex])

  getConfig: (config) ->
    atom.config.get "activate-power-mode.comboMode.#{config}"
