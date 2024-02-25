freeslot("MT_PT_DEATHRING")

mobjinfo[MT_PT_DEATHRING] = {
	doomednum = -1,
	spawnstate = S_RING,
	spawnhealth = 1000,
	deathstate = S_SPRK1,
	deathsound = sfx_hidden,
	radius = 16*FU,
	height = 24*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

addHook("MobjSpawn", function(mobj)
	mobj.scale = $*2
	mobj.colorized = true
	mobj.color = SKINCOLOR_GREEN
	table.insert(PTSR.deathrings, mobj)
end, MT_PT_DEATHRING)

addHook("ThinkFrame", function()
	if #PTSR.deathrings > 0 then
		for i,deathring in ipairs(PTSR.deathrings) do
			if not deathring or not deathring.valid then
				table.remove(PTSR.deathrings, i)
			end
		end
	end
end)	

addHook("TouchSpecial", function(special, toucher)
	local tplayer = toucher.player -- touching player
	if special and special.valid 
	and toucher and toucher.valid 
	and tplayer and tplayer.valid and not tplayer.pizzaface then
		if special.rings_kept then
			P_GivePlayerRings(tplayer, special.rings_kept)
			print("\x83"..tplayer.name.." stole "..special.rings_kept.." rings from "..special.drop_name)
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. ("**"..tplayer.name.."** stole "..special.rings_kept.." rings from "..special.drop_name)
			end
		end
	end
end, MT_PT_DEATHRING)

-- Doesn't limit to grabbing rings. you get extra score on killing other stuff too
addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and gametype == GT_PTSPICER and source and source.valid and source.player and source.player.valid then
		local player = source.player
		if (target.flags & MF_ENEMY) then 
			P_AddPlayerScore(player, 800)
		elseif (target.type == MT_RING or target.type == MT_COIN)
			P_AddPlayerScore(player, 100)
		end
	end
end)

addHook("MobjDeath", function(target, inflictor, source, damage, damagetype)
	local player = target.player
	if target and target.valid and player and player.valid and player.rings then
		local deathring = P_SpawnMobj(target.x, target.y, target.z, MT_PT_DEATHRING)
		if deathring then
			deathring.rings_kept = player.rings
			deathring.drop_name = player.name
		end
	end
end, MT_PLAYER)
