local floors = {
    "BLUEFLR", "CYANFLR", "GOLDFLR", "GREENFLR", "GREYFLR", "LIMEFLR", "NEOGFLR", "ORGFLR", "PURFLR", "REDFLR", "VIOFLR", "WHITEFLR", "YELFLR"
}
local colorsplash = false

local theThickener = {
    sec = function(sec, amount, mobjamount)
        sec.floorheight = FixedMul($, amount)
        sec.ceilingheight = FixedMul($, amount)
        if sec.floorxscale then
            sec.floorxscale = FixedDiv($, mobjamount)
            sec.flooryscale = FixedDiv($, mobjamount)
            sec.ceilingxscale = FixedDiv($, mobjamount)
            sec.ceilingyscale = FixedDiv($, mobjamount)
        end
    end,
    slope = function(slope, amount)
        slope.zdelta = FixedMul($, amount)
        slope.o = {x = slope.o.x, y = slope.o.y, z = FixedMul(slope.o.z, amount)}
    end,
    side = function(side, amount, mobjamount)
        if side.scalex_mid then
            side.scaley_top = FixedDiv($, amount)
            side.scaley_mid = FixedDiv($, amount)
            side.scaley_bottom = FixedDiv($, amount)
            side.scalex_top = FixedDiv($, mobjamount)
            side.scalex_mid = FixedDiv($, mobjamount)
            side.scalex_bottom = FixedDiv($, mobjamount)
        else
            side.rowoffset = FixedMul($, amount)
        end
    end,
    mo = function(mo, amount, mobjamount)
        mo.scale = FixedMul($, mobjamount)
        P_SetOrigin(mo, mo.x, mo.y, FixedMul((mo.prethiccz ~= nil and mo.prethiccz) or mo.z, amount))
        mo.momz = FixedMul((mo.prethiccmomz ~= nil and mo.prethiccmomz) or $, mobjamount)
        mo.prethiccz, mo.prethiccmomz = nil
        -- special case for lava fall.
        if mo.type == MT_LAVAFALL then
            if mo.thiccbakscale then
                mo.scale = FixedMul($, mobjamount)
                mo.thiccbakscale = nil
            end
            if mo.scale < FRACUNIT then
                mo.thiccbakscale = mo.scale
                mo.scale = FRACUNIT
            end
        end
    end
}

local colorSplashBackup = { secs = {}, sides = {} }

