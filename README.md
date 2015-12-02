# activate-power-mode atom package
A work in progress package for Atom to replicate [codeinthedark/editor#1](https://github.com/codeinthedark/editor/pull/1) by popular demand.

**NOTE THAT THIS VERSION IS VERY BUGGY RIGHT NOW**

![activate-power-mode](https://cloud.githubusercontent.com/assets/688415/11453297/b8f249ec-9605-11e5-978c-eb3bb21eecd8.gif)

## Installation
See the [contributing](#contributing) section. This package will be available through apm once it's stable.

## Usage
Activate with <kbd>Ctrl</kbd>-<kbd>Alt</kbd>-<kbd>O</kbd> or through the command panel with `Activate Power Mode: Toggle`. In
this early version it only affects the current tab. To run it in a new tab you need to run `Window: Reload` first.

## Contributing
If you haven't already done so, install [Node.js](https://nodejs.org/).

Once Node.js is installed, place this package in your `~/.atom/packages/` directory. It's recommended that you use git to clone this package into that directory, as follows:

    git clone https://github.com/JoelBesada/activate-power-mode.git ~/.atom/packages/activate-power-mode

Then you must install the project's dependencies using `npm`.

    cd ~/.atom/packages/activate-power-mode
    npm install

If Atom is already running, run `Window: Reload`. The package may now be used.
