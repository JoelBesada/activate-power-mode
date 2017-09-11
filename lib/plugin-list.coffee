SelectListView = require "atom-select-list"

module.exports =
  init: (pluginRegistry) ->
    @pluginRegistry = pluginRegistry
    @selectListView = new SelectListView({
      emptyMessage: 'No plugins in the registry.',
      itemsClassList: ['mark-active'],
      items: [],
      filterKeyForItem: (item) -> item.title + item.description,
      elementForItem: (item) =>
        element = document.createElement 'li'
        if @pluginRegistry.enabledPlugins[item.code]?
          element.classList.add 'active'
        html = "<b>#{item.title}</b>"
        html += "<b>:</b> #{item.description}" if item.description
        html += "<img src=\"#{item.image}\">" if item.image
        element.innerHTML = html
        element
      didConfirmSelection: (item) =>
        @pluginRegistry.togglePlugin item.code
      didCancelSelection: () =>
        @cancel()
    })
    @selectListView.element.classList.add('plugin-list')

  dispose: ->
    @cancel()
    @selectListView.destroy()

  cancel: ->
    if @panel?
      @panel.destroy()
    @panel = null
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
      plugins = []
      for code, plugin of @pluginRegistry.plugins
        plugins.push({
          code: code,
          title: if plugin.title then plugin.title else code,
          description: plugin.description
          image: plugin.image
        })
      @selectListView.update({items: plugins})
      @attach()
