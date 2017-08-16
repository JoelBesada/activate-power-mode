module.exports =
  getEditor: ->
    @editor

  getEditorElement: ->
    @editorElement

  getScrollView: ->
    @scrollView

  setEditor: (editor) ->
    @editor = editor
    @editorElement = editor.getElement()
    @scrollView = @editorElement.querySelector(".scroll-view")
