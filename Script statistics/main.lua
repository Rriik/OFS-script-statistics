local Utils = require("utils")                              -- include utils.lua

--------------- GLOBAL VARIABLES ----------------

DEBUG = false

CurrentActiveScriptIdx = -1                                 -- stores current active script index
CurrentSelectedIndices = {}                                 -- stores current selected action indices
ScriptChanged = false                                       -- scriptChange() flag

MIN_VALUE = 1.0e10                                          -- intentionally set as positive value
MAX_VALUE = -1.0e10                                         -- intentionally set as negative value

SlopeDirection = {RISING = 1, NEUTRAL = 0, FALLING = -1}    -- action slope direction enum

ScriptStatistics = {}                                       -- stores all script statistics variables

function reset_general_values()
    ScriptStatistics.TotalActions = 0                       -- total actions
    ScriptStatistics.TotalRuntime = 0.0                     -- total actions runtime (sec)
    ScriptStatistics.TotalPeaks = 0                         -- total peaks (local maxima)
    ScriptStatistics.TotalTroughs = 0                       -- total troughs (local minima)

    ScriptStatistics.AvgActionPosition = 0.0                -- avg action position (0 - 100)
    ScriptStatistics.MaxActionPosition = MAX_VALUE          -- max action position (0 - 100)
    ScriptStatistics.MinActionPosition = MIN_VALUE          -- min action position (0 - 100)

    ScriptStatistics.AvgSpeed = 0.0                         -- avg speed between actions (units/s)
    ScriptStatistics.MaxSpeed = MAX_VALUE                   -- max speed between actions (units/s)
    ScriptStatistics.MinSpeed = MIN_VALUE                   -- min speed between actions (units/s)

    ScriptStatistics.AvgDuration = 0.0                      -- avg duration between actions (msec)
    ScriptStatistics.MaxDuration = MAX_VALUE                -- max duration between actions (msec)
    ScriptStatistics.MinDuration = MIN_VALUE                -- min duration between actions (msec)

    ScriptStatistics.AvgPeakDuration = 0.0                  -- avg duration between peaks (msec)
    ScriptStatistics.MaxPeakDuration = MAX_VALUE            -- max duration between peaks (msec)
    ScriptStatistics.MinPeakDuration = MIN_VALUE            -- min duration between peaks (msec)

    ScriptStatistics.AvgTroughDuration = 0.0                -- avg duration between troughs (msec)
    ScriptStatistics.MaxTroughDuration = MAX_VALUE          -- max duration between troughs (msec)
    ScriptStatistics.MinTroughDuration = MIN_VALUE          -- min duration between troughs (msec)
end

function reset_selected_values()
    ScriptStatistics.SelectedActions = 0                    -- selected actions
    ScriptStatistics.SelectedRuntime = 0.0                  -- selected runtime (sec)
    ScriptStatistics.SelectedPeaks = 0                      -- selected peaks (local maxima)
    ScriptStatistics.SelectedTroughs = 0                    -- selected troughs (local minima)

    ScriptStatistics.AvgSelectedActionPosition = 0.0        -- avg selected action position (0 - 100)
    ScriptStatistics.MaxSelectedActionPosition = MAX_VALUE  -- max selected action position (0 - 100)
    ScriptStatistics.MinSelectedActionPosition = MIN_VALUE  -- min selected action position (0 - 100)

    ScriptStatistics.AvgSelectedSpeed = 0.0                 -- avg selected speed between actions (units/s)
    ScriptStatistics.MaxSelectedSpeed = MAX_VALUE           -- max selected speed between actions (units/s)
    ScriptStatistics.MinSelectedSpeed = MIN_VALUE           -- min selected speed between actions (units/s)

    ScriptStatistics.AvgSelectedDuration = 0.0              -- avg duration between selected actions (msec)
    ScriptStatistics.MaxSelectedDuration = MAX_VALUE        -- max duration between selected actions (msec)
    ScriptStatistics.MinSelectedDuration = MIN_VALUE        -- min duration between selected actions (msec)

    ScriptStatistics.AvgSelectedPeakDuration = 0.0          -- avg duration between selected peaks (msec)
    ScriptStatistics.MaxSelectedPeakDuration = MAX_VALUE    -- max duration between selected peaks (msec)
    ScriptStatistics.MinSelectedPeakDuration = MIN_VALUE    -- min duration between selected peaks (msec)

    ScriptStatistics.AvgSelectedTroughDuration = 0.0        -- avg duration between selected troughs (msec)
    ScriptStatistics.MaxSelectedTroughDuration = MAX_VALUE  -- max duration between selected troughs (msec)
    ScriptStatistics.MinSelectedTroughDuration = MIN_VALUE  -- min duration between selected troughs (msec)
