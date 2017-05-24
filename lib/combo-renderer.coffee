{CompositeDisposable} = require "atom"
debounce = require "lodash.debounce"
defer = require "lodash.defer"
sample = require "lodash.sample"
exclamationAudio = require "./play-exclamation"
musicPlayer = require "./music-player"

module.exports =
  subscriptions: null
  conf: []
  isEnable: false
  currentStreak: 0
  level: 0
  maxStreakReached: false
  exclamationAudio: exclamationAudio
  musicPlayer: musicPlayer

  setPluginManager: (pluginManager) ->
    @pluginManager = pluginManager

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.comboMode.#{key}", (value) =>
        @conf[key] = value
    )

  enable: ->
    @isEnable = true
    @initConfigSubscribers()

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'exclamationEvery'
    @observe 'activationThreshold'
    @observe 'exclamationTexts'
    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:reset-max-combo": => @resetMaxStreak()

  reset: ->
    @container?.parentNode?.removeChild @container

  destroy: ->
    @isEnable = false
    @reset()
    @subscriptions?.dispose()
    @container = null
    @debouncedEndStreak?.cancel()
    @debouncedEndStreak = null
    @streakTimeoutObserver?.dispose()
    @opacityObserver?.dispose()
    @comboModeStyleObserver?.dispose()
    @exclamationsTypeAndLapseObserver?.dispose()
    @exclamationsTextsOrPathObserver?.dispose()
    @currentStreak = 0
    @level = 0
    @maxStreakReached = false
    @musicPlayer.destroy()

  createElement: (name, parent)->
    @element = document.createElement "div"
    @element.classList.add name
    parent.appendChild @element if parent
    @element

  setup: (editorElement) ->
    @editor = atom.workspace.getActiveTextEditor() #test
    if not @container
      @maxStreak = @getMaxStreak()
      @container = @createElement "streak-container"
      @container.classList.add "combo-zero"
      @title = @createElement "title", @container
      @title.textContent = "Combo"
      @max = @createElement "max", @container
      @max.textContent = "Max #{@maxStreak}"
      @counter = @createElement "counter", @container
      @bar = @createElement "bar", @container
      @remainingTime = @createElement "text", @container
      @exclamations = @createElement "exclamations", @container

      @streakTimeoutObserver?.dispose()
      @streakTimeoutObserver = atom.config.observe 'activate-power-mode.comboMode.streakTimeout', (value) =>
        @streakTimeout = value * 1000
        @endStreak()
        @debouncedEndStreak?.cancel()
        @debouncedEndStreak = debounce @endStreak.bind(this), @streakTimeout

      @opacityObserver?.dispose()
      @opacityObserver = atom.config.observe 'activate-power-mode.comboMode.opacity', (value) =>
        @container?.style.opacity = value

      @comboModeStyleObserver?.dispose()
      @comboModeStyleObserver = atom.config.observe 'activate-power-mode.comboMode.style', (value) =>
        @style = value

      @exclamationsTypeAndLapseObserver?.dispose()
      @exclamationsTypeAndLapseObserver = atom.config.observe 'activate-power-mode.comboMode.customExclamations.typeAndLapse', (value) =>
        @exclamationType = value[0]
        lapseValue = value.map(Number)
        if lapseValue[1] >= 10 and lapseValue[1] <= 100 or lapseValue[1] is 0
          @exclamationEvery = lapseValue[1]
        else if lapseValue[1] < 10
          @exclamationEvery = 10
        else if lapseValue[1] > 100
          @exclamationEvery = 100

      @exclamationsTextsOrPathObserver?.dispose()
      @exclamationsTextsOrPathObserver = atom.config.observe 'activate-power-mode.comboMode.customExclamations.textsOrPath', (value) =>
        if(value[0].indexOf('/') > -1)  or (value[0].indexOf("\\") > -1)
          @textsOrPathIsPath = true
        else
          @textsOrPathIsPath = false

    if @textsOrPathIsPath and @style is "custom" and @exclamationType is "onlyText"
      @conflict = true
    else if not @textsOrPathIsPath and @style is "custom" and @exclamationType != "onlyText"
      @conflict = true
    else
      @conflict = false

    @exclamations.innerHTML = ''

    editorElement.querySelector(".scroll-view").appendChild @container

    if @currentStreak
      leftTimeout = @streakTimeout - (performance.now() - @lastStreak)
      @refreshStreakBar leftTimeout

    @renderStreak()

  resetCounter: ->
    return if @currentStreak is 0

    @showExclamation "#{-@currentStreak}", 'down', false
    @endStreak()

  modifyStreak: (n) ->
    return if @currentStreak is 0 and n < 0

    @lastStreak = performance.now()
    @debouncedEndStreak()

    n = n * (@level + 1) if n > 0

    oldStreak = @currentStreak
    @currentStreak += n
    @currentStreak = 0 if @currentStreak < 0

    @streakIncreased n if n > 0
    @streakDecreased n if n < 0

    if @currentStreak is 0
      @endStreak()
    else
      @refreshStreakBar()
    @renderStreak()

    if oldStreak is 0 and n > 0
      @pluginManager.runOnComboStartStreak()

  streakIncreased: (n) ->
    @container.classList.remove "combo-zero"
    if @currentStreak > @maxStreak
      @increaseMaxStreak()

