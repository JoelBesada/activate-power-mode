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
