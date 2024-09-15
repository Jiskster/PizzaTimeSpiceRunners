freeslot("MT_PTSR_ESCAPECLOCK", "S_PTSR_ESCAPECLOCK", "SPR_ESCK")
freeslot("sfx_escl01", "sfx_escl02", "sfx_escl03", "sfx_escl04", "sfx_escl05")

local soundlist = {
	sfx_escl01,
	sfx_escl02,
	sfx_escl03,
	sfx_escl04,
	sfx_escl05,
}

mobjinfo[MT_PTSR_ESCAPECLOCK] = {
	--$Category Spice Runners
	--$Name Escape Clock
	--$Sprite ESCKA0
	doomednum = 2114,
	spawnstate = S_PTSR_ESCAPECLOCK,

	radius = 16*FU,
	height = 24*FU,

	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

states[S_PTSR_ESCAPECLOCK] = {
	sprite = SPR_ESCK,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = J,
	var2 = 2,
}

addHook("TouchSpecial", function(special, toucher)
	local player = toucher.player
	
	if not PTSR.pizzatime then
		return true
	end
	
	if special and special.valid and toucher and toucher.valid then
		if special.clock_collect_list then
			if special.clock_collect_list[player] == nil
			or special.clock_collect_list[player] ~= player.ptsr.laps then
				if player and player.valid then	
					special.clock_collect_list[player] = player.ptsr.laps
					S_StartSound(toucher, soundlist[P_RandomRange(1,#soundlist)])
					
					P_AddPlayerScore(player, 50)
					PTSR.add_wts_score(player, special, 50)
					
					if not player.ptsr.pizzaface then
						PTSR:AddComboTime(player, TICRATE)
					end
				end
			end
		end
	end
	
	return true
end, MT_PTSR_ESCAPECLOCK)

addHook("MobjThinker", function(mobj)
	if displayplayer and displayplayer.valid then
		if not PTSR.pizzatime 
		or (mobj.clock_collect_list[displayplayer] 
		and mobj.clock_collect_list[displayplayer] == displayplayer.ptsr.laps) then
			mobj.frame = $ | FF_TRANS50
		else
			mobj.frame = $ & ~FF_TRANS50
		end
	end
end, MT_PTSR_ESCAPECLOCK)

addHook("MobjSpawn", function(mobj)
	mobj.clock_collect_list = {
		-- [player_t] = (latest_lap)
	}
end, MT_PTSR_ESCAPECLOCK)