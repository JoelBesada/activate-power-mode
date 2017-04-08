module.exports = class ComboApi
  constructor: (comboRenderer) ->
    @combo = comboRenderer

  increase: (n = 1) ->
    @combo.modifyStreak n

  decrease: (n = 1) ->
    @combo.modifyStreak(-n)

  exclame: (word = null, type = null) ->
    @combo.showExclamation word, type

  resetCounter: ->
    @combo.resetCounter()

  getLevel: ->
    @combo.getLevel()
