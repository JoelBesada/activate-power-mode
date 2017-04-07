{CompositeDisposable} = require "atom"
debounce = require "lodash.debounce"
defer = require "lodash.defer"
sample = require "lodash.sample"

module.exports =
  subscriptions: null
  conf: []
  currentStreak: 0
  level: 0
  maxStreakReached: false

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.comboMode.#{key}", (value) =>
        @conf[key] = value
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'exclamationEvery'
    @observe 'activationThreshold'
    @observe 'exclamationTexts'

  reset: ->
    @container?.parentNode?.removeChild @container

  destroy: ->
    @reset()
    @subscriptions.dispose()
    @container = null
    @debouncedEndStreak?.cancel()
    @debouncedEndStreak = null
    @streakTimeoutObserver?.dispose()
    @opacityObserver?.dispose()
    @currentStreak = 0
    @level = 0
    @maxStreakReached = false

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

    @exclamations.innerHTML = ''

    editorElement.querySelector(".scroll-view").appendChild @container

    if @currentStreak
      leftTimeout = @streakTimeout - (performance.now() - @lastStreak)
      @refreshStreakBar leftTimeout

    @renderStreak()

  resetCounter: ->
    @modifyStreak(-@currentStreak)
    @endStreak()

  modifyStreak: (n) ->
    @lastStreak = performance.now()
    @debouncedEndStreak()

    n = n * (@level + 1) if n > 0

    @currentStreak += n
    @currentStreak = 0 if @currentStreak < 0

    @streakIncreased n if n > 0
    @streakDecreased n if n < 0

    @refreshStreakBar()
    @renderStreak()

  streakIncreased: (n) ->
    @container.classList.remove "combo-zero"
    if @currentStreak > @maxStreak
      @increaseMaxStreak()

    if @currentStreak % @conf['exclamationEvery'] is 0
      @showExclamation()
    else
      @showExclamation "+#{n}", 'up'

    @checkLevel()

  streakDecreased: (n) ->
    @showExclamation "#{n}", 'down'

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
      @level = level
      @container.classList.add "level-#{@level}"

  getLevel: ->
    @level

  endStreak: ->
    @currentStreak = 0
    @maxStreakReached = false
    @container.classList.add "combo-zero"
    @container.classList.remove "level-#{@level}"
    @level = 0
    @container.classList.add "level-#{@level}"
    @renderStreak()

  renderStreak: ->
    @counter.textContent = @currentStreak
    @counter.classList.remove "bump"

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

  showExclamation: (text = null, type = null) ->
    exclamation = document.createElement "span"
    exclamation.classList.add "exclamation"
    exclamation.classList.add type if type
    text = sample @conf['exclamationTexts'] if text is null
    exclamation.textContent = text

    @exclamations.insertBefore exclamation, @exclamations.childNodes[0]
    setTimeout =>
      if exclamation.parentNode is @exclamations
        @exclamations.removeChild exclamation
    , 2000

  getMaxStreak: ->
    maxStreak = localStorage.getItem "activate-power-mode.maxStreak"
    maxStreak = 0 if maxStreak is null
    maxStreak

  increaseMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", @currentStreak
    @maxStreak = @currentStreak
    @max.textContent = "Max #{@maxStreak}"
    @showExclamation "NEW MAX!!!" if @maxStreakReached is false
    @maxStreakReached = true

  resetMaxStreak: ->
    localStorage.setItem "activate-power-mode.maxStreak", 0
    @maxStreakReached = false
    @maxStreak = 0
    if @max
      @max.textContent = "Max 0"
