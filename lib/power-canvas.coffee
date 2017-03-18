random = require "lodash.random"
colorHelper = require "./color-helper"

module.exports =
  colorHelper: colorHelper

  init: ->
    @resetParticles()

  resetCanvas: ->
    @animationOff()
    @editor = null
    @editorElement = null

  animationOff: ->
    cancelAnimationFrame(@animationFrame)
    @animationFrame = null

  animationOn: ->
    @animationFrame = requestAnimationFrame @drawParticles.bind(this)

  resetParticles: ->
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

    editorElement.appendChild @canvas
    @canvas.style.display = "block"
    @canvas.width = editorElement.offsetWidth
    @canvas.height = editorElement.offsetHeight
    @editorElement = editorElement
    @editor = editor

    @init()

  spawnParticles: (screenPosition) ->
    cursorOffset = @calculateCursorOffset()

    {left, top} = @editorElement.pixelPositionForScreenPosition screenPosition
    left += cursorOffset.left - @editorElement.getScrollLeft()
    top += cursorOffset.top - @editorElement.getScrollTop()

    numParticles = random @getConfig("spawnCount.min"), @getConfig("spawnCount.max")

    color = @colorHelper.getColor @editor, @editorElement, screenPosition

    while numParticles--
      nextColor = if typeof color is "object" then color.next().value else color

      @particles.shift() if @particles.length >= @getConfig("totalCount.max")
      @particles.push @createParticle left, top, nextColor

    @animationOn() if not @animationFrame

  calculateCursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = @editorElement.querySelector(".scroll-view").getBoundingClientRect()

    top: scrollViewRect.top - editorRect.top + @editor.getLineHeightInPixels() / 2
    left: scrollViewRect.left - editorRect.left

  createParticle: (x, y, color) ->
    x: x
    y: y
    alpha: 1
    color: color
    size: random @getConfig("size.min"), @getConfig("size.max"), true
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  drawParticles: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    if @editor and @particles.length
      @animationOn()
    else
      @animationOff()
      return

    gco = @context.globalCompositeOperation
    @context.globalCompositeOperation = "lighter"

    for i in [@particles.length - 1 ..0]
      particle = @particles[i]
      if particle.alpha <= 0.1
        @particles.splice i, 1
        continue

      particle.velocity.y += 0.075
      particle.x += particle.velocity.x
      particle.y += particle.velocity.y
      particle.alpha *= 0.96

      @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
      @context.fillRect(
        Math.round(particle.x - particle.size / 2)
        Math.round(particle.y - particle.size / 2)
        particle.size, particle.size
      )

    @context.globalCompositeOperation = gco

  getConfig: (config) ->
    atom.config.get "activate-power-mode.particles.#{config}"
