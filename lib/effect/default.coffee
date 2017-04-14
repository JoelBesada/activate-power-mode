random = require "lodash.random"

module.exports =
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
      @particles.push @createParticle position.left, position.top, colorGenerate, randomSize

  createParticle: (x, y, colorGenerate, randomSize) ->
    x: x
    y: y
    alpha: 1
    color: colorGenerate()
    size: randomSize()
    velocity:
      x: -1 + Math.random() * 2
      y: -3.5 + Math.random() * 2

  animate: (context) ->
    return if not @particles.length

    gco = context.globalCompositeOperation
    context.globalCompositeOperation = "lighter"

    for i in [@particles.length - 1 ..0]
      particle = @particles[i]
      if particle.alpha <= 0.1
        @particles.splice i, 1
        continue

      particle.velocity.y += 0.075
      particle.x += particle.velocity.x
      particle.y += particle.velocity.y
      particle.alpha *= 0.96

      context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
      context.fillRect(
        Math.round(particle.x - particle.size / 2)
        Math.round(particle.y - particle.size / 2)
        particle.size, particle.size
      )

    context.globalCompositeOperation = gco
