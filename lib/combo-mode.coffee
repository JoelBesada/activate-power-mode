debounce = require "lodash.debounce"
defer = require "lodash.defer"
sample = require "lodash.sample"
exclamationAudio = require "./play-exclamation"
musicPlayer = require "./music-player"

module.exports =
  currentStreak: 0
  reached: false
  maxStreakReached: false
  exclamationAudio: exclamationAudio
  musicPlayer: musicPlayer

  reset: ->
    @container?.parentNode?.removeChild @container

  destroy: ->
    @reset()
    @container = null
    @debouncedEndStreak?.cancel()
    @debouncedEndStreak = null
    @streakTimeoutObserver?.dispose()
    @opacityObserver?.dispose()
    @comboModeStyleObserver?.dispose()
    @exclamationsTypeAndLapseObserver?.dispose()
    @exclamationsTextsOrPathObserver?.dispose()
    @currentStreak = 0
    @reached = false
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

  increaseStreak: ->
    @lastStreak = performance.now()
    @debouncedEndStreak()

    @currentStreak++

    @container.classList.remove "combo-zero"
    if @currentStreak > @maxStreak
      @increaseMaxStreak()

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

    @renderStreak()

  endStreak: ->
    if ((@exclamationEvery is 0 and not @conflict) or (@style is "killerInstinct")) and @reached
      @chooseExclamation()
    if @getConfig("playBackgroundMusic.enabled") and @reached
      @musicPlayer.actionEndStreak()
    @currentStreak = 0
    @reached = false
    @maxStreakReached = false
    @container.classList.add "combo-zero"
    @container.classList.remove "reached"
    @renderStreak()
    @debouncedShowExclamation?.cancel()


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

  showExclamation: (text = null) ->
    exclamation = document.createElement "span"
    exclamation.classList.add "exclamation"
    text = sample @getConfig "comboMode.customExclamations.textsOrPath" if text is null
    exclamation.textContent = text

    @exclamations.insertBefore exclamation, @exclamations.childNodes[0]
    setTimeout =>
      if exclamation.parentNode is @exclamations
        @exclamations.removeChild exclamation
    , 2000

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

  getMaxStreak: ->
    maxStreak = localStorage.getItem "activate-power-mode.maxStreak"
    maxStreak = 0 if maxStreak is null
    maxStreak

  increaseMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", @currentStreak
    @maxStreak = @currentStreak
    @max.textContent = "Max #{@maxStreak}"
    if @maxStreakReached is false
      @showExclamation "NEW MAX!!!"
    @maxStreakReached = true

  resetMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", 0
    @maxStreakReached = false
    @maxStreak = 0
    if @max
      @max.textContent = "Max 0"

  getConfig: (config) ->
    atom.config.get "activate-power-mode.#{config}"
