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
		
		local output_text = chosen_player.name .. " has been eliminated!"
		
		chatprint("\x85".. "*" ..output_text)

		if DiscordBot then
			DiscordBot.Data.msgsrb2 = $ .. ":x: " .. output_text.. "\n"
		end
	end
end

PTSR_AddHook("onpizzatime", function()
	if PTSR.gamemode ~= PTSR.gm_elimination then return end

	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	PTSR.elimination_timer = gm_metadata.elimination_cooldown or 60*TICRATE
	
	chatprint("\x85\*Elimination! Don't be last!")
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
					local output_text = PTSR.leaderboard[1].name.. " won the game!"
					chatprint("\x85".. "*"..output_text)
					
					if DiscordBot then
						DiscordBot.Data.msgsrb2 = $ .. ":trophy: ".. output_text.. "\n"
					end
				end
				
				PTSR.gameover = true
				
				print("GAME OVER!")
				
				if consoleplayer and consoleplayer.valid then
					S_ChangeMusic(PTSR.RANKMUS[consoleplayer.ptsr_rank], false, player)
					mapmusname = PTSR.RANKMUS[consoleplayer.ptsr_rank]
				end
			end
		end
	end
end)

local elimination_timer_hud = function(v, player)
	if PTSR.gamemode ~= PTSR.gm_elimination and PTSR.pizzatime then return end
	
	if PTSR.elimination_timer ~= nil and not PTSR.gameover then
		local output
		
		if EL_GetPlayerCount() > 1 then
			output = "NEXT ELIMINATION: " ..tostring(PTSR.elimination_timer/TICRATE)
		else
			output = "GAME ENDING IN: " ..tostring(PTSR.elimination_timer/TICRATE)
		end
			
		customhud.CustomFontString(v, 160*FU, 148*FU, output, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/4, SKINCOLOR_WHITE)
	end
end

local elimination_warning_hud = function(v, player)
	if PTSR.gamemode ~= PTSR.gm_elimination and PTSR.pizzatime then return end
	
	if PTSR.elimination_timer ~= nil and not PTSR.gameover then
		if PTSR.leaderboard[#PTSR.leaderboard] and PTSR.leaderboard[#PTSR.leaderboard].valid then
			if PTSR.leaderboard[#PTSR.leaderboard] == player and EL_GetPlayerCount() > 1 then
				v.drawString(160*FU, 140*FU, "\x85\You are in last place!", (V_SNAPTOBOTTOM), "thin-fixed-center")
			end
		end
	end
end

customhud.SetupItem("PTSR_elimination_timer", hudmodname, elimination_timer_hud, "game", 2)
customhud.SetupItem("PTSR_elimination_warning", hudmodname, elimination_warning_hud, "game", 2)