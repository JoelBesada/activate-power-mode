module.exports =
  setComboRenderer: (comboRenderer) ->
    @combo = comboRenderer

  enable: ->
    @combo.enable()
    @combo.initConfigSubscribers()

  disable: ->
    @combo.destroy()

  onChangePane: (editor, editorElement) ->
    @combo.reset()
    @combo.setup editorElement if editor

  onInput: (cursor, screenPosition, input, data) ->
    if data['reset']
      @combo.resetCounter()
      return

    qty = 1
    if data['qty']
      qty = data['qty']

    @combo.modifyStreak qty
