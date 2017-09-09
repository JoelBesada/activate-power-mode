SelectListView = require "atom-select-list"

module.exports =
  init: (colorHelper) ->
    @colorHelper = colorHelper
    @selectListView = new SelectListView({
      emptyMessage: 'No colors options.',
      itemsClassList: ['mark-active'],
      items: [],
      filterKeyForItem: (item) -> item.value + item.description,
      elementForItem: (item) =>
        element = document.createElement 'li'
        if item.value is @currentColor
          element.classList.add 'active'
        html = "<b>#{item.description}</b>"
        element.innerHTML = html
        element
      didConfirmSelection: (item) =>
        @cancel()
        @colorHelper.selectColor item.value
      didCancelSelection: () =>
        @cancel()
    })
    @selectListView.element.classList.add('color-list')

  dispose: ->
    @cancel()
    @selectListView.destroy()

  cancel: ->
    if @panel?
      @panel.destroy()
    @panel = null
    @currentColor = null
    if @previouslyFocusedElement
      @previouslyFocusedElement.focus()
      @previouslyFocusedElement = null

  attach: ->
    @previouslyFocusedElement = document.activeElement
    if not @panel?
      @panel = atom.workspace.addModalPanel({item: @selectListView})
    @selectListView.focus()
    @selectListView.reset()

  toggle: ->
    if @panel?
      @cancel()
    else
      @currentColor = @colorHelper.conf['type']
      colors = []
      colorSchema = atom.config.getSchema(@colorHelper.key)
      for i, option of colorSchema.properties.type.enum
        colors.push(option)
      @selectListView.update({items: colors})
      @attach()
