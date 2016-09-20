module.exports =
  autoToggle:
    title: "Auto Toggle"
    description: "Toggle on start."
    type: "boolean"
    default: true

  screenShake:
    type: "object"
    properties:
      minIntensity:
        title: "Screen Shake - Minimum Intensity"
        description: "The minimum (randomized) intensity of the shake."
        type: "integer"
        default: 1
        minimum: 0
        maximum: 100

      maxIntensity:
        title: "Screen Shake - Maximum Intensity"
        description: "The maximum (randomized) intensity of the shake."
        type: "integer"
        default: 3
        minimum: 0
        maximum: 100

      enabled:
        title: "Screen Shake - Enabled"
        description: "Turn the shaking on/off."
        type: "boolean"
        default: true

  particles:
    type: "object"
    properties:
      enabled:
        title: "Particles - Enabled"
        description: "Turn the particles on/off."
        type: "boolean"
        default: true
        order: 1

      colours:
        type: "object"
        properties:
          type:
            title: "Colours"
            description: "Configure colour options"
            type: "string"
            default: "cursor"
            enum: [
              {value: 'cursor', description: 'Particles will be the colour at the cursor.'}
              {value: 'random', description: 'Particles will have random colours.'}
              {value: 'fixed', description: 'Particles will have a fixed colour.'}
            ]
            order: 1

          fixed:
            title: "Fixed colour"
            description: "Colour when fixed colour is selected"
            type: "color"
            default: "#fff"

      totalCount:
        type: "object"
        properties:
          max:
            title: "Particles - Max Total"
            description: "The maximum total number of particles on the screen."
            type: "integer"
            default: 500
            minimum: 0

      spawnCount:
        type: "object"
        properties:
          min:
            title: "Particles - Minimum Spawned"
            description: "The minimum (randomized) number of particles spawned on input."
            type: "integer"
            default: 5

          max:
            title: "Particles - Maximum Spawned"
            description: "The maximum (randomized) number of particles spawned on input."
            type: "integer"
            default: 15

      size:
        type: "object"
        properties:
          min:
            title: "Particles - Minimum Size"
            description: "The minimum (randomized) size of the particles."
            type: "integer"
            default: 2
            minimum: 0

          max:
            title: "Particles - Maximum Size"
            description: "The maximum (randomized) size of the particles."
            type: "integer"
            default: 4
            minimum: 0

  excludedFileTypes:
    type: "object"
    properties:
      excluded:
        title: "Prohibit activate-power-mode from enabling on these file types:"
        description: "Use comma separated, lowercase values (i.e. \"html, cpp, css\")"
        type: "array"
        default: ["."]
