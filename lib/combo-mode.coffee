debounce = require "lodash.debounce"
defer = require "lodash.defer"
sample = require "lodash.sample"

module.exports =
  currentStreak: 0
  reached: false

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
    reached = false

  createElement: (name, parent)->
    @element = document.createElement "div"
    @element.classList.add name
    parent.appendChild @element if parent
    @element

  setup: (editorElement) ->
    if not @container
      @container = @createElement "streak-container"
      @title = @createElement "title", @container
      @title.textContent = "Combo"
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

    (editorElement.shadowRoot ? editorElement).querySelector(".scroll-view").appendChild @container

    if @currentStreak
      leftTimeout = @streakTimeout - (performance.now() - @lastStreak)
      @refreshStreakBar leftTimeout

    @renderStreak()

  increaseStreak: ->
    @lastStreak = performance.now()
    @debouncedEndStreak()

    @currentStreak++
    @showExclamation() if @currentStreak > 0 and @currentStreak % @getConfig("exclamationEvery") is 0

    if @currentStreak >= @getConfig("activationThreshold") and not @reached
      @reached = true
      @container.classList.add "reached"

    @refreshStreakBar()

    @renderStreak()

  endStreak: ->
    @currentStreak = 0
    @reached = false
    @container.classList.remove "reached"
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

  showExclamation: ->
    exclamation = document.createElement "span"
    exclamation.classList.add "exclamation"
    exclamation.textContent = sample @getConfig "exclamationTexts"

    @exclamations.insertBefore exclamation, @exclamations.childNodes[0]
    setTimeout =>
      @exclamations.removeChild exclamation if @exclamations.firstChild
    , 3000

  hasReached: ->
    @reached

  getConfig: (config) ->
    atom.config.get "activate-power-mode.comboMode.#{config}"
