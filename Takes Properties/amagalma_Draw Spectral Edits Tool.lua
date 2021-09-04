-- @description Draw Spectral Edits Tool
-- @author amagalma
-- @version 1.0
-- @donation https://www.paypal.me/amagalma
-- @about
--   Draw Spectral Edits Tool
--
--   What it is: A tool for easy drawing spectral edits directly on items.
--
--   Supports: a) items with more than one takes, b) multi-channel items, c) display modes with “freq log” different than zero (thanks Justin for the help!).
--
--   Use: Just run the script and draw edits as needed (drawn spectral edits will have the default settings*). When finished, run the script again to disable drawing mode. A tooltip is shown near the mouse cursor to remind you that you are in drawing mode.
--
--   * For drawing with settings saved in presets and for maximum speed, functionality and user experience, it is recommended to use the “Draw Spectral Edits Tool – Preset System” companion script, which is offered separately with a small fee.
--
--   Requirements: JS_ReaScriptAPI, SWS Extension


local JHP5 = reaper.get_ini_file() local rgsY, of = reaper.BR_Win32_GetPrivateProfileString("\114\101\97\112\101\114", "\115\112\101\99\103\114\97\109\95\112\114\101\115\101\116\48", "", JHP5 ) if of == "" then return end  local yyc = tonumber( of:match("\91\37\100\37\46\93\43\32\91\37\100\37\46\93\43\32\91\37\100\37\46\93\43\32\40\91\37\100\37\46\93\43\41") ) local Sy = .1 + yyc * yyc local UP5L = {105, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 202, 203, 204, 417, 418, 419, 420, 421, 429, 430, 431, 433, 434, 450, 453, 460, 461, 462, 463, 464, 465, 472, 473, 488, 502, 503, 515, 517, 525, 526, 528, 529, 530, 531, 532, 533, 534, 535, 599, 600, 601, 1009, 1010, 1011, 32642, 32643, 32644, 32645 } for vn7q,jn0x in ipairs(UP5L) do local l_7K = reaper.JS_Mouse_LoadCursor( jn0x ) if l_7K then UP5L[l_7K] = true end UP5L[vn7q] = nil end local UBeK = reaper.GetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77", 0, "" ) local yq = reaper.GetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77\76\79\87\69\82", 0, "" ) reaper.SetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77", 0, "\48" ) reaper.SetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77\76\79\87\69\82", 0, "\48" ) local rgsY, rgsY, FV, mHd = reaper.get_action_context()  reaper.SetToggleCommandState( FV, mHd, 1 )  reaper.RefreshToolbar2( FV, mHd ) local Dl3 if reaper.GetToggleCommandState( 42294 ) == 0 then local T_vS = {42301, 42073, 42295} for W25a = 1, 3 do if reaper.GetToggleCommandState( T_vS[W25a] ) == 1 then Dl3 = T_vS[W25a] break end end reaper.Main_OnCommand( 42294, 0 )  end local nKj = reaper.JS_Window_FindChildByID( reaper.GetMainHwnd(), 1000 ) local rgsY, xd, zH, XW, PG, EThm local iXy, R4O, HyJj local log, floor, min, abs, max = math.log, math.floor, math.min, math.abs, math.max local MnDe = math.exp(1) local fN = false local y7S = {} local Zu_y = {} local xpcV = false local function U9( Ij ) return floor( (Ij - zH) * xd + 0.5 ) end local function TV( eoK ) return zH + eoK / xd end local function x6_( GmhW ) local g1Eg = reaper.JS_LICE_CreateBitmap( true, 1, 1 ) reaper.JS_LICE_Clear(g1Eg, GmhW or 0xFFFFFFFF) return g1Eg end local g1Eg = {} g1Eg[1] = x6_( 0x3F000000 ) for W25a = 2, 5 do g1Eg[W25a] = x6_() end local function t0( KS7, BD9, gp5, ZQ ) reaper.JS_Composite( nKj, KS7, BD9, gp5, ZQ, g1Eg[1], 0, 0, 1, 1, true ) reaper.JS_Composite( nKj, KS7, BD9, gp5, 1, g1Eg[2], 0, 0, 1, 1, true ) reaper.JS_Composite( nKj, KS7, BD9+ZQ, gp5, 1, g1Eg[3], 0, 0, 1, 1, true ) reaper.JS_Composite( nKj, KS7, BD9, 1, ZQ, g1Eg[4], 0, 0, 1, 1, true ) reaper.JS_Composite( nKj, KS7+gp5, BD9, 1, ZQ, g1Eg[5], 0, 0, 1, 1, true ) end local function Th() for W25a = 1, 5 do reaper.JS_Composite_Unlink( nKj, g1Eg[W25a], true ) end end local Kp = package.config:sub(1,1) local function rcr() if iXy then reaper.JS_WindowMessage_Release( nKj, "\87\77\95\76\66\85\84\84\79\78\68\79\87\78" ) end if R4O then reaper.JS_WindowMessage_Release( nKj, "\87\77\95\76\66\85\84\84\79\78\85\80" ) end end reaper.atexit(function() for W25a = 1, 5 do reaper.JS_LICE_DestroyBitmap( g1Eg[W25a] ) end reaper.SetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77", 0, UBeK ) reaper.SetMouseModifier( "\77\77\95\67\84\88\95\73\84\69\77\76\79\87\69\82", 0, yq ) rcr() reaper.SetToggleCommandState( FV, mHd, 0 ) reaper.RefreshToolbar2( FV, mHd ) if Dl3 then reaper.Main_OnCommand( Dl3, 0 ) end end) local function QXd() local rgsY, of = reaper.BR_Win32_GetPrivateProfileString("\114\101\97\112\101\114", "\115\112\101\99\103\114\97\109\95\112\114\101\115\101\116\48", "", JHP5 ) yyc = tonumber( of:match("\91\37\100\37\46\93\43\32\91\37\100\37\46\93\43\32\91\37\100\37\46\93\43\32\40\91\37\100\37\46\93\43\41") ) Sy = .1 + yyc * yyc y7S.oYb = reaper.GetMediaItemTakeInfo_Value( y7S.rX, "\68\95\83\84\65\82\84\79\70\70\83" ) end local function rS( xg ) local uB = xg - y7S.Oubx if not xpcV then xpcV = uB // y7S.M7px end if xpcV < 0 then xpcV = 0 end local MTc7 = floor(xpcV * (y7S.hH6l-1) / y7S.nWmL + 0.5) + y7S.Oubx - 1 local g_ = floor((xpcV+1) * (y7S.hH6l-1) / y7S.nWmL + 0.5) + y7S.Oubx local M7px = g_ - MTc7 if xg <= MTc7 then uB = -1 elseif xg >= g_ then uB = M7px else uB = xg - MTc7 end local LGg if yyc ~= 0 then local BmL = M7px / log( 1 + Sy ) LGg = (MnDe ^( (M7px - uB - 1.5) /BmL ) - 1 ) * y7S.IIh / Sy else LGg = y7S.IIh * (M7px - uB - 1) / M7px end if LGg < 0 then return 0 elseif LGg > y7S.IIh then return y7S.IIh else return LGg end end local YOur, S5, AS, SW, liRX, v8oo, DLom, xr, Hz = 1, 0, 0, 0, 0, 1, 1, 0, 0 local function Aoyg() local k8 = reaper.GetExtState( "\97\109\97\103\97\108\109\97\95\68\114\97\119\32\83\112\101\99\116\114\97\108\32\69\100\105\116\115\32\84\111\111\108", "\95" ) if k8 ~= "" then local iQe4, SP = {}, 0 for TzKa in k8:gmatch("\91\94\a\93\43") do SP = SP + 1 iQe4[SP] = tonumber( TzKa ) end YOur, S5, AS, SW, liRX, v8oo, DLom, xr, Hz = table.unpack( iQe4 ) end end local function Ch() Aoyg() local plwJ = string.format("\83\80\69\67\84\82\65\76\95\69\68\73\84\32\37\102\32\37\102\32\37\102\32\37\102\32\37\102\32\37\102\32\37\102\32\45\49\32\48\32\37\102\32\37\102\32\37\102\32\37\102\32\48\32\48\32\37\102\32\37\102", min(y7S.xa, y7S.Kn8), abs(y7S.xa - y7S.Kn8),  YOur, S5, AS, min(y7S.aa, y7S.pj), max(y7S.aa, y7S.pj), SW, liRX, v8oo, DLom, xr, Hz ) local eLP = ({reaper.GetItemStateChunk( y7S.YorQ, "", false )})[2] local iQe4, SP = {}, 0 local WuA, lNeZ = false, false for line in eLP:gmatch("\91\94\n\93\43") do if not WuA and line == "\71\85\73\68\32" .. reaper.BR_GetMediaItemTakeGUID( y7S.rX ) then WuA = true end if not lNeZ and WuA then if line:match("\94\84\65\75\69") then SP = SP + 1 iQe4[SP] = plwJ lNeZ = true end end SP = SP + 1 iQe4[SP] = line end if WuA and not lNeZ then iQe4[SP] = plwJ iQe4[SP+1] = "\62" end reaper.SetItemStateChunk( y7S.YorQ, table.concat(iQe4, "\n"), false ) reaper.Undo_OnStateChange_Item( 0, "\65\100\100\32\115\112\101\99\116\114\97\108\32\101\100\105\116", y7S.YorQ ) end local U_, fM, jwQ, kcU, RXB = 0, 0 local Gzqt, Sm, rvDF, mr local ewp1 local function Xh() local KS7, BD9 = reaper.GetMousePosition() local eoK, xg = reaper.JS_Window_ScreenToClient( nKj, KS7, BD9 ) xd = reaper.GetHZoomLevel() zH, XW = reaper.GetSet_ArrangeView2( 0, 0, 0, 0 ) XW = XW - 18/xd  rgsY, PG, EThm = reaper.JS_Window_GetClientSize( nKj ) local DZDO = reaper.JS_Mouse_GetState( 255 ) & 1 == 1 local sbXT = RXB == false and DZDO RXB = DZDO local YorQ, rX = reaper.GetItemFromPoint( KS7, BD9, true ) rgsY, rgsY, kcU = reaper.GetItemEditingTime2() if jwQ ~= rX then jwQ = rX fM = true else fM = false end if y7S.rX or rX then if not fN and fM then y7S.Of9 = reaper.GetMediaItemInfo_Value( y7S.YorQ or YorQ, "\68\95\80\79\83\73\84\73\79\78" ) y7S.yj = y7S.Of9 + reaper.GetMediaItemInfo_Value( y7S.YorQ or YorQ, "\68\95\76\69\78\71\84\72" ) y7S.EXvT = reaper.GetMediaItemTake_Source( y7S.rX or rX ) y7S.IIh = reaper.GetMediaSourceSampleRate( y7S.EXvT ) / 2 y7S.nWmL = reaper.GetMediaItemTakeInfo_Value( y7S.rX or rX, "\73\95\67\72\65\78\77\79\68\69" ) < 2 and reaper.GetMediaSourceNumChannels( y7S.EXvT ) or 1 y7S.f1CL = reaper.GetMediaItemTrack( y7S.YorQ or YorQ ) end y7S.ZSe = reaper.GetMediaTrackInfo_Value( y7S.f1CL, "\73\95\84\67\80\89" ) y7S.Oubx = y7S.ZSe + reaper.GetMediaItemTakeInfo_Value( y7S.rX or rX, "\73\95\76\65\83\84\89" ) y7S.hH6l = reaper.GetMediaItemTakeInfo_Value( y7S.rX or rX, "\73\95\76\65\83\84\72" ) y7S.M7px = floor(y7S.hH6l / y7S.nWmL + 0.5) if y7S.Of9 < zH then Zu_y.tvBZ = 0 else Zu_y.tvBZ = U9( y7S.Of9 ) end if y7S.yj > XW then Zu_y.oLHY = PG else Zu_y.oLHY = U9( y7S.yj ) end Zu_y.V7s = y7S.Oubx if Zu_y.V7s < 0 then Zu_y.V7s = 0 end Zu_y.xYo7 = y7S.Oubx + y7S.hH6l if Zu_y.xYo7 >= EThm then  Zu_y.xYo7 = EThm-1 end end if not y7S.rX and not rX then if Zu_y.xYo7 then Zu_y = {} end if y7S.EXvT then y7S = {} end end local nj5 = (Zu_y.tvBZ and eoK >= Zu_y.tvBZ+7 and eoK <= Zu_y.oLHY-7 and xg >= Zu_y.V7s and xg <= Zu_y.xYo7) and kcU == 0 local uul0 = reaper.JS_Mouse_GetCursor() local KjB = UP5L[uul0] or false if fN or (nj5 and KjB == false) then reaper.TrackCtl_SetToolTip( "\68\114\97\119\32\83\112\101\99\116\114\97\108\32\69\100\105\116", KS7-52, BD9-150, true ) ewp1 = true if not HyJj then HyJj = true iXy = reaper.JS_WindowMessage_Intercept( nKj, "\87\77\95\76\66\85\84\84\79\78\68\79\87\78", false ) >= 0 R4O = reaper.JS_WindowMessage_Intercept( nKj, "\87\77\95\76\66\85\84\84\79\78\85\80", false ) >= 0 end else if ewp1 then reaper.TrackCtl_SetToolTip( "", 0, 0, true ) ewp1 = false end if HyJj then HyJj = false rcr() end end if not y7S.rX then if sbXT and nj5 and KjB == false then y7S.rX, y7S.YorQ = rX, YorQ QXd() y7S.Zl6 = (xg - y7S.Oubx) / y7S.hH6l y7S.aa = rS( xg ) y7S.xa = TV( eoK ) Sm = y7S.hH6l Gzqt = y7S.ZSe fN = true end end if fN then local EcCY = eoK local tVlu = xg if eoK < Zu_y.tvBZ then EcCY = Zu_y.tvBZ end if eoK > Zu_y.oLHY then EcCY = Zu_y.oLHY end rvDF = false if y7S.ZSe ~= Gzqt then Gzqt = y7S.ZSe rvDF = true end if y7S.hH6l ~= Sm then Sm = y7S.hH6l rvDF = true end local uB = xg - y7S.Oubx y7S.Hy = rvDF and mr or uB // y7S.M7px if y7S.Hy < 0 then y7S.Hy = 0 end if rvDF or not Zu_y.Vgtw then Zu_y.Vgtw = floor(y7S.Hy * (y7S.hH6l-1) / y7S.nWmL + 0.5) + y7S.Oubx - 1 end if rvDF or not Zu_y.Bkt then Zu_y.Bkt = floor((y7S.Hy+1) * (y7S.hH6l-1) / y7S.nWmL + 0.5) + y7S.Oubx end if xg < Zu_y.Vgtw then tVlu = Zu_y.Vgtw end if tVlu < 0 then tVlu = 0 end if xg > Zu_y.Bkt then tVlu = Zu_y.Bkt end if tVlu >= EThm then tVlu = EThm-1 end local pm = floor(y7S.Zl6 * y7S.hH6l + y7S.Oubx + 0.5) local e6 = U9( y7S.xa ) mr = y7S.Hy local gp5, ZQ = abs( EcCY - e6 ), abs( tVlu - pm ) if not DZDO then if gp5*ZQ > 99 then y7S.pj = rS( tVlu ) y7S.Kn8 = TV( EcCY ) y7S.xa = y7S.xa - y7S.Of9 + y7S.oYb y7S.Kn8 = y7S.Kn8 - y7S.Of9 + y7S.oYb Ch() end fN = false y7S.rX, y7S.YorQ = nil, nil Zu_y = {} xpcV = false Th() else t0( EcCY < e6 and EcCY or e6, tVlu < pm and tVlu or pm, gp5, ZQ ) end end reaper.defer(Xh) end Xh()