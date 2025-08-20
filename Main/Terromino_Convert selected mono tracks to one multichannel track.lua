-- @author terromino
-- @version 1.0

--[[
 * ReaScript Name: Terromino_Convert selected mono tracks to one multichannel track
 * Author: terromino / Gwen Terrien
 * Author URL: terromino.com
 * Licence: GPL v3
--]]

--[[
 * Changelog
 * v1.0
  + Initial release
--]]


--------------------------------------------------------------------------------
-- MAIN VARIABLES --
--------------------------------------------------------------------------------

--Number of tracks selected
local selectedTrCount

--Table of selected tracks
local slcTrs = {}

--Table of item count per selected track
local itmCountSlcTr = {}

--Table of items for each selected track
local trItms = {}

--Table of items position per item per selected track
local trItmsPos = {}

--Table of items length per item per selected track
local trItmsLength = {}

--Table of items start offset per item per selected track
local trItmsStartOffs = {}

--Table of temporary tracks created for the purpose of this script (and deleted at the end of it)
local tempTrs = {}

--------------------------------------------------------------------------------
                                                     -- END OF MAIN VARIABLES --
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FUNCTIONS --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

--Checks number of tracks selected and stops the script if this number cannot be handled
--For now the script only supports 2, 4 and 6 tracks

function Init()

  selectedTrCount = reaper.CountSelectedTracks(0)

  if selectedTrCount < 2 then

    reaper.ShowMessageBox('Not enough tracks selected. Please select at least two tracks.', 'Multi-mono to multichannel', 0)
  
    return false
  
  elseif selectedTrCount == 3 then
  
    reaper.ShowMessageBox('Wrong number of tracks selected. This script only works for 2, 4 or 6 tracks at the moment.', 'Multi-mono to multichannel', 0)
  
    return false
  
  elseif selectedTrCount == 5 then
    
    reaper.ShowMessageBox('Wrong number of tracks selected. This script only works for 2, 4 or 6 tracks at the moment.', 'Multi-mono to multichannel', 0)
    
    return false
  
  elseif selectedTrCount > 6 then
  
    reaper.ShowMessageBox('Too many tracks selected. Please select 2, 4 or 6 tracks.', 'Multi-mono to multichannel', 0)
  
    return false
    
  else return true
  
  end
end


--------------------------------------------------------------------------------
-- ADD DATA TO TABLES --
--------------------------------------------------------------------------------

--This function will gather all the items of the selected tracks, the items length, position, and start offset
--If any of those parameters don't match up between tracks, the script will output a warning and stop

function AddDataToTables()
  
  for l = 0, selectedTrCount - 1 do
  
    slcTrs[l] = reaper.GetSelectedTrack(0, l)
    
    itmCountSlcTr[l] = reaper.CountTrackMediaItems(slcTrs[l])
    
    if l > 0 and itmCountSlcTr[l] ~= itmCountSlcTr[l - 1] then
      
      reaper.ShowMessageBox("Selected tracks don't have the same number of items. Couldn't proceed", 'Multi-mono to multichannel', 0)
        
      return false
      
    end
      
    if itmCountSlcTr[l] == 0 then
      
      reaper.ShowMessageBox("Selected track(s) has no media items.", 'Multi-mono to multichannel', 0)
        
      return false
      
    end
    
    --Creates a table inside each table to differentiate data from track to track easily
    trItms[l] = {}
    trItmsPos[l] = {}
    trItmsLength[l] = {}
    trItmsStartOffs[l] = {}
    
    for i = 0, itmCountSlcTr[0] - 1 do
      
      lItm = reaper.GetTrackMediaItem(slcTrs[l], i)
      
      trItms[l][i] = lItm
      
      trItmsPos[l][lItm] = reaper.GetMediaItemInfo_Value(lItm, 'D_POSITION')
      
      if l > 0 and trItmsPos[l][trItms[l][i]] ~= trItmsPos[l - 1][trItms[l - 1][i]] then
              
        local posErrorTime = reaper.format_timestr(trItmsPos[l][trItms[l][i]], '')
              
        local posConf = reaper.ShowMessageBox("Items position mismatch at "..tostring(posErrorTime)..". Proceed anyway?", 'Multi-mono to multichannel', 4)
        
        if posConf == 7 then
          
          return false
        
        end 
      end
      
      trItmsLength[l][lItm] = reaper.GetMediaItemInfo_Value(lItm, 'D_LENGTH')
      
      if l > 0 and trItmsLength[l][trItms[l][i]] ~= trItmsLength[l - 1][trItms[l - 1][i]] then
                    
        local lengthErrorTime = reaper.format_timestr(trItmsPos[l][trItms[l][i]], '')
                    
        reaper.ShowMessageBox("Items length mismatch at "..tostring(lengthErrorTime)..". Proceed anyway?", 'Multi-mono to multichannel', 4)
                        
        if posConf == 7 then
          
          return false
        
        end
                      
      end
      
      trItmsStartOffs[l][lItm] = reaper.GetMediaItemTakeInfo_Value(reaper.GetActiveTake(lItm), 'D_STARTOFFS')
      
      if l > 0 and trItmsStartOffs[l][trItms[l][i]] ~= trItmsStartOffs[l - 1][trItms[l - 1][i]] then
                          
        local startOffErrorTime = reaper.format_timestr(trItmsPos[l][trItms[l][i]], '')
                          
        reaper.ShowMessageBox("Items start offset mismatch at "..tostring(startOffErrorTime)..". Proceed anyway?", 'Multi-mono to multichannel', 4)
                              
        if posConf == 7 then
          
          return false
        
        end
                            
      end
      
    end 
  end
