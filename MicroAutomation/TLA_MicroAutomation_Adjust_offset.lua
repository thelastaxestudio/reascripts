-- @name TLA_MicroAutomation_Adjust_offset
-- @about
--   Adjust the offset of the two inner points of a four-point envelope.
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
]]
function TLA.getSelectionAndSelectedPoints(envelope)
  local selection = TLA.getCurrentTimeSelection()
  local selectedPoints = TLA.getContiguousSelectedPointsForEnvelope(envelope)
  local totalSelectedPoints = TLA.length(selectedPoints)
  log('Number of selected points: ' .. totalSelectedPoints)

  local points = selectedPoints
  if selectedPoints then
    if totalSelectedPoints == 4 then
      -- four selected points, are they within the time selection?
      if selection then
        local pointsCountWithinSelection = 0
        for k, point in pairs(points) do
          if point.time >= selection.startTime and point.time <= selection.endTime then
            pointsCountWithinSelection = pointsCountWithinSelection + 1
          end
        end

        log('Selected points within selection: ' .. pointsCountWithinSelection)
        if pointsCountWithinSelection == 0 then
          -- no points within the selection, deselect outer points
          points = nil
        else
          -- at least one point within selection, work with existing points
          points = selectedPoints
        end
      end
    else
      -- not enough selected points, do nothing
      log('Not enough points selected.')
      points = nil
    end
  else
    log('No selected points.')
    points = nil
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

    local firstPointOuter = TLA.getFirstPointByTime(points)
    local lastPointOuter = TLA.getLastPointByTime(points)

    local innerPoints = TLA.getInnerPoints(points)
    local firstPointInner = TLA.getFirstPointByTime(innerPoints)
    local lastPointInner = TLA.getLastPointByTime(innerPoints)


    local gap = 0.01
    local span = lastPointInner.time - firstPointInner.time - gap - 0.02 -- space so points don't overlap
    local halfSpan = span / 2

    local finalOffset = adjustedMidiInputValue * halfSpan

    local firstPointValue = firstPointOuter.time + TLA.config.offset + finalOffset
    TLA.setPointTime(envelope, firstPointInner, firstPointValue)

    local lastPointValue = lastPointOuter.time - TLA.config.offset - finalOffset
    TLA.setPointTime(envelope, lastPointInner, lastPointValue)

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
