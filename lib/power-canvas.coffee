random = require "lodash.random"
colorHelper = require "./color-helper"

module.exports =
  colorHelper: colorHelper

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

    editorElement.appendChild @canvas
    @canvas.style.display = "block"
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

      @particles[@particlePointer] = @createParticle left, top, nextColor
      @particlePointer = (@particlePointer + 1) % @getConfig("totalCount.max")

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
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  drawParticles: ->
    @animationFrame = requestAnimationFrame @drawParticles.bind(this) if @editor
    return unless @canvas and @editorElement

    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    gco = @context.globalCompositeOperation
    @context.globalCompositeOperation = "lighter"

    for particle in @particles
      continue if particle.alpha <= 0.1

      particle.velocity.y += 0.075
      particle.x += particle.velocity.x
      particle.y += particle.velocity.y
      particle.alpha *= 0.96

      @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
      size = random @getConfig("size.min"), @getConfig("size.max"), true
      @context.fillRect(
        Math.round(particle.x - size / 2)
        Math.round(particle.y - size / 2)
        size, size
      )

    @context.globalCompositeOperation = gco

  getConfig: (config) ->
    atom.config.get "activate-power-mode.particles.#{config}"
