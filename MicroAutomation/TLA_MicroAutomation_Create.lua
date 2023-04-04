-- @name TLA_MicroAutomation_Create
-- @about 
--   Create or adjust a four-point envelope based on selection.
--   Reads input from midi value (rotary encoder).
-- @author Aaron Fay - The Last Axe Studio
-- @version 1.0.0
-- @changelog
--   Initial version.

local TLA

--> Bootstrap the common methods by one of the following:
-- * reaper.GetResourcePath() to test locally in reaper 
-- * require for unit tests 
-- * bundled inline for dist 
if reaper then TLA = dofile(reaper.GetResourcePath()..'/Scripts/The Last Axe Studio Scripts/MicroAutomation/include/TLA_base.lua') else TLA = require "include.TLA_base" end
--> End bootstrap

--[[

  ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗   
  ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝   
  ███████╗██║     ██████╔╝██║██████╔╝   ██║      
  ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║      
  ███████║╚██████╗██║  ██║██║██║        ██║      
  ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝      
                                                
   ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
  ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
  ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 

 - offset: inset distance for inner points (default: 0.01 seconds)
 - maxRange: maximum percentage of total range to adjust (default: 50%)
 - debug: show console messages (default: false)
--]]

TLA.config = {
  offset = 0.01,
  maxRange = .5,
  debug = false
}

--[[
  END SCRIPT CONFIG
--]]

local log = TLA.log


--[[

  ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗   
  ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝   
  ███████╗██║     ██████╔╝██║██████╔╝   ██║      
  ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║      
  ███████║╚██████╗██║  ██║██║██║        ██║      
  ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝      
                                                
   █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗
  ██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
  ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║
  ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║
  ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
  ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
]]

--[[
  Manages determining what should be (de)selected when the script runs, and
  ultimately creates points if "it should".

  -- TODO: turn part of this into "Select four points within selection"
]]
function TLA.getSelectionAndSelectedPoints(envelope)
  local selection = TLA.getCurrentTimeSelection()
  local selectedPoints = TLA.getContiguousSelectedPointsForEnvelope(envelope)
  local totalSelectedPoints = TLA.length(selectedPoints)
  log('Number of selected points: ' .. totalSelectedPoints)

  local points = selectedPoints
  local shouldCreatePoints = false
  -- override startTime and endTime values for creating outer points
  local overrideInitialPointValue = nil
  local overrideTailingPointValue = nil

  if selectedPoints then
    if totalSelectedPoints == 4 then
      -- four selected points, are they within the time selection?
      if selection then
        local pointsCountWithinSelection = 0

        -- TODO: make TLA.countPointsWithinTime()
        for k, point in pairs(points) do
          if point.time >= selection.startTime and point.time <= selection.endTime then
            pointsCountWithinSelection = pointsCountWithinSelection + 1
          end
        end

        log('Selected points within selection: ' .. pointsCountWithinSelection)
        if pointsCountWithinSelection == 0 then
          -- TODO: abstract this unselected point checking
          -- check for unselected points within the selection
          local unselectedPointsWithinSelection = TLA.getPointsWithinTime(envelope, selection.startTime, selection.endTime)
          local totalUnselectedPoints = TLA.length(unselectedPointsWithinSelection)
          log('Total unselected within selection: ' .. totalUnselectedPoints)
          if totalUnselectedPoints == 4 then
            -- deselect the existing points
            TLA.deselectPoints(envelope, selectedPoints)
            -- we have 4 unselected points, select and return them
            TLA.selectPoints(envelope, unselectedPointsWithinSelection)
            points = unselectedPointsWithinSelection
          else

            -- no points within the selection, deselect outer points
            TLA.deselectPoints(envelope, selectedPoints)

            -- record and destroy what's in the selection
            overrideInitialPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.startTime)
            overrideTailingPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.endTime)
            
            -- we may have X unselected points, clear them so new ones can be created
            TLA.removePointsInTimeRange(envelope, selection.startTime, selection.endTime)
            shouldCreatePoints = true
          end
        else
          -- at least one point within selection, work with existing points
          points = selectedPoints
          shouldCreatePoints = false
        end
      end

    else
      log('Have selected points, but not 4 ')
      -- not enough selected points, do nothing
      points = nil
      shouldCreatePoints = false
    end
  else
    local unselectedPointsWithinSelection = TLA.getPointsWithinTime(envelope, selection.startTime, selection.endTime)
    local totalUnselectedPoints = TLA.length(unselectedPointsWithinSelection)
    log('Total unselected within selection: ' .. totalUnselectedPoints)
    if totalUnselectedPoints == 4 then
      -- we have 4 unselected points, select and return them
      TLA.selectPoints(envelope, unselectedPointsWithinSelection)
      points = unselectedPointsWithinSelection
    else
      if selection then
        -- first, capture the current envelope values so we recreate the points at the right levels
        overrideInitialPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.startTime)
        overrideTailingPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.endTime)
        
        -- we have X unselected points, clear them so new ones can be created
        TLA.removePointsInTimeRange(envelope, selection.startTime, selection.endTime)
        shouldCreatePoints = true
      else
        points = nil
        selection = nil
      end
    end
  end

  if shouldCreatePoints then
    if selection then
      -- create points for selection
      local offset = TLA.config.offset
      
      local initialPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.startTime)
      local tailingPointValue = TLA.getEnvelopeValueAtTime(envelope, selection.endTime)
      if overrideInitialPointValue then
        log('Using override initial point value')
        initialPointValue = overrideInitialPointValue
      end
      if overrideTailingPointValue then
        log('Using override tailing point value')
        tailingPointValue = overrideTailingPointValue
      end
      log('Initial point value: ' .. initialPointValue)
      log('Tailing point value: ' .. tailingPointValue)
      log('Creating points for selection')
      TLA.createEnvelopePointAtTime(envelope, selection.startTime, initialPointValue)
      TLA.createEnvelopePointAtTime(envelope, selection.endTime, tailingPointValue)
      TLA.createEnvelopePointAtTime(envelope, selection.startTime + offset, initialPointValue)
      TLA.createEnvelopePointAtTime(envelope, selection.endTime - offset, initialPointValue)
      TLA.sortPoints(envelope)

      -- regrab the points
      points = TLA.getContiguousSelectedPointsForEnvelope(envelope)

    else
      points = nil
      selection = nil
    end
  end

  return {
    selection = selection,
    points = points
  }
