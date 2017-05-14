{CompositeDisposable} = require "atom"
random = require "lodash.random"
colorHelper = require "./color-helper"

module.exports =
  colorHelper: colorHelper
  subscriptions: null
  conf: []
  phaseStep: 0

  setEffectRegistry: (effectRegistry) ->
    @effectRegistry = effectRegistry

  enable: ->
    @initConfigSubscribers()
    @colorHelper.init()

  init: ->
    @effectRegistry.effect.init()
    @animationOn()

  resetCanvas: ->
    @animationOff()
    @canvas?.style.display = "none"
    @editor = null
    @editorElement = null

  animationOff: ->
    cancelAnimationFrame(@animationFrame)
    @animationFrame = null

  animationOn: ->
    @animationFrame = requestAnimationFrame @animate.bind(this)

  destroy: ->
    @resetCanvas()
    @effectRegistry?.effect.disable()
    @canvas?.parentNode.removeChild @canvas
    @canvas = null
    @subscriptions?.dispose()
    @colorHelper?.disable()

  setupCanvas: (editor, editorElement) ->
    if not @canvas
      @canvas = document.createElement "canvas"
      @context = @canvas.getContext "2d"
      @canvas.classList.add "power-mode-canvas"
      @initConfigSubscribers()

    @scrollView = editorElement.querySelector(".scroll-view")
    @editorContents = editorElement.querySelector(".editor-contents--private")
    @editorContents.appendChild @canvas
    @canvas.style.display = "block"
    @editorElement = editorElement
    @editor = editor
    @updateCanvasDimesions()
    @calculateOffsets()
    window.addEventListener 'resize', =>
      @updateCanvasDimesions()
      @calculateOffsets()

    @init()

  observe: (key) ->
    @subscriptions.add atom.config.observe "activate-power-mode.particles.#{key}", (value) =>
      @conf[key] = value

  initConfigSubscribers: ->
    @subscriptions = new CompositeDisposable
    @observe 'spawnCount.min'
    @observe 'spawnCount.max'
    @observe 'totalCount.max'
    @observe 'size.min'
    @observe 'size.max'

  spawn: (cursor, screenPosition, input, size) ->
    position = @calculatePositions screenPosition
    colorGenerator = @colorHelper.generateColors cursor, @editorElement
    randomSize = => @randomSize(size)
    colorGenerate = -> colorGenerator.next().value

    @effectRegistry.effect.spawn position, colorGenerate, input, randomSize, @conf

  randomSize: (size) ->
    min = @conf['size.min']
    max = @conf['size.max']

    if size is 'max'
      random max - min + 2, max + 2, true
    else if size is 'min'
      random min - 1, max - min, true
    else
      random min, max, true

  calculatePositions: (screenPosition) ->
    {left, top} = @editorElement.pixelPositionForScreenPosition screenPosition
    left: left + @offsetLeft - @editorElement.getScrollLeft()
    top: top + @offsetTop - @editorElement.getScrollTop() + @editor.getLineHeightInPixels() / 2

  calculateOffsets: ->
    return if not @scrollView
    @offsetLeft = @scrollView.offsetLeft
    @offsetTop = @scrollView.offsetTop

  updateCanvasDimesions: ->
    return if not @editorElement
    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    @canvas.style.width = @editorElement.width
    @canvas.style.height = @editorElement.height

  animate: ->
    @animationOn()
    @effectRegistry.effect.update()
    if @phaseStep is 0
      @canvas.width = @canvas.width
      @effectRegistry.effect.animate(@context)

    @phaseStep++
    @phaseStep = 0 if @phaseStep > 2
