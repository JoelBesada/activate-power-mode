# Refactoring status: 100%
class Settings
  constructor: (@scope, @config) ->

  get: (param) ->
    atom.config.get "#{@scope}.#{param}"

  set: (param, value) ->
    atom.config.set "#{@scope}.#{param}", value

module.exports = new Settings 'activate-power-mode',
  throttledShake:
    order: 2
    type: 'boolean'
    default: true
