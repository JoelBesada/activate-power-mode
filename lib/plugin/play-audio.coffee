throttle = require "lodash.throttle"

module.exports =
  title: 'Play Audio'
  description: 'Plays selected audio on typing.'

  enable: (api) ->
    @api = api
    @throttledPlayAudio = throttle @api.playAudio.bind(@api), 100, trailing: false

  onInput: ->
    @throttledPlayAudio()
