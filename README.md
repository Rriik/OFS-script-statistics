# OFS script statistics extension

## Description
This is an [OpenFunscripter](https://github.com/OpenFunscripter/OFS) extension that enables detailed script-wide statistics, providing an (unofficial) addition to the default statistics window (View tab > Statistics).

By default, the OFS editor only shows statistics relating to the interval between two actions found at or near the timeline navigation cursor. This extension adds a whole new layer of information by analyzing the entire currently active script.

## Features
- View statistics about the entire script, as well as for a selected portion of the script
- View general information, such as number of actions, runtime of the script, number of peaks and troughs ([see explanation](#about-peaks-and-troughs))
- View the average, maximum and minimum action position, speed and duration, as well as peak and trough duration
- Convenient GUI with nested cascading headers allowing you to see only what interests you ([see showcase](#gui-showcase))
- Automatically refreshes values when the active script changes, when the script is changed in any way and when the action selection changes
- Developed for OFS v3

## Installation
1. Download and extract the latest version of the extension from [Releases](https://github.com/Rriik/OFS-script-statistics/releases)
2. Copy the `Script statistics` directory and add it to the OFS extensions directory (`%appdata%/OFS3_data/extensions/`)
3. Start OpenFunscripter
4. In the `Extensions` tab, hover over the `Script statistics` list item and tick `Enabled` and `Show window`
5. Optionally, you can pin the extension window to the OFS GUI. I prefer dedicating the right side of the UI to both the default and the extended statistics

## GUI showcase
![image](https://user-images.githubusercontent.com/132300166/236696928-c72adaca-f8d1-4964-8b02-c5b7b283197d.png)

## About peaks and troughs
Peaks and troughs are mathematical local maxima and minima (points on a plot which are highest/lowest among their vicinity). In this case, they are the actions with the highest/lowest position value in their vicinity. The script analyser respects the mathematical rules that dictate what should count as local extrema. This means that:

- a script with less than 2 actions or where all actions have the same position does not have local extrema
- multiple actions in a row that have the same position value will be considered local extrema if at least one fulfills the requirements for that
- the first and last actions (edges) of a script will be considered local extrema

To get a better sense of which actions are counted as peaks and troughs, you can check the debug section of the extension GUI. This section contains buttons that highlight the peaks and troughs by selecting the respective actions in the timeline. Here, you can also toggle more detailed extension logs to see when statistics are refreshed and how long that takes for your script.

## Notes
- The extension is not highly optimized in terms of loop operations, but that should not be a problem. Benchmark reporting is included in the extension logs, and using the example script showcased above, it is able to refresh statistics for ~250 actions in around 7 ms. The stats are only refreshed when certain conditions are met as explained in the features, so this should not have an impact on GUI performance.
- Upon initial startup, the statistics get refreshed multiple times as the editor loads the various scripts written for a project. This behavior does not repeat after initialization or when reloading the extension.