end

function reset_all_values()
    reset_general_values()
    reset_selected_values()
end

function init()
    -- this runs once when enabling the extension
    reset_all_values()
    local script = ofs.Script(ofs.ActiveIdx())
    if script ~= nil then
        CurrentSelectedIndices = script:selectedIndices()
    end
    print("initialized")
end

function update(delta)
    -- this runs every OFS frame
    -- delta is the time since the last call in seconds
    -- doing heavy computation here will lag OFS
end

function gui()
    -- this only runs when the window is open
    -- this is the place where a custom gui can be created
    -- doing heavy computation here will lag OFS

    check_update_needed(ofs.ActiveIdx())

    if ofs.CollapsingHeader("General") then
        ofs.Text("Actions: " .. ScriptStatistics.TotalActions)
        ofs.Text("Runtime: " ..
            string.format("%.3f", ScriptStatistics.TotalRuntime) .. " sec")
        ofs.Text("Peaks: " .. ScriptStatistics.TotalPeaks)
        ofs.Text("Troughs: " .. ScriptStatistics.TotalTroughs)

        if ofs.CollapsingHeader("  Action position##ActionPositionHeader1") then
            ofs.Text("Average: " .. (ScriptStatistics.TotalActions > 1
                and string.format("%.3f", ScriptStatistics.AvgActionPosition) or "0"))
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxActionPosition ~= MAX_VALUE
                and ScriptStatistics.MaxActionPosition or "0"))
            ofs.Text("Minimum: " .. (ScriptStatistics.MinActionPosition ~= MIN_VALUE
                and ScriptStatistics.MinActionPosition or "0"))
        end
        if ofs.CollapsingHeader("  Action speed##ActionSpeedHeader1") then
            ofs.Text("Average: " .. (ScriptStatistics.TotalActions > 1
                and string.format("%.3f", ScriptStatistics.AvgSpeed) or "0.000") .. " units/s")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSpeed ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxSpeed) or "0.000")  .. " units/s")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSpeed ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinSpeed) or "0.000")  .. " units/s")
        end
        if ofs.CollapsingHeader("  Action duration##ActionDurationHeader1") then
            ofs.Text("Average: " .. (ScriptStatistics.TotalActions > 1
                and string.format("%.3f", ScriptStatistics.AvgDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinDuration) or "0.000")  .. " msec")
        end
        if ofs.CollapsingHeader("  Peak duration##PeakDurationHeader1") then
            ofs.Text("Average: " .. (ScriptStatistics.TotalPeaks > 1
                and string.format("%.3f", ScriptStatistics.AvgPeakDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxPeakDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxPeakDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinPeakDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinPeakDuration) or "0.000")  .. " msec")
        end
        if ofs.CollapsingHeader("  Trough duration##TroughDurationHeader1") then
            ofs.Text("Average: " .. (ScriptStatistics.TotalTroughs > 1
                and string.format("%.3f", ScriptStatistics.AvgTroughDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxTroughDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxTroughDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinTroughDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinTroughDuration) or "0.000")  .. " msec")
        end
    end
    if ofs.CollapsingHeader("Selected") then
        ofs.Text("Actions: " .. ScriptStatistics.SelectedActions)
        ofs.Text("Runtime: " ..
            string.format("%.3f", ScriptStatistics.SelectedRuntime) .. " sec")
        ofs.Text("Peaks: " .. ScriptStatistics.SelectedPeaks)
        ofs.Text("Troughs: " .. ScriptStatistics.SelectedTroughs)

        if ofs.CollapsingHeader("  Action position##ActionPositionHeader2") then
            ofs.Text("Average: " .. (ScriptStatistics.SelectedActions > 1
                and string.format("%.3f", ScriptStatistics.AvgSelectedActionPosition) or "0"))
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSelectedActionPosition ~= MAX_VALUE
                and ScriptStatistics.MaxSelectedActionPosition or "0"))
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSelectedActionPosition ~= MIN_VALUE
                and ScriptStatistics.MinSelectedActionPosition or "0"))
        end
        if ofs.CollapsingHeader("  Action speed##ActionSpeedHeader2") then
            ofs.Text("Average: " .. (ScriptStatistics.SelectedActions > 1
                and string.format("%.3f", ScriptStatistics.AvgSelectedSpeed) or "0.000") .. " units/s")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSelectedSpeed ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxSelectedSpeed) or "0.000")  .. " units/s")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSelectedSpeed ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinSelectedSpeed) or "0.000")  .. " units/s")
        end
        if ofs.CollapsingHeader("  Action duration##ActionDurationHeader2") then
            ofs.Text("Average: " .. (ScriptStatistics.SelectedActions > 1
                and string.format("%.3f", ScriptStatistics.AvgSelectedDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSelectedDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxSelectedDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSelectedDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinSelectedDuration) or "0.000")  .. " msec")
        end
        if ofs.CollapsingHeader("  Peak duration##PeakDurationHeader2") then
            ofs.Text("Average: " .. (ScriptStatistics.SelectedPeaks > 1
                and string.format("%.3f", ScriptStatistics.AvgSelectedPeakDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSelectedPeakDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxSelectedPeakDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSelectedPeakDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinSelectedPeakDuration) or "0.000")  .. " msec")
        end
        if ofs.CollapsingHeader("  Trough duration##TroughDurationHeader2") then
            ofs.Text("Average: " .. (ScriptStatistics.SelectedTroughs > 1
                and string.format("%.3f", ScriptStatistics.AvgSelectedTroughDuration) or "0.000") .. " msec")
            ofs.Text("Maximum: " .. (ScriptStatistics.MaxSelectedTroughDuration ~= MAX_VALUE
                and string.format("%.3f", ScriptStatistics.MaxSelectedTroughDuration) or "0.000")  .. " msec")
            ofs.Text("Minimum: " .. (ScriptStatistics.MinSelectedTroughDuration ~= MIN_VALUE
                and string.format("%.3f", ScriptStatistics.MinSelectedTroughDuration) or "0.000")  .. " msec")
        end
    end
    if DEBUG then
        ofs.Separator()
        if ofs.CollapsingHeader("Debug options") then
            if ofs.Button("Select all peaks") then
                Utils.select_all_peaks_or_troughs("peaks")
            end
            if ofs.Button("Select all troughs") then
                Utils.select_all_peaks_or_troughs("troughs")
            end
        end
    end