local portableColorSplash = {
    sec = function(sec, undo)
        if not undo then
            colorSplashBackup.secs[#sec] = {floor = sec.floorpic, ciel = sec.ceilingpic}
            sec.floorpic = floors[P_RandomRange(1, #floors)]
            sec.ceilingpic = floors[P_RandomRange(1, #floors)]
        elseif colorSplashBackup.secs[#sec] then
            sec.floorpic = colorSplashBackup.secs[#sec].floor
            sec.ceilingpic = colorSplashBackup.secs[#sec].ciel
            colorSplashBackup.secs[#sec] = nil
        end
    end,
    side = function(side, undo)
        if not undo then
            colorSplashBackup.sides[#side] = {}
            if side.toptexture then
                colorSplashBackup.sides[#side].top = side.toptexture
                side.toptexture = R_TextureNumForName(floors[P_RandomRange(1, #floors)])
            end
            if side.bottomtexture then
                colorSplashBackup.sides[#side].bot = side.bottomtexture
                side.bottomtexture = R_TextureNumForName(floors[P_RandomRange(1, #floors)])
            end
            if side.midtexture then
                colorSplashBackup.sides[#side].mid = side.midtexture
                side.midtexture = R_TextureNumForName(floors[P_RandomRange(1, #floors)])
            end
        elseif colorSplashBackup.sides[#side] then
            if colorSplashBackup.sides[#side].top then
                side.toptexture = colorSplashBackup.sides[#side].top
            end
            if colorSplashBackup.sides[#side].bot then
                side.bottomtexture = colorSplashBackup.sides[#side].bot
            end
            if colorSplashBackup.sides[#side].mid then
                side.midtexture = colorSplashBackup.sides[#side].mid
            end
            colorSplashBackup.sides[#side] = nil
        end
    end,
    mo = function(mo, undo)
        if not undo then
            mo.colorSplashBak = {color = mo.color, colorized = mo.colorized}
            mo.color = P_RandomRange(1, #skincolors-1)
            mo.colorized = true
        elseif mo.colorSplashBak then
            mo.color = mo.colorSplashBak.color
            mo.colorized = mo.colorSplashBak.colorized
            mo.colorSplashBak = nil
        end
    end
}

local mobjTable = {}
addHook("MobjSpawn", function(mo)
    if not mobjTable[mo] then
        table.insert(mobjTable, mo)
    end
end)
addHook("MobjRemoved", function(mo)
    if mobjTable[mo] then
        table.remove(mobjTable, mo)
    end
end)
local squished = false
local curramount = FRACUNIT
local currmobjamount = FRACUNIT
addHook("MapChange", function()
    squished = false
    curramount = FRACUNIT
    currmobjamount = FRACUNIT
    mobjTable = {}
end)

local function doTheThing(constamount, constmobjamount)
	if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
	
    local amount = FixedMul(FixedDiv(FRACUNIT, curramount), constamount)
    local mobjamount = FixedMul(FixedDiv(FRACUNIT, currmobjamount), constmobjamount)
    -- this was a difficult decision, but... i need to iterate through objects twice.
    -- when changing height of a floor objects are standing on, it immediately changes the z of objects on it.
    -- there's no other way to know whether this happened, and it might also happen if i process the objects beforehand.
    -- i also need to make sure no object clips through a solid wall upon changing scale, but.. that's for later lol
    for i, mo in ipairs(mobjTable) do
        if mo and mo.valid then
            mo.prethiccz, mo.prethiccmomz = mo.z, mo.momz
        end
    end
    local prevslopes = {}
    for sector in sectors.iterate do
        if sector.f_slope and not (sector.f_slope.flags & SL_DYNAMIC) and not prevslopes[sector.f_slope] then
            theThickener.slope(sector.f_slope, amount)
            prevslopes[sector.f_slope] = true
        end
        if sector.c_slope and not (sector.c_slope.flags & SL_DYNAMIC) and not prevslopes[sector.c_slope] then
            theThickener.slope(sector.c_slope, amount)
            prevslopes[sector.c_slope] = true
        end
        theThickener.sec(sector, amount, mobjamount)
        if colorsplash then
            portableColorSplash.sec(sector, squished)
        end
        --[[for rover in sector.ffloors() do

        end]]
    end
    prevslopes = nil
    for side in sides.iterate do
        theThickener.side(side, amount, mobjamount)
        if colorsplash then
            portableColorSplash.side(side, squished)
        end
    end
    for i, mo in ipairs(mobjTable) do
		if mo and mo.valid then
			theThickener.mo(mo, amount, mobjamount)
			if colorsplash then
                portableColorSplash.mo(mo, squished)
            end
		end
	end
    curramount = constamount
    currmobjamount = constmobjamount
	squished = not $
end

addHook("MapLoad", function()
    local amount = FRACUNIT/4
    local mobjamount = FRACUNIT/4
    doTheThing(amount, mobjamount)
end)

-- we need to talk about checkpoints
addHook("TouchSpecial", function(mo, toucher)
	if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
	
    if mo and mo.valid and toucher and toucher.valid and toucher.player and toucher.player.valid
    and toucher.player.starpostnum ~= toucher.player.prethiccstarnum
    and not (netgame or mapheaderinfo[gamemap].levelflags & LF_NORELOAD) then
        toucher.player.starpostz = FixedDiv($, curramount)
        toucher.player.starpostscale = FixedDiv($, currmobjamount)
        toucher.player.prethiccstarnum = toucher.player.starpostnum
    end
end, MT_STARPOST)

-- Reworked ApplyMomentum Code by ThatOneCartridgeGuy
rawset(_G, "P_PlusMomentum", function(p)
	if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
local actualSpeed = FixedDiv(FixedHypot(p.cmomx - p.mo.momx, p.cmomy - p.mo.momy), p.mo.scale)
	if p.mo
	and p.mo.valid then
		p.mo.currz = p.mo.z
		p.mo.prevz = $ or 0
		if p.mo
		and (p.pflags & PF_SPINNING or p.pflags & PF_STARTDASH)
		and not (p.mo.skin == "vector" and p.cmd.buttons & BT_SPIN)
		and (P_IsObjectOnGround(p.mo) or p.mo.eflags & MFE_JUSTHITFLOOR) then
			p.normalspeed = 0
		elseif p.mo
		and p.mo.eflags & MFE_UNDERWATER
			if (p.pflags & PF_SPINNING or p.pflags & PF_STARTDASH)
			and p.mo.skin == "vector"
			and p.cmd.buttons & BT_SPIN then
				p.normalspeed = 36*FRACUNIT
			else
				if (P_IsObjectOnGround(p.mo) or p.mo.eflags & MFE_JUSTHITFLOOR)
					if p.mo
					and p.speed >= 29*(18*FRACUNIT)/32
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						if p.mo.currz < p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (actualSpeed*2)+FRACUNIT/2
						elseif p.mo.currz > p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (actualSpeed*2)-FRACUNIT/2
						else
							p.normalspeed = (actualSpeed*2)
						end
					end
					if p.mo
					and (p.speed < 29*(18*FRACUNIT)/32 or p.normalspeed < 36*FRACUNIT)
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
					if p.mo
					and p.speed >= 29*(30*FRACUNIT)/32
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						if p.mo.currz < p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (6*actualSpeed/5)+FRACUNIT/2
						elseif p.mo.currz > p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (6*actualSpeed/5)-FRACUNIT/2
						else
							p.normalspeed = (6*actualSpeed/5)
						end
					end
					if p.mo
					and (p.speed < 29*(30*FRACUNIT)/32 or p.normalspeed < 36*FRACUNIT)
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
				else
					if p.mo
					and p.speed >= 18*FRACUNIT
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = (actualSpeed*2)
					end
					if p.mo
					and (p.speed < 18*FRACUNIT or p.normalspeed < 36*FRACUNIT)
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
					if p.mo
					and p.speed >= 30*FRACUNIT
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = (6*actualSpeed/5)
					end
					if p.mo
					and (p.speed < 30*FRACUNIT or p.normalspeed < 36*FRACUNIT)
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
				end
			end
		else
			if (p.pflags & PF_SPINNING or p.pflags & PF_STARTDASH)
			and p.mo.skin == "vector"
			and p.cmd.buttons & BT_SPIN then
				p.normalspeed = 36*FRACUNIT
			else
				if (P_IsObjectOnGround(p.mo) or p.mo.eflags & MFE_JUSTHITFLOOR)
					if p.mo
					and p.speed >= 29*(36*FRACUNIT)/32
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						if p.mo.currz < p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = actualSpeed+FRACUNIT/2
						elseif p.mo.currz > p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = actualSpeed-FRACUNIT/2
						else
							p.normalspeed = actualSpeed
						end
					end
					if p.mo
					and (p.speed < 29*(36*FRACUNIT)/32 or p.normalspeed < 36*FRACUNIT)
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
					if p.mo
					and p.speed >= 29*(60*FRACUNIT)/32
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						if p.mo.currz < p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (3*actualSpeed/5)+FRACUNIT/2
						elseif p.mo.currz > p.mo.prevz and not (p.mo.eflags & MFE_JUSTHITFLOOR) then
							p.normalspeed = (3*actualSpeed/5)-FRACUNIT/2
						else
							p.normalspeed = (3*actualSpeed/5)
						end
					end
					if p.mo
					and (p.speed < 29*(60*FRACUNIT)/32 or p.normalspeed < 36*FRACUNIT)
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
				else
					if p.mo
					and p.speed >= 36*FRACUNIT
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = actualSpeed
					end
					if p.mo
					and (p.speed < 36*FRACUNIT or p.normalspeed < 36*FRACUNIT)
					and not (p.powers[pw_sneakers])
					and not (p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
					if p.mo
					and p.speed >= 60*FRACUNIT
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = (3*actualSpeed/5)
					end
					if p.mo
					and (p.speed < 60*FRACUNIT or p.normalspeed < 36*FRACUNIT)
					and (p.powers[pw_sneakers] or p.powers[pw_super]) then
						p.normalspeed = 36*FRACUNIT
					end
				end
			end
		end
	end
	p.mo.prevz = p.mo.z
end)

addHook("PlayerThink", function(player)
if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
local actualSpeed = FixedDiv(FixedHypot(player.cmomx - player.mo.momx, player.cmomy - player.mo.momy), player.mo.scale)
	if ((player.playerstate == PST_LIVE) and not (player.powers[pw_carry]) and player.mo.state != S_PLAY_SUPER_TRANS1 and player.mo.state != S_PLAY_SUPER_TRANS2 and player.mo.state != S_PLAY_SUPER_TRANS3 and player.mo.state != S_PLAY_SUPER_TRANS4 and player.mo.state != S_PLAY_SUPER_TRANS5 and player.mo.state != S_PLAY_SUPER_TRANS6 and (player.mo.skin == "sonic" or player.mo.skin == "tails" or player.mo.skin == "knuckles" or player.mo.skin == "amy" or player.mo.skin == "fang" or player.mo.skin == "metalsonic" or player.mo.skin == "espio" or player.mo.skin == "mighty" or player.mo.skin == "charmy" or player.mo.skin == "vector" or player.mo.skin == "heavy" or player.mo.skin == "bomb" or player.mo.skin == "ray" or (player.mo.skin == "shadow" and not (player.sbike)) or player.mo.skin == "tangle" or player.mo.skin == "whisper" or player.mo.skin == "surge" or player.mo.skin == "trip"))
		player.jumpfactor = skins[player.mo.skin].jumpfactor
		if (player.mo.skin == "vector" or player.mo.skin == "ray")
			if ((player.powers[pw_super] or player.powers[pw_sneakers]))
				if (player.mo.eflags & MFE_UNDERWATER)
					if (player.mo.skin == "vector")
						if (player.speed < 30*FRACUNIT)
							player.actionspd = 60*FRACUNIT
						elseif (player.speed >= 30*FRACUNIT)
							player.actionspd = actualSpeed*2
						end
					else
						if (player.speed < 40*FRACUNIT)
							player.actionspd = 60*FRACUNIT
						elseif (player.speed >= 40*FRACUNIT)
							player.actionspd = 3*actualSpeed/2
						end
					end
				else
					if (player.speed < 60*FRACUNIT)
						player.actionspd = 60*FRACUNIT
					elseif (player.speed >= 60*FRACUNIT)
						player.actionspd = actualSpeed
					end
				end
			elseif (not (player.powers[pw_super]) and not (player.powers[pw_sneakers]))
				if (player.mo.eflags & MFE_UNDERWATER)
					if (player.mo.skin == "vector")
						if (player.speed < 18*FRACUNIT)
							player.actionspd = 36*FRACUNIT
						elseif (player.speed >= 18*FRACUNIT)
							player.actionspd = actualSpeed*2
						end
					else
						if (player.speed < 24*FRACUNIT)
							player.actionspd = 36*FRACUNIT
						elseif (player.speed >= 24*FRACUNIT)
							player.actionspd = 3*actualSpeed/2
						end
					end
				else
					if (player.speed < 36*FRACUNIT)
						player.actionspd = 36*FRACUNIT
					elseif (player.speed >= 36*FRACUNIT)
						player.actionspd = actualSpeed
					end
				end
			end
		elseif (player.mo.skin == "knuckles" or player.mo.skin == "amy" or player.mo.skin == "fang" or player.mo.skin == "espio" or player.mo.skin == "tangle")
			player.actionspd = 0
		end
		if (player.mo.skin != "heavy")
			P_PlusMomentum(player)
		end
		if (player.mo.skin == "metalsonic" and (player.cmd.forwardmove or player.cmd.sidemove) and not (player.pflags & PF_SPINNING) and not (player.pflags & PF_STARTDASH) and not (player.skidding) and player.dashmode >= 3*TICRATE)
			player.mo.friction = FRACUNIT
		else
			player.mo.friction = 29*FRACUNIT/32
		end
		if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_BOUNCING)
			player.thrustfactor = 8*skins[player.mo.skin].thrustfactor/3
		elseif (not (P_IsObjectOnGround(player.mo)) and not (player.climbing) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and not (player.pflags & PF_BOUNCING))
			player.thrustfactor = 2*skins[player.mo.skin].thrustfactor
		elseif ((player.mo.skin == "heavy" or player.mo.state == S_PLAY_SPINDASH or (player.mo.skin == "vector" and player.mo.state == S_VECTOR_SPINDASH)) and (player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH) and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR))
			player.thrustfactor = 0
		else
			player.thrustfactor = skins[player.mo.skin].thrustfactor
		end
		if (P_IsObjectOnGround(player.mo) and not (player.mo.eflags & MFE_JUSTHITFLOOR))
			player.charflags = $|SF_RUNONWATER
		else
			player.charflags = $ & ~SF_RUNONWATER
		end
		if ((player.mo.skin == "sonic" or player.mo.skin == "tails" or player.mo.skin == "knuckles" or player.mo.skin == "metalsonic" or player.mo.skin == "espio" or player.mo.skin == "mighty" or player.mo.skin == "ray" or player.mo.skin == "shadow" or player.mo.skin == "surge" or player.mo.skin == "trip") and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.cmd.buttons & BT_SPIN and not (player.plusbuttons & BT_SPIN) and player.skidtime)
			player.mo.state = S_PLAY_SPINDASH
			player.pflags = $|PF_STARTDASH|PF_SPINNING
			player.pflags = $ & ~PF_THOKKED
			player.dashspeed = player.mindash
			P_InstaThrust(player.mo, player.mo.angle, 0)
			S_StartSound(player.mo, sfx_spndsh)
		end
		if (player.mo.skin == "sonic" or player.mo.skin == "tails" or player.mo.skin == "knuckles" or player.mo.skin == "metalsonic" or player.mo.skin == "mighty" or player.mo.skin == "ray" or player.mo.skin == "espio" or player.mo.skin == "charmy" or player.mo.skin == "vector" or player.mo.skin == "bomb" or player.mo.skin == "shadow" or player.mo.skin == "surge" or player.mo.skin == "trip")
			if (player.mo.eflags & MFE_UNDERWATER and (player.powers[pw_super] or player.powers[pw_sneakers]))
				player.mindash = 30*FRACUNIT
			elseif (player.mo.eflags & MFE_UNDERWATER and not (player.powers[pw_super]) and not (player.powers[pw_sneakers]))
				player.mindash = 18*FRACUNIT
			elseif (not (player.mo.eflags & MFE_UNDERWATER) and (player.powers[pw_super] or player.powers[pw_sneakers]))
				player.mindash = 60*FRACUNIT
			elseif (not (player.mo.eflags & MFE_UNDERWATER) and not (player.powers[pw_super]) and not (player.powers[pw_sneakers]))
				player.mindash = 36*FRACUNIT
			end
			if (player.powers[pw_super] or player.powers[pw_sneakers])
				player.maxdash = 120*FRACUNIT
			else
				player.maxdash = 72*FRACUNIT
			end
		end
		if (player.secondjump == UINT8_MAX)
			player.mo.state = S_PLAY_JUMP
			player.pflags = $|PF_JUMPED
			player.pflags = $ & ~(PF_SPINNING|PF_THOKKED|PF_SHIELDABILITY)
			player.secondjump = 0
		end
		if (player.mo.skin != "heavy" and player.pflags & PF_JUMPED and ((player.charflags & SF_NOJUMPSPIN and player.mo.state == S_PLAY_JUMP) or player.mo.state == S_PLAY_FLOAT or player.mo.state == S_PLAY_FLOAT_RUN or player.mo.state == S_PLAY_SPRING or player.mo.state == S_PLAY_FALL or (player.mo.skin == "mighty" and player.mo.state == S_MIGHTY_HAMMERDROP_SPRING)) and not (player.powers[pw_super]) and not (player.powers[pw_invulnerability]) and not (player.mo.skin == "metalsonic" and player.dashmode >= 3*TICRATE))
			player.pflags = $|PF_NOJUMPDAMAGE
		else
			player.pflags = $ & ~PF_NOJUMPDAMAGE
		end
		if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and ((player.charflags & SF_NOJUMPSPIN and player.mo.state == S_PLAY_JUMP) or player.mo.state == S_PLAY_SPRING or player.mo.state == S_PLAY_FALL or (player.mo.skin == "mighty" and player.mo.state == S_MIGHTY_HAMMERDROP_SPRING) or player.mo.state == S_PLAY_STND or player.mo.state == S_PLAY_WALK or player.mo.state == S_PLAY_RUN or player.mo.state == S_PLAY_SKID or player.mo.state == S_PLAY_WAIT or player.mo.state == S_PLAY_EDGE or player.mo.state == S_PLAY_FLOAT or player.mo.state == S_PLAY_FLOAT_RUN or player.mo.state == S_PLAY_DASH) and player.secondjump != 2)
			player.pflags = $|PF_JUMPED
			player.pflags = $ & ~PF_SPINNING
			if (player.mo.state == S_PLAY_STND or player.mo.state == S_PLAY_WALK or player.mo.state == S_PLAY_RUN or player.mo.state == S_PLAY_DASH)
				player.pflags = $ & ~PF_THOKKED
			end
			if not (player.mo.skin == "mighty" and player.mo.state == S_MIGHTY_HAMMERDROP_SPRING)
				if (player.mo.momz*P_MobjFlip(player.mo) > 0 and not (player.mo.skin == "trip" and player.powers[pw_super]))
					player.mo.state = S_PLAY_SPRING
				elseif (player.mo.momz*P_MobjFlip(player.mo) <= 0 and not (player.mo.skin == "trip" and player.powers[pw_super]))
					player.mo.state = S_PLAY_FALL
				end
			end
		end
		if (player.pflags & PF_SHIELDABILITY and not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR))
			player.pflags = $|PF_SPINNING|PF_THOKKED
			if (player.mo.state != S_PLAY_JUMP and player.mo.skin != "amy" and not (player.charflags & SF_NOJUMPSPIN))
				player.mo.state = S_PLAY_JUMP
			elseif (player.mo.state != S_PLAY_ROLL and (player.mo.skin == "amy" or player.charflags & SF_NOJUMPSPIN))
				player.mo.state = S_PLAY_ROLL
			end
		end
		if ((player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH) and player.mo.skin != "charmy" and player.mo.skin != "heavy" and player.mo.skin != "bomb")
			if (player.pflags & PF_JUMPED and not (player.pflags & PF_THOKKED))
				player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
			elseif (player.mo.skin == "vector" and player.cmd.buttons & BT_SPIN and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR))
				player.pflags = $ & ~PF_THOKKED
			else
				player.pflags = $|PF_THOKKED
			end
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.speed >= 5*FRACUNIT and not (player.pflags & PF_STARTDASH) and not (player.mo.skin == "vector" and player.cmd.buttons & BT_SPIN))
				if (player.powers[pw_super] or player.powers[pw_sneakers])
					P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(3*FRACUNIT/10))
				else
					P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(FRACUNIT/4))
				end
			end
		elseif ((player.mo.skin == "charmy" or player.mo.skin == "heavy") and (player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH))
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.speed >= 5*FRACUNIT and not (player.pflags & PF_STARTDASH) and player.mo.skin == "charmy")
				if (player.powers[pw_super] or player.powers[pw_sneakers])
					P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(3*FRACUNIT/10))
				else
					P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(FRACUNIT/4))
				end
			end
			player.pflags = $|PF_SPINNING|PF_THOKKED
		end
		if (((player.powers[pw_super] and player.mo.skin == "sonic") or player.mo.skin == "metalsonic") and (player.mo.skin == "sonic" or player.mo.skin == "tails" or player.mo.skin == "knuckles" or player.mo.skin == "metalsonic" or player.mo.skin == "espio" or player.mo.skin == "mighty" or player.mo.skin == "vector" or player.mo.skin == "shadow" or player.mo.skin == "ray") and player.pflags & PF_JUMPED and not (player.pflags & PF_THOKKED) and player.cmd.buttons & BT_SPIN and not (player.plusbuttons & BT_SPIN))
			player.secondjump = 2
		end
		if (player.secondjump == 2 and (player.mo.skin == "sonic" or player.mo.skin == "metalsonic"))
			player.pflags = $ | PF_JUMPED | PF_THOKKED
			player.secondjump = 2
			player.mo.flags = $ | MF_NOGRAVITY
			if (player.speed < player.runspeed)
				player.mo.state = S_PLAY_FLOAT
			elseif (player.speed >= player.runspeed and not (player.dashmode >= 3*TICRATE))
				player.mo.state = S_PLAY_FLOAT_RUN
			elseif (player.speed >= player.runspeed and player.dashmode >= 3*TICRATE)
				player.mo.state = S_PLAY_DASH
			end
			if (player.cmd.buttons & BT_JUMP and not (player.cmd.buttons & BT_SPIN))
				if P_MobjFlip(player.mo)*player.mo.momz < 5*FRACUNIT
					P_SetObjectMomZ(player.mo, FRACUNIT/2, true)
				elseif P_MobjFlip(player.mo)*player.mo.momz > 5*FRACUNIT
					P_SetObjectMomZ(player.mo, -(FRACUNIT/2), true)
				end
			elseif (player.cmd.buttons & BT_SPIN and not (player.cmd.buttons & BT_JUMP))
				if P_MobjFlip(player.mo)*player.mo.momz > -(5*FRACUNIT)
					P_SetObjectMomZ(player.mo, -(FRACUNIT/2), true)
				elseif P_MobjFlip(player.mo)*player.mo.momz < -(5*FRACUNIT)
					P_SetObjectMomZ(player.mo, FRACUNIT/2, true)
				end
			elseif (not (player.cmd.buttons & BT_JUMP) and not (player.cmd.buttons & BT_SPIN))
				if P_MobjFlip(player.mo)*player.mo.momz > 0
					P_SetObjectMomZ(player.mo, -(FRACUNIT/2), true)
				elseif P_MobjFlip(player.mo)*player.mo.momz < 0
					P_SetObjectMomZ(player.mo, FRACUNIT/2, true)
				end
			elseif (player.cmd.buttons & BT_JUMP and player.cmd.buttons & BT_SPIN)
				player.mo.state = S_PLAY_JUMP
				player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
				player.secondjump = 0
				P_SpawnThokMobj(player)
				S_StartSound(player.mo, sfx_thok)
				player.drawangle = player.mo.angle
				if (player.dashmode < 3*TICRATE and player.mo.skin == "metalsonic")
					if not (maptol & TOL_NIGHTS)
						player.dashmode = 3*TICRATE
						S_StartSound(player.mo, sfx_kc4d)
					end
				end
				if ((player.mo.skin == "sonic" or player.mo.skin == "metalsonic") and (player.cmd.forwardmove or player.cmd.sidemove))
					P_InstaThrust(player.mo, player.mo.angle, player.actionspd)
				elseif not (player.cmd.forwardmove) and not (player.cmd.sidemove)
					P_InstaThrust(player.mo, player.mo.angle, 0)
				end
				P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
			end
		else
			player.mo.flags = $ & ~MF_NOGRAVITY
		end
		if (player.mo.skin == "sonic" or player.mo.skin == "metalsonic")
			if ((player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER))
				if (player.speed < 60*FRACUNIT)
					player.actionspd = 60*FRACUNIT
				elseif (player.speed >= 60*FRACUNIT)
					player.actionspd = actualSpeed+(6*FRACUNIT)
				end
			elseif (not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER))
				if (player.speed < 36*FRACUNIT)
					player.actionspd = 36*FRACUNIT
				elseif (player.speed >= 36*FRACUNIT)
					player.actionspd = actualSpeed+(6*FRACUNIT)
				end
			elseif ((player.powers[pw_super] or player.powers[pw_sneakers]) and player.mo.eflags & MFE_UNDERWATER)
				if (player.speed < 30*FRACUNIT)
					player.actionspd = 30*FRACUNIT
				elseif (player.speed >= 30*FRACUNIT)
					player.actionspd = actualSpeed+(6*FRACUNIT)
				end
			elseif (not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and player.mo.eflags & MFE_UNDERWATER)
				if (player.speed < 18*FRACUNIT)
					player.actionspd = 18*FRACUNIT
				elseif (player.speed >= 18*FRACUNIT)
					player.actionspd = actualSpeed+(6*FRACUNIT)
				end
			end
			if (player.mo.skin == "metalsonic")
				if (player.dashmode >= 3*TICRATE and (player.cmd.forwardmove or player.cmd.sidemove) and not (player.skidtime) and not (player.pflags & PF_SPINNING) and not (player.pflags & PF_STARTDASH) and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR or player.secondjump == 2))
					if (player.powers[pw_super] or player.powers[pw_sneakers])
						P_Thrust(player.mo, player.mo.angle, (3*FRACUNIT/10))
					else
						P_Thrust(player.mo, player.mo.angle, (FRACUNIT/4))
					end
				end
				if (player.dashmode < 3*TICRATE and player.mo.state == S_PLAY_SPINDASH and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR))
					if not (maptol & TOL_NIGHTS)
						player.dashmode = 3*TICRATE
						S_StartSound(player.mo, sfx_kc4d)
					end
				end
			end
		end
		if (player.mo.skin == "tails")
			if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and (player.mo.state == S_PLAY_FLY or player.mo.state == S_PLAY_FLY_TIRED or player.mo.state == S_PLAY_SWIM))				
				if (player.mo.momz*P_MobjFlip(player.mo) < 0)
					if (player.powers[pw_super] or player.powers[pw_sneakers])
						P_Thrust(player.mo, player.mo.angle, 3*FRACUNIT/10)
					else
						P_Thrust(player.mo, player.mo.angle, FRACUNIT/4)
					end
				end
				if (player.cmd.buttons & BT_JUMP and player.cmd.buttons & BT_SPIN)
					player.mo.state = S_PLAY_JUMP
					player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
					P_SpawnThokMobj(player)
					S_StartSound(player.mo, sfx_zoom)
					P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
					player.drawangle = player.mo.angle
					if (not (player.cmd.forwardmove) and not (player.cmd.sidemove))
						P_InstaThrust(player.mo, player.mo.angle, 0)
					else
						if (player.powers[pw_super] or player.powers[pw_sneakers])
							if (player.speed < 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
							elseif (player.speed >= 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers])
							if (player.speed < 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
							elseif (player.speed >= 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						end
					end
				end
				if (player.mo.state != S_PLAY_FLY_TIRED)
					if (player.cmd.buttons & BT_JUMP)
						player.fly1 = 1
					else
						player.fly1 = 0
					end
				end
				if (player.powers[pw_tailsfly] > 3*TICRATE and not (player.powers[pw_super]))
					player.powers[pw_tailsfly] = 3*TICRATE
				end
			end
		end
		if (player.mo.skin == "knuckles")
			if player.momentumplusglidelast == nil
				player.momentumplusglidelast = 0
			end
			local gliding = player.pflags & PF_GLIDING
			local thokked = player.pflags & PF_THOKKED
			local exitglide = (player.momentumplusglidelast == 1 and not (gliding) and thokked)
			local landglide = (player.momentumplusglidelast == 2 and not (gliding|thokked))
			if ((exitglide or landglide) and (player.mo.state == S_PLAY_SPRING or player.mo.state == S_PLAY_FALL or player.mo.state == S_PLAY_GLIDE or player.mo.state == S_PLAY_SWIM or player.mo.state == S_PLAY_GLIDE_LANDING))
				player.mo.momx = $*2
				player.mo.momy = $*2
				if (exitglide)
					if (player.mo.state != S_PLAY_JUMP)
						player.mo.state = S_PLAY_JUMP
					end
					player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
					player.pflags = $ & ~(PF_NOJUMPDAMAGE|PF_GLIDING)
				end
			end
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_GLIDING)
				player.mo.state = S_PLAY_GLIDE_LANDING
				S_StartSound(player.mo, sfx_s3k4c)
				player.pflags = $ & ~PF_GLIDING
				player.skidtime = 0
			end
			if (gliding and (player.mo.state == S_PLAY_GLIDE or player.mo.state == S_PLAY_SWIM))
				if (player.mo.momz*P_MobjFlip(player.mo) < 0)
					if (player.powers[pw_super] or player.powers[pw_sneakers])
						P_Thrust(player.mo, player.mo.angle, 3*FRACUNIT/10)
					else
						P_Thrust(player.mo, player.mo.angle, FRACUNIT/4)
					end
				end
				if (player.cmd.buttons & BT_SPIN)
					player.mo.state = S_PLAY_JUMP
					player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
					player.pflags = $ & ~PF_GLIDING
					P_SpawnThokMobj(player)
					S_StartSound(player.mo, sfx_zoom)
					player.drawangle = player.mo.angle
					if (not (player.cmd.forwardmove) and not (player.cmd.sidemove))
						P_InstaThrust(player.mo, player.mo.angle, 0)
						P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
					else
						if (player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
							if (player.speed < 60*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
							elseif (player.speed >= 60*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
							if (player.speed < 36*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
							elseif (player.speed >= 36*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						elseif (player.powers[pw_super] or player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
							if (player.speed < 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
							elseif (player.speed >= 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
							if (player.speed < 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
							elseif (player.speed >= 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
							end
						end
						P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
					end
				end
			end
			if gliding
				player.momentumplusglidelast = 1
			elseif exitglide
				player.momentumplusglidelast = 2
			elseif not(gliding|thokked)
				player.momentumplusglidelast = 0
			end
		end
		if (player.mo.skin == "amy")
			if (player.powers[pw_super])
				player.thokitem = MT_LHRT
				player.revitem = MT_LHRT
			else
				player.thokitem = MT_NULL
				player.revitem = MT_NULL
			end
			if (player.mo.state == S_PLAY_JUMP)
				player.mo.state = S_PLAY_TWINSPIN
				player.powers[pw_strong] = STR_TWINSPIN
				player.mo.frame = 0
			end
			if (player.mo.state == S_PLAY_MELEE or player.mo.state == S_PLAY_MELEE_FINISH or player.mo.state == S_PLAY_TWINSPIN)
				if (player.mo.state == S_PLAY_TWINSPIN)
					player.powers[pw_strong] = STR_TWINSPIN
					if (player.realmo.frame&FF_FRAMEMASK == 5)
						player.mo.state = S_PLAY_TWINSPIN
						player.powers[pw_strong] = STR_TWINSPIN
						player.mo.frame = 0
					end
				end
				if (player.mo.state == S_PLAY_MELEE or player.mo.state == S_PLAY_MELEE_FINISH)
					player.charability2 = CA2_MELEE
					player.powers[pw_strong] = STR_MELEE
					if (player.mo.state == S_PLAY_MELEE_FINISH)
						player.mo.state = S_PLAY_MELEE
					end
				end
			else
				player.charability2 = CA2_NONE
			end
			if (player.cmd.buttons & BT_SPIN and not (player.plusbuttons & BT_SPIN) and (player.pflags & PF_JUMPED or player.pflags & PF_SPINNING or P_IsObjectOnGround(player.mo)) and player.mo.state != S_PLAY_MELEE and player.mo.state != S_PLAY_MELEE_FINISH and player.mo.state != S_PLAY_MELEE_LANDING)
				P_ResetPlayer(player)
				player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
				player.mo.state = S_PLAY_MELEE
				player.drawangle = player.mo.angle
				player.skidtime = 0
				S_StartSound(player.mo, sfx_s3k42)
				if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
					if (player.mo.eflags & MFE_UNDERWATER)
						P_SetObjectMomZ(player.mo, 585*player.mindash/1000, false)
					else
						P_SetObjectMomZ(player.mo, player.mindash, false)
					end
					if (P_MobjFlip(player.mo)*player.mo.pmomz < 0)
						player.mo.momz = $+player.mo.pmomz
					elseif (P_MobjFlip(player.mo)*player.mo.pmomz >= 0)
						player.mo.pmomz = 0
					end
				elseif (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR))
					if (not (player.cmd.forwardmove) and not (player.cmd.sidemove))
						P_InstaThrust(player.mo, player.mo.angle, 0)
						P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
					else
						P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
					end
				end
				if (player.cmd.forwardmove or player.cmd.sidemove)
					if (player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
						if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
							if (player.speed < 29*(60*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
							elseif (player.speed >= 29*(60*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						else
							if (player.speed < 60*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
							elseif (player.speed >= 60*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						end
					elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
						if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
							if (player.speed < 29*(36*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
							elseif (player.speed >= 29*(36*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						else
							if (player.speed < 36*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
							elseif (player.speed >= 36*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						end
					elseif (player.powers[pw_super] or player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
						if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
							if (player.speed < 29*(30*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
							elseif (player.speed >= 29*(30*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						else
							if (player.speed < 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
							elseif (player.speed >= 30*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						end
					elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
						if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
							if (player.speed < 29*(18*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
							elseif (player.speed >= 29*(18*FRACUNIT)/32)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						else
							if (player.speed < 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
							elseif (player.speed >= 18*FRACUNIT)
								P_InstaThrust(player.mo, player.mo.angle, actualSpeed+(6*FRACUNIT))
							end
						end
					end
				elseif (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR))
					P_InstaThrust(player.mo, player.mo.angle, 0)
				end
			end
			if (player.mo.state == S_PLAY_MELEE_LANDING or (player.mo.state == S_PLAY_MELEE and player.mo.eflags & MFE_JUSTHITFLOOR) or (player.mo.state == S_PLAY_MELEE_FINISH and player.mo.eflags & MFE_JUSTHITFLOOR))
				if (player.cmd.buttons & BT_SPIN and not (player.cmd.buttons & BT_JUMP) and player.speed > 5*FRACUNIT)
					player.mo.state = S_PLAY_ROLL
					player.pflags = $|PF_SPINNING|PF_THOKKED
					player.pflags = $ & ~PF_JUMPED
					S_StartSound(player.mo, sfx_spin)
				elseif (player.cmd.buttons & BT_JUMP)
					P_DoJump(player, false)
					player.mo.state = S_PLAY_TWINSPIN
					player.powers[pw_strong] = STR_TWINSPIN
					player.pflags = $|PF_JUMPED
					player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
					S_StartSound(player.mo, sfx_jump)
					player.mo.frame = 0
				else
					if (player.speed == 0)
						player.mo.state = S_PLAY_STND
					elseif (player.speed > 0 and player.speed < player.runspeed)
						player.mo.state = S_PLAY_WALK
					elseif (player.speed >= player.runspeed)
						player.mo.state = S_PLAY_RUN
					end
					player.pflags = $ & ~(PF_SPINNING|PF_JUMPED|PF_THOKKED)
				end
			end
		end
		if (player.mo.skin == "fang")
			local fanglockon = P_LookForEnemies(player, false, true)
			local fangbullet = nil
			local fangbomb = nil
			if (fanglockon and fanglockon.valid)
				P_SpawnLockOn(player, fanglockon, mobjinfo[MT_LOCKON].spawnstate)
			end
			if player.momentumplusbouncelast == nil
				player.momentumplusbouncelast = false
			end
			if ((player.pflags & PF_BOUNCING and not (player.momentumplusbouncelast)) or (not (player.pflags & PF_BOUNCING) and player.momentumplusbouncelast) and (player.mo.state == S_PLAY_BOUNCE or player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_ROLL or player.mo.state == S_PLAY_SPRING or player.mo.state == S_PLAY_FALL))
				player.mo.momx = $*2
				player.mo.momy = $*2
				if (player.mo.momz*P_MobjFlip(player.mo) < 0)
					player.mo.momz = $*2
				end
				if (not (player.pflags & PF_BOUNCING) and player.momentumplusbouncelast and player.mo.state != S_PLAY_ROLL)
					player.mo.state = S_PLAY_ROLL
					player.pflags = $|PF_JUMPED|PF_THOKKED
					player.pflags = $ & ~(PF_SPINNING|PF_BOUNCING)
				end
			end
			if (player.cmd.buttons & BT_SPIN and not (player.plusbuttons & BT_SPIN) and not (player.weapondelay) and (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR or player.pflags & PF_JUMPED or player.pflags & PF_BOUNCING or (player.pflags & PF_SPINNING and P_IsObjectOnGround(player.mo))) and player.mo.state != S_PLAY_FIRE and player.mo.state != S_PLAY_FIRE_FINISH and not (player.pflags & PF_JUMPED and player.pflags & PF_THOKKED and player.mo.state == S_PLAY_ROLL))
				player.mo.state = S_PLAY_FIRE
				player.pflags = $ & ~(PF_SPINNING|PF_JUMPED|PF_THOKKED|PF_BOUNCING)
				player.pflags = $|PF_JUMPDOWN
				if (player.powers[pw_super])
					player.weapondelay = 6
				else
					player.weapondelay = TICRATE/2
				end
				if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.mo.momz*P_MobjFlip(player.mo) > 0)
					player.mo.momz = $/2
				end
				if (fanglockon and fanglockon.valid)
					player.mo.angle = R_PointToAngle2(player.mo.x, player.mo.y, fanglockon.x, fanglockon.y)
					player.drawangle = R_PointToAngle2(player.mo.x, player.mo.y, fanglockon.x, fanglockon.y)
					fangbullet = P_SpawnPointMissile(player.mo, fanglockon.x, fanglockon.y, fanglockon.z, player.revitem, player.mo.x, player.mo.y, player.mo.z)
				end
				if not (fanglockon and fanglockon.valid)
					fangbullet = P_SpawnPointMissile(player.mo, player.mo.x + P_ReturnThrustX(nil, player.mo.angle, FRACUNIT), player.mo.y + P_ReturnThrustY(nil, player.mo.angle, FRACUNIT), player.mo.z, player.revitem, player.mo.x, player.mo.y, player.mo.z)
					player.drawangle = player.mo.angle
				end
			end
			if (player.mo.state == S_PLAY_FIRE or player.mo.state == S_PLAY_FIRE_FINISH)
				if (player.weapondelay)
					player.charflags = $|SF_NOSKID
					player.pflags = $ & ~(PF_SPINNING|PF_JUMPED|PF_THOKKED|PF_BOUNCING)
					player.pflags = $|PF_JUMPDOWN
				elseif not (player.weapondelay)
					if (P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR)
						if ((player.cmd.buttons & BT_SPIN or player.plusbuttons & BT_SPIN) and player.speed > FixedMul(5<<FRACBITS, player.mo.scale)) and not (player.cmd.buttons & BT_JUMP or player.plusbuttons & BT_JUMP)
							player.mo.state = S_PLAY_ROLL
							player.pflags = $|PF_SPINNING|PF_THOKKED
							S_StartSound(player.mo, sfx_spin)
						elseif (player.cmd.buttons & BT_JUMP or player.plusbuttons & BT_JUMP)
							P_DoJump(player, false)
							player.mo.state = S_PLAY_ROLL
							player.pflags = $|PF_JUMPED
							player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
							S_StartSound(player.mo, sfx_jump)
						else
							if (player.speed == 0)
								player.mo.state = S_PLAY_STND
							elseif (player.speed > 0 and player.speed < player.runspeed)
								player.mo.state = S_PLAY_WALK
							elseif (player.speed >= player.runspeed)
								player.mo.state = S_PLAY_RUN
							end
							player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
						end
					elseif (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR))
						player.mo.state = S_PLAY_ROLL
						player.pflags = $|PF_JUMPED|PF_THOKKED
						player.pflags = $ & ~PF_SPINNING
					end
				end
			else
				player.charflags = $ & ~SF_NOSKID
			end
			if ((player.mo.state == S_PLAY_BOUNCE_LANDING or ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and (player.pflags & PF_BOUNCING or player.momentumplusbouncelast))))
				player.pflags = $|PF_JUMPDOWN
				player.drawangle = player.mo.angle
				if not (player.weapondelay)
					fangbomb = P_SpawnMobjFromMobj(player.mo,5*FRACUNIT,5*FRACUNIT,player.mo.height+5*FRACUNIT,MT_FBOMB)
					fangbomb.target = player.mo
					fangbomb.momz = 10*FRACUNIT
					player.weapondelay = 6
					S_StartSound(player.mo, sfx_s3k51)
				end
				if (player.cmd.forwardmove or player.cmd.sidemove)
					if (player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
						if (player.speed < 60*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
						elseif (player.speed >= 60*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
						end
					elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
						if (player.speed < 36*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
						elseif (player.speed >= 36*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
						end
					elseif (player.powers[pw_super] or player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
						if (player.speed < 30*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
						elseif (player.speed >= 30*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
						end
					elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
						if (player.speed < 18*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
						elseif (player.speed >= 18*FRACUNIT)
							P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
						end
					end
				else
					P_InstaThrust(player.mo, player.mo.angle, 0)
				end
			end
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_SPINNING)
				player.pflags = $|PF_JUMPDOWN
				if (player.cmd.buttons & BT_JUMP and not (player.plusbuttons & BT_JUMP))
					P_DoJump(player, false)
					player.mo.state = S_PLAY_ROLL
					player.pflags = $|PF_JUMPED
					player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
					S_StartSound(player.mo, sfx_jump)
				end
			end
		end
		if (((player.mo.skin == "espio" and (player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_ROLL or player.mo.state == S_ESPIO_ROLL)) or (player.mo.skin == "surge" and (player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_ROLL))) and not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_JUMPED and player.pflags & PF_THOKKED and not (player.pflags & PF_SHIELDABILITY))
			if (player.mo.state != S_PLAY_JUMP)
				player.mo.state = S_PLAY_JUMP
			end
			player.pflags = $|PF_SPINNING
		end
		if (player.mo.skin == "mighty" and not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_JUMPED and player.pflags & PF_THOKKED and not (player.pflags & PF_SPINNING)and not (player.pflags & PF_SHIELDABILITY) and player.mo.state == S_PLAY_ROLL)
			player.mo.state = S_PLAY_JUMP
			player.pflags = $ | PF_JUMPED
			player.pflags = $ & ~(PF_SPINNING|PF_THOKKED)
			player.drawangle = player.mo.angle
			if (player.cmd.forwardmove or player.cmd.sidemove)
				if (player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
					if (player.speed < 60*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
					elseif (player.speed >= 60*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
					end
				elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
					if (player.speed < 36*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
					elseif (player.speed >= 36*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
					end
				elseif (player.powers[pw_super] or player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
					if (player.speed < 30*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
					elseif (player.speed >= 30*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
					end
				elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
					if (player.speed < 18*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
					elseif (player.speed >= 18*FRACUNIT)
						P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
					end
				end
			else
				P_InstaThrust(player.mo, player.mo.angle, 0)
			end
		end
		if (player.mo.skin == "vector")
			if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_THOKKED and (player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_SPRING or player.mo.state == S_PLAY_FALL or player.mo.state == S_PLAY_ROLL) and not (player.pflags & PF_SHIELDABILITY) and not (player.pflags & PF_SPINNING))
				if (player.mo.state != S_PLAY_JUMP)
					player.mo.state = S_PLAY_JUMP
				end
				player.pflags = $|PF_SPINNING
			end
			if (player.mo.state == S_VECTOR_BEATBASH and player.cmd.buttons & BT_SPIN)
				player.mo.state = S_PLAY_JUMP
				player.pflags = $|PF_JUMPED|PF_SPINNING|PF_THOKKED
				P_SpawnThokMobj(player)
				S_StartSound(player.mo, sfx_zoom)
				player.drawangle = player.mo.angle
				if (not (player.cmd.forwardmove) and not (player.cmd.sidemove))
					P_InstaThrust(player.mo, player.mo.angle, 0)
					P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
				else
					P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
					P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
				end
			end
		end
		if (player.mo.skin == "heavy" and (player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH) and player.mo.heavyvars.tics > 3)
			player.mo.heavyvars.tics = 3
		end
		if (player.mo.skin == "bomb")
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and (player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH))
				player.pflags = $|PF_JUMPDOWN|PF_SPINNING|PF_THOKKED
				if (player.speed >= 5*FRACUNIT and not (player.pflags & PF_STARTDASH and player.mo.state == S_PLAY_SPINDASH))
					if (player.powers[pw_super] or player.powers[pw_sneakers])
						P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(3*FRACUNIT/10))
					else
						P_Thrust(player.mo, R_PointToAngle2(0, 0, player.rmomx, player.rmomy), -(FRACUNIT/4))
					end
				end
				if (player.cmd.buttons & BT_JUMP and not (player.plusbuttons & BT_JUMP))
					P_DoJump(player, false)
					S_StartSound(player.mo, sfx_jump)
					if (player.speed >= 18*FRACUNIT and not (player.pflags & PF_STARTDASH))
						player.mo.state = S_BOMB_TOPSPIN_FAST
						player.mo.tics = min(2, $)
					elseif (player.speed <= 12*FRACUNIT and not (player.pflags & PF_STARTDASH))
						player.mo.state = S_BOMB_TOPSPIN
						if (player.speed <= 12*FRACUNIT)
							player.mo.tics = 1
						end
					elseif (player.pflags & PF_STARTDASH)
						player.mo.state = S_PLAY_SPINDASH
					end
					player.pflags = $|PF_JUMPED
					player.pflags = $ & ~(PF_SPINNING|PF_THOKKED|PF_NOJUMPDAMAGE)
				end
			end
			if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and (player.pflags & PF_SPINNING or player.pflags & PF_STARTDASH))
				player.mo.bomb_thokked = 2 ^ 1
			end
		end
		if (player.mo.skin == "ray" and not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_THOKKED and (player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_ROLL) and not (player.pflags & PF_SHIELDABILITY))
			if (player.mo.state != S_PLAY_JUMP)
				player.mo.state = S_PLAY_JUMP
			end
			player.pflags = $|PF_SPINNING
		end
		if (player.mo.skin == "shadow")
			if ((P_IsObjectOnGround(player.mo) or player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_SPINNING and player.mo.state != S_PLAY_ROLL and player.mo.state != S_PLAY_SPINDASH)
				player.mo.state = S_PLAY_ROLL
			end
			if (not (P_IsObjectOnGround(player.mo)) and not (player.mo.eflags & MFE_JUSTHITFLOOR) and player.pflags & PF_JUMPED and player.pflags & PF_THOKKED and (player.mo.state == S_PLAY_JUMP or player.mo.state == S_PLAY_ROLL) and not (player.pflags & PF_SHIELDABILITY))
				player.pflags = $|PF_SPINNING
			end
		end
		if (player.mo.skin == "surge" and player.mo.state == S_PLAY_ROLL and player.pflags & PF_JUMPED)
			player.mo.state = S_PLAY_JUMP
		end
	end
	player.momentumplusbouncelast = (player.pflags & PF_BOUNCING > 0)
	player.plusbuttons = player.cmd.buttons
end)
addHook("AbilitySpecial", function(player)
if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
local actualSpeed = FixedDiv(FixedHypot(player.cmomx - player.mo.momx, player.cmomy - player.mo.momy), player.mo.scale)
	if ((player.mo.skin == "sonic" or player.mo.skin == "metalsonic") and not (player.pflags & PF_THOKKED))
		if (player.mo.state != S_PLAY_JUMP)
			player.mo.state = S_PLAY_JUMP
		end
		player.drawangle = player.mo.angle
		if (player.dashmode < 3*TICRATE and player.mo.skin == "metalsonic")
			if not (maptol & TOL_NIGHTS)
				player.dashmode = 3*TICRATE
				S_StartSound(player.mo, sfx_kc4d)
			end
		end
		if (player.cmd.forwardmove or player.cmd.sidemove)
			P_InstaThrust(player.mo, player.mo.angle, player.actionspd)
		else
			P_InstaThrust(player.mo, player.mo.angle, 0)
		end
		S_StartSound(player.mo, sfx_thok)
		P_SpawnThokMobj(player)
		if (player.cmd.buttons & BT_SPIN)
			player.pflags = $|PF_SPINNING|PF_THOKKED
			player.pflags = $ & ~(PF_STARTJUMP)
			P_SetObjectMomZ(player.mo, -(24*FRACUNIT), false)
		else
			if (player.mo.eflags & MFE_UNDERWATER)
				if (player.powers[pw_super] and not (player.charflags & SF_NOSUPERJUMPBOOST))
					P_SetObjectMomZ(player.mo, FixedMul(13*FRACUNIT, FixedDiv(117*FRACUNIT, 200*FRACUNIT)), false)
				elseif (maptol & TOL_NIGHTS)
					P_SetObjectMomZ(player.mo, FixedMul(18*FRACUNIT, FixedDiv(117*FRACUNIT, 200*FRACUNIT)), false)
				else
					P_SetObjectMomZ(player.mo, FixedMul(39*FRACUNIT/4, FixedDiv(117*FRACUNIT, 200*FRACUNIT)), false)
				end
			else
				if (player.powers[pw_super] and not (player.charflags & SF_NOSUPERJUMPBOOST))
					P_SetObjectMomZ(player.mo, 13*FRACUNIT, false)
				elseif (maptol & TOL_NIGHTS)
					P_SetObjectMomZ(player.mo, 18*FRACUNIT, false)
				else
					P_SetObjectMomZ(player.mo, 39*FRACUNIT/4, false)
				end
			end
			player.pflags = $|PF_SPINNING|PF_THOKKED|PF_STARTJUMP
		end
	end
	if (player.mo.skin == "tails" and (player.mo.state == S_PLAY_FLY or player.mo.state == S_PLAY_SWIM) and player.speed > FixedMul(8*FRACUNIT, player.mo.scale) and player.speed > FixedMul(player.normalspeed/2, player.mo.scale))
		P_Thrust(player.mo, R_PointToAngle2(0,0,player.mo.momx,player.mo.momy), FixedMul(4*FRACUNIT, player.mo.scale))
	end
	if (player.mo.skin == "knuckles" and not (player.pflags & PF_THOKKED))
		player.drawangle = player.mo.angle
		if (player.powers[pw_super] or player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
			if (player.speed < 60*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, 60*FRACUNIT)
			elseif (player.speed >= 60*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
			end
		elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and not (player.mo.eflags & MFE_UNDERWATER)
			if (player.speed < 36*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, 36*FRACUNIT)
			elseif (player.speed >= 36*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
			end
		elseif (player.powers[pw_super] or player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
			if (player.speed < 30*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, 30*FRACUNIT)
			elseif (player.speed >= 30*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
			end
		elseif not (player.powers[pw_super]) and not (player.powers[pw_sneakers]) and (player.mo.eflags & MFE_UNDERWATER)
			if (player.speed < 18*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, 18*FRACUNIT)
			elseif (player.speed >= 18*FRACUNIT)
				P_InstaThrust(player.mo, player.mo.angle, actualSpeed)
			end
		end
	end
end)
-- Repurposed Spam Dash Code by Starlight
addHook("SpinSpecial", function(player)
if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
local actualSpeed = FixedDiv(FixedHypot(player.cmomx - player.mo.momx, player.cmomy - player.mo.momy), player.mo.scale)
	if ((player.mo.skin == "sonic" or player.mo.skin == "tails" or player.mo.skin == "knuckles" or player.mo.skin == "metalsonic" or player.mo.skin == "espio" or (player.mo.skin == "bomb" and not (player.mo.bomb_volatile)) or player.mo.skin == "mighty" or player.mo.skin == "ray" or player.mo.skin == "shadow" or player.mo.skin == "surge" or player.mo.skin == "trip") and player.playerstate == PST_LIVE and not (player.powers[pw_carry]))
		if (player.speed > 5*FRACUNIT and player.pflags & PF_STARTDASH) then return true end
		if (P_IsObjectOnGround(player.mo) and player.pflags & PF_SPINNING and not (player.pflags & (PF_SPINDOWN|PF_STARTDASH))) then
			if (player.speed == 0)
				player.mo.state = S_PLAY_STND
			elseif (player.speed > 0 and player.speed < player.runspeed)
				player.mo.state = S_PLAY_WALK
			elseif (player.speed >= player.runspeed)
				player.mo.state = S_PLAY_RUN
			end
			player.pflags = $ & ~PF_SPINNING
			player.pflags = $|PF_SPINDOWN
			return true
		end
	end
end)
addHook("MobjDamage", function(enemy, mo, source)
if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
	if ((mo and mo.valid) and not (P_IsObjectOnGround(mo)) and not (mo.eflags & MFE_JUSTHITFLOOR) and (mo.skin == "sonic" or mo.skin == "tails" or mo.skin == "knuckles" or mo.skin == "amy" or mo.skin == "fang" or mo.skin == "metalsonic" or mo.skin == "espio" or mo.skin == "mighty" or (mo.skin == "vector" and (mo.player.pflags & PF_SHIELDABILITY or mo.player.pflags & PF_SPINNING)) or mo.skin == "ray" or mo.skin == "shadow" or mo.skin == "tangle" or mo.skin == "whisper" or mo.skin == "surge" or mo.skin == "trip"))
		if ((enemy and enemy.valid) and (mo.state == S_PLAY_JUMP or mo.state == S_PLAY_SPRING or mo.state == S_PLAY_FALL or mo.state == S_PLAY_TWINSPIN or mo.state == S_PLAY_ROLL or (mo.skin == "espio" and mo.state == S_ESPIO_ROLL)))
			mo.player.pflags = $ & ~(PF_THOKKED|PF_SPINNING|PF_SHIELDABILITY)
			mo.player.pflags = $ | PF_JUMPED
		end
	end
end)
addHook("MobjDeath", function(enemy, mo, source)
if PTSR.gamemode ~= PTSR.gm_ptkidmode then return end
	if ((mo and mo.valid) and not (P_IsObjectOnGround(mo)) and not (mo.eflags & MFE_JUSTHITFLOOR) and (mo.skin == "sonic" or mo.skin == "tails" or mo.skin == "knuckles" or mo.skin == "amy" or mo.skin == "fang" or mo.skin == "metalsonic" or mo.skin == "espio" or mo.skin == "mighty" or (mo.skin == "vector" and (mo.player.pflags & PF_SHIELDABILITY or mo.player.pflags & PF_SPINNING)) or mo.skin == "ray" or mo.skin == "shadow" or mo.skin == "tangle" or mo.skin == "whisper" or mo.skin == "surge" or mo.skin == "trip"))
		if ((enemy and enemy.valid) and (mo.state == S_PLAY_JUMP or mo.state == S_PLAY_SPRING or mo.state == S_PLAY_FALL or mo.state == S_PLAY_TWINSPIN or mo.state == S_PLAY_ROLL or (mo.skin == "espio" and mo.state == S_ESPIO_ROLL)))
			mo.player.pflags = $ & ~(PF_THOKKED|PF_SPINNING|PF_SHIELDABILITY)
			mo.player.pflags = $ | PF_JUMPED
		end
	end
end)