module.exports =
  handle: (input, switcher, comboLvl) ->
    if comboLvl == 0
      switcher.offAll()
      switcher.on('comboMode')
