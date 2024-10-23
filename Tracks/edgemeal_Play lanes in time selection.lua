-- @description Play lanes in time selection
-- @author Edgemeal
-- @version 1.01
-- @changelog
--   * Auto-terminate on relaunch, simplify toolbar highlight code.
--   * Indent/center Radio Buttons.
--   * Check if REAPER version is >= 7.03.
--   * Check if ReaImGui installed.
-- @link Forum Thread https://forum.cockos.com/showthread.php?t=295370
-- @screenshot Example https://stash.reaper.fm/49429/Play%20Lanes%20v1.00.gif
-- @donation Donate via PayPal https://www.paypal.me/Edgemeal
-- @about
--   Play fixed track lanes in time selection, Auto advances to next lane...
--
--   Requires: REAPER v7.03 and ReaImGui v0.9.3.1
--   * Fixed Lane Track must have two or more lanes.
--   * Comp lane names must start with "C" (REAPER default: C1, C2, C3, etc...).
--   * In 'comp lane' mode, if user deletes all comps, play stops/script exits.
--   * In 'skip comp' mode, if user deletes all non-comps, play stops/script exits.

local rea_ver = tonumber(reaper.GetAppVersion():match('[%d.]+'))
if rea_ver < 7.03 then reaper.MB("This script requires REAPER v7.0+", "ERROR", 0) return end

if not reaper.APIExists('ImGui_Begin') then
  reaper.MB('Please install ReaImGui extension from ReaPack.', 'ERROR', 0)
  reaper.ReaPack_BrowsePackages("ReaImGui")
  return
end

package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
local ImGui = require 'imgui' '0.9.3.1'

local r = reaper
local repeatOn = r.GetToggleCommandState(1068) == 1 -- save users repeat mode setting
local title = 'Play lanes in time selection'
local ctx = ImGui.CreateContext(title, ImGui.ConfigFlags_NoSavedSettings)
local start_butn_colr = 0x00FF0080 -- green

local track, ui_vis, ui_open, x, y
local play_all, skip_comps, only_comps = true, false, false
local pp, prev_pp, lane_cnt, comp_ndx, lane = 0,0,0,0,-1
local comps = {}

function SetAction(action, state)
  if r.GetToggleCommandState(action) == 1 ~= state then
    r.Main_OnCommand(action, 0)
  end
end

