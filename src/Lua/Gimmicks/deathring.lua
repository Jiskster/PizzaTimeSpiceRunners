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
	mobj.color = SKINCOLOR_CHARTREUSE
	table.insert(PTSR.deathrings, mobj)
end, MT_PT_DEATHRING)

addHook("ThinkFrame", function()
	if #PTSR.deathrings > 0 then
		for i,deathring in ipairs(PTSR.deathrings) do
			if not deathring or not deathring.valid then
				table.remove(PTSR.deathrings, i)
			else
				PTSR.addw2sobject(deathring)
			end
		end
	end
end)	

addHook("TouchSpecial", function(special, toucher)
	local tplayer = toucher.player -- touching player
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	if tplayer.pizzaface then return true end
	
	if special and special.valid 
	and toucher and toucher.valid 
	and tplayer and tplayer.valid and not tplayer.pizzaface then
		if special.deathring_used then return true end
		
		if gm_metadata.allowrevive then 
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
				
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ("**"..tplayer.name.."** revived "..special.drop_name)
				end
				
				rplayer.powers[pw_invulnerability] = 5*TICRATE
				
				if rplayer == consoleplayer then
					displayplayer = consoleplayer -- go back in your view boi
					chatprintf(consoleplayer, "\x83You have been revived!")
				end
				
				rplayer.ptsr_justrevived = true -- variable for the hack to respawn 1 frame later
				
				rplayer.ptsr_gotrevivedonce = true -- variable to check if the player got revived before
			end				
		else
			if special.rings_kept then
				P_GivePlayerRings(tplayer, special.rings_kept)
				print("\x83"..tplayer.name.." stole "..special.rings_kept.." rings from "..special.drop_name)
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ("**"..tplayer.name.."** stole "..special.rings_kept.." rings from "..special.drop_name)
				end
				
				special.deathring_used = true
			end
		end
	end
end, MT_PT_DEATHRING)

addHook("MobjDeath", function(target, inflictor, source, damage, damagetype)
	local player = target.player
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
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
