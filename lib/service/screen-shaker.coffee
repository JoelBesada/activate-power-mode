throttle = require "lodash.throttle"
random = require "lodash.random"

module.exports =
  init: ->
    @throttledShake = throttle @shakeElement.bind(this), 100, trailing: false

  shake: (element) ->
    @throttledShake(element)

  shakeElement: (element) ->
    min = @getConfig "minIntensity"
    max = @getConfig "maxIntensity"

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

  getConfig: (config) ->
    atom.config.get "activate-power-mode.screenShake.#{config}"
