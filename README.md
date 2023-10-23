# OFS script statistics extension

## Description
This is an [OpenFunscripter](https://github.com/OpenFunscripter/OFS) extension that enables detailed script-wide statistics, providing an (unofficial) addition to the default statistics window (View tab > Statistics).

By default, the OFS editor only shows statistics relating to the interval between two actions found at or near the timeline navigation cursor. This extension adds a whole new layer of information by analyzing the entire currently active script.

## Table of contents
- [Description](#description)
- [Features](#features)
- [GUI showcase](#gui-showcase)
- [Installation](#installation)
- [About peaks and troughs](#about-peaks-and-troughs)
- [Notes](#notes)

## Features
- View statistics about the entire script, as well as for a selected portion of the script
- View general information, such as number of actions, runtime of the script, number of peaks and troughs ([see explanation](#about-peaks-and-troughs))
- View the average, maximum and minimum action position, speed and duration, as well as peak and trough duration
- Convenient GUI with nested cascading headers allowing you to see only what interests you ([see showcase](#gui-showcase))
- Automatically refreshes values when the active script changes, when the script is changed in any way and when the action selection changes
- Developed for OFS v3

## GUI showcase
![image](https://user-images.githubusercontent.com/132300166/236696928-c72adaca-f8d1-4964-8b02-c5b7b283197d.png)

## Installation
1. Download and extract the latest version of the extension from [Releases](https://github.com/Rriik/OFS-script-statistics/releases)
2. Copy the `Script statistics` directory and add it to the OFS extensions directory (`%appdata%/OFS3_data/extensions/`)
3. Start OpenFunscripter
4. In the `Extensions` tab, hover over the `Script statistics` list item and tick `Enabled` and `Show window`
5. Optionally, you can pin the extension window to the OFS GUI. I prefer dedicating the right side of the UI to both the default and the extended statistics

## About peaks and troughs
Peaks and troughs are mathematical local maxima and minima (points on a plot which are highest/lowest among their vicinity). In this case, they are the actions with the highest/lowest position value in their vicinity. The script analyser respects the mathematical rules that dictate what should count as local extrema. This means that:

- a script with less than 2 actions or where all actions have the same position does not have local extrema
- multiple actions in a row that have the same position value will be considered local extrema if at least one fulfills the requirements for that
- the first and last actions (edges) of a script will be considered local extrema

To get a better sense of which actions are counted as peaks and troughs, you can check the debug section of the extension GUI. This section contains buttons that highlight the peaks and troughs by selecting the respective actions in the timeline. Here, you can also toggle more detailed extension logs to see when statistics are refreshed and how long that takes for your script.

## Notes

If you like this extension, please spread the word about it! Any feedback is welcome, so feel free to share your thoughts, suggestions for improvements or bugs you may find in the comment sections where this is posted, or through GitHub issues.

Also, check out my other OFS extension project:
- [OFS fuck machine script converter](https://github.com/Rriik/OFS-FM-script-converter) - converts funscript patterns into power level variations suitable for any [buttplug.io-supported](https://iostindex.com/?filter0Type=Fucking%20Machine) rotary fuck machine
