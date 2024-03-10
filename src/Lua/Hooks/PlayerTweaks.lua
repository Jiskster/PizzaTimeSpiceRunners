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
	local gm_metadata = PTSR.getCurrentModeMetadata()
	
	if special and special.valid 
	and toucher and toucher.valid 
	and tplayer and tplayer.valid and not tplayer.pizzaface then
		if special.deathring_used then return true end
		
		if not gm_metadata.allowrevive then
			if special.rings_kept then
				P_GivePlayerRings(tplayer, special.rings_kept)
				print("\x83"..tplayer.name.." stole "..special.rings_kept.." rings from "..special.drop_name)
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ("**"..tplayer.name.."** stole "..special.rings_kept.." rings from "..special.drop_name)
				end
				
				special.deathring_used = true
			end
		else
			if special.player_ref and special.player_ref.valid then -- dumb ass lua hack
				local rplayer = special.player_ref
				if rplayer == tplayer then return true end
				
				G_DoReborn(#rplayer)
				rplayer.spectator = false
				rplayer.ctfteam = 1
				rplayer.playerstate = PST_REBORN

				rplayer.ptsr_revivelocation = {
					x = special.x,
					y = special.y,
					z = special.z
				}
				
				if special.rings_kept then
					rplayer["ptsr_revive_await_rings"] = special.rings_kept
				end
				
				if special.score_kept then
					rplayer["ptsr_revive_await_score"] = special.score_kept
				end
				
				special.deathring_used = true
				
				P_ResetPlayer(rplayer)
				
				rplayer.mo.health = 1
				rplayer.mo.flags = mobjinfo[MT_PLAYER].flags
				
				print("\x83"..tplayer.name.." revived "..special.drop_name)
				
				print(rplayer.spectator)
				
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ("**"..tplayer.name.."** revived "..special.drop_name)
				end
				
				rplayer.ptsr_justrevived = true -- variable for the hack to respawn 1 frame later
				
				rplayer.ptsr_gotrevivedonce = true -- variable to check if the player got revived before
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
	local gm_metadata = PTSR.getCurrentModeMetadata()
	
	if target and target.valid and player and player.valid 
	and ((player.rings and not gm_metadata.allowrevive) or (gm_metadata.allowrevive and PTSR.pizzatime)) 
	and not player.ptsr_gotrevivedonce then
		local deathring = P_SpawnMobj(target.x, target.y, target.z, MT_PT_DEATHRING)
		if deathring then
			deathring.rings_kept = player.rings
			deathring.score_kept = player.score
			deathring.drop_name = player.name
			deathring.player_ref = player
		end
	end
end, MT_PLAYER)
