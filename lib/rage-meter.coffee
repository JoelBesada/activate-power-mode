module.exports =
  rage: 0
  enraged: false
  rageMeter: null
  statusBarTile: null

  init: (statusBar) ->
    self = @
    atom.config.observe "activate-power-mode.rage.visible", ->
      if self.getConfig "enabled"
        if self.addRageMeter(statusBar)
          return
      self.dispose()

    atom.config.observe "activate-power-mode.rage.enabled", ->
      if self.getConfig "enabled"
        self.addRageMeter(statusBar)
        self.decayRage()
      else
        self.enraged = false
        self.rage = 0
        self.dispose()

  decayRage: ->
    if @getConfig "enabled"
      requestAnimationFrame @decayRage.bind(this)
    if @rage > 0
      @rage -= 2
      @rageMeter?.style.width = "#{@rage/10}%"
    else
      @enraged = false

  addRage: ->
    if @getConfig "enabled"
      @rage += 100

      if @rage >= 1000
        @rage = 1000
        @enraged = true

      @rageMeter?.style.width = "#{@rage/10}%"

  isEnraged: ->
    return @enraged

  addRageMeter: (statusBar) ->
    if @getConfig "visible"
      if !@statusBarTile
        @div = document.createElement "div"
        @rageMeter = document.createElement "span"
        @div.classList.add "meter"
        @div.appendChild @rageMeter
        @rageMeter.style.width = "#{@rage/10}%"
        @statusBarTile = statusBar.addLeftTile(item: @div, priority: 100)

  dispose: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  getConfig: (config) ->
    atom.config.get "activate-power-mode.rage.#{config}"