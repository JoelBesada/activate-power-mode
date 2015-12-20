# Effect based on Soulwire's demo: http://codepen.io/soulwire/pen/foktm
random = require "lodash.random"

getConfig = (config) ->
  atom.config.get "activate-power-mode.#{config}"

module.exports =
  init: (particle) ->
    particle.size = random getConfig("particles.size.min"), getConfig("particles.size.max"), true
    particle.drag = 0.92
    particle.vx = random -3, 3
    particle.vy = random -3, 3
    particle.wander = 0.15
    particle.theta = random(0, 360) * Math.PI / 180;

  update: (particle, context) ->
    particle.x += particle.vx;
    particle.y += particle.vy;
    particle.vx *= particle.drag
    particle.vy *= particle.drag
    particle.theta += random -0.5, 0.5
    particle.vx += Math.sin( particle.theta ) * 0.1
    particle.vy += Math.cos( particle.theta ) * 0.1
    particle.size *= 0.96

    context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
    context.beginPath()
    context.arc(Math.round(particle.x - 1), Math.round(particle.y - 1), particle.size, 0, 2 * Math.PI)
    context.fill()