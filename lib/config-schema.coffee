module.exports =
  screenShake:
    type: "object"
    properties:
      minIntensity:
        title: "Screen Shake - Minimum Intensity"
        description: "The minimum (randomized) intensity of the shake"
        type: "number"
        default: 1.0
        minimum: 0
        maximum: 100

      maxIntensity:
        title: "Screen Shake - Maximum Intensity"
        description: "The maximum (randomized) intensity of the shake"
        type: "number"
        default: 3.0
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
