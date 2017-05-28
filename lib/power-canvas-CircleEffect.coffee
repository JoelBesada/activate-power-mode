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
        color = "#{r},#{g},#{b}"

        @particles[@particlePointer] = @createParticle left, top, color
        @particlePointer = (@particlePointer + 1) % @getConfig("totalCount.max")

    else
      if colorType == "fixed"
        c = @getConfig "colours.fixed"
        color = "rgb(#{c.red},#{c.green},#{c.blue})"
      else
        color = @getColorAtPosition [screenPosition.row, screenPosition.column - 1]

      while numParticles--
        @particles[@particlePointer] = @createParticle left, top, color, sizection
        @particlePointer = (@particlePointer + 1) % @getConfig("totalCount.max")

  getColorAtPosition: (screenPosition) ->
    bufferPosition = @editor.bufferPositionForScreenPosition screenPosition
    scope = @editor.scopeDescriptorForBufferPosition bufferPosition

    try
      el = (@editorElement.shadowRoot ? @editorElement).querySelector scope.toString()
    catch error
      "255, 255, 255"

    if el
      getComputedStyle(el).color
    else
      "255, 255, 255"


  calculateCursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = (@editorElement.shadowRoot ? @editorElement).querySelector(".scroll-view").getBoundingClientRect()

    top: scrollViewRect.top - editorRect.top + @editor.getLineHeightInPixels() / 2
    left: scrollViewRect.left - editorRect.left

  createParticle: (x, y, color) ->
    x: x+10
    y: y
    alpha: 1
    color: color
    velocity: 0.1
    size: 1
    rdm: Math.random()


  drawParticles: ->
    @animationFrame = requestAnimationFrame @drawParticles.bind(this) if @editor
    return unless @canvas and @editorElement


    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    gco = @context.globalCompositeOperation
    @context.globalCompositeOperation = "lighter"

    for particle in @particles
      continue if particle.alpha <= 0.1

      particle.alpha *= 0.96
      particle.size += particle.alpha * 3;

      @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
      size = random @getConfig("size.min"), @getConfig("size.max"), true

      radius = particle.size
      startAngle = 2 * Math.PI + particle.rdm*2 * Math.PI - (particle.alpha-0.08) * 2 * Math.PI
      endAngle = 2 * Math.PI + particle.rdm*2 * Math.PI + (particle.alpha-0.08) * 2 * Math.PI

      counterClockwise = false
      @context.beginPath()

      @context.arc(particle.x, particle.y, radius, startAngle, endAngle, counterClockwise)
      @context.lineWidth = 4
      #@context.strokeStyle = particle.color
      @context.strokeStyle = 'rgba('+particle.color+','+particle.alpha*1.5+')';
      @context.stroke()

    @context.globalCompositeOperation = gco

  getConfig: (config) ->
    atom.config.get "activate-power-mode.particles.#{config}"
