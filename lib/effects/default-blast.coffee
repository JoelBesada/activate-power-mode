random = require "lodash.random"

getConfig = (config) ->
  atom.config.get "activate-power-mode.#{config}"

module.exports =
  init: (particle) ->
    particle.size = random getConfig("particles.size.min"), getConfig("particles.size.max"), true
    particle.vx = -1 + Math.random() * 2
    particle.vy = -3.5 + Math.random() * 2

  update: (particle, context) ->
    particle.vy += 0.075
    particle.x += particle.vx
    particle.y += particle.vy
    particle.alpha *= 0.96

    context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
    context.fillRect(
      Math.round(particle.x - particle.size / 2)
      Math.round(particle.y - particle.size / 2)
      particle.size, particle.size
    )