end

function scriptChange(scriptIdx)
    -- is called when a funscript gets changed in some way
    -- this can be used for validation (or other creative ways?)
    ScriptChanged = true
    check_update_needed(scriptIdx)
end

-- checks whether certain conditions are met for updating statistics
function check_update_needed(scriptIdx)
    local script = ofs.Script(scriptIdx)
    if script == nil then
        reset_all_values()
        return
    end
    local selectedIndices = script:selectedIndices()

    -- active script index changes
    if scriptIdx ~= CurrentActiveScriptIdx then
        print("active index changed")
        update_statistics(scriptIdx, "all")
        CurrentActiveScriptIdx = scriptIdx
        CurrentSelectedIndices = selectedIndices

    -- scriptChange function triggers
    elseif ScriptChanged then
        if scriptIdx == CurrentActiveScriptIdx then
            print("script changed")
            update_statistics(scriptIdx, "all")
        end
        ScriptChanged = false

    -- selection changes
    elseif not Utils.table_compare_no_order(selectedIndices, CurrentSelectedIndices) then
        print("selection changed")
        update_statistics(scriptIdx, "selected")
        CurrentSelectedIndices = selectedIndices
    end
end

-- updates statistics on demand (can update all or some sections of the GUI)
function update_statistics(scriptIdx, which)
    local x = os.clock()
    if which == "all" then
        update_general_section(scriptIdx)
        update_selected_section(scriptIdx)
    elseif which == "general" then
        update_general_section(scriptIdx)
    elseif which == "selected" then
        update_selected_section(scriptIdx)
    end
    print(string.format("refresh took %.3f s", os.clock() - x))
