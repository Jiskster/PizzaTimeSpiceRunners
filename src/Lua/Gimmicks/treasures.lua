local TREASURE_SCORE_AWARD = 10000

states[freeslot "S_PTSR_TREASURE"] = {
	sprite = freeslot "SPR_STRE",
	frame = A,
	tics = -1
}

states[freeslot "S_PTSR_TREASURE_EFFECT"] = {
	sprite = freeslot "SPR_TEFF",
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = C,
	var2 = 1
}

mobjinfo[freeslot "MT_PTSR_TREASURE"] = {
	doomednum = 2113,
	radius = 16*FU,
	height = 16*FU,
	spawnstate = S_PTSR_TREASURE,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_SPECIAL
}

sfxinfo[freeslot "sfx_trefou"].caption = "Treasure found!"

addHook("MobjSpawn", function(mo)
	mo.player_got = false
	mo.last_time = 3*TICRATE

	mo.set_frame = P_RandomRange(A, T)

	mo.spawn_x = mo.x
	mo.spawn_y = mo.y
	mo.spawn_z = mo.z

	mo.collect_time = 0
end, MT_PTSR_TREASURE)

addHook("TouchSpecial", function(mo, pmo)
	if not mo.player_got
	and pmo
	and pmo.player
	and pmo.player.ptsr
	and not pmo.player.ptsr.treasure_got then
		pmo.player.ptsr.treasure_got = mo
		pmo.player.ptsr.treasures = $+1

		mo.player_got = pmo.player

		mo.effect = P_SpawnMobjFromMobj(mo, 0,0,0, MT_THOK)
		mo.effect.state = S_PTSR_TREASURE_EFFECT
		mo.effect.dispoffset = -1

		if pmo.player ~= displayplayer then
			S_StartSound(mo, sfx_trefou)
		end
		
		S_StartSound(nil, sfx_trefou, pmo.player)
		S_FadeMusic(50, 500, pmo.player)
	end
	return true
end, MT_PTSR_TREASURE)

addHook("MobjThinker", function(mo)
	mo.frame = mo.set_frame

	if not mo.player_got then return end

	if not (mo.player_got.valid
		and mo.player_got.mo
		and mo.player_got.ptsr
		and mo.player_got.mo.health
		and mo.player_got.ptsr.treasure_got == mo)
	or not (mo.last_time) then
		if mo.player_got.valid
		and mo.player_got.ptsr 
		and mo.player_got.ptsr.treasure_got == mo then
			mo.player_got.ptsr.treasure_got = nil
			P_AddPlayerScore(mo.player_got, TREASURE_SCORE_AWARD)
			PTSR.add_wts_score(mo.player_got, mo, TREASURE_SCORE_AWARD, 15, SKINCOLOR_YELLOW)
			S_FadeMusic(100, 500, mo.player_got)
			PTSR:FillCombo(mo.player_got)
			
			if mo.player_got.mo then
				mo.player_got.mo.state = S_PLAY_FALL
			end
		end

		if mo.effect and mo.effect.valid then
			P_RemoveMobj(mo.effect)
		end

		P_RemoveMobj(mo)
		return
	end

	local pmo = mo.player_got.mo
	pmo.momx = 0
	pmo.momy = 0
	pmo.momz = 0
	
	if pmo.state ~= mo.player_got.ptsr.treasure_state then
		pmo.state = mo.player_got.ptsr.treasure_state
	end

	P_SetOrigin(pmo, mo.spawn_x, mo.spawn_y, mo.spawn_z)
	P_SetOrigin(mo, mo.spawn_x, mo.spawn_y, mo.spawn_z+pmo.height+(8*FU))
	
	if mo.effect and mo.effect.valid then
		P_SetOrigin(mo.effect, mo.x, mo.y, mo.z)

		local time = FixedDiv(min(mo.last_time, 35), 35)
		local alpha = FF_TRANS10*ease.linear(time, 10, 0)

		mo.effect.frame = $|alpha
	end

	mo.last_time = $-1
end, MT_PTSR_TREASURE)

addHook("PreThinkFrame", do
	for p in players.iterate do
		if p.ptsr then
			p.ptsr.treasure_state = S_PLAY_RIDE
		end
	end
end)