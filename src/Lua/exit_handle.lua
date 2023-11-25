
-- Nothing really needed to be touched here (Maybe)

addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	
	local count = PTSR_COUNT()
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if player.exiting then
			player.exiting = 1
		end
		
		if leveltime then -- just a safety check
			if (player.lapsdid > PTSR.maxlaps and CV_PTSR.default_maxlaps.value) then
				player.exiting = 1
			elseif ((count.active > 1) and (not count.pizzas and not CV_PTSR.aimode.value) and PTSR.pizzatime) or (count.inactive == count.active) then
				if player.valid and not (player.exiting)
					player.exiting = 1
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
