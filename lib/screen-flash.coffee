module.exports =
  flash: (editorElement) ->
    normalBG = editorElement.style.background
    c = @getConfig "color"
    editorElement.style.background = "rgb(#{c.red},#{c.green},#{c.blue})"
    setTimeout ->
      editorElement.style.background = normalBG
    , @getConfig "duration"

  getConfig: (config) ->
    atom.config.get "activate-power-mode.screenFlash.#{config}"
