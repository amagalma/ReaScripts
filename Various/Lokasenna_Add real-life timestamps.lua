--[[
    Description: Add real-life timestamps
    Version: 1.0.3
    Author: Lokasenna
    Donation: https://paypal.me/Lokasenna
    Changelog:
        Fix: Compatibility with font changes in GUI library
    Links:
        Lokasenna's Website http://forum.cockos.com/member.php?u=10417
    About:
        Fills a project with real (i.e. 11:45:01 PM) timestamps, with 
        a variety of user options.

    Donation: https://www.paypal.me/Lokasenna
]]--



-- Script generated by Lokasenna's GUI Builder


local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()


GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Button.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end





dm = false

local function dMsg(str)
   if dm then reaper.ShowConsoleMsg(tostring(str) .. "\n") end
end


local settings = {}

-- Constants
local FORMAT_AM = 1
local FORMAT_PM = 2
local FORMAT_24 = 3

local RANGE_PROJ = 1
local RANGE_TIME = 2
local RANGE_ITEMS = 3

local INSERT_MARKERS = 1
local INSERT_REGIONS = 2



-- seconds -> "HH:MM:SS (24H)"
-- Wrapped to 0 for each day
local function timeToString(t, twelve)

    dMsg("\ttime to string: " .. t)

    local h = math.modf(t / 3600)
    local left = t - h*3600
    local m = math.modf(left / 60)
    local s = left - m*60

    dMsg("\tgot h: " .. h .. ", m: " .. m .. ", s: " .. s)


    --[[
    local h, frac = math.modf(t / 3600)
    dMsg("got h: " .. h .. ", frac: " .. frac)
    local m, frac = math.modf(frac * 3600 / 60)
    dMsg("got m: " .. m .. ", frac: " .. frac)
    local s = frac * 60
    dMsg("got s: " .. s)
]]--
    h = h % 24

    local suff = ""
    if twelve then

        suff = (h > 11 and " PM" or " AM")
        if h > 12 then 
            h = h - 12
        elseif h == 0 then
            h = 12
        end

    end


    return string.format("%02d", h) .. ":" .. string.format("%02d", m) .. ":" .. string.format("%02d", s) .. suff

end


function string.mmatch(str, pattern)

    local ret = {}
    for match in string.gmatch(str, pattern) do
        ret[#ret+1] = match
    end

    return table.unpack(ret)

end


-- "HH:MM:SS" (24h) -> seconds
local function stringToTime(str)

    local h, m, s = str:mmatch("(%d+)")
    if not (h and m and s) then return end
    
    dMsg("stringToTime: " .. str)
    dMsg("\th, m, s = " .. h .. ", " .. m .. ", " .. s)
    dMsg("\treturning " .. h*3600+m*60+s.."\n")
    return h*3600 + m*60 + s

end

local function parseSettings()

    --  Parse settings
    local mults = {1, 60, 3600}
    settings.interval = GUI.Val("txt_interval")
    if not tonumber(settings.interval) then 
        reaper.MB("Please enter a valid interval.", "Whoops!", 0)
        return 
    end

    settings.interval = settings.interval * mults[GUI.Val("mnu_interval")]

    settings.start = stringToTime( GUI.Val("txt_start") )
    if not settings.start then
        reaper.MB("Please enter a valid start time. (HH:MM:SS)", "Whoops!", 0)
        return 
    end

    settings.format = GUI.Val("mnu_format")

    -- Offset for PM
    if settings.format == FORMAT_PM then
        settings.start = settings.start + (12 * 3600)
    end

    settings.range = GUI.Val("mnu_range")
    settings.insert = GUI.Val("mnu_insert")

    --settings.interval = 18
    --settings.start = 0
    --settings.format = 3


    return true

end


local function getSelectedItemsRange()

    local s, e

    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do

        local item = reaper.GetSelectedMediaItem(0, i)
        local item_s = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local item_e = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_s

        s = s and math.min(s, item_s) or item_s
        e = e and math.max(e, item_e) or item_e

    end

    return s, e

end


local function doMarkerLoop()

    --start, end = reaper.GetSet_LoopTimeRange( isSet, isLoop, start, end, allowautoseek )
    local s, e
    if     settings.range == RANGE_TIME then
        s, e = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    elseif settings.range == RANGE_PROJ then
        s = 0
        e = reaper.GetProjectLength(0)
    
        --reaper.GetProjectLength( proj )
        -- reaper.GetProjectTimeOffset( proj, rndframe )

    elseif settings.range == RANGE_ITEMS then

        s, e = getSelectedItemsRange()

    end
    dMsg("range start = " .. s .. ", end = " .. e)
    dMsg("interval = " .. settings.interval .. " seconds")


    reaper.Undo_BeginBlock()

    for pos = s, e, settings.interval do

        local elapsed = (pos - s) + settings.start
        local str = timeToString(elapsed, settings.format ~= 3)

    -- reaper.AddProjectMarker( proj, isrgn, pos, rgnend, name, wantidx )        
        reaper.AddProjectMarker(
            0, -- proj
            (settings.insert == INSERT_REGIONS), -- isrgn
            pos, -- pos
            math.min(pos + settings.interval, e), --rgnend
            str, -- name
            -1 -- wantidx
        )

    end

    reaper.Undo_EndBlock("Add real-life timestamps", -1)

end


local function btn_go()

    if parseSettings() then doMarkerLoop() end
    
end



GUI.name = "Add real-life timestamps"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 288, 224
GUI.anchor, GUI.corner = "mouse", "C"



GUI.New("mnu_interval", "Menubox", {
    z = 11,
    x = 164.0,
    y = 16.0,
    w = 96,
    h = 20,
    caption = "",
    optarray = {"seconds", "minutes", "hours"},
    retval = 1,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})

GUI.New("txt_interval", "Textbox", {
    z = 11,
    x = 112.0,
    y = 16.0,
    w = 48,
    h = 20,
    caption = "Marker interval:",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("mnu_range", "Menubox", {
    z = 11,
    x = 80.0,
    y = 96.0,
    w = 128,
    h = 20,
    caption = "Range:",
    optarray = {"Entire project", "Time selection", "Selected items"},
    retval = 1,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})

GUI.New("btn_go", "Button", {
    z = 11,
    x = 88.0,
    y = 168.0,
    w = 112,
    h = 24,
    caption = "Create markers",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = btn_go
})

GUI.New("lbl_start", "Label", {
    z = 11,
    x = 128.0,
    y = 68.0,
    caption = "(hh:mm:ss)",
    font = 3,
    color = "txt",
    bg = "wnd_bg",
    shadow = true
})

GUI.New("mnu_format", "Menubox", {
    z = 11,
    x = 212.0,
    y = 44.0,
    w = 48,
    h = 20,
    caption = "",
    optarray = {"AM", "PM", "24"},
    retval = 1,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})

GUI.New("txt_start", "Textbox", {
    z = 11,
    x = 112.0,
    y = 44.0,
    w = 96,
    h = 20,
    caption = "Real-life start:",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("mnu_insert", "Menubox", {
    z = 11,
    x = 80.0,
    y = 128.0,
    w = 128,
    h = 20,
    caption = "Insert:",
    optarray = {"Markers", "Regions"},
    retval = 1,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})




GUI.Init()
GUI.Main()