<<<<<<< HEAD:lib/combo-mode.coffee
    if not @reached and (@style is "killerInstinct" and @currentStreak >= 3)
      @reached = true
      @container.classList.add "reached"
    else if not @reached and (@style is "custom" and @currentStreak >= @getConfig("comboMode.activationThreshold"))
      @reached = true
      @container.classList.add "reached"

    if @getConfig("playBackgroundMusic.enabled") and @reached
      @musicPlayer.play @currentStreak

    if @style is "custom" and @getConfig("comboMode.customExclamations.enabled")
      if @currentStreak % @exclamationEvery is 0 and @reached and not @conflict
        @chooseExclamation()

    @refreshStreakBar()
=======
    return if @checkLevel()

    if @currentStreak % @conf['exclamationEvery'] is 0
      @showExclamation()
    else
      @showExclamation "+#{n}", 'up', false

  streakDecreased: (n) ->
    @showExclamation "#{n}", 'down', false
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee

    @checkLevel()
    if @currentStreak == 0
      @container.classList.add "combo-zero"

  checkLevel: ->
    level = 0
    for threshold, i in @conf['activationThreshold']
      break if @currentStreak < threshold
      level++

    if level != @level
      @container.classList.remove "level-#{@level}"
      @container.classList.add "level-#{level}"
      @showExclamation "#{level+1}x", 'level', false
      @pluginManager.runOnComboLevelChange(level, @level)
      @level = level
      return true

  getLevel: ->
    @level

  endStreak: ->
    if ((@exclamationEvery is 0 and not @conflict) or (@style is "killerInstinct")) and @reached
      @chooseExclamation()
    if @getConfig("playBackgroundMusic.enabled") and @reached
      @musicPlayer.actionEndStreak()
    @currentStreak = 0
    @maxStreakReached = false
    @container.classList.add "combo-zero"
    @container.classList.remove "level-#{@level}"
    @level = 0
    @container.classList.add "level-#{@level}"
    @renderStreak()
<<<<<<< HEAD:lib/combo-mode.coffee
    @debouncedShowExclamation?.cancel()

=======
    @refreshStreakBar(0)
    @pluginManager.runOnComboEndStreak()
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee

  renderStreak: ->
    @counter.textContent = @currentStreak
    @counter.classList.remove "bump"

    defer =>
      @counter.classList.add "bump"


    defer =>
      @counter.classList.add "bump"

  refreshStreakBar: (leftTimeout = @streakTimeout) ->
    scale = leftTimeout / @streakTimeout
    @bar.style.transition = "none"
    @bar.style.transform = "scaleX(#{scale})"

    setTimeout =>
      @bar.style.transform = ""
      @bar.style.transition = "transform #{leftTimeout}ms linear"
    , 100

  showExclamation: (text = null, type = 'message', trigger = true) ->
    exclamation = document.createElement "span"
    exclamation.classList.add "exclamation"
<<<<<<< HEAD:lib/combo-mode.coffee
    text = sample @getConfig "comboMode.customExclamations.textsOrPath" if text is null
=======
    exclamation.classList.add type
    text = sample @conf['exclamationTexts'] if text is null
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee
    exclamation.textContent = text

    @exclamations.appendChild exclamation
    setTimeout =>
      if exclamation.parentNode is @exclamations
        @exclamations.removeChild exclamation
    , 2000

<<<<<<< HEAD:lib/combo-mode.coffee
  playExclamation: ->
    @exclamationAudio.play(@currentStreak,@style)


  chooseExclamation: ->
    if @style is "custom"
      if @exclamationType is "onlyText"
        return @showExclamation()
      if @exclamationType is "onlyAudio"
        return @playExclamation()
      if @exclamationType is "bouth"
        return @showExclamation @playExclamation()
    if @style is "killerInstinct"
      @showExclamation @playExclamation()

  hasReached: ->
    @reached
=======
    if trigger
      @pluginManager.runOnComboExclamation(text)
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee

  getMaxStreak: ->
    maxStreak = localStorage.getItem "activate-power-mode.maxStreak"
    maxStreak = 0 if maxStreak is null
    maxStreak

  increaseMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", @currentStreak
    @maxStreak = @currentStreak
    @max.textContent = "Max #{@maxStreak}"
    if @maxStreakReached is false
<<<<<<< HEAD:lib/combo-mode.coffee
      @showExclamation "NEW MAX!!!"
=======
      @showExclamation "NEW MAX!!!", 'max-combo', false
      @pluginManager.runOnComboMaxStreak(@maxStreak)
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee
    @maxStreakReached = true

  resetMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", 0
    @maxStreakReached = false
    @maxStreak = 0
    if @max
      @max.textContent = "Max 0"
<<<<<<< HEAD:lib/combo-mode.coffee

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
=======
>>>>>>> refs/remotes/JoelBesada/master:lib/combo-renderer.coffee
