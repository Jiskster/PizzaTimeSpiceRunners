-- Randomly TPS to a peppino, check for stuntime manually
function PTSR.pfRandomTP(pizza, uselaugh)
	local peppinos = {} -- temp list of chosen players, or "peppinos" in this case.

	for peppino in players.iterate() do
		if not peppino.ptsr.pizzaface and (peppino.mo and peppino.mo.valid) and
		not peppino.spectator and not peppino.ptsr.outofgame and (peppino.playerstate ~= PST_DEAD)
		and not peppino.quittime and not PTSR.DoHook("pfplayertpfind", pizza, peppino) 
		and not peppino.ptsr.treasure_got
		and not peppino.mo.pf_tele_delay
		then
			table.insert(peppinos, #peppino)
		end
	end

	if #peppinos > 0 then
		local chosen_peppinonum = P_RandomRange(1,#peppinos) -- random entry in table
		local chosen_peppino = peppinos[chosen_peppinonum] -- get the chosen value in table
		local peppino_pmo = players[chosen_peppino].realmo
		pizza.next_pfteleport = peppino_pmo -- next player object (mobj_t) to teleport to

		pizza.next_pfteleport.pf_tele_delay = 10
		if pizza.player then -- If Real Player
			local player = pizza.player

			player.pizzacharge = 0
			if not PTSR.timeover then
				player.pizzachargecooldown = CV_PTSR.pizzatpcooldown.value
				pizza.pfstuntime = CV_PTSR.pizzatpstuntime.value
			else
				player.pizzachargecooldown = (CV_PTSR.pizzatpcooldown.value)/3
				pizza.pfstuntime = (CV_PTSR.pizzatpstuntime.value)/3
			end

			P_SetOrigin(player.mo, pizza.next_pfteleport.x, pizza.next_pfteleport.y, pizza.next_pfteleport.z)
			
			if uselaugh == true then
				S_StartSound(player.mo, PTSR.PFMaskData[player.ptsr.pizzastyle].sound)
			end
			
			pizza.next_pfteleport = nil
		else -- If AI Pizza Face
			PTSR.DoHook("pfteleport", pizza)
			
			if not PTSR.timeover then
				pizza.pfstuntime = CV_PTSR.aitpstuntime.value
			else
				pizza.pfstuntime = (CV_PTSR.aitpstuntime.value)/3
			end

			P_SetOrigin(pizza, pizza.next_pfteleport.x, pizza.next_pfteleport.y, pizza.next_pfteleport.z)
			
			if uselaugh == true then
				local laughsound = pizza.laughsound or sfx_pizzah
				S_StartSound(pizza, laughsound)
			end
			
			pizza.next_pfteleport = nil
		end
	end
end
