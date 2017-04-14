{CompositeDisposable} = require "atom"
throttle = require "lodash.throttle"
random = require "lodash.random"

module.exports =
  enabled: false
  subscriptions: null
  conf: []

  init: ->
    @enableSubscription = atom.config.observe(
      'activate-power-mode.screenShake.enabled', (value) =>
        @enabled = value
        if @enabled
          @enable()
        else
          @disable()
    )

  destroy: ->
    @enableSubscription.dispose()
    @disable()

  enable: ->
    @initConfigSubscribers()
    @throttledShake = throttle @shakeElement.bind(this), 100, trailing: false

  disable: ->
    @subscriptions?.dispose()

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.screenShake.#{key}", (value) =>
        @conf[key] = value
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'minIntensity'
    @observe 'maxIntensity'

  shake: (element, intensity) ->
    @throttledShake(element, intensity) if @enabled

  shakeElement: (element, intensity) ->
    min = @conf['minIntensity']
    max = @conf['maxIntensity']
    if intensity is 'max'
      min = max - min
      max = max + 2
    else if intensity is 'min'
      max = max - min

    x = @shakeIntensity min, max
    y = @shakeIntensity min, max

    element.style.top = "#{y}px"
    element.style.left = "#{x}px"

    setTimeout ->
      element.style.top = ""
      element.style.left = ""
    , 75

  shakeIntensity: (min, max) ->
    direction = if Math.random() > 0.5 then -1 else 1
    random(min, max, true) * direction
