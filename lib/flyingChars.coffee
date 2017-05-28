random = require "lodash.random"

module.exports =
  init: ->
    @resetParticles()

    @animationFrame = requestAnimationFrame @drawParticles.bind(this)

  resetCanvas: ->
    @editor = null
    @editorElement = null
    cancelAnimationFrame(@animationFrame)

  resetParticles: ->
    @particlePointer = 0
    @particles = []
    @cursorX = 0
    @cursorY = 0

  destroy: ->
    @resetCanvas()
    @resetParticles()
    @canvas?.parentNode.removeChild @canvas
    @canvas = null

  setupCanvas: (editor, editorElement) ->
    if not @canvas
      @canvas = document.createElement "canvas"
      @context = @canvas.getContext "2d"
      @canvas.classList.add "power-mode-canvas"

    (editorElement.shadowRoot ? editorElement).appendChild @canvas
    @canvas.style.display = "block"
    @editorElement = editorElement
    @editor = editor

    @init()

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

  spawnParticles: (screenPosition) ->
    cursorOffset = @calculateCursorOffset()

    {left, top} = @editorElement.pixelPositionForScreenPosition screenPosition
    left += cursorOffset.left - @editorElement.getScrollLeft()
    top += cursorOffset.top - @editorElement.getScrollTop()

    getBuffer: -> @buffer
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()

    pos = editor.getCursorBufferPosition()
    row = pos.row
    col = pos.column
    lastChar = editor.getTextInBufferRange([
      [row,col-1],
      [row,col]
    ])

    numParticles = 1 #random @getConfig("spawnCount.min"), @getConfig("spawnCount.max")
    colorType = @getConfig "colours.type"
    if (colorType == "random") # If colours are random
      seed = Math.random()
      # Use the golden ratio to keep colours distinct
      golden_ratio_conjugate = 0.618033988749895

      while numParticles--
        seed += golden_ratio_conjugate
        seed = seed - (seed//1)
        rgb = @hsvToRgb(seed,1,1)
        r = (rgb[0]*255)//1
        g = (rgb[1]*255)//1
        b = (rgb[2]*255)//1
        color = "rgb(#{r},#{g},#{b})"

        maxparticles = 100
        @particles[@particlePointer] = @createParticle left, top, color, Math.random()*2*Math.PI, lastChar
        @particlePointer = (@particlePointer + 1) % maxparticles

    else
      if colorType == "fixed"
        c = @getConfig "colours.fixed"
        color = "rgb(#{c.red},#{c.green},#{c.blue})"
      else
        color = @getColorAtPosition [screenPosition.row, screenPosition.column - 1]

      while numParticles--
        @particles[@particlePointer] = @createParticle left, top, color, Math.random()*2*Math.PI, lastChar
        @particlePointer = (@particlePointer + 1) % @getConfig("totalCount.max")

  getColorAtPosition: (screenPosition) ->
    bufferPosition = @editor.bufferPositionForScreenPosition screenPosition
    scope = @editor.scopeDescriptorForBufferPosition bufferPosition

    try
      el = (@editorElement.shadowRoot ? @editorElement).querySelector scope.toString()
    catch error
      "rgb(255, 255, 255)"

    if el
      getComputedStyle(el).color
    else
      "rgb(255, 255, 255)"


  calculateCursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = (@editorElement.shadowRoot ? @editorElement).querySelector(".scroll-view").getBoundingClientRect()

    top: scrollViewRect.top - editorRect.top + @editor.getLineHeightInPixels() / 2
    left: scrollViewRect.left - editorRect.left

  createParticle: (x, y, color, angle, chr) ->
    size: 2 + Math.random()*4
    x: x+Math.cos(angle)*150
    y: y+Math.sin(angle)*150
    startX: x+Math.cos(angle)*150
    startY: y+Math.sin(angle)*150
    targetX: x
    targetY: y+8
    lifetime: 0
    color: color
    char: chr

  drawParticles: ->
    @animationFrame = requestAnimationFrame @drawParticles.bind(this) if @editor
    return unless @canvas and @editorElement

    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    gco = @context.globalCompositeOperation
    @context.globalCompositeOperation = "lighter"


    animationLength = 20
    for particle in @particles
      continue if particle.lifetime > animationLength

      particle.lifetime += 1;
      if particle.lifetime <= animationLength+3
        particle.x = particle.startX + (particle.targetX - particle.startX)*(particle.lifetime/animationLength)
        particle.y = particle.startY + (particle.targetY - particle.startY)*(particle.lifetime/animationLength)

      @context.font= 18+(animationLength-particle.lifetime)/animationLength * 35 + 'px bold Arial'
      @context.fillStyle = particle.color
      @context.fillText(particle.char, particle.x,particle.y, 30)

    @context.globalCompositeOperation = gco


  getConfig: (config) ->
    atom.config.get "activate-power-mode.particles.#{config}"
