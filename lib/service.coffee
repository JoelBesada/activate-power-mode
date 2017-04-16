module.exports = class Service
  constructor: (pluginRegistry) ->
    @pluginRegistry = pluginRegistry

  registerPlugin: (code, plugin) ->
    @pluginRegistry.addPlugin code, plugin
