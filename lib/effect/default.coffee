module.exports =
  title: 'Default effect'
  description: 'Simple blaster effect.'
  image: 'atom://activate-power-mode/images/default-effect.gif'

  isDone: (particle) ->
    particle.alpha <= 0.1

  update: (particle) ->
    particle.velocity.y += 0.075
    particle.x += particle.velocity.x
    particle.y += particle.velocity.y
    particle.alpha *= 0.96

  draw: (particle, context) ->
    context.fillStyle = "rgba(#{particle.color[4...-1]}, #{particle.alpha})"
    context.fillRect(
      Math.round(particle.x - particle.size / 2)
      Math.round(particle.y - particle.size / 2)
      particle.size, particle.size
    )
