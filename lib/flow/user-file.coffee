path = require "path"
os = require "os"

module.exports =
  title: 'User File'
  description: 'Based on user-file located on user\'s home'

  handle: (input, switcher, comboLvl) ->
    return if @error
    if not @file
      filePath = path.join(os.homedir(), '/user-flow')
      try
        @file = require filePath
      catch error
        atom.notifications.addWarning("File #{filePath} couldn't be open.")
        @error = true
        return

    @file.handle(input, switcher, comboLvl)
