
-- Nothing really needed to be touched here (Maybe)

addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	
	local exitingCount, playerCount, pizzaCount = PTSR_COUNT()
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if leveltime then -- just a safety check
			if (player.lapsdid > PTSR.maxlaps) then
				P_DoPlayerExit(player)
			elseif ((playerCount > 1) and (not pizzaCount and not CV_PTSR.aimode.value) and PTSR.pizzatime) or (exitingCount == playerCount) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
				end
				--print(2)
			else
				if player.valid and (player.pizzaface or player.spectator) and not (player.lapsdid > PTSR.maxlaps) then
					player.exiting = 0
				end
				--print(4)
			end
		end
	end
end)
