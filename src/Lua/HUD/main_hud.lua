local path = "HUD/Drawers/default"

PTSR.hud_style = "default"

local hudstyle_file = io.openlocal("client/SpiceRunners/hudstyle.txt", "r")

if hudstyle_file then
	local value = hudstyle_file:read("*l")
	
	PTSR.hud_style = value
end

function PTSR.isHudStyle(style)
	return PTSR.hud_style == style
end

function PTSR.SetupHud(filepath)
	local funcname, drawfunc, type, style, hudlayer = dofile(filepath)
	local hudstyle = (style or "default")
	local hudtype = (type or "game")
	
	-- Make a new function from the current function.
	-- Currently makes it so huds don't draw if it's not PTSR.
	-- And makes it so it only draws the current style
	
	if drawfunc and funcname then
		local new_drawfunc = function(v, player)
			if gametype ~= GT_PTSPICER then 
				return 
			end
			
			if not PTSR.isHudStyle(hudstyle) and hudtype == "game" then 
				return
			end
			
			drawfunc(v, player)
		end
		
		if PTSR.HUD[hudstyle] == nil then
			PTSR.HUD[hudstyle] = {}
		end
		
		PTSR.HUD[hudstyle][funcname] = {draw = new_drawfunc, draw_type = type, draw_layer = hudlayer, draw_style = hudstyle}
		
		customhud.SetupItem(
			"PTSR:"..string.upper(hudstyle)..":"..string.upper(funcname), -- String Example: "PTSR:DEFAULT:BAR"
			ptsr_hudmodname, PTSR.HUD[hudstyle][funcname].draw, 
			PTSR.HUD[hudstyle][funcname].draw_type or "game", 
			PTSR.HUD[hudstyle][funcname].draw_layer or 0
		)
	end
end

local function SetupHud(filename)
	PTSR.SetupHud(path.."/"..filename)
end

local function FillMissingHudElements(style)
	if PTSR.HUD[style] then
		for funcname,v in pairs(PTSR.HUD["default"]) do
			if not PTSR.HUD[style][funcname] then
				--print("CCC: "..funcname) --DEBUG
				PTSR.HUD[style][funcname] = PTSR.HUD["default"][funcname]
				
				customhud.SetupItem(
					"PTSR:"..string.upper(style)..":"..string.upper(funcname),
					ptsr_hudmodname, PTSR.HUD[style][funcname].draw, 
					PTSR.HUD[style][funcname].draw_type or "game", 
					PTSR.HUD[style][funcname].draw_layer or 0
				)
			end
		end
	end
end

rawset(_G, "ptsr_hudmodname", "spicerunners")
-- time expected to reach to the final tween position, when pizza time starts
rawset(_G, "pthud_expectedtime", TICRATE*3)
-- pt animation position start
rawset(_G, "pthud_start_pos", 225*FRACUNIT)
-- pt animation position end
rawset(_G, "pthud_finish_pos", 175*FRACUNIT)

--MinimalHud Command
rawset(_G, "ptsr_minimalhud", function(p, arg)
	if arg == "1" or arg == "on" or arg == "true"
		PTSR.hud_style = "minimal"
		if io and p == consoleplayer
			local file = io.openlocal("client/SpiceRunners/hudstyle.txt", "w+")
			file:write(PTSR.hud_style)
			file:close()
		end
	elseif arg == "0" or arg == "off" or arg == "false"
		PTSR.hud_style = "default"
		if io and p == consoleplayer
			local file = io.openlocal("client/SpiceRunners/hudstyle.txt", "w+")
			file:write(PTSR.hud_style)
			file:close()
		end
	else
		CONS_Printf(p, "Insert a valid value")
	end
end)

COM_AddCommand("ptsr_minimalhud", ptsr_minimalhud, COM_LOCAL)

-- rank to patch
PTSR.r2p = function(v,rank) 
	if v.cachePatch("PTSR_RANK_"..rank:upper()) then
		return v.cachePatch("PTSR_RANK_"..rank:upper())
	end
end

-- rank to fill
PTSR.r2f = function(v,rank) 
	if v.cachePatch("PTSR_FRANK_"..rank:upper()) then
		return v.cachePatch("PTSR_FRANK_"..rank:upper())
	end
end

-- Hardcoded for now.
addHook("HUD", function(v,p,c)
	if PTSR.IsPTSR() then
		hud.disable("textspectator") -- sonic team junior
		hud.disable("score")
		hud.disable("time")
		hud.disable("rankings")
		
		if PTSR.hud_style == "minimal" then
			hud.disable("rings")
			hud.disable("lives")
		else
			hud.enable("rings")
			hud.enable("lives")
		end
	end
end)

SetupHud "DoorFade"
SetupHud "Bar"
SetupHud "ItsPizzaTime"
SetupHud "Tooltips"
SetupHud "Lapping"
SetupHud "Rank"
SetupHud "PlayerPFSwap"
SetupHud "Gamemode"
SetupHud "OvertimeMultiplier"
SetupHud "UntilEnd"

-- Minimal Hud Setup --
path = "HUD/Drawers/minimal";

SetupHud "Bar"
SetupHud "Tooltips"
SetupHud "Lapping"
SetupHud "Rank"
SetupHud "PlayerPF"
SetupHud "OvertimeMultiplier"
SetupHud "Lives"

path = "HUD/Drawers/default";
-- Minimal Hud Setup End --

-- Hardcoded. (And has the legacy prefix)
dofile "HUD/intermission/drawVoteScreenChosenMap.lua"
dofile "HUD/intermission/drawVoteScreenRoulette.lua"
dofile "HUD/intermission/drawVoteScreenMaps.lua"
dofile "HUD/intermission/drawVoteScreenTimer.lua"
dofile "HUD/intermission/draw_p_rank_animation.lua"
dofile "HUD/intermission/drawBackground.lua"
dofile "HUD/intermission/main.lua"

SetupHud "Combo"
SetupHud "Overtime"
SetupHud "Rankings"
SetupHud "Score"
SetupHud "HurryUp"
SetupHud "PFViewpoint"

-- Minimal Hud Setup --

path = "HUD/Drawers/minimal";

SetupHud "Combo"
SetupHud "Score" -- And rings

path = "HUD/Drawers/default";
-- Minimal Hud Setup End --

FillMissingHudElements("minimal")
