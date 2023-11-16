
-- Nothing really needed to be touched here (Maybe)

addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	
	local exitingCount, playerCount, pizzaCount = PTSR_COUNT()
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if leveltime then -- just a safety check
			if (CV_PTSR.lappingtype.value == 2) and (player.lapsdid > CV_PTSR.maxlaps_perplayer.value) then
				P_DoPlayerExit(player)
			elseif ((playerCount > 1) and (not pizzaCount and not CV_PTSR.aimode.value) and PTSR.pizzatime) or (exitingCount == playerCount) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
				end
				--print(2)
			elseif (CV_PTSR.maxlaps.value and PTSR.laps > CV_PTSR.maxlaps.value and not CV_PTSR.dynamiclaps.value) or PTSR.quitting 
			or (PTSR.dynamic_maxlaps and PTSR.laps > PTSR.dynamic_maxlaps and CV_PTSR.dynamiclaps.value) 
			and not ((CV_PTSR.lappingtype.value == 2) and (player.lapsdid > CV_PTSR.maxlaps_perplayer.value)) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
					PTSR.quitting = true
				end
				--print(3)
			else
				if player.valid and (player.pizzaface or player.spectator) and not ( (CV_PTSR.lappingtype.value == 2) and (player.lapsdid > CV_PTSR.maxlaps_perplayer.value) ) then
					player.exiting = 0
				end
				--print(4)
			end
		end
	end
end)
