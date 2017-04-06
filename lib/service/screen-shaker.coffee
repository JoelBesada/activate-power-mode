{CompositeDisposable} = require "atom"
throttle = require "lodash.throttle"
random = require "lodash.random"

module.exports =
  subscriptions: null
  conf: []

  init: ->
    @initConfigSubscribers()
    @throttledShake = throttle @shakeElement.bind(this), 100, trailing: false

  disable: ->
    @subscriptions.dispose()

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.screenShake.#{key}", (value) =>
        @conf[key] = value
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'minIntensity'
    @observe 'maxIntensity'

  shake: (element) ->
    @throttledShake(element)

  shakeElement: (element) ->
    min = @conf['minIntensity']
    max = @conf['maxIntensity']

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
