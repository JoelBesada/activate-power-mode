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
    @e.newText is '\n'

  hasDeleted: ->
    not not @e.oldText

  hasWritten: ->
    not not @e.newText and @e.newText isnt '\n'

  getText: ->
    @e.newText

  getDeletedText: ->
    @e.oldText

  isGhost: ->
    not @e.newText and not @e.oldText
