/*
	player has died text
	screams
	dynamic lap adjustments
*/

local lastScreamTic = -1

addHook("MobjDeath", function(mobj)
	local player = mobj.player
	if PTSR.pizzatime then
		if not player.pizzaface then
			if CV_PTSR.showdeaths.value then
				if PTSR.gamemode == 1 or PTSR.gamemode == 2 then
					chatprint("\x82*"..player.name.."\x82 has died.")
					if DiscordBot then
						DiscordBot.Data.msgsrb2 = $ .. "[" .. #player .. "]:skull: **" .. player.name .. "** died.\n"
					end
				end
			end
			if P_RandomChance(FRACUNIT/4) and CV_PTSR.screams.value and lastScreamTic ~= leveltime then
				lastScreamTic = leveltime
				S_StartSound(nil, sfx_pepdie)
			end
			if (PTSR.dynamic_maxlaps - 1) > 0 and (PTSR.dynamic_maxlaps - PTSR.laps) > 0 then
				PTSR.dynamic_maxlaps = $ - 1
				if (PTSR.dynamic_maxlaps - 1) > 15 and (PTSR.dynamic_maxlaps - PTSR.laps) > 0  then
					PTSR.dynamic_maxlaps = $ - 1 -- delete one extra maxlap if its more than 15 laps
				end
			end
		end
	end
end, MT_PLAYER)