end

-- updates values for the 'General' GUI section
function update_general_section(scriptIdx)
    reset_general_values()

    local script = ofs.Script(scriptIdx)
    local actions = script.actions
    local peaks, troughs = Utils.get_peaks_troughs(actions)

    ScriptStatistics.TotalActions = #actions
    if ScriptStatistics.TotalActions > 0 then
        local firstAction = actions[1]
        local lastAction = actions[#actions]
        ScriptStatistics.TotalRuntime = lastAction.at - firstAction.at
    end
    ScriptStatistics.TotalPeaks = #peaks
    ScriptStatistics.TotalTroughs = #troughs

    local prevAction, prevPeak, prevTrough
    for _, action in ipairs(actions) do
        ScriptStatistics.AvgActionPosition = ScriptStatistics.AvgActionPosition + action.pos
        ScriptStatistics.MaxActionPosition = math.max(action.pos, ScriptStatistics.MaxActionPosition)
        ScriptStatistics.MinActionPosition = math.min(action.pos, ScriptStatistics.MinActionPosition)

        if prevAction then
            local actionSpeed = Utils.get_action_speed(prevAction, action)
            ScriptStatistics.AvgSpeed = ScriptStatistics.AvgSpeed + actionSpeed
            ScriptStatistics.MaxSpeed = math.max(actionSpeed, ScriptStatistics.MaxSpeed)
            ScriptStatistics.MinSpeed = math.min(actionSpeed, ScriptStatistics.MinSpeed)

            local actionDuration = Utils.get_action_duration(prevAction, action) * 1000
            ScriptStatistics.AvgDuration = ScriptStatistics.AvgDuration + actionDuration
            ScriptStatistics.MaxDuration = math.max(actionDuration, ScriptStatistics.MaxDuration)
            ScriptStatistics.MinDuration = math.min(actionDuration, ScriptStatistics.MinDuration)
        end
        prevAction = action

        if Utils.find_action_in_table(action, peaks) then
            if prevPeak then
                local peakDuration = Utils.get_action_duration(prevPeak, action) * 1000
                ScriptStatistics.AvgPeakDuration = ScriptStatistics.AvgPeakDuration + peakDuration
                ScriptStatistics.MaxPeakDuration = math.max(peakDuration, ScriptStatistics.MaxPeakDuration)
                ScriptStatistics.MinPeakDuration = math.min(peakDuration, ScriptStatistics.MinPeakDuration)
            end
            prevPeak = action
        elseif Utils.find_action_in_table(action, troughs) then
            if prevTrough then
                local troughDuration = Utils.get_action_duration(prevTrough, action) * 1000
                ScriptStatistics.AvgTroughDuration = ScriptStatistics.AvgTroughDuration + troughDuration
                ScriptStatistics.MaxTroughDuration = math.max(troughDuration, ScriptStatistics.MaxTroughDuration)
                ScriptStatistics.MinTroughDuration = math.min(troughDuration, ScriptStatistics.MinTroughDuration)
            end
            prevTrough = action
        end
    end

    ScriptStatistics.AvgActionPosition = ScriptStatistics.AvgActionPosition / ScriptStatistics.TotalActions
    ScriptStatistics.AvgSpeed = ScriptStatistics.AvgSpeed / (ScriptStatistics.TotalActions - 1)
    ScriptStatistics.AvgDuration = ScriptStatistics.AvgDuration / (ScriptStatistics.TotalActions - 1)
    ScriptStatistics.AvgPeakDuration = ScriptStatistics.AvgPeakDuration / (ScriptStatistics.TotalPeaks - 1)
    ScriptStatistics.AvgTroughDuration = ScriptStatistics.AvgTroughDuration / (ScriptStatistics.TotalTroughs - 1)
end

-- updates values for the 'Selected' GUI section
function update_selected_section(scriptIdx)
    reset_selected_values()

    local script = ofs.Script(scriptIdx)
    local selectedActions = {}
    for idx, selectedIndex in ipairs(script:selectedIndices()) do
        selectedActions[idx] = script.actions[selectedIndex]
    end
    local peaks, troughs = Utils.get_peaks_troughs(selectedActions)

    ScriptStatistics.SelectedActions = #selectedActions
    if ScriptStatistics.SelectedActions > 0 then
        local firstSelectedAction = selectedActions[1]
        local lastSelectedAction = selectedActions[#selectedActions]
        ScriptStatistics.SelectedRuntime = lastSelectedAction.at - firstSelectedAction.at
    end
    ScriptStatistics.SelectedPeaks = #peaks
    ScriptStatistics.SelectedTroughs = #troughs

    local prevAction, prevPeak, prevTrough
    for _, action in ipairs(selectedActions) do
        ScriptStatistics.AvgSelectedActionPosition = ScriptStatistics.AvgSelectedActionPosition + action.pos
        ScriptStatistics.MaxSelectedActionPosition = math.max(action.pos, ScriptStatistics.MaxSelectedActionPosition)
        ScriptStatistics.MinSelectedActionPosition = math.min(action.pos, ScriptStatistics.MinSelectedActionPosition)

        if prevAction then
            local actionSpeed = Utils.get_action_speed(prevAction, action)
            ScriptStatistics.AvgSelectedSpeed = ScriptStatistics.AvgSelectedSpeed + actionSpeed
            ScriptStatistics.MaxSelectedSpeed = math.max(actionSpeed, ScriptStatistics.MaxSelectedSpeed)
            ScriptStatistics.MinSelectedSpeed = math.min(actionSpeed, ScriptStatistics.MinSelectedSpeed)

            local actionDuration = Utils.get_action_duration(prevAction, action) * 1000
            ScriptStatistics.AvgSelectedDuration = ScriptStatistics.AvgSelectedDuration + actionDuration
            ScriptStatistics.MaxSelectedDuration = math.max(actionDuration, ScriptStatistics.MaxSelectedDuration)
            ScriptStatistics.MinSelectedDuration = math.min(actionDuration, ScriptStatistics.MinSelectedDuration)
        end
        prevAction = action

        if Utils.find_action_in_table(action, peaks) then
            if prevPeak then
                local peakDuration = Utils.get_action_duration(prevPeak, action) * 1000
                ScriptStatistics.AvgSelectedPeakDuration = ScriptStatistics.AvgSelectedPeakDuration + peakDuration
                ScriptStatistics.MaxSelectedPeakDuration = math.max(peakDuration, ScriptStatistics.MaxSelectedPeakDuration)
                ScriptStatistics.MinSelectedPeakDuration = math.min(peakDuration, ScriptStatistics.MinSelectedPeakDuration)
            end
            prevPeak = action
        elseif Utils.find_action_in_table(action, troughs) then
            if prevTrough then
                local troughDuration = Utils.get_action_duration(prevTrough, action) * 1000
                ScriptStatistics.AvgSelectedTroughDuration = ScriptStatistics.AvgSelectedTroughDuration + troughDuration
                ScriptStatistics.MaxSelectedTroughDuration = math.max(troughDuration, ScriptStatistics.MaxSelectedTroughDuration)
                ScriptStatistics.MinSelectedTroughDuration = math.min(troughDuration, ScriptStatistics.MinSelectedTroughDuration)
            end
            prevTrough = action
        end
    end

    ScriptStatistics.AvgSelectedActionPosition = ScriptStatistics.AvgSelectedActionPosition / ScriptStatistics.SelectedActions
    ScriptStatistics.AvgSelectedSpeed = ScriptStatistics.AvgSelectedSpeed / (ScriptStatistics.SelectedActions - 1)
    ScriptStatistics.AvgSelectedDuration = ScriptStatistics.AvgSelectedDuration / (ScriptStatistics.SelectedActions - 1)
    ScriptStatistics.AvgSelectedPeakDuration = ScriptStatistics.AvgSelectedPeakDuration / (ScriptStatistics.SelectedPeaks - 1)
    ScriptStatistics.AvgSelectedTroughDuration = ScriptStatistics.AvgSelectedTroughDuration / (ScriptStatistics.SelectedTroughs - 1)
end
