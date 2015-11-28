ActivatePowerModeView = require './activate-power-mode-view'
throttle = require "lodash.throttle"
{CompositeDisposable} = require 'atom'

module.exports = ActivatePowerMode =
  activatePowerModeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @activatePowerModeView = new ActivatePowerModeView(state.activatePowerModeViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @activatePowerModeView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'activate-power-mode:toggle': => @toggle()

    @throttledShake = throttle @shake.bind(this), 100, trailing: false
    @throttledSpawnParticles = throttle @spawnParticles.bind(this), 25, trailing: false

    @editor = atom.workspace.getActiveTextEditor()
    @editorElement = atom.views.getView @editor
    @editorElement.classList.add "power-mode"

    @cursorOffset = @calculatecursorOffset()
    console.log "off", @cursorOffset

    @subscriptions.add @editor.getBuffer().onDidChange(@onChange.bind(this))
    @setupCanvas()

  setupCanvas: ->
    @canvas = document.createElement "canvas"
    @context = @canvas.getContext "2d"
    @canvas.classList.add "power-mode-canvas"
    @canvas.width = @editorElement.offsetWidth
    @canvas.height = @editorElement.offsetHeight
    @editorElement.parentNode.appendChild @canvas

  calculatecursorOffset: ->
    editorRect = @editorElement.getBoundingClientRect()
    scrollViewRect = @editorElement.shadowRoot.querySelector(".scroll-view").getBoundingClientRect()

    top: 10
    left: scrollViewRect.left - editorRect.left

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @activatePowerModeView.destroy()

  serialize: ->
    activatePowerModeViewState: @activatePowerModeView.serialize()

  onChange: (e) ->
    console.log "on change", e
    @throttledSpawnParticles @editor.pixelPositionForScreenPosition(e.newRange.end)
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

  spawnParticles: ({left, top}) ->
    offset = @editorElement.getBoundingClientRect()
    # console.log(
    #   left + offset.left + @parti
    #   top + offset.top + 5
    # )
    el = atom.views.getView(@editor).shadowRoot.elementFromPoint(
      left + offset.left + @cursorOffset.left
      top + offset.top + 5
    )
    color = getComputedStyle(el).color
    console.log color
    numParticles = 10
    while numParticles--
      @particles[@particlePointer] = @createParticle left, top, color
      @particlePointer = (@particlePointer + 1) % 500

  createParticle: (x, y, color) ->
    x: x + @cursorOffset.left
    y: y + @cursorOffset.top
    alpha: 1
    color: color
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  drawParticles: ->
    requestAnimationFrame @drawParticles.bind(this)
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    for particle in @particles
      continue if particle.alpha <= 0.1

      particle.velocity.y += 0.075
      particle.x += particle.velocity.x
      particle.y += particle.velocity.y
      particle.alpha *= 0.96

      @context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
      @context.fillRect(
        Math.round(particle.x - 1)
        Math.round(particle.y - 1)
        3, 3
      )

  toggle: ->
    console.log 'ActivatePowerMode was toggled!'
    @particlePointer = 0
    @particles = []
    requestAnimationFrame @drawParticles.bind(this)
