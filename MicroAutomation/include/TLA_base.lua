--[[
Name: The Last Axe Helpers
@version 1.0.0
Provides: [nomain] .
]]

--[[

████████╗██╗  ██╗███████╗    ██╗      █████╗ ███████╗████████╗     █████╗ ██╗  ██╗███████╗
╚══██╔══╝██║  ██║██╔════╝    ██║     ██╔══██╗██╔════╝╚══██╔══╝    ██╔══██╗╚██╗██╔╝██╔════╝
   ██║   ███████║█████╗      ██║     ███████║███████╗   ██║       ███████║ ╚███╔╝ █████╗  
   ██║   ██╔══██║██╔══╝      ██║     ██╔══██║╚════██║   ██║       ██╔══██║ ██╔██╗ ██╔══╝  
   ██║   ██║  ██║███████╗    ███████╗██║  ██║███████║   ██║       ██║  ██║██╔╝ ██╗███████╗
   ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝


█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝

            ██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗ ██╗██╗
            ██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝ ██║██║
            ██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗██║██║
            ██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║╚═╝╚═╝
            ╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝██╗██╗

            DO NOT MODIFY BELOW THESE LINES, THIS CONTENT IS AUTO-GENERATED

█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝


                ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
                ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
                ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
                ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
                ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
                ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝

These helper functions are auto-included from TLA_base.lua when the package distribution is built.
They primarily abstract portions of interacting with the reaper.* built-in API methods, to sanitize
the responses, and create nice boundaries for automated testing.

If you want to make changes to the configuration for this script, see the SCRIPT CONFIG section
below.

]]

local TLA = {}


--[[
  Set the global reaper variable.
]]
function TLA.initReaper(rpr)
  reaper = rpr
end


--[[
  Log for reaper.
]]
function TLA.log(value) 
  if TLA.config.debug == true then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end


--[[
  Clear the console if in debug mode.
]]
function TLA.debugInit()
  if TLA.config.debug then
    reaper.ClearConsole()
  end
end


--[[
  Return {startTime, endTime} for current time selection, or nil if 
  nothing is selected.
]]
function TLA.getCurrentTimeSelection()
  local range = TLA.getLoopTimeRange()

  if range.startTime == 0.0 and range.endTime == 0.0 or range.startTime == range.endTime then
    return nil
  end

  return {
    startTime = range.startTime,
    endTime = range.endTime,
    length = range.endTime - range.startTime
  }
end


--[[
  Find contiguous set of points in an envelope (2 or more).
]]
function TLA.getContiguousSelectedPointsForEnvelope(envelope)
  local allPoints = TLA.getEnvelopePoints(envelope)
  if not allPoints then
    return nil
  end

  local lastWasSelected = nil
  local index = 0
  local points = {}
  local totalPoints = TLA.length(allPoints)

  -- TODO: pairs() is a better way to do this, but it returns out of order for the tests
  -- for j = 1, totalPoints - 1 do
  for _, point in pairs(allPoints) do
    -- local point = allPoints[j]
    if point.selected then
      lastWasSelected = true
      points[index] = point
      index = index + 1
    else
      if lastWasSelected then
        break
      end
    end
  end

  if TLA.length(points) < 1 then
    return nil
  end
  return points
end

--[[
  Retreive the two inner points from a list
]]
function TLA.getInnerPoints(points)
  local extremes = TLA.getTimeBoundsForPoints(points)
  local out = {}
  for k, point in pairs(points) do
    if point.time > extremes.min and point.time < extremes.max then
      table.insert(out, point)
    end
  end
  return out
end

--[[
  Convert the MIDI input scale 0-127 to a percentage 0-1.
]]
function TLA.midiInputToPercent(value) 
  return value / 127
end


--[[
  Gets the midi input value, scaled to a linear 0-1
]]
function TLA.getMidiInputToPercent()
  local value = TLA.getMidiInputValue()
  return TLA.midiInputToPercent(value)
end

--[[
  Determine the min/max time values from a list of points
]]
function TLA.getTimeBoundsForPoints(points) 
  local min = nil
  local max = nil

  for k, point in pairs(points) do 
    if min == nil then
      min = point.time
    end
    if max == nil then
      max = point.time
    end
    min = math.min(point.time, min)
    max = math.max(point.time, max)
  end
  return {min = min, max = max}
end

--[[
  Count the number of points within a selection.
]]
function TLA.countPointsWithinSelection(points, selection)
  local startTime = selection.startTime
  local endTime = selection.endTime
  local count = 0

  for k, point in pairs(points) do
    if point.time >= startTime and point.time <= endTime then
      count = count + 1
    end
  end

  return count
end


