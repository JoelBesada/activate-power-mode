module.exports =
  setComboRenderer: (comboRenderer) ->
    @combo = comboRenderer

  enable: ->
    @combo.initConfigSubscribers()

  disable: ->
    @combo.destroy()

  onChangePane: (editor, editorElement) ->
    @combo.reset()
    @combo.setup editorElement if editor

  onInput: ->
    @combo.modifyStreak 1
