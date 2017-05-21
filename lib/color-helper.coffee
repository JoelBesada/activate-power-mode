{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  conf: []
  golden_ratio_conjugate: 0.618033988749895

  init: ->
    @initConfigSubscribers()

  disable: ->
    @subscriptions?.dispose()

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "activate-power-mode.particles.colours.#{key}", (value) =>
        @conf[key] = value
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'type'
    @observe 'fixed'

  hsvToRgb: (h,s,v) -> # HSV to RGB algorithm, as per wikipedia
    c = v * s
    h2 = (360.0*h) /60.0 # According to wikipedia, 0<h<360...
    h3 = Math.abs((h2%2) - 1.0)
    x = c * (1.0 - h3)
    m = v - c
    if 0<=h2<1 then return [c+m,x+m,m]
    if 1<=h2<2 then return [x+m,c+m,m]
    if 2<=h2<3 then return [m,c+m,x+m]
    if 3<=h2<4 then return [m,x+m,c+m]
    if 4<=h2<5 then return [x+m,m,c+m]
    if 5<=h2<6 then return [c+m,m,x+m]

  getFixedColorGenerator: ->
    c = @conf['fixed']
    color = "rgb(#{c.red},#{c.green},#{c.blue})"

    loop
      yield color
    return

  getRandomGenerator: ->
    seed = Math.random()
    loop
      seed += @golden_ratio_conjugate
      seed = seed - (seed//1)
      rgb = @hsvToRgb(seed,1,1)
      r = (rgb[0]*255)//1
      g = (rgb[1]*255)//1
      b = (rgb[2]*255)//1

      yield "rgb(#{r},#{g},#{b})"
    return

  getColorAtCursorGenerator: (cursor, editorElement) ->
    color = @getColorAtCursor cursor, editorElement
    loop
      yield color
    return

  getColorAtCursor: (cursor, editorElement) ->
    scope = cursor.getScopeDescriptor()
    scope = scope.toString().replace(/\./g, '.syntax--')

    try
      el = editorElement.querySelector scope
    catch error
      "rgb(255, 255, 255)"

    if el
      getComputedStyle(el).color
    else
      "rgb(255, 255, 255)"

  generateColors: (cursor, editorElement) ->
    colorType = @conf['type']
    if (colorType == 'random')
      return @getRandomGenerator()
    else if colorType == 'fixed'
      @getFixedColorGenerator()
    else
      @getColorAtCursorGenerator cursor, editorElement
