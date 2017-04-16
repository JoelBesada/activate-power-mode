{CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null
  flows: []
  flow: null
  key: "activate-power-mode.flow"

  enable: ->
    @subscriptions = new CompositeDisposable
    @observeFlow()

  disable: ->
    @subscriptions?.dispose()

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
