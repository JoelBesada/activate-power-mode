module.exports =
  title: 'Delete Flow'
  description: 'Run only on deleting text'

  handle: (input, switcher, comboLvl) ->
    if !input.hasDeleted()
      switcher.offAll()
    else if comboLvl == 0
      switcher.offAll()
      switcher.on('comboMode')
