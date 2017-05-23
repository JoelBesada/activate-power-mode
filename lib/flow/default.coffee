module.exports =
  title: 'Default Flow'
  description: 'Basic flow'

  handle: (input, switcher, comboLvl) ->
    if comboLvl == 0
      switcher.offAll()
      switcher.on('comboMode')
