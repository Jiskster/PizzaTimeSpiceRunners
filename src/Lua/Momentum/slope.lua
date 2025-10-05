local sl_mul = "1.789" -- slope launch
local hp_mul = "1.5" -- half pipe

addHook("PlayerThink", function(player)
	if player.mo and player.mo.valid then
		if (player.mo.standingslope) and not (player.mo.standingslope.flags & SL_NOPHYSICS) and ((player.mo.standingslope.normal.x != 0) or (player.mo.standingslope.normal.y != 0)) and not (P_IsObjectOnGround(player.mo)) and not P_PlayerInPain(player) and not player.powers[pw_tailsfly] then
			player.mo.momz = $/2
		end
	end
end)

addHook("ThinkFrame", function()
	for player in players.iterate do
		if player.mo and player.mo.valid then
			if (player.powers[pw_justlaunched]) and not P_PlayerInPain(player) and not player.powers[pw_tailsfly] then
				if (player.powers[pw_justlaunched] == 1) then
					player.mo.momz = FixedMul($, tofixed(sl_mul)) //normal launch
				else
					player.mo.momz = FixedMul($, tofixed(hp_mul)) //half pipe
				end
			end
		end
	end
end)