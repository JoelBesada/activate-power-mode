debounce = require "lodash.debounce"
defer = require "lodash.defer"
sample = require "lodash.sample"
exclamationAudio = require "./play-exclamation-audio"
musicPlayer = require "./music-player"

module.exports =
  currentStreak: 0
  reached: false
  maxStreakReached: false
  exclamationAudio: exclamationAudio
  musicPlayer: musicPlayer
  lapseType: ""
  lapse: 0
  islapsing: false

  reset: ->
    @container?.parentNode?.removeChild @container

  destroy: ->
    @reset()
    @container = null
    @debouncedEndStreak?.cancel()
    @debouncedEndStreak = null
    @streakTimeoutObserver?.dispose()
    @opacityObserver?.dispose()
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

      @superExclamationLapse?.dispose()
      @superExclamationLapse = atom.config.observe "activate-power-mode.superExclamation.exclamationLapse", (value) =>
        @sExclamationLapse = value
      @lapseType = @sExclamationLapse[0]
      @lapse = @sExclamationLapse[1]

    if (@lapseType is "Time" or @lapseType is "time")
      @timeLapse = @lapse * 1000
      @debouncedShowExclamation?.cancel()
      @debouncedShowExclamation = debounce @showExclamation.bind(this),@timeLapse

      @opacityObserver?.dispose()
      @opacityObserver = atom.config.observe 'activate-power-mode.comboMode.opacity', (value) =>
        @container?.style.opacity = value

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

    if @getConfigE "playBackgroundMusic.enabled"
      @musicPlayer.play @currentStreak

    @chooseExclamation()

    if @currentStreak >= @getConfig("activationThreshold") and not @reached
      @reached = true
      @container.classList.add "reached"

    @refreshStreakBar()

    @renderStreak()

  endStreak: ->
    if ((@getConfigE "exclamations.exclamationEvery") is 0 or (@getConfigE "exclamations.type") is "killerInstint") and @currentStreak > 2
      @showExclamation @playExclamation()
    @currentStreak = 0
    @reached = false
    @maxStreakReached = false
    @container.classList.add "combo-zero"
    @container.classList.remove "reached"
    @renderStreak()
    @debouncedShowExclamation?.cancel()
    @islapsing = false


  renderStreak: ->
    @counter.textContent = @currentStreak
    #@counter.textContent = @lapseType + @lapse
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
    if (@getConfigE "exclamations.type") != "onlyAudio"
      exclamation = document.createElement "span"
      exclamation.classList.add "exclamation"
      text = sample @getConfigE "exclamations.exclamationTexts" if text is null
      exclamation.textContent = text

      @exclamations.insertBefore exclamation, @exclamations.childNodes[0]
      setTimeout =>
        if exclamation.parentNode is @exclamations
          @exclamations.removeChild exclamation
      , 2000

  playExclamation: ->
    if (@getConfigE "exclamations.type") != "onlyText"
      @exclamationAudio.play @currentStreak
    else
      return null

  playSuperExclamation: ->
    #if @getConfigE "playBackgroundMusic.enabled"
      #@musicPlayer.mute @lapseType, 5
    @exclamationAudio.play @currentStreak, @lapseType

  chooseExclamation: ->
    if @currentStreak > 0 and @currentStreak % @getConfigE("exclamations.exclamationEvery") is 0 and (@getConfigE "exclamations.type") != "killerInstint"
      return @showExclamation @playExclamation()

    if @currentStreak > 0 and @currentStreak % @lapse is 0 and (@lapseType is "Streak" or @lapseType is "streak")
      return @showExclamation @playSuperExclamation()

    if @lapse != 0 and (@lapseType is "Time" or @lapseType is "time") and (!@islapsing)
      #@debouncedShowExclamation @playSuperExclamation()
      @islapsing = true

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
    if @maxStreakReached is false and @getConfigE "exclamations.enabled"
      @showExclamation "NEW MAX!!!"
    @maxStreakReached = true

  resetMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", 0
    @maxStreakReached = false
    @maxStreak = 0
    if @max
      @max.textContent = "Max 0"

  getConfig: (config) ->
    atom.config.get "activate-power-mode.comboMode.#{config}"

  getConfigE: (config) ->
    atom.config.get "activate-power-mode.#{config}"
