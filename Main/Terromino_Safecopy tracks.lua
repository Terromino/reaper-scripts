-- @author terromino
-- @version 1.0

--[[
 * ReaScript Name: Terromino_Safecopy tracks
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
-- GUI --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- USER CONFIG AREA --
--------------------------------------------------------------------------------

console = true -- Display debug messages in the console

reaimgui_force_version = false

local copyHTr = false
local lockItm = true
local hideTr = false
local visHTr = true
local disFX = true

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "RIPO_Safecopy"


--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

if reaimgui_force_version then
  reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
  if reaper.file_exists( reaimgui_shim_file_path ) then
    dofile( reaimgui_shim_file_path )(reaimgui_force_version)
  end
end

--------------------------------------------------------------------------------
                                                       -- END OF DEPENDENCIES --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DEBUG --
--------------------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

--------------------------------------------------------------------------------
-- DEFER --
--------------------------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

--------------------------------------------------------------------------------
-- OTHER --
--------------------------------------------------------------------------------

function IsLastItemFocusedAndKeyPressed( val )
  if val == "enter" then val = 13 end
  return reaper.ImGui_IsItemFocused( ctx ) and reaper.ImGui_IsKeyPressed( ctx, val )
end

-- Draw a button and returned true if pressed or if focus and enter key is pressed
function ButtonEnter( ctx, label, w, h )
  return reaper.ImGui_Button( ctx, label, w, h ) or IsLastItemFocusedAndKeyPressed( "enter" )
end

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()
  
  reaper.ImGui_BeginGroup(ctx)
  
  reaper.ImGui_SeparatorText(ctx, '')
  
  retValDisFX, disFX = reaper.ImGui_Checkbox( ctx,  "Disable copied FX", disFX)
  if reaper.ImGui_IsItemHovered(ctx, reaper.ImGui_HoveredFlags_DelayNormal()) then -- With a delay
      reaper.ImGui_SetTooltip(ctx, 'Disable all effects on copied tracks and media items. [RECOMMENDED]')
  end
  
  retvalLckItm, lockItm = reaper.ImGui_Checkbox( ctx,  "Lock copied media items", lockItm)
  if reaper.ImGui_IsItemHovered(ctx, reaper.ImGui_HoveredFlags_DelayNormal()) then -- With a delay
    reaper.ImGui_SetTooltip(ctx, 'Lock all media on copied tracks. [RECOMMENDED]')
  end

  retvalHTr, hideTr = reaper.ImGui_Checkbox( ctx,  "Hide tracks after safecopy", hideTr)
  if reaper.ImGui_IsItemHovered(ctx, reaper.ImGui_HoveredFlags_DelayNormal()) then -- With a delay
    reaper.ImGui_SetTooltip(ctx, 'Hides all copied tracks. Tracks can be set visible via the Track Manager.')
  end

  retvalHTr, copyHTr = reaper.ImGui_Checkbox( ctx,  "Copy hidden tracks", copyHTr)
  if reaper.ImGui_IsItemHovered(ctx, reaper.ImGui_HoveredFlags_DelayNormal()) then -- With a delay
    reaper.ImGui_SetTooltip(ctx, 'Safecopy tracks that are not currently visible in the TCP.')
  end
  
  if copyHTr then
   
    if hideTr then
      
        reaper.ImGui_BeginDisabled(ctx)
        visHTr = false
    
    end
  
    reaper.ImGui_Indent(ctx, 28)
  
    retvalVisHTr, visHTr = reaper.ImGui_Checkbox( ctx,  "Set copied hidden tracks visible", visHTr)
    if reaper.ImGui_IsItemHovered(ctx, reaper.ImGui_HoveredFlags_DelayNormal()) then -- With a delay
        reaper.ImGui_SetTooltip(ctx, 'All previously insivible tracks will be visible in the safecopy (IF the safecopy is visible of course).')
    end
  
    if hideTr then
  
      reaper.ImGui_EndDisabled(ctx)
    
    end
    
    reaper.ImGui_Unindent(ctx, 28)
  
  end
  
  reaper.ImGui_EndGroup(ctx)
  
  reaper.ImGui_SeparatorText(ctx, '')
  
  reaper.ImGui_Indent(ctx, 138)
  
  reaper.ImGui_PushFont(ctx, boldFont)
  
  
  if ButtonEnter( ctx, "SAFECOPY", 100, 50) then
     goButtonClick()
  end
  reaper.ImGui_PopFont(ctx)
  
end

function Run()
  
  reaper.ImGui_SetNextWindowBgAlpha( ctx, 1)
  
  reaper.ImGui_PushFont(ctx, font)
  
  reaper.ImGui_SetNextWindowSize(ctx, 400, 320, reaper.ImGui_Cond_Appearing())
  
  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end
  
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(), 12, 8)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(),    12, 12)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(),   6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(),     6, 4)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),    6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(),      8, 8)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemInnerSpacing(), 6, 4)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_IndentSpacing(),    20)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_GrabRounding(),     6)
  
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TextDisabled(),          0x808080FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(),              0x282828FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ChildBg(),               0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_PopupBg(),               0x141414F0)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Border(),                0x6E6E8080)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_BorderShadow(),          0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),               0x78787872)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),        0xF4769B46)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),         0x8E2F4CB4)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBg(),               0x0A0A0AFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),         0x561F30FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgCollapsed(),      0x00000082)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_MenuBarBg(),             0x242424FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ScrollbarBg(),           0x05050587)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ScrollbarGrab(),         0x4F4F4FFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ScrollbarGrabHovered(),  0x696969FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ScrollbarGrabActive(),   0x828282FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_CheckMark(),             0xF4769BFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrab(),            0x8E2F4CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrabActive(),      0xF42D68FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),                0xF42D68FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),         0xF4769BFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),          0x8E2F4CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),                0x4296FA4F)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(),         0x4296FACC)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),          0x4296FAFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),             0x6E6E8080)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SeparatorHovered(),      0x1A66BFC7)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SeparatorActive(),       0x1A66BFFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGrip(),            0x8E2F4CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGripHovered(),     0x8E2F4CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGripActive(),      0x8E2F4CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Tab(),                   0x464646DC)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabHovered(),            0x808080CC)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabActive(),             0x6A6A6AFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabUnfocused(),          0x111A26F8)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabUnfocusedActive(),    0x23436CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_DockingPreview(),        0x4296FAB3)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_DockingEmptyBg(),        0x333333FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_PlotLines(),             0x9C9C9CFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_PlotLinesHovered(),      0xFF6E59FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_PlotHistogram(),         0xE6B300FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_PlotHistogramHovered(),  0xFF9900FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TableHeaderBg(),         0x303033FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TableBorderStrong(),     0x4F4F59FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TableBorderLight(),      0x3B3B40FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TableRowBg(),            0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TableRowBgAlt(),         0xFFFFFF0F)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TextSelectedBg(),        0x4296FA59)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_DragDropTarget(),        0xFFFF00E6)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_NavHighlight(),          0x4296FAFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_NavWindowingHighlight(), 0xFFFFFFB3)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_NavWindowingDimBg(),     0xCCCCCC33)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ModalWindowDimBg(),      0xCCCCCC59)
     
  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse()) 
  
  if imgui_visible then

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    Main()
    
    --------------------

    reaper.ImGui_End(ctx)
    
  end
  
  reaper.ImGui_PopFont(ctx)
  reaper.ImGui_PopStyleVar(ctx, 9)
  reaper.ImGui_PopStyleColor(ctx, 54)
  
  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title)
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  boldFont = reaper.ImGui_CreateFont('sans-serif', 16, reaper.ImGui_FontFlags_Bold())
  reaper.ImGui_Attach(ctx, font)
  reaper.ImGui_Attach(ctx, boldFont)
  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
                                                                -- END OF GUI --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SAFECOPY --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- MAIN FUNCTION : SAFECOPY --
