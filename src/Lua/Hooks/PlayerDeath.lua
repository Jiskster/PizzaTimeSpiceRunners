/*
	player has died text
	screams
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
		end
	end
end, MT_PLAYER)