end


function TLA.performAction()

  -- initialize console
  TLA.debugInit()

  -- if no selected envelope, bail
  local envelope = TLA.getSelectedEnvelope()
  if not envelope then
    log('No selected envelope, exiting.')
    return
  end

  local envelopeProperties = TLA.getEnvelopeProperties(envelope)
  if envelopeProperties.armed and envelopeProperties.visible then
    -- Make sure we have some points to work with first.
    local result = TLA.getSelectionAndSelectedPoints(envelope)
    -- local selection = result.selection
    local points = result.points
    local pointsCount = TLA.length(points)
    if pointsCount == 0 then
      log('No selected points, exiting.')
      return
    end
    log('Returned points: ' .. pointsCount)
  
    -- Now with selected points to work with, attenuate the inner points.
    local adjustedMidiInputValue = TLA.getMidiInputToPercent()
    log('Midi input (adjusted to %): ' .. adjustedMidiInputValue)

    -- just attenuate the inner points to the new value
    log('Points already selected, augmenting inner points')

    local firstPointOverall = TLA.getFirstPointByTime(points)
    local lastPointOverall = TLA.getLastPointByTime(points)
    log('First point time: ' .. firstPointOverall.time)

    local valueAtFirstPoint = TLA.getEnvelopeValueAtTime(envelope, firstPointOverall.time)
    local innerPoints = TLA.getInnerPoints(points)
    log('Inner count: ' .. TLA.length(innerPoints))

    -- -- TODO: try to maintain ramped inner points
    local firstInner = TLA.getFirstPointByTime(innerPoints)
    local lastInner = TLA.getLastPointByTime(innerPoints)

    -- local firstPointOffset = 0
    -- local lastPointOffset = 0
    -- if not firstInner.value == lastInner.value then      
    --   -- figure out which point is further away from it's neighbor
    --   local firstPointDistance = firstInner.value - firstPointOverall.value
    --   local lastPointDistance = lastInner.value - lastPointOverall.value
  
    --   if firstPointDistance < lastPointDistance then
    --     lastPointOffset = lastPointDistance - firstPointDistance
    --   else
    --     firstPointOffset = firstPointDistance - lastPointDistance
    --   end
    -- end
    
    -- -- adjust First point
    --   local firstPointValue = TLA.calculateFinalPointValue(valueAtFirstPoint,
    --     adjustedMidiInputValue,
    --     envelopeProperties.minValue,
    --     envelopeProperties.maxValue,
    --     TLA.config.maxRange) + firstPointOffset
    --   log(' -firstPointValue: ' .. firstPointValue)
    --   TLA.setPointValue(envelope, firstInner, firstPointValue)
      
    --   -- adjust second point
    --   local lastPointValue = TLA.calculateFinalPointValue(firstPointValue,
    --     adjustedMidiInputValue,
    --     envelopeProperties.minValue,
    --     envelopeProperties.maxValue,
    --     TLA.config.maxRange) + lastPointOffset
    --   log(' -lastPointValue: ' .. lastPointValue)
    --   TLA.setPointValue(envelope, lastInner, lastPointValue)
    


    for k, point in pairs(innerPoints) do
      log(' -time ' .. point.time)
      log(' -value ' .. point.value)
      local finalValue = TLA.calculateFinalPointValue(valueAtFirstPoint,
        adjustedMidiInputValue,
        envelopeProperties.minValue,
        envelopeProperties.maxValue,
        TLA.config.maxRange)
      log(' -finalValue: ' .. finalValue)
      TLA.setPointValue(envelope, point, finalValue)
    end
  else
    log('Envelope not armed, or not visible. Exiting.')
  end
end


function main(rpr) 
  -- set up
  rpr.PreventUIRefresh(1)
  rpr.Undo_BeginBlock()
  -- register reaper with the TLA library
  TLA.initReaper(rpr)
  -- main action
  TLA.performAction()
  -- tear down
  rpr.Undo_EndBlock("Create four point micro envelope for rotary encoder", -1)
  rpr.TrackList_AdjustWindows(false)
  rpr.PreventUIRefresh(-1)
  rpr.UpdateArrange()
end

if reaper then
  reaper.defer(main(reaper))
end

return TLA
