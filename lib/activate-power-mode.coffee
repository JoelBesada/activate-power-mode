throttle = require "lodash.throttle"
{CompositeDisposable} = require 'atom'

module.exports = ActivatePowerMode =
  activatePowerModeView: null
  modalPanel: null
  subscriptions: null

  config:
    effect:
      type: 'number'
      default: 1

  effectType: 2

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle": => @toggle()

    @throttledShake = throttle @shake.bind(this), 100, trailing: false
    @throttledSpawnParticles = throttle @spawnParticles.bind(this), 25, trailing: false

    @editor = atom.workspace.getActiveTextEditor()
    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @subscriptions.add @editor.getBuffer().onDidChange(@onChange.bind(this))
    @setupCanvas()

  random: (min, max) ->
    if !max
      max = min; min = 0;

    min + ~~(Math.random() * (max - min + 1))

  setupCanvas: ->
    @canvas = document.createElement "canvas"
    @context = @canvas.getContext "2d"
    @canvas.classList.add "power-mode-canvas"
    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    @editorElement.parentNode.appendChild @canvas

  calculateCursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = @editorElement.shadowRoot.querySelector(".scroll-view").getBoundingClientRect()

    top: scrollViewRect.top - editorRect.top + @editor.getLineHeightInPixels() / 2
    left: scrollViewRect.left - editorRect.left

  onChange: (e) ->
    spawnParticles = true
    if e.newText
      spawnParticles = e.newText isnt "\n"
      range = e.newRange.end
    else
      range = e.newRange.start

    @throttledSpawnParticles(range) if spawnParticles
    @throttledShake()

  shake: ->
    intensity = 1 + 2 * Math.random()
    x = intensity * (if Math.random() > 0.5 then -1 else 1)
    y = intensity * (if Math.random() > 0.5 then -1 else 1)

    @editorElement.style.top = "#{y}px"
    @editorElement.style.left = "#{x}px"

    setTimeout =>
      @editorElement.style.top = ""
      @editorElement.style.left = ""
    , 75

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
    particle =
      x: x
      y: y
      alpha: 1
      color: color

    if atom.config.get('activate-power-mode.effect') == 1
      particle.size = @random(2, 4)
      particle.vx = -1 + Math.random() * 2
      particle.vy = -3.5 + Math.random() * 2
    else if atom.config.get('activate-power-mode.effect') == 2
      particle.size = @random(2, 8)
      particle.drag = 0.92
      particle.vx = @random(-3, 3)
      particle.vy = @random(-3, 3)
      particle.wander = 0.15
      particle.theta = @random(0, 360) * Math.PI / 180;

    particle;

  drawParticles: ->
    requestAnimationFrame @drawParticles.bind(this)
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    for particle in @particles
      continue if particle.alpha <= 0.1 or particle.size < 0.5

      if atom.config.get('activate-power-mode.effect') == 1
        @effect1(particle)
      else if atom.config.get('activate-power-mode.effect') == 2
        @effect2(particle)

  effect1: (particle) ->
    particle.vy += 0.075
    particle.x += particle.vx
    particle.y += particle.vy
    particle.alpha *= 0.96

    @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
    @context.fillRect(
      Math.round(particle.x - 1.5)
      Math.round(particle.y - 1.5)
      particle.size, particle.size
    )

  # Effect based on Soulwire's demo: http://codepen.io/soulwire/pen/foktm
  effect2: (particle) ->
    particle.x += particle.vx;
    particle.y += particle.vy;
    particle.vx *= particle.drag
    particle.vy *= particle.drag
    particle.theta += @random( -0.5, 0.5 )
    particle.vx += Math.sin( particle.theta ) * 0.1
    particle.vy += Math.cos( particle.theta ) * 0.1
    particle.size *= 0.96

    @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
    @context.beginPath()
    @context.arc(Math.round(particle.x - 1), Math.round(particle.y - 1), particle.size, 0, 2 * Math.PI)
    @context.fill()

  toggle: ->
    console.log 'ActivatePowerMode was toggled!'
    @particlePointer = 0
    @particles = []
    requestAnimationFrame @drawParticles.bind(this)
