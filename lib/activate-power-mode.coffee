throttle = require "lodash.throttle"
{CompositeDisposable} = require 'atom'

module.exports = ActivatePowerMode =
  activatePowerModeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:toggle": => @toggle()

    @combo = 0

    @throttledShake = throttle @shake.bind(this), 100, trailing: false
    @throttledSpawnParticles = throttle @spawnParticles.bind(this), 25, trailing: false
    @throttledComboTextShake = throttle @comboTextShake.bind(this), 50, trailing: false

    @editor = atom.workspace.getActiveTextEditor()
    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @subscriptions.add @editor.getBuffer().onDidChange(@onChange.bind(this))
    @subscriptions.add @editor.getBuffer().onDidChange(@onComboDidChange.bind(this))
    @setupCanvas()

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

  onComboDidChange: (e) ->
    if e.oldText is '' and e.newText is ''
      # do nothing
      @combo = @combo
    else if e.oldText.length <= e.newText.length
      # auto completion case.
      @combo += 1
    else if e.oldText isnt ''
      if e.newText isnt ''
        # replacing will keep combo
        @combo += 1
      else if e.oldText.trim() is '' and e.oldText.indexOf("\n") < 0
        # allow deleting space for typesetting.
        @combo = @combo
      else
        # delete some character(s), reset combo
        @combo = 0
    else
      # input character case
      @combo += 1
    @throttledComboTextShake()

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

  comboTextShake: ->
      @comboTextSize = 70

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

  drawEffects: ->
    requestAnimationFrame @drawEffects.bind(this)
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @drawParticles()
    @drawCombo()

  drawParticles: ->
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

  drawCombo: ->
    return if @combo <= 1
    @context.save()
    @context.font = @comboTextSize + "px Verdan"
    @comboTextSize -= 1 if @comboTextSize >= 55
    gradient = @context.createLinearGradient 0, 0, 0, @canvas.height * 0.1
    gradient.addColorStop "0", "orange"
    gradient.addColorStop "0.5", "yellow"
    gradient.addColorStop "1.0","red"
    @context.fillStyle = gradient
    @context.textAlign = "center"
    text = @combo + " COMBO!"
    comboPosX = @canvas.width * 0.8
    comboPosY = @canvas.height * 0.1
    @context.fillText text, comboPosX, comboPosY
    @context.restore()

  toggle: ->
    console.log 'ActivatePowerMode was toggled!'
    @particlePointer = 0
    @particles = []
    requestAnimationFrame @drawEffects.bind(this)
