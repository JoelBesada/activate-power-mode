{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  effects: []
  effect: null
  key: "activate-power-mode.particles.effect"

  enable: ->
    @subscriptions = new CompositeDisposable
    @observeEffect()
    @initList()

  disable: ->
    @subscriptions?.dispose()
    @effectList?.dispose()
    @effectList = null

  setDefaultEffect: (effect) ->
    @effect = effect
    @effects['default'] = effect

  addEffect: (code, effect) ->
    @effects[code] = effect

    if atom.config.get(@key) is code
      @effect = effect

  observeEffect: ->
    @subscriptions.add atom.config.observe(
      @key, (code) =>
        if @effects[code]?
          effect = @effects[code]
        else
          effect = @effects['default']
        @effect.disable()
        @effect = effect
        @effect.init()
    )

  selectEffect: (code) ->
    atom.config.set(@key, code)

  initList: ->
    return if @effectList?

    @effectList = require "./effect-list"
    @effectList.init this

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:select-effect": =>
        @effectList.toggle()
