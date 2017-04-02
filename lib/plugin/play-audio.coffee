throttle = require "lodash.throttle"

module.exports =
  enable: (api) ->
    @api = api
    @throttledPlayAudio = throttle @api.playAudio.bind(@api), 100, trailing: false

  onInput: ->
    @throttledPlayAudio()
