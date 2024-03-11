-- Keep most rings if more than 125 rings. Else do "normal" ring drop
addHook("MobjDamage", function(target, inflictor, source, damage, damagetype)
	local player = target.player
	if target and target.valid and player and player.valid then
		if not (damagetype & DMG_DEATHMASK) then
			if player.powers[pw_shield] then 
				return 
			end
			
			if not player.ptsr_outofgame then
				if player.rings < 125 then
					S_StartSound(target, sfx_s3kb9) -- ring loss sound
					P_PlayerRingBurst(player, 5)
					player.rings = 0
					player.powers[pw_shield] = 0
				else
					S_StartSound(target, sfx_shldls)
					P_PlayerRingBurst(player, 32)
					player.rings = ($*5)/6
					player.powers[pw_shield] = 0
				end
				
				player.score = ($*3)/4 -- 3/4 remaining
				P_DoPlayerPain(player, source, inflictor)
				return true
			end
		end
	end
end, MT_PLAYER)