--[[
  Get all points for an envelope.
]]
function TLA.getEnvelopePoints(envelope)
  local totalPoints = TLA.countEnvelopePoints(envelope)
  local points = {}
  for i = 0, totalPoints - 1 do
    local point = TLA.getEnvelopePoint(envelope, i)
    table.insert(points, point)
  end
  return points
end


--[[
  Get the first point in a list
]]
function TLA.getFirstPointByTime(points)
  local minTime = nil
  local firstPoint = nil
  for k, point in pairs(points) do 
    if minTime == nil or point.time < minTime then
      minTime = point.time
      firstPoint = point
    end
  end
  return firstPoint
end


--[[
  Get the first point in a list
]]
function TLA.getLastPointByTime(points)
  local maxTime = nil
  local lastPoint = nil
  for k, point in pairs(points) do 
    if maxTime == nil or point.time > maxTime then
      maxTime = point.time
      lastPoint = point
    end
  end
  return lastPoint
end


--[[
  Get points within selection.
]]
function TLA.getPointsWithinTime(envelope, startTime, endTime)
  local allPoints = TLA.getEnvelopePoints(envelope)
  local points = {}
  for k, point in pairs(allPoints) do
    if point.time >= startTime and point.time <= endTime then
      table.insert(points, point)
    end
  end
  return points
end


--[[
  Deselect points
]]
function TLA.deselectPoints(envelope, points) 
  for k, point in pairs(points) do
    local index = TLA.getPointIndexAtTime(envelope, point.time)
    TLA.deselectPoint(envelope, index)
  end
end

--[[
  Deselect a single point at time.
]]
function TLA.deselectPoint(envelope, index)
  reaper.SetEnvelopePoint(envelope, index, _, _, _, _, false, _)
end

--[[
  Select points
]]
function TLA.selectPoints(envelope, points)
  for k, point in pairs(points) do
    local index = TLA.getPointIndexAtTime(envelope, point.time)
    TLA.selectPoint(envelope, index)
  end
end

--[[
  Select point
]]
function TLA.selectPoint(envelope, index)
  reaper.SetEnvelopePoint(envelope, index, _, _, _, _, true, _)
end

--[[
  Set point value
]]
function TLA.setPointValue(envelope, point, value)
  local index = TLA.getPointIndexAtTime(envelope, point.time)
  reaper.SetEnvelopePoint(envelope, index, _, value, _, _, _, _)
end

--[[
  Set point time
]]
function TLA.setPointTime(envelope, point, time)
  local index = TLA.getPointIndexAtTime(envelope, point.time)
  reaper.SetEnvelopePoint(envelope, index, time, _, _, _, _, _)
end


--[[
  Remove point at time
]]
function TLA.removePointsInTimeRange(envelope, startTime, endTime)
  reaper.DeleteEnvelopePointRange(envelope, startTime, endTime)
end


-- converts values from 0/1 to -1/1
function TLA.proportionalValue(input)
  return (2 * input) - 1;
end


--[[
  The math: 
   - 'range' is percentage how much of the total available we are allowed to
     adjust up or down, multiply this by the max range to get localRange
   - then we take that and multiply it by the input proportionally, so that
     anything above 50% gives us +localRange/2 and anything under 50% gives
     us -localRange/2
   - then add that +/- value to the currentValue for the final adjustment
   - NOTE: that values may come in with min/max of 0/X but also may be -1/1
]]
function TLA.calculateFinalPointValue(currentValue, input, min, max, range)
  local totalMaxRange = max - min
  -- print('totalMaxRange: ' .. totalMaxRange)
  local totalLocalRange = totalMaxRange * range / 2
  -- print('totalLocalRange: ' .. totalLocalRange)
  local effectiveAdjustmentRatio = TLA.proportionalValue(input)
  -- print('effectiveAdjustmentRatio: ' .. effectiveAdjustmentRatio)
  local effectiveAdjustment = totalLocalRange * effectiveAdjustmentRatio
  -- print('effectiveAdjustment: ' .. effectiveAdjustment)
  local finalValue = currentValue + effectiveAdjustment
  -- print('finalValue: ' .. finalValue)
  if finalValue < min then
    finalValue = min
  end
  if finalValue > max then
    finalValue = max
  end
  return finalValue
end


--[[          
                                                                  
          ██╗    ██╗██████╗  █████╗ ██████╗ ██████╗ ███████╗██████╗ ███████╗
          ██║    ██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
          ██║ █╗ ██║██████╔╝███████║██████╔╝██████╔╝█████╗  ██████╔╝███████╗
          ██║███╗██║██╔══██╗██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
          ╚███╔███╔╝██║  ██║██║  ██║██║     ██║     ███████╗██║  ██║███████║

Methods that only wrap the built-in `reaper.*` API (aka: sans logic), mainly for sanitizing
inputs/outputs and unit testing.
]]