--------------------------------------------------------------------------------

function Safecopy()

  baseTracks = {}
  for j = 0, reaper.CountTracks(0) - 1 do
      currentTrack = reaper.GetTrack(0, j)
      table.insert(baseTracks, currentTrack)
  end
  
  local retval2, currentTrackName
  
  trackCount = 0
  
  -- UNSELECT TRACKS
  reaper.Main_OnCommand(40297, 0)
  
  for k in pairs(baseTracks) do
    
    trackCount = trackCount + 1
    
    retval2, currentTrackName = reaper.GetSetMediaTrackInfo_String(baseTracks[k], 'P_NAME', '', false)
    
    if currentTrackName:find("SAFECOPY", 1, true) == nil then
        
      reaper.SetTrackSelected(baseTracks[k], true)
      
    end
    
    if copyHiddenTracks == false then
    
      if reaper.GetMediaTrackInfo_Value(baseTracks[k], 'B_SHOWINTCP') == 0 then
        
        reaper.SetTrackSelected(baseTracks[k], false)
      
      end
    end
    
  end

  
  -- DUPLICATE TRACKS
  reaper.Main_OnCommand(40062, 0)
  
  -- CUT SELECTED TRACKS
  reaper.Main_OnCommand(40337, 0)
  
  -- INSERT TRACK AT THE END OF TRACK LIST
  reaper.Main_OnCommand(40702, 0)
  
  safecopyFolderTrack = reaper.GetSelectedTrack(0, 0)
  
  reaper.GetSetMediaTrackInfo_String(safecopyFolderTrack, "P_NAME", "SAFECOPY", true)
  
  -- PASTE TRACKS
  reaper.Main_OnCommand(42398, 0)
  
  for o = 0, reaper.CountSelectedTracks(0) - 1 do
    
    retValO, oName = reaper.GetSetMediaTrackInfo_String(reaper.GetSelectedTrack(0, o), 'P_NAME', '', false)
    
    oTrack = reaper.GetSelectedTrack(0, o)
    
    reaper.GetSetMediaTrackInfo_String(oTrack, 'P_NAME', oName .." (SAFECOPY)", true)
    
    if setCopiedHiddenTrackVisible == true and hideSafecopyFolder == false then
    
      reaper.SetMediaTrackInfo_Value(oTrack, 'B_SHOWINTCP', 1)
      reaper.SetMediaTrackInfo_Value(oTrack, 'B_SHOWINMIXER', 1)
      
    end
    
    if lockSafecopyItems then
      
      for q = 0, reaper.CountTrackMediaItems(oTrack) - 1 do
        
        reaper.SetMediaItemInfo_Value(reaper.GetTrackMediaItem(oTrack, q), 'C_LOCK', 1)
        
      end
    end
    
    if disFX then
      
      if reaper.TrackFX_GetCount(oTrack) ~= 0 then
        
        reaper.SetMediaTrackInfo_Value(oTrack, 'I_FXEN', 0)
      
      end
      
      for r = 0, reaper.CountTrackMediaItems(oTrack) - 1 do
        
        rItem = reaper.GetTrackMediaItem(oTrack, r)       
        
        rTakeCount = reaper.CountTakes(rItem)
        
        for s = 0, rTakeCount - 1 do
          
          sTake = reaper.GetTake(rItem, s)
          
          sTakeFXCount = reaper.TakeFX_GetCount(sTake)
          
          if sTakeFXCount ~= 0 then
            
            for t = 0, sTakeFXCount - 1 do
              
              reaper.TakeFX_SetEnabled(sTake, t, false)
            
            end
          end
        end
      end
    end
  end
  
  -- SELECT PREVIOUS TRACKS KEEPING CURRENT SELECTION
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELPREVTRACKKEEP"), 0)
  
  -- MAKE FOLDER
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_MAKEFOLDER"), 0)
  
  -- MUTE TRACKS
  reaper.SetTrackUIMute(safecopyFolderTrack, 1, 0)
  
  -- SET TRACK COLOR
  reaper.SetMediaTrackInfo_Value(safecopyFolderTrack, "I_CUSTOMCOLOR",reaper.ColorToNative(80,80,80)|0x1000000 )
    
  if hideSafecopyFolder == true then
    
    -- reaper.SetMediaTrackInfo_Value(safecopyFolderTrack, "B_SHOWINTCP", 0)
    reaper.SetOnlyTrackSelected(safecopyFolderTrack, true)
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN2"), 0)
     
    for p = 0, reaper.CountSelectedTracks(0) - 1 do
     
    reaper.SetMediaTrackInfo_Value(reaper.GetSelectedTrack(0, p), "B_SHOWINTCP", 0)
    reaper.SetMediaTrackInfo_Value(reaper.GetSelectedTrack(0, p), 'B_SHOWINMIXER', 0)
   
    end
  end   
