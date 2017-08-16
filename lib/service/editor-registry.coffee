module.exports =
  getEditor: ->
    @editor

  getEditorElement: ->
    @editorElement

  getScrollView: ->
    @scrollView

  setEditor: (editor) ->
    if editor
      @editor = editor
      @editorElement = editor.getElement()
      @scrollView = @editorElement.querySelector(".scroll-view")
    else
      @editor = @editorElement = @scrollView = null
