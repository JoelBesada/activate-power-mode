throttle = require "lodash.throttle"
{CompositeDisposable} = require 'atom'

configSchema = require './config-schema'

module.exports = ActivatePowerMode =
  config: configSchema
  activatePowerModeView: null
  modalPanel: null
  subscriptions: null
  active: false

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle": => @toggle()

    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()
    @setupCanvas()

  destroy: ->
    @activeItemSubscription?.dispose()

  subscribeToActiveTextEditor: ->
    @throttledShake = throttle @shake.bind(this), 100, trailing: false
    @throttledSpawnParticles = throttle @spawnParticles.bind(this), 25, trailing: false

    @editor = atom.workspace.getActiveTextEditor()
    return unless @editor

    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @editorChangeSubscription?.dispose()
    @editorChangeSubscription = @editor.getBuffer().onDidChange @onChange.bind(this)
    @canvas.style.display = "block" if @canvas

  setupCanvas: ->
    @canvas = document.createElement "canvas"
    @context = @canvas.getContext "2d"
    @canvas.classList.add "power-mode-canvas"
    @editorElement.parentNode.appendChild @canvas

  calculateCursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = @editorElement.shadowRoot.querySelector(".scroll-view").getBoundingClientRect()

    top: scrollViewRect.top - editorRect.top + @editor.getLineHeightInPixels() / 2
    left: scrollViewRect.left - editorRect.left

  onChange: (e) ->
    return if not @active
    spawnParticles = true
    if e.newText
      spawnParticles = e.newText isnt "\n"
      range = e.newRange.end
    else
      range = e.newRange.start

    if atom.config.get('activate-power-mode.animation')
      @throttledSpawnParticles(range) if spawnParticles
    if atom.config.get('activate-power-mode.shake')
      @throttledShake()

  shake: ->
    intensity = (atom.config.get 'activate-power-mode.minShake') + (atom.config.get 'activate-power-mode.intensity') * Math.random()
    x = intensity * @intensity_factor()
    y = intensity * @intensity_factor()

    @editorElement.style.top = "#{y}px"
    @editorElement.style.left = "#{x}px"

    setTimeout =>
      @editorElement.style.top = ""
      @editorElement.style.left = ""
    , 75

  intensity_factor: ->
    if Math.random() > 0.5 then -1 else 1

  spawnParticles: (range) ->
    cursorOffset = @calculateCursorOffset()

    {left, top} = @editor.pixelPositionForScreenPosition range
    left += cursorOffset.left - @editor.getScrollLeft()
    top += cursorOffset.top - @editor.getScrollTop()

    color = @getColorAtPosition left, top
    numParticles = 5 + Math.round(Math.random() * 10)
    while numParticles--
      part =  @createParticle left, top, color
      @particles[@particlePointer] = part
      @particlePointer = (@particlePointer + 1) % 500

  getColorAtPosition: (left, top) ->
    offset = @editorElement.getBoundingClientRect()
    el = atom.views.getView(@editor).shadowRoot.elementFromPoint(
      left + offset.left
      top + offset.top
    )

    if el
      getComputedStyle(el).color
    else
      "rgb(255, 255, 255)"

  createParticle: (x, y, color) ->
    x: x
    y: y
    alpha: 1
    color: color
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  drawParticles: ->
    requestAnimationFrame @drawParticles.bind(this) if @active
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
      @context.fillRect(
        Math.round(particle.x - 1.5)
        Math.round(particle.y - 1.5)
        3, 3
      )

    @context.globalCompositeOperation = gco

  toggle: ->
    console.log 'ActivatePowerMode was toggled!'
    @active = !@active
    @particlePointer = 0
    @particles = []
    requestAnimationFrame @drawParticles.bind(this)
