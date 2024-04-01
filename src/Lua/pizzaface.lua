local already_announced_tornado = true

freeslot("MT_PIZZA_ENEMY") -- For AI

-- For AI
mobjinfo[MT_PIZZA_ENEMY] = {
	doomednum = -1,
	spawnstate = S_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 24*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL|MF_BOSS
}

PTSR.PFMaskData = {
	{
		name = "Pizzaface",
		state = S_PIZZAFACE,
		scale = FU/2,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":pizza:",
		aiselectable = true,
		tagcolor = SKINCOLOR_ORANGE
	},
	{
		name = "Coneball",
	    state = S_CONEBALL,
		scale = 3*FU/4,
		trails = {SKINCOLOR_SKY, SKINCOLOR_NEON},
		sound = sfx_coneba,
		emoji = ":candy:",
		aiselectable = true,
		tagcolor = SKINCOLOR_MAGENTA
	},
	{
		name = "Eggman",
	    state = S_PF_EGGMAN,
		scale = FU,
		trails = {SKINCOLOR_GOLD, SKINCOLOR_FLAME},
		sound = sfx_bewar3,
		emoji = ":egg:",
		aiselectable = true,
		tagcolor = SKINCOLOR_RED
	},
	{
		name = "Summa",
	    state = S_SUMMADAT_PF,
		scale = FU/2,
		trails = {SKINCOLOR_PEACHY, SKINCOLOR_RED},
		sound = sfx_smdah,
		emoji = ":stuck_out_tongue:",
		tagcolor = SKINCOLOR_ORANGE
	},
	{
		name = "Normal",
	    state = S_NORMALFACE_PF,
		scale = FU/2,
		trails = {SKINCOLOR_GREEN, SKINCOLOR_WHITE},
		sound = sfx_nrmlfc,
		emoji = ":green_circle:",
		tagcolor = SKINCOLOR_GREEN
	},
	{ -- Suggested by Maverick, maverick_2k on discord (841504642306801674)
		name = "Kimizza",
		state = S_KIMIZZA_PF,
		scale = FU,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_evlagh,
		emoji = ":pizza:",
		aiselectable = true,
		tagcolor = SKINCOLOR_ORANGE
	},
	{
		name = "Gooch",
	    state = S_GOOCH_PF,
		scale = FU,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":slight_smile:",
		tagcolor = SKINCOLOR_RED,
		momentum = true,
		aiselectable = true
	}
}


function PTSR:PizzaCollision(peppino, pizza)
	if peppino.player.lastparryframe and (leveltime - peppino.player.lastparryframe) <= CV_PTSR.parry_safeframes.value then
		PTSR.DoParry(peppino.player.mo, pizza)
		PTSR.DoParryAnim(peppino.player.mo, true)
		PTSR.DoParryAnim(pizza)
		peppino.player.lastparryframe = leveltime
	else
		P_KillMobj(peppino,pizza)
	end
end

function PTSR:PizzaCanTag(peppino, pizza)
	if not self.pizzatime then return false end
	if CV_PTSR.nuhuh.value then return false end

	if not (peppino.player and peppino.valid and peppino.player.valid) then return false end

	if peppino.player.ptsr_outofgame then return false end

	if peppino.player.powers[pw_invulnerability] then return false end

	if peppino.player.powers[pw_flashing] and not CV_PTSR.flashframedeath.value then return false end

	if peppino.player.pizzaface then return false end -- lets not tag our buddies!!

	if peppino.pizza_out or peppino.pizza_in then return false end -- in pizza portal? then dont kill

	if pizza.player and pizza.player.valid and pizza.player.pizzaface then
		if pizza.pfstuntime then return false end
		if not L_ZCollide(peppino,pizza) then return false end
		return true
	elseif pizza.type == MT_PIZZA_ENEMY then
		return true
	end

	return false
end

