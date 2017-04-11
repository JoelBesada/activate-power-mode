module.exports =
  handle: (e) ->
    @e = e

  getEvent: ->
    @e

  getPosition: ->
    if @e.newText
      @e.newRange.end
    else
      @e.newRange.start

  isNewLine: ->
    not @e.newText and not @e.oldText

  hasDeleted: ->
    not not @e.oldText

  hasWritten: ->
    not not @e.newText

  getText: ->
    @e.newText

  getDeletedText: ->
    @e.oldText
