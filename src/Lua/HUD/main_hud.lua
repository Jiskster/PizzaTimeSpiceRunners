local path = "HUD/Drawers/default"

PTSR.hud_style = "default"

local hudstyle_file = io.openlocal("client/SpiceRunners/hudstyle.txt", "r")

if hudstyle_file then
	local value = hudstyle_file:read("*l")
	
	PTSR.hud_style = value
	hudstyle_file:close()
end

function PTSR.isHudStyle(style_table)
	for i=1, #style_table do
		if style_table[i] == PTSR.hud_style then
			return true
		end
	end
	
	return false
end

function PTSR.hudAddToStyleTable(funcname, style_get, add_style)
	table.insert(PTSR.HUD[style_get][funcname].draw_style, add_style)
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
			if not PTSR.IsPTSR() then 
				return 
			end
			
			if not PTSR.isHudStyle(PTSR.HUD[hudstyle][funcname].draw_style) and hudtype == "game" then 
				return
			end
			
			drawfunc(v, player)
		end
		
		if PTSR.HUD[hudstyle] == nil then
			PTSR.HUD[hudstyle] = {}
		end
		
		PTSR.HUD[hudstyle][funcname] = {}
		PTSR.HUD[hudstyle][funcname].draw = new_drawfunc
		PTSR.HUD[hudstyle][funcname].draw_type = type
		PTSR.HUD[hudstyle][funcname].draw_layer = hudlayer
		PTSR.HUD[hudstyle][funcname].draw_style = {hudstyle}
		
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
		if io and p == consoleplayer then
			local file = io.openlocal("client/SpiceRunners/hudstyle.txt", "w+")
			file:write(PTSR.hud_style)
			file:close()
		end
	elseif arg == "0" or arg == "off" or arg == "false"
		PTSR.hud_style = "default"
		if io and p == consoleplayer then
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

local patches = {}
local loaded_fastpatch = false
local cachePatch = nil 

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
	
	if not loaded_fastpatch then
		cachePatch = v.cachePatch
		
		v.fastPatch = function(patch)
			if patches[patch] then
				return patches[patch]
			else
				patches[patch] = cachePatch(patch)
				
				return patches[patch]
			end
		end
		
		loaded_fastpatch = true
	end
	
	/*
	local c = 0
	for i,v in pairs(patches) do
		c = $ + 1
	end
	
	print(c)
	*/
end)

SetupHud "DoorFade"
SetupHud "Bar"
SetupHud "Tooltips"
SetupHud "Lapping"
SetupHud "Rank"
SetupHud "PlayerPF"
SetupHud "PlayerPFSwap"
SetupHud "Gamemode"
SetupHud "OvertimeMultiplier"
SetupHud "UntilEnd"

-- Refresh patch cache when addon is loaded.
addHook("AddonLoaded", function()
	for i,v in pairs(patches) do
		patches[i] = nil
	end
end)

-- [Minimal Hud Setup] --
path = "HUD/Drawers/minimal";

SetupHud "Bar"
SetupHud "Tooltips"
SetupHud "Lapping"
SetupHud "Rank"
SetupHud "OvertimeMultiplier"
SetupHud "Lives"

path = "HUD/Drawers/default";
-- [Minimal Hud Setup End] --

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
SetupHud "ItsPizzaTime"

-- [Minimal Hud Setup] --
path = "HUD/Drawers/minimal";

SetupHud "Combo"
SetupHud "Score" -- And rings

path = "HUD/Drawers/default";
-- [Minimal Hud Setup End] --

-- Copy some "default" huds into "minimal".
PTSR.hudAddToStyleTable("Gamemode", "default", "minimal")
PTSR.hudAddToStyleTable("ItsPizzaTime", "default", "minimal")
PTSR.hudAddToStyleTable("PlayerPF", "default", "minimal")
PTSR.hudAddToStyleTable("UntilEnd", "default", "minimal")
PTSR.hudAddToStyleTable("HurryUp", "default", "minimal")
PTSR.hudAddToStyleTable("Overtime", "default", "minimal")