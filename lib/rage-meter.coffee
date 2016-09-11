module.exports =
  rage: 0
  enraged: false
  rageMeter: null
  statusBarTile: null

  init: (statusBar) ->
    self = @
    atom.config.observe "activate-power-mode.rage.enabled", (value) ->
      if value
        self.div = document.createElement "div"
        self.rageMeter = document.createElement "span"
        self.div.classList.add "meter"
        self.div.appendChild self.rageMeter
        self.rageMeter.style.width = "#{self.rage/10}%"
        self.statusBarTile = statusBar.addLeftTile(item: self.div, priority: 100)

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
      @rageMeter.style.width = "#{@rage/10}%"
    else
      @enraged = false

  addRage: ->
    if @getConfig "enabled"
      @rage += 100

      if @rage >= 1000
        @rage = 1000
        @enraged = true

      @rageMeter.style.width = "#{@rage/10}%"

  isEnraged: ->
    return @enraged

  dispose: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  getConfig: (config) ->
    atom.config.get "activate-power-mode.rage.#{config}"