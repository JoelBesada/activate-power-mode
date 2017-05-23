{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  flows: []
  flow: null
  key: "activate-power-mode.flow"

  enable: ->
    @subscriptions = new CompositeDisposable
    @observeFlow()
    @initList()

  disable: ->
    @subscriptions?.dispose()
    @flowList?.dispose()
    @flowList = null

  setDefaultFlow: (flow) ->
    @flow = flow
    @flows['default'] = flow

  addFlow: (code, flow) ->
    @flows[code] = flow

    if atom.config.get(@key) is code
      @flow = flow

  observeFlow: ->
    @subscriptions.add atom.config.observe(
      @key, (code) =>
        if @flows[code]?
          @flow = @flows[code]
        else
          @flow = @flows['default']
    )

  selectFlow: (code) ->
    atom.config.set(@key, code)

  initList: ->
    return if @flowList?

    @flowList = require "./flow-list"
    @flowList.init this

    @subscriptions.add atom.commands.add "atom-workspace",
      "activate-power-mode:select-flow": =>
        @flowList.toggle()
