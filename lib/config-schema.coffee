module.exports =
  minShake:
    type: 'number'
    default: 1.0
    minimum: 0
    maximum: 100
    description: 'The minimum intensity of the shake.'
  intensity:
    type: 'number'
    default: 2.0
    minimum: 0
    maximum: 100
    description: 'The intensity of the shake.'
  animation:
    type: 'boolean'
    default: true
  shake:
    title: 'Shake Editor'
    description: 'Turn on/off editor shaking behaviour'
    type: 'boolean'
    default: true