end


--------------------------------------------------------------------------------
-- SETUP TRACKS --
--------------------------------------------------------------------------------

--This function will create and setup the temporary tracks necessary to render the imploded files later on

function SetupTracks()
 
  local retvalA, nameTrA = reaper.GetSetMediaTrackInfo_String(slcTrs[0], 'P_NAME', '', false)
  
  if selectedTrCount == 2 then
  
    nameTrA = nameTrA:sub(0, -2)..'LR'
  
  elseif selectedTrCount == 4 then
    
    nameTrA = nameTrA:sub(0, -2)..'Quad'
  
  elseif selectedTrCount == 6 then
    
    nameTrA = nameTrA:sub(0, -2)..'5.1'
  
  end
  
  reaper.GetSetMediaTrackInfo_String(slcTrs[0], 'P_NAME', nameTrA, true)
  reaper.SetMediaTrackInfo_Value(slcTrs[0], 'D_PAN', 0)
  
  if selectedTrCount == 2 then
  
    --Insert track
    reaper.Main_OnCommand(40001, 0)
    
    tempTrs[0] = reaper.GetSelectedTrack(0, 0)
  
  elseif selectedTrCount == 4 then
    
    for i = 0, selectedTrCount do
      
      --Insert track
      reaper.Main_OnCommand(40001, 0)
      
      tempTrs[i] = reaper.GetSelectedTrack(0, 0)
      
    end
      
    for j = 0, selectedTrCount do
      
      reaper.SetTrackSelected(tempTrs[j], true)
        
    end
    
    --Make forlder from selected tracks
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_MAKEFOLDER"), 0)
    
    --SET UP ALL PAN AND PARENT SENDS
    
    reaper.SetMediaTrackInfo_Value(tempTrs[0], 'I_NCHAN', 4)
    
    -- Child Track 1
    reaper.SetMediaTrackInfo_Value(tempTrs[1], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[1], 'D_PAN', -1)
    
    -- Child Track 2
    reaper.SetMediaTrackInfo_Value(tempTrs[2], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[2], 'D_PAN', 1)
    
    -- Child Track 3
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'D_PAN', -1)
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'C_MAINSEND_OFFS', 2)
    
    -- Child Track 4
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'D_PAN', 1)
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'C_MAINSEND_OFFS', 2)
  
  elseif selectedTrCount == 6 then
    
    for i = 0, selectedTrCount do
    
    --Insert track
    reaper.Main_OnCommand(40001, 0)
    tempTrs[i] = reaper.GetSelectedTrack(0, 0)
    
    end
    
    for j = 0, selectedTrCount do
    
      reaper.SetTrackSelected(tempTrs[j], true)
      
    end
    
    --Make forlder from selected tracks
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_MAKEFOLDER"), 0)
    
    --SET UP ALL PAN AND PARENT SENDS
    
    reaper.SetMediaTrackInfo_Value(tempTrs[0], 'I_NCHAN', 6)
    
    -- Child Track 1
    reaper.SetMediaTrackInfo_Value(tempTrs[1], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[1], 'D_PAN', -1)
    
    -- Child Track 2
    reaper.SetMediaTrackInfo_Value(tempTrs[2], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[2], 'D_PAN', 1)
    
    -- Child Track 3
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'D_PAN', -1)
    reaper.SetMediaTrackInfo_Value(tempTrs[3], 'C_MAINSEND_OFFS', 2)
    
    -- Child Track 4
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'D_PAN', 1)
    reaper.SetMediaTrackInfo_Value(tempTrs[4], 'C_MAINSEND_OFFS', 2)
    
    -- Child Track 5
    reaper.SetMediaTrackInfo_Value(tempTrs[5], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[5], 'D_PAN', -1)
    reaper.SetMediaTrackInfo_Value(tempTrs[5], 'C_MAINSEND_OFFS', 4)
    
    -- Child Track 6
    reaper.SetMediaTrackInfo_Value(tempTrs[6], 'I_NCHAN', 2)
    reaper.SetMediaTrackInfo_Value(tempTrs[6], 'D_PAN', 1)
    reaper.SetMediaTrackInfo_Value(tempTrs[6], 'C_MAINSEND_OFFS', 4)
    
  end