end
  
  

function ResetAllItemsColor()
  local itemCount = reaper.CountMediaItems(0)
  
  for i = 0, itemCount - 1 do
    
    local currentItem = reaper.GetMediaItem(0, i)
    local currentItemTrack = reaper.GetMediaItemTrack(currentItem)
      
  end
end



--------------------------------------------------------------------------------
-- CHECK FOR ALREADY EXISTING SAFECOPY --
--------------------------------------------------------------------------------

-- CHECK FOR PRESENCE OF SAFECOPY, RETURNS TRUE IF NEW SAFECOPY IS NEEDED

function CheckForSafecopy()
  
  local safeCopyPresent = false
  
  -- UNSELECT TRACKS
  reaper.Main_OnCommand(40297, 0)
  
  local retval1, trackName
  
  for m = 0, reaper.CountTracks() - 1 do
  
    retval1, trackName = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, m), 'P_NAME', '', false)
    
    if trackName:find("SAFECOPY", 1, true) then
    
      reaper.SetTrackSelected(reaper.GetTrack(0, m), true)
      safeCopyPresent = true
    
    end
  end
  
  if safeCopyPresent then
  
    -- SAFECOPY IS ALREADY PRESENT : ASK IF PROCEED OR CANCEL
      
    local proceedConfirmation = reaper.ShowMessageBox("A safecopy is already present in this session. Do you wish to proceed?", "Session Safecopy", 1)
      
    if proceedConfirmation == 1 then -- user pressed ok button in dialog
       
      local deleteConfirmation = reaper.ShowMessageBox("Do you wish to delete the existing safecopy and replace it with a new one?", "Session Safecopy", 4)
        
      if deleteConfirmation == 6 then
          
        reaper.Main_OnCommand(40005, 0)
      
      end
    
    else
      
      return false
    
    end 
  end

  return true

end

--------------------------------------------------------------------------------
-- PRESS GO BUTTON --
--------------------------------------------------------------------------------

function goButtonClick()

  copyHiddenTracks = copyHTr
  lockSafecopyItems = lockItm
  hideSafecopyFolder = hideTr
  setCopiedHiddenTrackVisible = visHTr
  
  
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  if CheckForSafecopy() then
    Safecopy()
  end
  
  reaper.Undo_EndBlock("RIPO Safecopy", - 1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

  local trackManagerVisible = reaper.GetToggleCommandState(40906)
    
  if hideSafecopyFolder then

    if trackManagerVisible == 1 then
  
      reaper.ShowMessageBox("Safecopy complete", "Session Safecopy", 0)
  
    else
    
      local copyConfirmation = reaper.ShowMessageBox("Safecopy complete. Do you wish to open the Track Manager?", "Session Safecopy", 4)
    
      if copyConfirmation == 6 then
    
        reaper.Main_OnCommand(40906, 0)
      
      end
    end
  end 
end
