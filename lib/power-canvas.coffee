{CompositeDisposable} = require "atom"
random = require "lodash.random"
colorHelper = require "./color-helper"

module.exports =
  colorHelper: colorHelper
  subscriptions: null

  init: ->
    @resetParticles()
    @animationOn()

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
    @subscriptions?.dispose()

  setupCanvas: (editor, editorElement) ->
    if not @canvas
      @canvas = document.createElement "canvas"
      @context = @canvas.getContext "2d"
      @canvas.classList.add "power-mode-canvas"
      @initConfigSubscribers()

    editorElement.appendChild @canvas
    @canvas.style.display = "block"
    @canvas.width = editorElement.offsetWidth
    @canvas.height = editorElement.offsetHeight
    @scrollView = editorElement.querySelector(".scroll-view")
    @editorElement = editorElement
    @editor = editor

    @init()

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'activate-power-mode.particles.spawnCount.min', (value) =>
      @confMinCount = value
    @subscriptions.add atom.config.observe 'activate-power-mode.particles.spawnCount.max', (value) =>
      @confMaxCount = value
    @subscriptions.add atom.config.observe 'activate-power-mode.particles.totalCount.max', (value) =>
      @confTotalCount = value
    @subscriptions.add atom.config.observe 'activate-power-mode.particles.size.min', (value) =>
      @confMinSize = value
    @subscriptions.add atom.config.observe 'activate-power-mode.particles.size.max', (value) =>
      @confMaxSize = value

  spawnParticles: (screenPosition) ->
    {left, top} = @calculatePositions screenPosition

    numParticles = random @confMinCount, @confMaxCount

    color = @colorHelper.getColor @editor, @editorElement, screenPosition

    while numParticles--
      nextColor = if typeof color is "object" then color.next().value else color

      @particles.shift() if @particles.length >= @confTotalCount
      @particles.push @createParticle left, top, nextColor

  calculatePositions: (screenPosition) ->
    {left, top} = @editorElement.pixelPositionForScreenPosition screenPosition
    left: left + @scrollView.offsetLeft - @editorElement.getScrollLeft()
    top: top + @scrollView.offsetTop - @editorElement.getScrollTop() + @editor.getLineHeightInPixels() / 2

  createParticle: (x, y, color) ->
    x: x
    y: y
    alpha: 1
    color: color
    size: random @confMinSize, @confMaxSize, true
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  drawParticles: ->
    @animationOn()
    @canvas.width = @canvas.width
    return if not @particles.length

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
