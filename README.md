# Activate Power Mode

A package for Atom to replicate the effects from [codeinthedark/editor](https://github.com/codeinthedark/editor).

![activate-power-mode-0 4 0](https://cloud.githubusercontent.com/assets/688415/11615565/10f16456-9c65-11e5-8af4-265f01fc83a0.gif)

Now with a COMBO MODE!!!
And EXCLAMATION SOUNDS!!!
And BACKGROUND MUSIC!!!

![activate-power-mode-combo](https://cloud.githubusercontent.com/assets/10590799/18817237/876c2d84-8321-11e6-8324-f1540604c0bd.gif)

**For a list of power mode packages to other editors, check out [codeinthedark/awesome-power-mode](https://github.com/codeinthedark/awesome-power-mode).**

**For a video of activate-power-mode, check out [new-features](https://youtu.be/fBr48lHVYJE).**

## Install

With the atom package manager:
```bash
apm install activate-power-mode
```
Or Settings ➔ Packages ➔ Search for `activate-power-mode`

## Usage

- Activate with <kbd>Ctrl</kbd>-<kbd>Alt</kbd>-<kbd>O</kbd> or through the command panel with `Activate Power Mode: Toggle`. Use the command again to deactivate.

**IMPORTANT: When `Combo Mode` is enabled, particles and other effects won't appear until you reach the activation threshold.**

- Reset the max combo streak with the command `Activate Power Mode: Reset Max Combo`

## Settings

### Auto Toggle
Auto enable power mode on atom start.

### Combo Mode
* **Enable/Disable**

**When enabled effects won't appear until reach the activation threshold.**

* Style **killerInstinct/custom**
* Activation Threshold
* Streak Timeout
* Opacity
* Exclamation volume

### Custom Exclamations
* **Enable/Disable**
* Type and Lapse
* Text or Path

### Screen Shake
* **Enable/Disable**
* Intensity

### Play Audio
* **Enable/Disable**
* Volume
* Audioclip (Gun, Typewriter, Custom)
* Custom Audio Path

### Play Intro Audio
* **Enable/Disable**
* Volume
* Audioclip (Intro, Custom)
* Custom Audio Path

### Play Background Music
* **Enable/Disable**
* Path to Audio
* Volume

### Play Background Music Action
* **none/repit/change, endMusic/endStreak/duringStreak, streak/time, lapse**

**The last 2 parameters are only used on duringStreak**

### Particles
* **Enable/Disable**
* Colour

With this option you can select if use the color at cursor position, random colors or a fixed one.

* Total Count
* Spawn Count
* Size

### Excluded File Types
* Array of file types to exclude

## References
* Intro Sound downloaded from [here](https://www.freesound.org/people/kantouth/sounds/104396/).
* Exclamation audios downloaded from [here](http://www.killerinstinctonline.net/).
* Background Music downloaded from [here](http://www.bensound.com).
