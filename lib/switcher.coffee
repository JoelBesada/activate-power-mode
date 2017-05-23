module.exports =
  reset: ->
    @onAll()

  offAll: ->
    @default = false
    @plugins = []

  onAll: ->
    @default = true
    @plugins = []

  off: (code) ->
    @plugins[code] = false

  on: (code, data) ->
    if data?
      @plugins[code] = data
    else
      @plugins[code] = true

  isOff: (code) ->
    not @isOn code

  isOn: (code) ->
    if not @plugins[code]?
      @default
    else
      true

  getData: (code) ->
    if @plugins[code]? and typeof @plugins[code] is 'object'
      @plugins[code]
    else
      []
