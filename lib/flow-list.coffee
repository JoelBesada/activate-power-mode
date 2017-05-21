SelectListView = require "atom-select-list"

module.exports =
  init: (flowRegistry) ->
    @flowRegistry = flowRegistry
    @selectListView = new SelectListView({
      emptyMessage: 'No flows in the registry.',
      itemsClassList: ['mark-active'],
      items: [],
      filterKeyForItem: (item) -> item.title + item.description,
      elementForItem: (item) =>
        element = document.createElement 'li'
        if item.flow is @currentFlow
          element.classList.add 'active'
        html = "<b>#{item.title}</b>"
        html += "<b>:</b> #{item.description}" if item.description
        element.innerHTML = html
        element
      didConfirmSelection: (item) =>
        @cancel()
        @flowRegistry.selectFlow item.code
      didCancelSelection: () =>
        @cancel()
    })
    @selectListView.element.classList.add('flow-list')

  dispose: ->
    @cancel()
    @selectListView.destroy()

  cancel: ->
    if @panel?
      @panel.destroy()
    @panel = null
    @currentFlow = null
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
      @currentFlow = @flowRegistry.flow
      flows = []
      for code, flow of @flowRegistry.flows
        flows.push({
          code: code,
          flow: flow,
          title: if flow.title then flow.title else code,
          description: flow.description
        })
      @selectListView.update({items: flows})
      @attach()
