local hudmodname = "spicerunners"

PTSR.elimination_timer = nil

addHook("NetVars", function(net)
	PTSR.elimination_timer = net($)
end)

addHook("MapLoad", function()
	PTSR.elimination_timer = nil
end)

-- only players in game
local function EL_GetPlayerCount()
	local player_range = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid 
		and player.playerstate ~= PST_DEAD  
		and not player.ptsr_outofgame then
			table.insert(player_range, player)
		end
	end
	
	return #player_range
end

local function EL_EliminateLastPlayer()
	if PTSR.leaderboard[#PTSR.leaderboard] 
	and PTSR.leaderboard[#PTSR.leaderboard].valid then
		local chosen_player = PTSR.leaderboard[#PTSR.leaderboard] 
		P_KillMobj(chosen_player.realmo)
		chatprint("\x85".. chosen_player.name .. " has been eliminated!")
	end
end

PTSR_AddHook("onpizzatime", function()
	if PTSR.gamemode ~= PTSR.gm_elimination then return end

	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	PTSR.elimination_timer = gm_metadata.elimination_cooldown or 60*TICRATE
	
	chatprint("\x85\Elimination! Don't be last!")
end)

addHook("ThinkFrame", function()
	if PTSR.gamemode ~= PTSR.gm_elimination then return end
	
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	if PTSR.elimination_timer and not PTSR.gameover then -- its also pizza time in here
		PTSR.elimination_timer = $ - 1
		
		if not PTSR.elimination_timer then
			if EL_GetPlayerCount() > 1 then
				PTSR.elimination_timer = gm_metadata.elimination_cooldown or 60*TICRATE
				S_StartSound(nil, sfx_s3kb2)
				EL_EliminateLastPlayer()
			else
				if PTSR.leaderboard[1] and PTSR.leaderboard[1].valid then
					chatprint("\x85"..PTSR.leaderboard[1].name.. " won the game!")
				end
				
				PTSR.gameover = true
			end
		end
	end
end)

local elimination_timer_hud = function(v, player)
	if PTSR.gamemode ~= PTSR.gm_elimination and PTSR.pizzatime then return end
	
	if PTSR.elimination_timer ~= nil and not PTSR.gameover then
		customhud.CustomFontString(v, 25*FU, 156*FU, tostring(PTSR.elimination_timer/TICRATE), "PTFNT", (V_SNAPTOLEFT|V_SNAPTOBOTTOM), nil, FRACUNIT/2, SKINCOLOR_WHITE)
	end
end

customhud.SetupItem("PTSR_elimination_timer", hudmodname, elimination_timer_hud, "game", 2)