--[[
  Wrapper for reaper.GetSet_LoopTimeRange2()
]]
function TLA.getLoopTimeRange()
  local startTime, endTime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  return {
    startTime = startTime,
    endTime = endTime
  }
end

--[[
  Wrapper for reaper.CountSelectedTracks(0)
]]
function TLA.countSelectedTracks()
  return reaper.CountSelectedTracks(0)
end


--[[
  Wrapper around reaper.GetEnvelopePoint().
  Return an envelope point by index.
]]
function TLA.getEnvelopePoint(envelope, index)
  local scaleMode = TLA.getEnvelopeScalingMode(envelope)
  local _, time, value, _, _, selected = reaper.GetEnvelopePoint(envelope, index)
  return {
    time = time,
    selected = selected,
    value = value,
    normalValue = TLA.scaleFromEnvelopeMode(scaleMode, value),
    scaleMode = scaleMode
  }
end

--[[
  Return the current midi input value
]]
function TLA.getMidiInputValue()
  local _, _, _, _, _, _, midi_value = reaper.get_action_context()
  return midi_value
end

--[[
  Wrapper around reaper.GetSelectedEnvelope(0)
]]
function TLA.getSelectedEnvelope()
  return reaper.GetSelectedEnvelope(0)
end

--[[
  Wrapper around reaper.CountEnvelopePoints()
]]
function TLA.countEnvelopePoints(envelope)
  return reaper.CountEnvelopePoints(envelope)
end


--[[
  Set the selection.
]]
function TLA.setSelection(startTime, endTime) 
  reaper.GetSet_LoopTimeRange(true, false, startTime, endTime, false)
end

--[[
  Get point at time.
]]
function TLA.getPointIndexAtTime(envelope, time)
  return reaper.GetEnvelopePointByTime(envelope, time)
end

--[[
  Get envelope value at time
]]
function TLA.getEnvelopeValueAtTime(envelope, time)
  local _, value, _, _, _ = reaper.Envelope_Evaluate(envelope, time, 0, 0)
  return value
end

--[[
  Create envelope point at time.
]]
function TLA.createEnvelopePointAtTime(envelope, time, value)
  reaper.InsertEnvelopePoint(envelope, time, value, 0, 0, true, true)
end


--[[
  Get value of the envelope at the cursor time.
]]
function TLA.getEnvelopeValueAtCursor(envelope)
  local time = TLA.getTimeAtCursor()
  return TLA.getEnvelopeValueAtTime(envelope, time)
end

--[[
  Get envelope min/max properties
]]
function TLA.getEnvelopeProperties(envelope)
  local allocated = reaper.BR_EnvAlloc(envelope, false)
  local _, visible, armed, _, _, _, minValue, maxValue, _, _, _ = reaper.BR_EnvGetProperties(allocated, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
  reaper.BR_EnvFree(allocated, 0)
  -- adjust maxValue for scaling mode
  maxValue = reaper.ScaleToEnvelopeMode(reaper.GetEnvelopeScalingMode(envelope), maxValue)
  return {
    visible = visible,
    armed = armed,
    minValue = minValue,
    maxValue = maxValue
  }
end

--[[
  Get envelope scaling mode
]]
function TLA.getEnvelopeScalingMode(envelope)
  return reaper.GetEnvelopeScalingMode(envelope) 
end

--[[
  Convert the value from the envelope scale
]]
function TLA.scaleFromEnvelopeMode(mode, value)
  return reaper.ScaleFromEnvelopeMode(mode, value)
end

--[[
  Get time at cursor.
]]
function TLA.getTimeAtCursor()
  return reaper.GetCursorPosition()
end

function TLA.sortPoints(envelope)
  reaper.Envelope_SortPoints(envelope)
end

--[[
  Helper to filter a list
]]
TLA.filter = function(t, filterIter)
  local out = {}
  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end
  return out
end

--[[
  Helper to find the length of an array
]]
TLA.length = function(tbl)
  local length = 0

  if not tbl then
    return length
  end
  for _ in pairs(tbl) do
    length = length + 1
  end

	return length
end

--[[
  Every list item meets the condition
]]
TLA.every = function(tbl, condition)
  local result = true
  for key, val in ipairs(tbl) do
    result = condition(val)
    if result == false then
      return false
    end
  end
  return result
end

--[[

            DO NOT MODIFY ABOVE THESE LINES, THIS CONTENT IS AUTO-GENERATED

█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
                                                                  
]]

return TLA -- remove this