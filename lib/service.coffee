ParticlesEffect = require "./effect/particles"

module.exports = class Service
  constructor: (pluginRegistry, flowRegistry, effectRegistry) ->
    @pluginRegistry = pluginRegistry
    @flowRegistry = flowRegistry
    @effectRegistry = effectRegistry

  registerPlugin: (code, plugin) ->
    @pluginRegistry.addPlugin code, plugin

  registerFlow: (code, flow) ->
    @flowRegistry.addFlow code, flow

  registerEffect: (code, effect) ->
    @effectRegistry.addEffect code, effect

  createParticlesEffect: (particleManager) ->
    new ParticlesEffect(particleManager)
