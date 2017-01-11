random = require "lodash.random"

module.exports =
  shake: (editorElement) ->
    min = @getConfig "minIntensity"
    max = @getConfig "maxIntensity"

    x = @shakeIntensity min, max
    y = @shakeIntensity min, max

    editorElement.style.top = "#{y}px"
    editorElement.style.left = "#{x}px"

    setTimeout ->
      editorElement.style.top = ""
      editorElement.style.left = ""
    , 75

  shakeIntensity: (min, max) ->
    direction = if Math.random() > 0.5 then -1 else 1
    random(min, max, true) * direction

  getConfig: (config) ->
    atom.config.get "activate-power-mode.screenShake.#{config}"
