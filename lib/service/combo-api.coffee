module.exports = class ComboApi
  constructor: (comboRenderer) ->
    @combo = comboRenderer

  increase: (n = 1) ->
    @combo.modifyStreak n if @combo.isEnable

  decrease: (n = 1) ->
    @combo.modifyStreak(-n) if @combo.isEnable

  exclame: (word = null, type = null) ->
    @combo.showExclamation word, type if @combo.isEnable

  resetCounter: ->
    @combo.resetCounter() if @combo.isEnable

  getLevel: ->
    if @combo.isEnable
      @combo.getLevel()
    else
      null

  isEnable: ->
    @combo.isEnable
