combo = require "../combo-renderer"

module.exports =
  combo: combo
  t: 0

  enable: ->
    @combo.initConfigSubscribers()

  disable: ->
    @combo.destroy()

  onChangePane: (editor, editorElement) ->
    @combo.reset()
    @combo.setup editorElement if editor

  onInput: ->
    @combo.modifyStreak 1
    # if @t < 20
    #   @combo.modifyStreak 1
    #   @t++
    # else
    #   @combo.resetCounter()
    #   @t = 0