end

--------------------------------------------------------------------------------
-- MERGE ITEMS AND GLUE STEREO --
--------------------------------------------------------------------------------

function MergeItemsAndGlueStereo(itmL, itmR)
  
  local takeL = reaper.GetActiveTake(itmL)
  
  -- DISABLE ITEM L ENV
    
  local takeLEnvCount = reaper.CountTakeEnvelopes(takeL)
    
  if takeLEnvCount ~= 0 then
    
    for k = 0, takeLEnvCount - 1 do
        
      kEnv = reaper.GetTakeEnvelope(takeL, k)
      
      allocEnv = reaper.BR_EnvAlloc(kEnv, false)
      
      active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, outType, faderScaling = reaper.BR_EnvGetProperties(allocEnv, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
      
      reaper.BR_EnvSetProperties(allocEnv, false, false, false, inLane, laneHeight, defaultShape, faderScaling)
      
      reaper.BR_EnvFree(allocEnv, true)
      
    end
  end
    
  local takeR = reaper.AddTakeToMediaItem(itmL)
  local takeR0 = reaper.GetActiveTake(itmR)
  local srcR = reaper.GetMediaItemTake_Source(takeR0)
  
  
  
  -- TAKEN FROM Script: mpl_Implode mono track session to stereo items relative to LR at the trackname end.lua
  
  
  reaper.SetMediaItemTake_Source(takeR, srcR)
                
  reaper.SetMediaItemInfo_Value(itmL, 'B_ALLTAKESPLAY', 1) 
  reaper.SetMediaItemTakeInfo_Value( takeL, 'I_CHANMODE',3  )
  reaper.SetMediaItemTakeInfo_Value( takeL, 'D_PAN',-1 )
  reaper.SetMediaItemTakeInfo_Value( takeR, 'I_CHANMODE',4  )  
  reaper.SetMediaItemTakeInfo_Value( takeR, 'D_PAN',1 )
  
  -------------------------
  
  reaper.MoveMediaItemToTrack(itmL, tempTrs[0])
  
  local itmVol = reaper.GetMediaItemInfo_Value(itmL, 'D_VOL')
  
  reaper.SetMediaItemInfo_Value(itmL, 'D_VOL', 1)
  
  -- TAKEN FROM Script: X-Raym_Expand selected items length to start and end of their source.eel


  reaper.SetMediaItemPosition(itmL, trItmsPos[0][itmL] - trItmsStartOffs[0][itmL], true)
  reaper.SetMediaItemLength(itmL, trItmsLength[0][itmL] + trItmsStartOffs[0][itmL], true)
  reaper.SetMediaItemTakeInfo_Value(takeL, 'D_STARTOFFS', 0)
  reaper.SetMediaItemTakeInfo_Value(takeR, 'D_STARTOFFS', 0)
  
  ------------------------- 

  --Item: Unselect (clear selection of) all items
  reaper.Main_OnCommand(40289, 0);
  
  reaper.SetMediaItemSelected(itmL, true)
  
  --Item: Set item end to source media end
  reaper.Main_OnCommand(40612, 0);
  
  --Item: Glue items, ignoring time selection
  reaper.Main_OnCommand(40362, 0);
  
  local gluedItem = reaper.GetSelectedMediaItem(0, 0)
  
  --Item: Unselect (clear selection of) all items
  reaper.Main_OnCommand(40289, 0);
  
  reaper.SetMediaItemPosition(gluedItem, trItmsPos[0][itmL], true)
  reaper.SetMediaItemLength(gluedItem, trItmsLength[0][itmL], true)
  gluedTake = reaper.GetActiveTake(gluedItem)
  reaper.SetMediaItemTakeInfo_Value(gluedTake, 'D_STARTOFFS', trItmsStartOffs[0][itmL])
  
  reaper.SetMediaItemInfo_Value(gluedItem, 'D_VOL', itmVol)
  
  reaper.MoveMediaItemToTrack(gluedItem, slcTrs[0]) 

  -- SET VOL ENV
  
  local volEnv = reaper.GetTakeEnvelopeByName(takeR0, 'Volume')
  
  if volEnv ~= nil then
  
    local retValVolEnv, volEnvStateR = reaper.GetEnvelopeStateChunk(volEnv, '', false)
  
    reaper.SetMediaItemSelected(gluedItem, true)
  
    -- Take: Toggle take volume envelope
    reaper.Main_OnCommand(40693, 0);
  
    local gluedTakeVolEnv = reaper.GetTakeEnvelopeByName(gluedTake, "Volume")
  
    reaper.SetEnvelopeStateChunk(gluedTakeVolEnv, volEnvStateR, false)
  
  end
  
  -- SET PAN ENV
  local panEnv = reaper.GetTakeEnvelopeByName(takeR0, 'Pan')
  
  if panEnv ~= nil then
  
    local retValPanEnv, panEnvStateR = reaper.GetEnvelopeStateChunk(panEnv, '', false)
  
    reaper.SetMediaItemSelected(gluedItem, true)
  
    -- Take: Toggle take pan envelope
    reaper.Main_OnCommand(40694, 0);
  
    local gluedTakePanEnv = reaper.GetTakeEnvelopeByName(gluedTake, "Pan")
  
    reaper.SetEnvelopeStateChunk(gluedTakePanEnv, panEnvStateR, false)
  
  end
end

--------------------------------------------------------------------------------
-- MERGE ITEMS AND GLUE MULTI --
--------------------------------------------------------------------------------

function MergeItemsAndGlueMulti(items)
  
  --Time selection: Remove (unselect) time selection and loop points
  reaper.Main_OnCommand(40020, 0);
  
  local itmsVol = {}
  local takes = {}  
  
  for i = 0, selectedTrCount - 1 do
     
    reaper.MoveMediaItemToTrack(items[i], tempTrs[i + 1])
    
    itmsVol[i] = reaper.GetMediaItemInfo_Value(items[i], 'D_VOL')
    
    reaper.SetMediaItemInfo_Value(items[i], 'D_VOL', 1)
    
    takes[i] = reaper.GetActiveTake(items[i])
    
  end
  
  local volEnv = reaper.GetTakeEnvelopeByName(takes[0], 'Volume')
  local panEnv = reaper.GetTakeEnvelopeByName(takes[0], 'Pan')
  
  if VolEnv ~= nil or panEnv ~= nil then
  
    --Clear Item Selection
    reaper.Main_OnCommand(40289, 0)
  
    reaper.SetMediaItemSelected(items[0], true)
  
    --Item: Duplicate items
    reaper.Main_OnCommand(41295, 0);
  
    local duplItm = reaper.GetSelectedMediaItem(0, 0)
  
    reaper.MoveMediaItemToTrack(duplItm, slcTrs[1])
    
    local duplTake = reaper.GetActiveTake(duplItm)
    
    volEnv = reaper.GetTakeEnvelopeByName(duplTake, 'Volume')
    panEnv = reaper.GetTakeEnvelopeByName(duplTake, 'Pan')
  
  end

-- DISABLE ITEMS ENV
  
  local takeEnvCount = {}
  
  --Item: Unselect (clear selection of) all items
  reaper.Main_OnCommand(40289, 0)  
  
  for r = 0, selectedTrCount - 1 do
    
    takeEnvCount[r] = reaper.CountTakeEnvelopes(takes[r])
    
    if takeEnvCount[r] ~= 0 then
    
      for k = 0, takeEnvCount[r] - 1 do
        
        kEnv = reaper.GetTakeEnvelope(takes[r], k)
        
        allocEnv = reaper.BR_EnvAlloc(kEnv, false)
        
        active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, outType, faderScaling = reaper.BR_EnvGetProperties(allocEnv, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
        
        reaper.BR_EnvSetProperties(allocEnv, false, false, false, inLane, laneHeight, defaultShape, faderScaling)
        
        reaper.BR_EnvFree(allocEnv, true)        
    
      end
    end
    
    reaper.SetMediaItemPosition(items[r], trItmsPos[r][items[r]] - trItmsStartOffs[r][items[r]], true)
    reaper.SetMediaItemLength(items[r], trItmsLength[r][items[r]] + trItmsStartOffs[r][items[r]], true)
    reaper.SetMediaItemTakeInfo_Value(takes[r], 'D_STARTOFFS', 0)
    reaper.SetMediaItemSelected(items[r], true)
    
  end
  
  --Item: Set item end to source media end
  reaper.Main_OnCommand(40612, 0)
  
  --Time selection: Set time selection to items
  reaper.Main_OnCommand(40290, 0)
  
  reaper.UpdateArrange()
  reaper.UpdateTimeline()
  
  --Cursor to start of items
  reaper.Main_OnCommand(41173, 0)
  
  reaper.Main_OnCommand(41044, 0)
  
  reaper.SetOnlyTrackSelected(tempTrs[0])
  
  --Clear Item Selection
  reaper.Main_OnCommand(40289, 0)
  
  --Track: Render selected area of tracks to multichannel stem tracks (and mute originals)
  reaper.Main_OnCommand(41720, 0)
  
  local renderTrack = reaper.GetSelectedTrack(0,0)
  
  local renderedItem = reaper.GetTrackMediaItem(renderTrack, 0)
  
  reaper.SetMediaTrackInfo_Value(tempTrs[0], 'B_MUTE', 0)
  
  reaper.SetMediaItemPosition(renderedItem, trItmsPos[0][items[0]], true)
  
  reaper.SetMediaItemLength(renderedItem, trItmsLength[0][items[0]], true)
  
  local renderedTake = reaper.GetActiveTake(renderedItem)
  
  reaper.SetMediaItemTakeInfo_Value(renderedTake, 'D_STARTOFFS', trItmsStartOffs[0][items[0]])
    
  reaper.SetMediaItemInfo_Value(renderedItem, 'D_VOL', itmsVol[0])
  
  reaper.MoveMediaItemToTrack(renderedItem, slcTrs[0])
  
  reaper.DeleteTrack(renderTrack)
  
-- SET VOL ENV
  
  if volEnv ~= nil then
    
    local retValVolEnv, volEnvState = reaper.GetEnvelopeStateChunk(volEnv, '', false)
  
    reaper.SetMediaItemSelected(renderedItem, true)
  
    -- Take: Toggle take volume envelope
    reaper.Main_OnCommand(40693, 0);
  
    local renderedTakeVolEnv = reaper.GetTakeEnvelopeByName(renderedTake, "Volume")
  
    reaper.SetEnvelopeStateChunk(renderedTakeVolEnv, volEnvState, false)
  
  end
  
  -- SET PAN ENV
  
  if panEnv ~= nil then
  
    local retValPanEnv, panEnvState = reaper.GetEnvelopeStateChunk(panEnv, '', false)
  
    reaper.SetMediaItemSelected(renderedItem, true)
  
    -- Take: Toggle take pan envelope
    reaper.Main_OnCommand(40694, 0);
  
    local renderedTakePanEnv = reaper.GetTakeEnvelopeByName(renderedTake, "Pan")
  
    reaper.SetEnvelopeStateChunk(renderedTakePanEnv, panEnvState, false)
  
  end    
  
end


--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()

  if selectedTrCount == 2 then
      
    for j = 0, itmCountSlcTr[0] - 1 do
      
      MergeItemsAndGlueStereo(trItms[0][j], trItms[1][j])
        
    end
    
    reaper.DeleteTrack(slcTrs[1])
    reaper.DeleteTrack(tempTrs[0])
    
  elseif selectedTrCount > 2 then
      
    for j = 0, itmCountSlcTr[0] - 1 do
    
      local jItems = {}
      
      for k = 0, selectedTrCount - 1 do
      
        jItems[k] = trItms[k][j]
      
      end
      
      MergeItemsAndGlueMulti(jItems)
            
    end
    
    for j = 1, selectedTrCount - 1 do
    
      reaper.DeleteTrack(slcTrs[j])
    
    end
    
    for i = 0, selectedTrCount do
    
      reaper.DeleteTrack(tempTrs[i])
    
    end 
  end
  
  --Time selection: Remove (unselect) time selection and loop points
  reaper.Main_OnCommand(40020, 0);
  
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
                                                          -- END OF FUNCTIONS --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- START --
--------------------------------------------------------------------------------

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

local initRetVal = Init()

if initRetVal == false then

  return

end

local dataRetVal = AddDataToTables()

if dataRetVal == false then

  return

end

SetupTracks()

Main()

reaper.Undo_EndBlock("RIPO Multi-mono to multichannel", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)

--------------------------------------------------------------------------------
                                                                       -- END --
--------------------------------------------------------------------------------
