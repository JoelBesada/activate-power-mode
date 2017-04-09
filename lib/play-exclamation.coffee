#inspired in code-champion
path = require "path"

module.exports =
  audio: null
  fileName: ""

  setupExclamation: (combo,style) ->
    exclamationPath = @getConfig "customExclamations.textsOrPath"
    customPath = exclamationPath[0]

    exclamationTaL = @getConfig "customExclamations.typeAndLapse"
    @exclamationType = exclamationTaL[0]

    if style is "killerInstint"
      pathtoaudio = path.join(__dirname, "../audioclips/Exclamations/")
      @fileName = @killerInstintAudio(combo)
      @audio = new Audio(pathtoaudio + @fileName + ".wav")
    else
      @fileName = @customAudio(customPath)
      @audio = new Audio(customPath + @fileName)
      @fileName = @fileName.substr(0, @fileName.indexOf('.'))

  setupSuperExclamation: (style) -> #not yet
    exclamationToP = @getConfig "customSuperExclamation.textOrFile"
    customPath = exclamationPath[0]

    exclamationTaL = @getConfig "customExclamations.typeAndLapse"
    @exclamationType = exclamationTaL[0]

    superExclamationLapse = @getConfig "customSuperExclamation.lapse"
    lapsetype = superExclamationLapse[0]
    lapse = superExclamationLapse[1]

    if (exclamationToP.indexOf('/') > -1)  or (exclamationToP.indexOf("\\") > -1)
      pathtoaudio = exclamationToP.substring(0, exclamationToP.lastIndexOf("/") + 1)
      @fileName = exclamationToP.replace(/^.*[\\\/]/, '')
      if (pathtoaudio is "../audioclips/exclamations/")
        pathtoaudio = path.join(__dirname, pathtoaudio)
    else
      return exclamationToP

    if exclamationType is "onlyText" #array typeAndLapse
      return (@fileName + "!")
    else
      @audioExclamation = new Audio(pathtoaudio + @fileName)
      @audioExclamation.volume = 1
      @isPlaying = true
      @audioExclamation.play()
      if exclamationType is "bouth"
        @fileName = @fileName.substr(0, @fileName.indexOf('.'))
        return (@fileName + "!")

  play: (type,combo,style) ->
    @setupExclamation(combo,style) if type is "exclamation"
    @setupSuperExclamation(style) if type is "superExclamation"

    @audio.volume = @getConfig "exclamationVolume"
    @audio.play()
    if @exclamationType is "bouth" or style is "killerInstint"
      return (@fileName + "!")

  killerInstintAudio: (combo) ->
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