-- Randomly TPS to a peppino, check for stuntime manually
function PTSR:RNGPizzaTP(pizza, uselaugh)
	local peppinos = {} -- temp list of chosen players, or "peppinos" in this case.

	for peppino in players.iterate() do
		if not peppino.pizzaface and (peppino.mo and peppino.mo.valid) and
		not peppino.spectator and not peppino.ptsr_outofgame and (peppino.playerstate ~= PST_DEAD)
		and not peppino.quittime then
			table.insert(peppinos, #peppino)
		end
	end

	local chosen_peppinonum = P_RandomRange(1,#peppinos) -- random entry in table
	local chosen_peppino = peppinos[chosen_peppinonum] -- get the chosen value in table
	local peppino_pmo = players[chosen_peppino].realmo
	pizza.next_pfteleport = peppino_pmo -- next player object (mobj_t) to teleport to

	if peppinos ~= {} then
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
				S_StartSound(player.mo, PTSR.PFMaskData[player.PTSR_pizzastyle].sound)
			end
			
			pizza.next_pfteleport = nil
		else -- If AI Pizza Face
			PTSR_DoHook("pfteleport", pizza)
			
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

-- spawns at the uhh normal spot where it spawns
function PTSR:SpawnPFAI(forcestyle)
	local newpizaface = P_SpawnMobj(PTSR.end_location.x*FRACUNIT,
					PTSR.end_location.y*FRACUNIT,
					PTSR.end_location.z*FRACUNIT,
					MT_PIZZA_ENEMY)

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
	if not PTSR.PFMaskData[style] then
		style = 1
	end
	newpizaface.laughsound = PTSR.PFMaskData[style].sound
	newpizaface.state = PTSR.PFMaskData[style].state
	newpizaface.spritexscale = PTSR.PFMaskData[style].scale
	newpizaface.spriteyscale = PTSR.PFMaskData[style].scale
	newpizaface.pizzastyle = style

	return newpizaface
end
-- Player Touches AI
addHook("TouchSpecial", function(special, toucher)
	-- toucher: player
	-- special: pizzaface
	if not (toucher and toucher.valid) then return true end
	if special.pfstuntime then return true end

	local player = toucher.player
	if player and player.valid then
		if player.powers[pw_shield] & SH_FORCE then
		
			PTSR.DoParry(toucher, special)
			
			PTSR.DoParryAnim(toucher, true)
			PTSR.DoParryAnim(special)
			
			if player.powers[pw_shield] & SH_FORCEHP then
				player.powers[pw_shield] = SH_FORCE
			else
				player.powers[pw_shield] = SH_NONE
				P_DoPlayerPain(player)
			end
			
			return true
		end
	
		if player.powers[pw_invulnerability] then
			return true
		end
		
		if PTSR_DoHook("pfdamage", toucher, special) == true then
			return true
		end
		
		if not PTSR:PizzaCanTag(toucher, special) then return true end

		PTSR:PizzaCollision(toucher, special)
	end
	return true
end, MT_PIZZA_ENEMY)

-- Player touches human pizzaface
addHook("MobjCollide", function(peppino, pizza)
	if not PTSR:PizzaCanTag(peppino, pizza) then return end

	PTSR:PizzaCollision(peppino, pizza)
end, MT_PLAYER)


addHook("PlayerCmd", function (player, cmd)
	if player.pizzaface and player.realmo.pfstuntime then
		cmd.buttons = 0
		cmd.forwardmove = 0
		-- dont do sidemove cuz face swapping
	end
end)

local function PF_PlayerIsChasable(player)
	return (not player.ptsr_outofgame and not player.spectator and not player.quittime and not player.pizzaface
			and not player.mo.pizza_out and not player.mo.pizza_in and player.playerstate ~= PST_DEAD
			and player.mo.health)
end

local function PF_FindNewPlayer(mobj)
	local activeplayers = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid and PF_PlayerIsChasable(player) then
			table.insert(activeplayers, player)
		end
	end
	
	for i,player in ipairs(activeplayers) do
		if player.mo and player.mo.valid then
			if not (mobj.pizza_target and mobj.pizza_target.valid) or not PF_PlayerIsChasable(mobj.pizza_target.player)then
				mobj.pizza_target = player.mo
			else
				if (mobj.pizza_target and mobj.pizza_target.valid) then
					local dist_nptopizza = R_PointToDist2(mobj.pizza_target.x, mobj.pizza_target.y, mobj.x, mobj.y)
					local dist_newplayertopizza = R_PointToDist2(player.mo.x, player.mo.y, mobj.x, mobj.y)
					
					if dist_newplayertopizza < dist_nptopizza then
						mobj.pizza_target = player.mo
					end
				end
			end
		end	
	end
end

-- Ai Pizza Face Thinker
addHook("MobjThinker", function(mobj)
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	local laughsound = mobj.laughsound or sfx_pizzah
	local maskdata = PTSR.PFMaskData[mobj.pizzastyle or 1]

	PTSR.addw2sobject(mobj)

	if not PTSR.pizzatime then return end

	if mobj.pfstuntime then
		mobj.pfstuntime = $ - 1
		if not mobj.pfstunmomentum then
			L_SpeedCap(mobj, 0) -- Freeze! You peasant food!
		end

		if not mobj.pfstuntime then -- If we just got to 0
			if not PTSR.showtime // hiiii adding onto this for showtime
				PTSR.showtime = true
				local anim = animationtable["pizzaface"]
				if anim then
					anim:ChangeAnimation('PIZZAFACE_SHOWTIME', 3, 8, false)
				end

				S_StartSound(nil, laughsound)
			end
			mobj.pfstunmomentum = false
		end
		return
	end
	
	PF_FindNewPlayer(mobj)
	PTSR_DoHook("pfthink", mobj)
	
	if mobj.pizza_target and mobj.pizza_target.valid and mobj.pizza_target.health and mobj.pizza_target.player and mobj.pizza_target.player.valid and
	not mobj.pizza_target.player.ptsr_outofgame and not mobj.pizza_target.player.quittime and not mobj.pizza_target.player.spectator 
	and not mobj.pizza_target.player.pizzaface then
		local speed = CV_PTSR.aispeed.value
		local dist = R_PointToDist2(mobj.pizza_target.x, mobj.pizza_target.y, mobj.x, mobj.y)
		local offset_speed = 0
		
		if CV_PTSR.airubberband.value then
			offset_speed = (10*FU)
		end
		
		if mobj.eflags & MFE_UNDERWATER then
			speed = $ / 2
		end

		if PTSR.timeover then
			local yum = FRACUNIT + (PTSR.timeover_tics*25)

			speed = FixedMul($, yum)
		end
		
		if gm_metadata.pfspeedmulti then
			local newspeed = gm_metadata.pfspeedmulti
			
			speed = FixedMul($, newspeed)
		end

		if dist > CV_PTSR.aileash.value then
			if not mobj.pfstuntime then
				PTSR:RNGPizzaTP(mobj, true)
			end
		end

		-- t in tx means "player that we're TARGETING"
		local tx = mobj.pizza_target.x
		local ty = mobj.pizza_target.y
		local tz = mobj.pizza_target.z
		
		if maskdata.momentum then
			-- a bit of yoink from FlyTo
			local sped = 3*speed/2
			local flyto = P_AproxDistance(P_AproxDistance(tx - mobj.x, ty - mobj.y), tz - mobj.z)
			if flyto < 1 then
				flyto = 1
			end
            local tmomx = FixedMul(FixedDiv(tx - mobj.x, flyto), sped)
            local tmomy = FixedMul(FixedDiv(ty - mobj.y, flyto), sped)
            local tmomz = FixedMul(FixedDiv(tz - mobj.z, flyto), sped)
			-- and again
			local sped2 = speed/15
			local flyto2 = P_AproxDistance(P_AproxDistance(tmomx - mobj.momx, tmomy - mobj.momy), tmomz - mobj.momz)
			if flyto2 < 1 then
				flyto2 = 1
			end
            mobj.momx = $ + FixedMul(FixedDiv(tmomx - mobj.momx, flyto2), sped2)
            mobj.momy = $ + FixedMul(FixedDiv(tmomy - mobj.momy, flyto2), sped2)
            mobj.momz = $ + FixedMul(FixedDiv(tmomz - mobj.momz, flyto2), sped2)
			L_SpeedCap(mobj, sped)
		else
			P_FlyTo(mobj, tx, ty, tz, speed, true)
		end
		
		mobj.angle = R_PointToAngle2(mobj.x, mobj.y, tx, ty)

		if not (leveltime % 6) then
			local colors = maskdata.trails
			local ghost = P_SpawnGhostMobj(mobj)
			P_SetOrigin(ghost, mobj.x, mobj.y, mobj.z)
			ghost.fuse = 22
			ghost.colorized = true

			if mobj.redgreen then
				ghost.color = colors[1]
			else
				ghost.color = colors[2]
			end
			mobj.redgreen = not mobj.redgreen
			ghost.frame = $|FF_TRANS10|FF_FULLBRIGHT
		end

		if not maskdata.momentum then
			L_SpeedCap(mobj, speed+(offset_speed))
		end
	else
		if not mobj.pfstunmomentum then
			L_SpeedCap(mobj, 0)
		end
	end

	if PTSR.timeover and not PTSR.gameover and gm_metadata.dustdevil then
		local timeend = gm_metadata.dustdeviltimer or CV_PTSR.dustdeviltimerend.value
		
		PTSR.dustdeviltimer = $ + 1
		
		if PTSR.dustdeviltimer >= timeend then
			P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_ALIVEDUSTDEVIL)
			PTSR.dustdeviltimer = 0
			local tornado_text = "\x86*A tornado spawned!"
			chatprint(tornado_text)
			
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. ":cloud_tornado: A tornado spawned!\n"
			end
		end
	end
end, MT_PIZZA_ENEMY)

-- this should no longer happen cuz health=0 but just in case
addHook("MobjDeath", function(mobj)
	-- SRB2 does some stuff before we can stop it so
	mobj.flags = $ | MF_SPECIAL
	mobj.health = 1000
	return true
end, MT_PIZZA_ENEMY)

addHook("MobjSpawn", function(mobj)
	mobj.spritexscale = $ / 2
	mobj.spriteyscale = $ / 2

	mobj.pfstuntime = CV_PTSR.pizzatimestun.value*TICRATE
end, MT_PIZZA_ENEMY)

--Player Pizza Face Thinker
addHook("PlayerThink", function(player)
	player.PTSR_pizzastyle = $ or 1
	player.realmo.pfstuntime = $ or 0
	if gametype ~= GT_PTSPICER then return end
	if player.realmo and player.realmo.valid and player.pizzaface and leveltime then
		if player.redgreen == nil then
			player.redgreen = $ or false
		end
		player.pizzacharge = $ or 0
		player.pizzachargecooldown = $ or 0

		player.realmo.scale = 2*FU
		player.spectator = false -- dont give up! dont spectate as pizzaface! (theres another check when spawning so idk

		if player.realmo.pfstuntime then -- player freeze decrement (mainly for pizza faces)
			player.realmo.pfstuntime = $ - 1
			-- # No Momentum # --
			if not player.realmo.pfstunmomentum then
				player.mo.momx = 0
				player.mo.momy = 0
				player.mo.momz = 0
				L_SpeedCap(player.mo, 0)
			end
			-- # No Momentum # --
			--player.pflags = $|PF_FULLSTASIS
			if not player.realmo.pfstuntime then -- once it hits zero, LAUGH AHHHHAHHAAHAHAHHAHAH
				if CV_PTSR.pizzalaugh.value and not player.pizzachargecooldown
					S_StartSound(player.mo, PTSR.PFMaskData[player.PTSR_pizzastyle].sound)
				end

				if not PTSR.showtime // hiiii adding onto this for showtime
					PTSR.showtime = true
					local anim = animationtable['pizzaface']
					if anim then
						anim:ChangeAnimation('PIZZAFACE_SHOWTIME', 3, 8, false)
					end
				end
				
				player.realmo.pfstunmomentum = false
			elseif PTSR.pizzatime_tics < CV_PTSR.pizzatimestun.value*TICRATE then
				player.mo.momz = P_MobjFlip(player.mo)*-FU
				if player.facechangecooldown then
					player.facechangecooldown = $ - 1
				else
					local change = 0
					if player.cmd.sidemove > 5 then
						change = $ + 1
					elseif player.cmd.sidemove < -5 then
						change = $ - 1
					end
					if change ~= 0 then
						S_StartSound(nil, sfx_menu1, player)
						player.facechangecooldown = TICRATE/3
						local changeTo = (player.PTSR_pizzastyle + change + #PTSR.PFMaskData - 1) % #PTSR.PFMaskData + 1
						player.PTSR_pizzastyle = changeTo
						/* TODO: Make these save with an i/o system
						if consoleplayer == player then
							CV_StealthSet(CV_PTSR.pizzastyle, changeTo)
						end
						*/
					end
				end
			end
		end

		if (not player.pizzamask or not player.pizzamask.valid) then
			player.pizzamask = P_SpawnMobj(player.realmo.x,player.realmo.y,player.realmo.z,MT_PIZZAMASK)
			player.pizzamask.targetplayer = player --dream reference
			player.pizzamask.scale = PTSR.PFMaskData[1].scale
		end

		if player.pizzamask then
			player.realmo.flags2 = $|MF2_DONTDRAW -- invisible so that the pizza mask can draw over.
		else
			player.mo.color = SKINCOLOR_ORANGE
			player.mo.colorized = true
		end


		if not (leveltime % 3) and player.pizzamask and player.pizzamask.valid and player.speed > FRACUNIT then
			if (player ~= displayplayer) or (camera.chase and player == displayplayer) then
				local colors = PTSR.PFMaskData[player.PTSR_pizzastyle].trails
				local ghost = P_SpawnGhostMobj(player.pizzamask)
				P_SetOrigin(ghost, player.pizzamask.x, player.pizzamask.y, player.pizzamask.z)
				ghost.fuse = 11
				ghost.colorized = true

				if player.redgreen then
					ghost.color = colors[1]
				else
					ghost.color = colors[2]
				end
				ghost.frame = $|FF_TRANS10|FF_FULLBRIGHT
			end
			player.redgreen = not player.redgreen
		end

		if player.ptsr_outofgame or PTSR.quitting then
			player.pizzacharge = 0
		end
		if not player.ptsr_outofgame and (player.cmd.buttons & BT_ATTACK)
		and not PTSR.quitting and not player.realmo.pfstuntime and not player.pizzachargecooldown then -- basically check if you're active in general
			if player.pizzacharge < TICRATE then
				player.pizzacharge = $ + 1
			else
				PTSR:RNGPizzaTP(player.mo, true) -- Tp to random active player
			end
		elseif player.pizzacharge > 0 then
			player.pizzacharge = $ - 1
		end

		if player.pizzachargecooldown then
			player.pizzachargecooldown = $ - 1
		end

		if PTSR.timeover and not player.realmo.pfstuntime then
			local pmo = player.mo
			local findrange = 2500*FRACUNIT
			local zrange = 400*FU
			searchBlockmap("objects", function(refmobj, foundmobj)
				local strength = 3*FRACUNIT
				if foundmobj and abs(pmo.z-foundmobj.z) < zrange
				and foundmobj.valid and P_CheckSight(pmo, foundmobj) then
					if (foundmobj.type == MT_PLAYER) and ((leveltime/2)%2) == 0 then
						if foundmobj.player and foundmobj.player.valid and
						not foundmobj.player.spectator and foundmobj.player.pizzaface then
							return
						end
						if P_IsObjectOnGround(foundmobj) then
							strength = $ * 4
						end
						P_FlyTo(foundmobj,pmo.x,pmo.y,pmo.z,strength,true)
					end
				end
			end,pmo,
			pmo.x-findrange,pmo.x+findrange,
			pmo.y-findrange,pmo.y+findrange)
		end
	end
end)

-- Pizza Mask Thinker
addHook("MobjThinker", function(mobj)
	if gametype ~= GT_PTSPICER then return end
	if mobj.targetplayer and mobj.targetplayer.valid and mobj.targetplayer.mo and mobj.targetplayer.mo.valid then
		local targetplayer = mobj.targetplayer
		P_MoveOrigin(mobj, targetplayer.mo.x, targetplayer.mo.y, targetplayer.mo.z)
		mobj.angle = targetplayer.drawangle
		local thisMask = PTSR.PFMaskData[targetplayer.PTSR_pizzastyle]
		if mobj.state ~= thisMask.state then
			mobj.state = thisMask.state
			mobj.scale = thisMask.scale
		end
		mobj.flags2 = ($ & ~MF2_OBJECTFLIP) | (targetplayer.mo.flags2 & MF2_OBJECTFLIP)
		mobj.eflags = ($ & ~MFE_VERTICALFLIP) | (targetplayer.mo.eflags & MFE_VERTICALFLIP)
		mobj.color = targetplayer.skincolor
	end
end, MT_PIZZAMASK)

--THE BADNIKS ARENT PIZZAHEAD'S ENEMY
addHook("ShouldDamage", function(target, inflictor)
	if target.valid and target.player and target.player.pizzaface then
	--and inflictor and inflictor.valid and (inflictor.flags & MF_ENEMY)
	--this code is gone because we want pizzaface to not die
		return false
	end
end)


