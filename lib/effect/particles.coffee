random = require "lodash.random"

module.exports = class ParticlesEffect
  particles: []

  constructor: (particleManager) ->
    @title = particleManager.title
    @description = particleManager.description
    @image = particleManager.image
    @particleManager = particleManager

  init: ->
    @reset()

  disable: ->
    @reset()

  reset: ->
    @particles = []

  spawn: (position, colorGenerate, input, randomSize, conf) ->
    @conf = conf
    numParticles = random @conf['spawnCount.min'], @conf['spawnCount.max']

    while numParticles--
      @particles.shift() if @particles.length >= @conf['totalCount.max']
      if @particleManager.create?
        particle = @particleManager.create position.left, position.top, colorGenerate, randomSize
      else
        particle = @createParticle position.left, position.top, colorGenerate, randomSize
        @particleManager.init?(particle)

      @particles.push particle

  createParticle: (x, y, colorGenerate, randomSize) ->
    x: x
    y: y
    alpha: 1
    color: colorGenerate()
    size: randomSize()
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  update: ->
    return if not @particles.length

    for i in [@particles.length - 1 ..0]
      particle = @particles[i]

      if @particleManager.isDone particle
        @particles.splice i, 1
        continue

      @particleManager.update particle

  animate: (context) ->
    return if not @particles.length

    gco = context.globalCompositeOperation
    context.globalCompositeOperation = "lighter"

    for i in [@particles.length - 1 ..0]
      particle = @particles[i]

      @particleManager.draw particle, context

    context.globalCompositeOperation = gco
