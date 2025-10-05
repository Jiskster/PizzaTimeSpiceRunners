-- Exclusive to AI

function PTSR.pfAITryDamage(special, toucher)
	if not (toucher and toucher.valid) then return true end
	if special.pfstuntime then return true end
	
	local player = toucher.player
	
	if player and player.valid then
		if not PTSR.pfCanChase(player) then
			return true
		end
		
		if PTSR.DoHook("pfpredamage", toucher, special) then
			return true
		end
	
		if player.powers[pw_shield] & SH_FORCE then
			PTSR.pfForceShieldParry(toucher, special)
			return true
		elseif player.powers[pw_shield] > 0 then
			PTSR.pfDoShieldDamage(toucher, special)
			return true
		end
	
		if player.powers[pw_invulnerability] then
			return true
		end
		
		if PTSR.DoHook("pfdamage", toucher, special) then
			return true
		end
		
		if not PTSR.pfCanDamage(toucher, special) then return true end

		PTSR.pfCollideHandle(toucher, special)
	end
	return true
end
