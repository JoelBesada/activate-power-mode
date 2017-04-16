SelectListView = require "atom-select-list"

module.exports =
  init: (effectRegistry) ->
    @effectRegistry = effectRegistry
    @selectListView = new SelectListView({
      emptyMessage: 'No effects in the registry.',
      itemsClassList: ['mark-active'],
      items: [],
      filterKeyForItem: (item) -> item.title + item.description,
      elementForItem: (item) =>
        element = document.createElement 'li'
        if item.effect is @currentEffect
          element.classList.add 'active'
        html = "<b>#{item.title}</b>"
        html += "<b>:</b> #{item.description}" if item.description
        html += "<img src=\"#{item.image}\">" if item.image
        element.innerHTML = html
        element
      didConfirmSelection: (item) =>
        @cancel()
        @effectRegistry.selectEffect item.code
      didCancelSelection: () =>
        @cancel()
    })
    @selectListView.element.classList.add('effect-list')

  dispose: ->
    @cancel()
    @selectListView.destroy()

  cancel: ->
    if @panel?
      @panel.destroy()
    @panel = null
    @currentEffect = null
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
      @currentEffect = @effectRegistry.effect
      effects = []
      for code, effect of @effectRegistry.effects
        effects.push({
          code: code,
          effect: effect,
          title: if effect.title then effect.title else code,
          description: effect.description
          image: effect.image
        })
      @selectListView.update({items: effects})
      @attach()
