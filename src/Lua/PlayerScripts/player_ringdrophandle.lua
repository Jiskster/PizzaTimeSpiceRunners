-- Keep most rings if more than 125 rings. Else do "normal" ring drop
addHook("MobjDamage", function(target, inflictor, source, damage, damagetype)
	local player = target.player
	if target and target.valid and player and player.valid then
		if not (damagetype & DMG_DEATHMASK) then
			if not player.ptsr.outofgame
			and not PTSR.DoHook('ondamage', target, inflictor, source, damage, damagetype) then
				local damagesound = (player.rings > 0) and sfx_s3kb9 or sfx_shldls

				PTSR:AddComboTime(player, -(2*TICRATE + TICRATE/2))
				
				if player.powers[pw_shield] then 
					return 
				end

				if player.rings > 0 then
					local ringslost = player.rings - (player.rings/3)

					P_PlayerRingBurst(player, ringslost)
					player.rings = $ / 3

					player.powers[pw_shield] = 0
				end

				S_StartSound(target, damagesound)
				PTSR.DeductScore(player, 500)
				P_DoPlayerPain(player, source, inflictor)
			end
			return true
		end
	end
end, MT_PLAYER)