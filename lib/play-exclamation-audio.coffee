path = require "path"

module.exports =
  audioExclamation: new Audio(__dirname + "../audioclips/gun.wav")
  isPlaying: false

  play: (combo) ->

    if (@audioExclamation.paused)
      @isPlaying = false

    if (@isPlaying)
      return null

    if (@getConfig "exclamationPath") is "customAudioclip"
      @audioExclamation = new Audio(@selecCustomExclamationAudio())
    else
      @audioExclamation = new Audio(@selectExclamationAudio(combo))

    @audioExclamation.volume = @getConfig "exclamationVolume"
    @isPlaying = true
    @audioExclamation.play()

  selecCustomExclamationAudio: ->
    pathtoaudio = @getConfig "customExclamationPath"

    #Save all files in the directory
    audioFiles = fs.readdirSync(pathtoaudio.toString())

    #Select a random file
    maxIndex = audioFiles.length - 1
    minIndex = 0
    randomIndex = Math.floor(Math.random() * (maxIndex - minIndex + 1) + minIndex)

    audioPath = (pathtoaudio + audioFiles[randomIndex])

  selectExclamationAudio: (combo) ->
    pathtoaudio = path.join(__dirname, "../audioclips/Exclamation/")
    return audioPath = (pathtoaudio + "Triple-Combo.wav") if combo is 3
    return audioPath = (pathtoaudio + "Super-Combo.wav") if combo > 3 and combo < 6
    return audioPath = (pathtoaudio + "Hyper-Combo.wav") if combo > 5 and combo < 9
    return audioPath = (pathtoaudio + "Brutal-Combo.wav") if combo > 8 and combo < 12
    return audioPath = (pathtoaudio + "Master-Combo.wav") if combo > 11 and combo < 15
    return audioPath = (pathtoaudio + "Blaster-Combo.wav") if combo > 14 and combo < 18
    return audioPath = (pathtoaudio + "Awesome-Combo.wav") if combo > 17 and combo < 21
    return audioPath = (pathtoaudio + "Monster-Combo.wav") if combo > 20 and combo < 24
    return audioPath = (pathtoaudio + "King-Combo.wav") if combo > 23 and combo < 27
    return audioPath = (pathtoaudio + "Killer-Combo.wav") if combo > 26 and combo < 30
    return audioPath = (pathtoaudio + "Ultra-Combo.wav") if combo >= 30
    audioPath = null

  getConfig: (config) ->
    atom.config.get "activate-power-mode.playExclamation.#{config}"
