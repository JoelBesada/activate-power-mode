module.exports =
  enable: (api) ->
    @api = api

  onInput: ->
    @api.shakeScreen()
