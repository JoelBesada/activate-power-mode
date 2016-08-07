module.exports =

  rage: 0
  enraged: false
  rageMeter: null
  statusBarTile: null

  init: (statusBar) ->
    @div = document.createElement "div"
    @rageMeter = document.createElement "span"
    @div.classList.add "meter"
    @div.appendChild @rageMeter
    @rageMeter.style.width = "#{@rage/10}%"
    @statusBarTile = statusBar.addLeftTile(item: @div, priority: 100)
    @decayRage()

  decayRage: ->
    if @getConfig "enabled"
      requestAnimationFrame @decayRage.bind(this)
    if @rage > 0
      @rage -= 2
      @rageMeter.style.width = "#{@rage/10}%"
    else
      @enraged = false

  addRage: ->
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