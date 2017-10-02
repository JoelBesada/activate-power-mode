{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  key: "activate-power-mode.particles.colours"
  conf: []
  golden_ratio_conjugate: 0.618033988749895

  init: ->
    @initConfigSubscribers()
    @initList()

  disable: ->
    @subscriptions?.dispose()
    @colorList?.dispose()
    @colorList = null

  observe: (key) ->
    @subscriptions.add atom.config.observe(
      "#{@key}.#{key}", (value) =>
        @conf[key] = value
    )

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'type'
    @observe 'fixed'
    @observe 'randomType'

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

  getRandomBrightColor: ->
    @seed += @golden_ratio_conjugate
    @seed = @seed - (@seed//1)
    rgb = @hsvToRgb(@seed,1,1)
    r = (rgb[0]*255)//1
    g = (rgb[1]*255)//1
    b = (rgb[2]*255)//1
    "rgb(#{r},#{g},#{b})"

  getRandomAllColor: ->
    r = Math.floor(Math.random() * 256)
    g = Math.floor(Math.random() * 256)
    b = Math.floor(Math.random() * 256)
    "rgb(#{r},#{g},#{b})"

  getRandomGenerator: ->
    if @conf['randomType'] == 'bright'
      @seed = Math.random()

      loop
        yield @getRandomBrightColor()
      return

    else
      loop
        yield @getRandomAllColor()
      return

  getRandomSpawnGenerator: ->
    if @conf['randomType'] == 'bright'
      @seed = Math.random()
      color = @getRandomBrightColor()
    else
      color = @getRandomAllColor()

    loop
      yield color
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
    else if colorType == 'randomSpawn'
      @getRandomSpawnGenerator()
    else
      @getColorAtCursorGenerator cursor, editorElement

  selectColor: (code) ->
    atom.config.set("#{@key}.type", code)

  initList: ->
    return if @colorList?

    @colorList = require "./color-list"
    @colorList.init this

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:select-color": =>
        @colorList.toggle()
