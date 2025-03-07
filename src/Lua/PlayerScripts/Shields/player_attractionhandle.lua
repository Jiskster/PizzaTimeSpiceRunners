addHook("PlayerThink", function(player)
	if gametype ~= GT_PTSPICER then return end
	if not (player and player.valid and player.ptsr) then return end
	if not (player.mo and player.mo.valid) then return end
	
	if player.ptsr.atrraction_timer then
		if (player.powers[pw_shield] == SH_ATTRACT) then
			player.ptsr.atrraction_timer = max(0, $ - 1)
			
			if not player.ptsr.atrraction_timer then
				P_SwitchShield(player, SH_PITY)
				P_SpawnShieldOrb(player)
				S_StartSound(player.mo, sfx_s3k79)
				P_FlashPal(player, 1, 12)
			else
				if (player.ptsr.atrraction_timer % TICRATE) == 0 then
					S_StartSoundAtVolume(player.mo, sfx_s1b1, min(player.ptsr.atrraction_timer, 255))
				end
			end
		else -- Clear silently cause its probably illegal.
			player.ptsr.atrraction_timer = 0
		end
	end
end)