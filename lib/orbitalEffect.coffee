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

    @cursorX = left
    @cursorY = top

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

        maxparticles = 100
        @particles[@particlePointer] = @createParticle left, top, color
        @particlePointer = (@particlePointer + 1) % maxparticles

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
    size: 2 + Math.random()*4
    x: x
    y: y
    shiftx: x
    shifty: y
    angle: 0
    speed: 0.03 + Math.random()*0.02
    force: -(Math.random()*2)-4
    orbit: 3
    lifetime: 0
    color: color
    lastPointsX: []
    lastPointsY: []



  drawParticles: ->
    @animationFrame = requestAnimationFrame @drawParticles.bind(this) if @editor
    return unless @canvas and @editorElement


    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    gco = @context.globalCompositeOperation
    @context.globalCompositeOperation = "lighter"

    @context.fillStyle = 'rgba(0,0,0,0.01)';
    @context.fillRect(0, 0, @canvas.width, @canvas.height);
    for particle in @particles
      continue if particle.lifetime >= 500

      particle.angle -= particle.speed;
      particle.shiftx += (@cursorX - particle.shiftx) * particle.speed;
      particle.shifty += (@cursorY - particle.shifty) * particle.speed;
      particle.x = particle.shiftx + Math.sin(1 + particle.angle) * (particle.orbit*particle.force);
      particle.y = particle.shifty + Math.cos(1 + particle.angle) * (particle.orbit*particle.force);

      particle.orbit += (20 - particle.orbit) * 0.01;
      particle.lifetime += 1;

      trailLength = 30;


      num = 0
      for xs in particle.lastPointsX
        @context.beginPath();
        @context.fillStyle = "rgba("+particle.color+","+((500-particle.lifetime)/1000 - ((trailLength-num)/trailLength))+")"
        @context.arc(particle.lastPointsX[num], particle.lastPointsY[num], particle.size, 0, Math.PI*2, true);
        @context.fill();
        num += 1


      particle.lastPointsX.push(particle.x);
      particle.lastPointsY.push(particle.y);

      # trail max length
      if particle.lastPointsX.length > trailLength
        particle.lastPointsX.shift()

      if particle.lastPointsY.length > trailLength
        particle.lastPointsY.shift()

    @context.globalCompositeOperation = gco


  getConfig: (config) ->
    atom.config.get "activate-power-mode.particles.#{config}"
