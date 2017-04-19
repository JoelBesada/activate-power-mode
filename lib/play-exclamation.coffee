#inspired in code-champion
path = require "path"

module.exports =
  audio: null
  fileName: ""

  setup: (combo,style) ->
    if style is "killerInstinct"
      pathtoaudio = path.join(__dirname, "../audioclips/exclamations/")
      @fileName = @killerInstinctAudio(combo)
      @audio = new Audio(pathtoaudio + @fileName + ".wav")
    else
      exclamationPath = @getConfig "customExclamations.textsOrPath"
      if exclamationPath[0] is "../audioclips/exclamations/"
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

  customAudio: (pathtoaudio) ->
    allFiles = fs.readdirSync(pathtoaudio.toString())
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

    maxIndex = allFiles.length - 1
    minIndex = 0
    randomIndex = Math.floor(Math.random() * (maxIndex - minIndex + 1) + minIndex)

    fileName = (allFiles[randomIndex])

  getConfig: (config) ->
    atom.config.get "activate-power-mode.comboMode.#{config}"
