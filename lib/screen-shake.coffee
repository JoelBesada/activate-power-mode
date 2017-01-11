random = require "lodash.random"

module.exports =
  shake: (editorElement) ->
    min = @getConfig "minIntensity"
    max = @getConfig "maxIntensity"

    x = @shakeIntensity min, max
    y = @shakeIntensity min, max

    editorElement.style.transform = "translate(#{x}, #{y})"

    requestAnimationFrame ->
      editorElement.style.transform = "translate(0, 0)"

  shakeIntensity: (min, max) ->
    direction = if Math.random() > 0.5 then -1 else 1
    random(min, max, true) * direction

  getConfig: (config) ->
    atom.config.get "activate-power-mode.screenShake.#{config}"
