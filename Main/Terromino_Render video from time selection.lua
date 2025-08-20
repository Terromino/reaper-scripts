-- @author terromino
-- @version 1.0

--[[
 * ReaScript Name: Terromino_Render video from time selection
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
--------------------------------------------------------------------------------
-- FUNCTIONS --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  
  start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  
  if start_time ~= end_time then
  
    return true
  
  else
  
    reaper.ShowMessageBox('No time selection. Please select a time range to be rendered.', 'Terromino_Render video from time selection', 0)
  
    return false
  
  end
end

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()

  -- get

  render_settings = reaper.GetSetProjectInfo(0, 'RENDER_SETTINGS', 0, false)
  render_boundsflag = reaper.GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', 0, false)
  render_tailflag = reaper.GetSetProjectInfo(0, 'RENDER_TAILFLAG', 0, false)
  render_addtoproj = reaper.GetSetProjectInfo(0, 'RENDER_ADDTOPROJ', 0, false)
  render_normalize = reaper.GetSetProjectInfo(0, 'RENDER_NORMALIZE', 1536, false)
  render_fadein = reaper.GetSetProjectInfo(0, 'RENDER_FADEIN', 0.25, false)
  render_fadeout = reaper.GetSetProjectInfo(0, 'RENDER_FADEOUT', 0.25, false)
  
  rfi_retval, render_file = reaper.GetSetProjectInfo_String(0, 'RENDER_FILE', '', false)
  rp_retval, render_pattern = reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', '', false)
  rfo1_retval, render_format_01 = reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT', '', false)
  rfo2_retval, render_format_02 = reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT2', '', false)
  
  -- set
  
  reaper.GetSetProjectInfo(0, 'RENDER_SETTINGS', 0, true) -- 0 master mix
  reaper.GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', 2, true) -- 2 time selection
  reaper.GetSetProjectInfo(0, 'RENDER_TAILFLAG', 0, true)
  reaper.GetSetProjectInfo(0, 'RENDER_ADDTOPROJ', 0, true)
  reaper.GetSetProjectInfo(0, 'RENDER_NORMALIZE', 1536, true) -- fade in & fade out
  reaper.GetSetProjectInfo(0, 'RENDER_FADEIN', 0.25, true)
  reaper.GetSetProjectInfo(0, 'RENDER_FADEOUT', 0.25, true)
  
  reaper.GetSetProjectInfo_String(0, 'RENDER_FILE', '/Video', true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', '$project_VIDEO_$datetime', true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT', 'PMFF', true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT2', '', true)
  
  --File: Render project, using the most recent render settings
  reaper.Main_OnCommand(41824, 0)
  -- reset all previous

  reaper.GetSetProjectInfo(0, 'RENDER_SETTINGS', render_settings, true) -- 0 master mix
  reaper.GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', render_boundsflag, true) -- 2 time selection
  reaper.GetSetProjectInfo(0, 'RENDER_TAILFLAG', render_tailflag, true)
  reaper.GetSetProjectInfo(0, 'RENDER_ADDTOPROJ', render_addtoproj, true)
  reaper.GetSetProjectInfo(0, 'RENDER_NORMALIZE', render_normalize, true) -- fade in & fade out
  reaper.GetSetProjectInfo(0, 'RENDER_FADEIN', render_fadein, true)
  reaper.GetSetProjectInfo(0, 'RENDER_FADEOUT', render_fadeout, true)
  
  reaper.GetSetProjectInfo_String(0, 'RENDER_FILE', render_file, true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', render_pattern, true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT', render_format_01, true)
  reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT2', render_format_02, true)
 
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

Main()

reaper.Undo_EndBlock("Terromino_Render video from time selection", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)

--------------------------------------------------------------------------------
                                                                       -- END --
--------------------------------------------------------------------------------
