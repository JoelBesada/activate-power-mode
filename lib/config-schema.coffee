module.exports =
  screenShake:
    type: "object"
    properties:
      minIntensity:
        title: "Screen Shake - Minimum Intensity"
        description: "The minimum (randomized) intensity of the shake"
        type: "integer"
        default: 1
        minimum: 0
        maximum: 100

      maxIntensity:
        title: "Screen Shake - Maximum Intensity"
        description: "The maximum (randomized) intensity of the shake"
        type: "integer"
        default: 3
        minimum: 0
        maximum: 100

      enabled:
        title: "Screen Shake - Enabled"
        description: "Turn the shaking on/off"
        type: "boolean"
        default: true

  particles:
    type: "object"
    properties:
      enabled:
        title: "Particles - Enabled"
        description: "Turn the particles on/off"
        type: "boolean"
        default: true

      maxTotal:
        title: "Particles - Max Total"
        description: "The maximum total number of particles on the screen"
        type: "integer"
        default: 500
        minimum: 0

      min:
        title: "Particles - Minimum Spawned"
        description: "The minimum (randomized) number of particles spawned on input"
        type: "integer"
        default: 5

      max:
        title: "Particles - Maximum Spawned"
        description: "The maximum (randomized) number of particles spawned on input"
        type: "integer"
        default: 15
