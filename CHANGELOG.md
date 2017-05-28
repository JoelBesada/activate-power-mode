### 2.0.0 2017-05-27
* New service to register plugins, canvas effects and input flows.
* Api to access the screen shake, audio player and the combo.
* Events on input, pane change, add cursor, and combo streak.
* Combo now supports multi levels (with multipliers), by default at 20, 50, 100, 200 and 500.
* Combo shows the counter change.
* Combo supports decrease and reset.
* Particles manager util class to create a particle based effect.
* Improve package activation performance with `requestIdleCallback`.
* Non-blocking input by calling `requestIdleCallback`.
* Commands to choose effect and flow from a list.
* Flow from a user's file, for now `user-flow.coffee` (or .js) in your home dir.
* Render only 1 each 3 frames.
* Avoid calling configs each input or frame.
* Fix issue when minimap is on the left.

### 1.4.0 2017-03-19
* Some performance improvements
* Fix rare bug with combo exclamations

### 1.3.0 2017-03-02
* Added typewriter and custom path to audio settings
* Allow custom audio path to be an absolute path
* Added reset max combo streak command
* Add class (`combo-zero`) to combo when 0
* Move color logic to new color helper
* Remark particles and effects flow when combo mode on readme
* Mention audio settings on readme

### 1.2.0 2017-01-10
* Fix deprecations related to the removed Shadow DOM
* Compatible with only >=1.13.0
* Try to change for requestAnimationFrame and 2D translate for screen shake, but has to be reverted

### 1.1.0 2016-10-26
* Saves max streak

### 1.0.2 2016-10-05
* Fix combo font

### 1.0.1 2016-10-05
* Audio disabled by default

### 1.0.0 2016-10-05
* Audio on keystroke
* Combo mode, **if enabled effects won't appear until reach the activation threshold**.

### 0.9.0 2016-09-19
* Random colours setting
* Fixed colour setting

### 0.8.1 2016-08-25
* Fix error on untitled files

### 0.8.0 2016-08-24
* Exclude file types feature
* Add enable/disable commands

### 0.7.4 2016-08-10
* Fix when canvas has no parent

### 0.7.3 2016-08-06
* Fix when scope descriptor is a invalid selector
* Uses more specific selectors

### 0.7.2 2016-08-04
* Fix issue with split panes on atom 1.9.*

### 0.7.1 2016-08-04
* Fix issue with autocomplete and linter messages positions on atom 1.9.*
* Fix issue with getting color, changed color detection logic.
* Update activate-power-mode.cson for menus
* Update README
* Update CHANGELOG

### 0.7.0 2016-07-01
* Fix issue with plugin not working when Shadow DOM is disabled in Atom
* Add support for multiple cursors
* Add better color detection to prevent getting gray particles when writing at the end of the line

### 0.6.0 2016-06-30
* Code refactor, no user-facing changes.

### 0.5.2 2016-05-03
* Properly dispose event listeners when disabling the plugin.

### 0.5.1 2016-05-03
* Fix issue with the plugin not always initializing correctly when opening a new window.

### 0.5.0 2016-05-03
* Added an option to automatically toggle the plugin when starting Atom.
* Various fixes for particle positioning.

### 0.4.1 2015-12-06
Version bump to update description on atom.io/packages.

### 0.4.0 2015-12-06
Related PR: https://github.com/JoelBesada/activate-power-mode/pull/76

* Power mode now correctly works when switching between tabs.
* Fixed drawing issues caused after resizing the window.
* Power mode can now be toggled off by using the command again.
* Minor cosmetic changes to the particle effect.
* Added screen shake config.
* Added particle config.
