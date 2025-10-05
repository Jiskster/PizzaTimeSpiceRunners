-- spawns at the uhh normal spot where it spawns
function PTSR.pfSpawnAI(forcestyle)
	if not multiplayer then
		if PTSR.aipf and PTSR.aipf.valid then
			PTSR.pfRandomTP(PTSR.aipf, true)
			return
		end
	end
	local newpizzaface = P_SpawnMobj(PTSR.end_location.x,
		PTSR.end_location.y,
		PTSR.end_location.z,
		MT_PIZZA_ENEMY)
	if not multiplayer then
		PTSR.aipf = newpizzaface
	end

	-- choose a random PF style if nothing was provided
	local style = forcestyle
	if forcestyle == nil then
		local good = {}
		for index, value in ipairs(PTSR.PFMaskData) do
			if value.aiselectable then
				table.insert(good, index)
			end
		end
		style = good[P_RandomRange(1, #good)]
	elseif type(forcestyle) == "string" then
		for index, value in ipairs(PTSR.PFMaskData) do
			if value.name:lower() == forcestyle:lower() then
				style = index
				break
			end
		end
	end
	
	if not PTSR.PFMaskData[style] or not multiplayer then
		style = 1
	end
	
	newpizzaface.laughsound = PTSR.PFMaskData[style].sound
	newpizzaface.state = PTSR.PFMaskData[style].state
	newpizzaface.spritexscale = PTSR.PFMaskData[style].scale
	newpizzaface.spriteyscale = PTSR.PFMaskData[style].scale
	newpizzaface.pizzastyle = style

	if not multiplayer and consoleplayer and consoleplayer.mo then
		local cmo = consoleplayer.mo
		P_SetOrigin(newpizzaface, cmo.x, cmo.y, cmo.z)
	end
	
	if not multiplayer then
		local laughsound = newpizzaface.laughsound or sfx_pizzah
		if not PTSR.showtime // hiiii adding onto this for showtime
			PTSR.showtime = true
			
			PTSR.resetHudState("PIZZAFACE_SHOWTIME")

			S_StartSound(nil, laughsound)
		end
	end

	table.insert(PTSR.pizzas,newpizzaface)
	return newpizzaface
end