function GetComps()
  local t = {}
  for i = 0, lane_cnt-1 do
    local retval, str = r.GetSetMediaTrackInfo_String(track, "P_LANENAME:" .. i, "", false)
    if retval and str:sub(1,1) == "C" then t[#t+1] = i end
  end
  return t
end

function NextNonComp(curlane)
  for i = curlane, lane_cnt-1 do
    local retval, str = r.GetSetMediaTrackInfo_String(track, "P_LANENAME:" .. i, "", false)
    if retval and str:sub(1,1) ~= "C" then return i end
  end
  return -1
end

function PlayLanes()
  track = r.GetSelectedTrack(0,0)
  if track == nil then return end
  if (r.GetPlayState() & 1 == 1) then
    pp = r.GetPlayPosition2()
    if pp < prev_pp then
      lane_cnt = r.GetMediaTrackInfo_Value(track, "I_NUMFIXEDLANES")
      if lane_cnt < 2 then return end
      lane=lane+1 if lane > lane_cnt-1 then lane = 0 end
      if only_comps then comps = GetComps() if #comps == 0 then return end end
      if only_comps and #comps > 0 then
        comp_ndx=comp_ndx+1 if comp_ndx > #comps then comp_ndx = 1 end
        lane = comps[comp_ndx]
      elseif skip_comps and #comps > 0 then
        local n = NextNonComp(lane)
        if n == -1 and (lane_cnt-#comps < 1) then return end
        while n == -1 do lane=lane+1 if lane > lane_cnt-1 then lane = 0 end
          n = NextNonComp(lane)
        end
        lane = n
      end
      r.SetMediaTrackInfo_Value(track, "C_LANEPLAYS:" .. lane, 1)
    end
    r.defer(PlayLanes)
    prev_pp = pp
  end
end

function Int_Lane()
  for i = 0, lane_cnt-1 do
   local n = r.GetMediaTrackInfo_Value(track, "C_LANEPLAYS:" .. i, 1)
   if n~=0 then return i-1 end
  end
  return -1
end

function Int_Comp(curlane)
  local val = 0
  for i = 1, #comps do
    if comps[i] >= curlane then
      val=i-1 if val < 0 then val = 0 end
      break
    end
  end
  return val
end

function ImGui_Loop()
  ImGui.SetNextWindowPos(ctx, x, y, ImGui.Cond_FirstUseEver, 0.5, 0.5) -- center window @ mouse pos.
  ui_vis, ui_open = ImGui.Begin(ctx, title, true, ImGui.WindowFlags_TopMost | ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoMove | ImGui.WindowFlags_NoCollapse )
  if ui_vis then
    ImGui.SameLine(ctx, 48)
    if ImGui.RadioButton(ctx,"Play all lanes", play_all) then
      play_all = true
      skip_comps = false
      only_comps = false
    end
    ImGui.NewLine(ctx) ImGui.SameLine(ctx, 48)
    if ImGui.RadioButton(ctx,"Skip comp lanes", skip_comps) then
      skip_comps = true
      play_all = false
      only_comps = false
    end
    ImGui.NewLine(ctx) ImGui.SameLine(ctx, 48)
    if ImGui.RadioButton(ctx,"Play only comps", only_comps) then
      only_comps = true
      play_all  = false
      skip_comps = false
    end
    -- start button
    ImGui.NewLine(ctx)
    ImGui.PushStyleColor(ctx, ImGui.Col_Button, start_butn_colr)
    start_butn_colr = 0x404040FF -- gray

    track = r.GetSelectedTrack(0,0)
    if track then
      lane_cnt = r.GetMediaTrackInfo_Value(track, "I_NUMFIXEDLANES")
      comps = GetComps()
    end

    local s_time, e_time = r.GetSet_LoopTimeRange(false, false, 0, 0, false)
    if s_time == e_time then
      ImGui.Button(ctx, "No Time Selection", 220, 24)
    elseif track == nil then
      ImGui.Button(ctx, "No track selected", 220, 24)
    elseif track and r.GetMediaTrackInfo_Value(track, 'I_FREEMODE') ~= 2 then
      ImGui.Button(ctx, "Not a fixed lane track", 220, 24)
    elseif track and lane_cnt < 2 then
      ImGui.Button(ctx, "Only one lane", 220, 24)
    elseif track and only_comps and #comps == 0 then
      ImGui.Button(ctx, "No comp lanes", 220, 24)
    else
      start_butn_colr = 0x00FF0080 -- green
      if ImGui.Button(ctx, "Start", 220, 24) then
        lane = Int_Lane()          -- selected lane
        comp_ndx = Int_Comp(lane+1)-- selected/next comp
        ui_open = false            -- close UI
        r.Main_OnCommand(1016, 0)  -- Transport: Stop
        r.Main_OnCommand(40630, 0) -- Go to start of time selection
        SetAction(1068,true)       -- Enable Repeat
        r.Main_OnCommand(40044, 0) -- Transport: Play (/stop)
        _, prev_pp = r.GetSet_LoopTimeRange(false, false, 0, 0, false)
        r.defer(PlayLanes)
      end
    end

    ImGui.PopStyleColor(ctx, 1)
    ImGui.End(ctx)  -- ui done --
  end
  if ui_open then r.defer(ImGui_Loop) end
end

-- exit
function Exit()
  r.Main_OnCommand(1016, 0) -- Transport: Stop
  SetAction(1068,repeatOn)  -- restore user repeat mode setting
  reaper.set_action_options(8)
end
r.atexit(Exit)

r.set_action_options(1|4)
-- get mouse pos (app will be centered @ mouse)
x, y = r.GetMousePosition()
r.defer(ImGui_Loop)