{CompositeDisposable} = require "atom"
random = require "lodash.random"
colorHelper = require "./color-helper"

module.exports =
  colorHelper: colorHelper
  subscriptions: null
  conf: []

  setEffect: (effect) ->
    @effect = effect

  enable: ->
    @initConfigSubscribers()
    @colorHelper.init()

  init: ->
    @effect.init()
    @animationOn()

  resetCanvas: ->
    @animationOff()
    @editor = null
    @editorElement = null

  animationOff: ->
    cancelAnimationFrame(@animationFrame)
    @animationFrame = null

  animationOn: ->
    @animationFrame = requestAnimationFrame @animate.bind(this)

  destroy: ->
    @resetCanvas()
    @effect.disable()
    @canvas?.parentNode.removeChild @canvas
    @canvas = null
    @subscriptions?.dispose()
    @colorHelper.disable()

  setupCanvas: (editor, editorElement) ->
    if not @canvas
      @canvas = document.createElement "canvas"
      @context = @canvas.getContext "2d"
      @canvas.classList.add "power-mode-canvas"
      @initConfigSubscribers()

    editorElement.appendChild @canvas

    @canvas.style.display = "block"
    @scrollView = editorElement.querySelector(".scroll-view")
    @editorElement = editorElement
    @editor = editor
    @updateCanvasDimesions()
    @calculateOffsets()
    @editorElement.addEventListener 'resize', =>
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

    @effect.spawn position, colorGenerate, input, randomSize, @conf

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
    @offsetLeft = @scrollView.offsetLeft
    @offsetTop = @scrollView.offsetTop

  updateCanvasDimesions: ->
    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight

  animate: ->
    @animationOn()
    @canvas.width = @canvas.width

    @effect.animate(@context)
