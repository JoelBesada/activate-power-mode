module.exports = class Service
  constructor: (pluginRegistry, flowRegistry) ->
    @pluginRegistry = pluginRegistry
    @flowRegistry = flowRegistry

  registerPlugin: (code, plugin) ->
    @pluginRegistry.addPlugin code, plugin

  registerFlow: (code, flow) ->
    @flowRegistry.addFlow code, flow
