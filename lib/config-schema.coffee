module.exports =
  autoToggle:
    title: "Auto Toggle"
    description: "Toggle on start."
    type: "boolean"
    default: true

  comboMode:
    type: "object"
    properties:
      enabled:
        title: "Combo Mode - Enabled"
        description: "When enabled effects won't appear until reach the activation threshold."
        type: "boolean"
        default: true
        order: 1

      style:
        title: "Combo Mode - Style"
        description: "Sets the settings to have pre-configured style or use custom settings."
        type: "string"
        default: 'killerInstint'
        enum: [
          {value: 'killerInstint', description: 'Killer Instint'}
          {value: 'custom', description: 'Custom'}
        ]
        order: 2

      activationThreshold:
        title: "Combo Mode - Activation Threshold (To aply this setting Combo Mode - Style has to be Custom)"
        description: "Streak threshold to activate the power mode."
        type: "integer"
        default: 50
        minimum: 1
        maximum: 1000
        order: 3

      streakTimeout:
        title: "Combo Mode - Streak Timeout"
        description: "Timeout to reset the streak counter. In seconds."
        type: "integer"
        default: 10
        minimum: 1
        maximum: 100
        order: 4

      opacity:
        title: "Combo Mode - Opacity"
        description: "Opacity of the streak counter."
        type: "number"
        default: 0.6
        minimum: 0
        maximum: 1
        order: 5

      customExclamations:
        type: "object"
        description: "To aply this setting Combo Mode - Style has to be Custom"
        properties:
          typeAndLapse:
            title: "Exclamations - Type and Display Every Streak"
            description: "types: onlyText, onlyAudio, bouth. streakCount: min 10 max 100. (left in 0 to display at end of the Streak)."
            type: "array"
            default: ["onlyText", "10"]
            order: 1

          textsOrPath:
            title: "Exclamations - Exclamation Texts or Path"
            description: 'Custom exclamations to show (randomized) or Path to exclamations audiofiles. (Add "/" or, "\\" at the end of the path).'
            type: "array"
            default: ["Super!", "Radical!", "Fantastic!", "Great!", "OMG", "Whoah!", ":O", "Nice!", "Splendid!", "Wild!", "Grand!", "Impressive!", "Stupendous!", "Extreme!", "Awesome!"]
            order: 3

      exclamationVolume:
        title: "Exclamations - Exclamation Volume"
        description: "Volume of the exclamation audio."
        type: "number"
        default: 0.50
        minimum: 0.0
        maximum: 1.0

      customSuperExclamation:
        type: "object"
        description: "To aply this setting Combo Mode - Style has to be Custom"
        properties:
          lapse:
            title: "Super Exclamation - Lapse"
            description: 'Shows a super exclamations every lapse. Could be time lapse (in seconds)  or streak count lapse. Ej: "streak, 100" or "Time, 60". (lpse will reset if streak ends) left in 0 to desable super exclamation.'
            type: "array"
            default: ["streak","100"]

          textOrFile:
            title: "Super Exclamation - Texts or File"
            description: "Super exclamation to show. Could be a text or a file path if is a file also will show the file's name"
            type: "string"
            default: "../audioclips/exclamations/Yes oh my God.wav"

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

  playAudio:
    type: "object"
    properties:
      enabled:
        title: "Play Audio - Enabled"
        description: "Play audio clip on/off."
        type: "boolean"
        default: false
        order: 1

      audioclip:
        title: "Play Audio - Audioclip"
        description: "Which audio clip played at keystroke."
        type: "string"
        default: '../audioclips/gun.wav'
        enum: [
          {value: '../audioclips/gun.wav', description: 'Gun'}
          {value: '../audioclips/typewriter.wav', description: 'Type Writer'}
          {value: 'customAudioclip', description: 'Custom Path'}
        ]
        order: 3

      customAudioclip:
        title: "Play Audio - Path to Audioclip"
        description: "Path to audioclip played at keystroke."
        type: "string"
        default: 'rocksmash.wav'
        order: 4

      volume:
        title: "Play Audio - Volume"
        description: "Volume of the audio clip played at keystroke."
        type: "number"
        default: 0.42
        minimum: 0.0
        maximum: 1.0
        order: 2

  playBackgroundMusic:
    type: "object"
    properties:
      enabled:
        title: "Background Music - Enabled"
        description: "Play Background Music on/off."
        type: "boolean"
        default: true
        order: 1

      musicPath:
        title: "Background Music - Path to Audio"
        description: "Path to Music Tracks played in combo Mode."
        type: "string"
        default: '../audioclips/backgroundmusics/'
        order: 2

      musicVolume:
        title: "Background Music - Volume"
        description: "Volume of the Music Track played in combo Mode."
        type: "number"
        default: 0.25
        minimum: 0.0
        maximum: 1.0
        order: 3

      actions:
        type: "object"
        properties:
          command:
            title: "Music Player - Action"
            description: 'Syntax "action, when, lapseType, lapse".\n
            action: repit, change, none\n
            execution: duringStreak, endStreak, endMusic\n
            lapseType: streak, time (This value is used only if execution is duringStreak)\n
            lapse: Number Value (if lapseType is time, lapse will be in seconds)\n
            Note: the lapsetype and lapse values is only used in duringStreak.'
            type: "array"
            default: ['change', 'duringStreak', 'Streak', '100']

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
