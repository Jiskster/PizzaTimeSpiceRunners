addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	local count = PTSR_COUNT()
	
	local playerpfmode = gm_metadata.player_pizzaface
	local aimode = not playerpfmode
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if player.ptsr_outofgame then
			player.ptsr_outofgame = 1
		end

		if leveltime then -- just a safety check
			if (player.lapsdid > PTSR.maxlaps and CV_PTSR.default_maxlaps.value) then
				player.ptsr_outofgame = 1
				print(2)
			elseif (count.inactive - count.pizzas) == count.active then
				if player.valid and not (player.ptsr_outofgame) then
					player.ptsr_outofgame = 1
				end	
			elseif (playerpfmode and not count.pizzas and PTSR.pizzatime) then -- no pizzas in playerpf mode
				if player.valid and not (player.ptsr_outofgame) then
					player.ptsr_outofgame = 1
				end	
			else
				if player.valid and (player.pizzaface or player.spectator) and not (player.lapsdid > PTSR.maxlaps) then
					player.ptsr_outofgame = 0
				end
			end
		end
	end
end)
