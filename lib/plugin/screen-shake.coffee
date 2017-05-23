module.exports =
  title: 'Screen Shake'
  description: 'Shakes the screen on typing.'

  enable: (api) ->
    @api = api

  onInput: (cursor, screenPosition, input, data) ->
    @api.shakeScreen(data['intensity'])
