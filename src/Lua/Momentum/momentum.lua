--[[
	
]]

local momblacklist = {
	["adventuresonic"] = true -- slope influence stacks and doubles soo yea
}

local function getFriction(player)
	return player.mo.friction
end

-- This function calculates the new player.normalspeed to be applied.
local function get3dTopSpeed(player)
	local friction = getFriction(player)

	local momx = FixedDiv(player.rmomx, friction)
	local momy = FixedDiv(player.rmomy, friction)

	local topspeed = R_PointToDist2(0, 0, momx, momy)

	if player.powers[pw_sneakers] or player.powers[pw_super] then
		topspeed = 3*$/5
	end
	if player.powers[pw_tailsfly]
	or player.mo.eflags & MFE_UNDERWATER or player.mo.eflags & MFE_GOOWATER then
		topspeed = $<<1
	end

	return FixedDiv(topspeed, player.mo.scale)
end

-- Also this one, except for 2D sections
local function get2dTopSpeed(player)
	local friction = getFriction(player)

	local momx = player.rmomx
	momx = FixedDiv($, friction)
	local topspeed = abs(momx)

	if maptol & TOL_2D then
		topspeed = FixedDiv($, 2*FRACUNIT/3)
	end

	if player.powers[pw_sneakers] or player.powers[pw_super] then
		if not (player.powers[pw_tailsfly])
		and not (player.mo.eflags & (MFE_UNDERWATER|MFE_GOOWATER) and not (player.pflags & PF_SLIDING)) then
			topspeed = $ / 2
		end
	else
		if (player.powers[pw_tailsfly])
		or (player.mo.eflags & (MFE_UNDERWATER|MFE_GOOWATER) and not (player.pflags & PF_SLIDING)) then
			topspeed = $ * 2
		end
	end

	return FixedDiv(topspeed, player.mo.scale)
end

local function doMomentum(player)
	local normalspeed = player.vphysnspeed
	local topspeed
	if twodlevel or player.mo.flags2 & MF2_TWOD then
		topspeed = get2dTopSpeed(player)
	else
		topspeed = get3dTopSpeed(player)
	end
	if player.mo.eflags & MFE_JUSTHITFLOOR then
		topspeed = FixedMul($, getFriction(player))
	end

	player.normalspeed = max(topspeed, normalspeed)
	player.vphyslasttop = player.normalspeed
end


addHook("PreThinkFrame", function()
	for player in players.iterate do
		if not (player and player.valid and player.mo and player.mo.valid) then
			continue
		end

		if not player.isxmomentum then
			if player.xmlastskin and player.xmlastskin ~= player.mo.skin then
				player.hasnomomentum = false
			end
			player.xmlastskin = player.mo.skin
		end

		if P_IsObjectOnGround(player.mo) and not (player.pflags & PF_SLIDING) and not P_PlayerInPain(player) and not (player.pflags & PF_SPINNING)
		and not (player.hasnomomentum or player.isxmomentum) and not momblacklist[player.mo.skin] then
			-- ok so, if this is the case, then either a mod has changed the normal speed or srb2 reset it
			-- in either case we should take it and use it as our top speed.
			if player.vphysnspeed ~= player.normalspeed and player.vphyslasttop ~= player.normalspeed then
				player.vphysnspeed = player.normalspeed
			end

			doMomentum(player)

		elseif player.vphysnspeed then
			player.normalspeed = player.vphysnspeed
			player.vphysnspeed = nil
			player.vphyslasttop = nil
		end
	end
end)

-- ok so. this thing, makes sure that the player does not accelerate past their top speed in 2D sections.
-- SRB2 already does this, but not when you're in 2D mode.
-- this fixes infinite acceleration!
local function TWODFIX(player)
	local thrustfactor, acceleration, topspeed, movepushforward
	--local friction = getFriction(player)
	local normalspd = player.normalspeed
	local result = 0
	local rmomx = player.vphyslastrmomx or player.rmomx
	local speed = abs(rmomx)
	// Set the player speeds.
	if maptol & TOL_2D then
		normalspd = FixedMul(normalspd, 2*FRACUNIT/3)
	end

	if player.powers[pw_super] or player.powers[pw_sneakers] then
		thrustfactor = player.thrustfactor*2
		acceleration = player.accelstart/2 + (FixedDiv(speed, player.mo.scale)>>FRACBITS) * player.acceleration/2

		if player.powers[pw_tailsfly] then
			topspeed = normalspd
		elseif player.mo.eflags & (MFE_UNDERWATER|MFE_GOOWATER) and not (player.pflags & PF_SLIDING) then
			topspeed = normalspd
			acceleration = 2*acceleration/3
		else
			topspeed = normalspd * 2
		end
	else
		thrustfactor = player.thrustfactor
		acceleration = player.accelstart + (FixedDiv(speed, player.mo.scale)>>FRACBITS) * player.acceleration

		if player.powers[pw_tailsfly] then
			topspeed = normalspd/2
		elseif player.mo.eflags & (MFE_UNDERWATER|MFE_GOOWATER) and not (player.pflags & PF_SLIDING) then
			topspeed = normalspd/2
			acceleration = 2*acceleration/3
		else
			topspeed = normalspd
		end
	end

	if not player.climbing and (player.cmd.sidemove ~= 0 and not (player.pflags & PF_GLIDING or player.exiting
	or (P_PlayerInPain(player) and not P_IsObjectOnGround(player.mo)))) then

		movepushforward = abs(player.cmd.sidemove) * (thrustfactor * acceleration)

		movepushforward = FixedMul(movepushforward, player.mo.scale)
		if rmomx < topspeed and player.cmd.sidemove > 0 then // Sonic's Speed
			result = movepushforward
		elseif rmomx > -topspeed and player.cmd.sidemove < 0 then
			result = -movepushforward
		end
	end

	if not movepushforward then
		return
	end
	
	player.mo.momx = $ - result
	
	topspeed = FixedMul($, player.mo.scale)
	local nmove = rmomx
	if abs(nmove) < topspeed then
		nmove = $ + (player.cmd.sidemove and player.cmd.sidemove/abs(player.cmd.sidemove) or 0) * movepushforward
		if abs(nmove) > topspeed then
			nmove = ($/abs($))*topspeed
		end
	end

	player.mo.momx = $ + nmove-rmomx
	player.rmomx = player.mo.momx-player.cmomx
end

addHook("PlayerThink", function(player)
	if player.mo and player.mo.valid then
		if twodlevel or player.mo.flags2 & MF2_TWOD
		and P_IsObjectOnGround(player.mo) and not (player.pflags & PF_SLIDING) and not P_PlayerInPain(player) and not (player.pflags & PF_SPINNING)
		and not (player.hasnomomentum or player.isxmomentum) then
			player.vphyslastrmomx = player.rmomx
		else
			player.vphyslastrmomx = nil
		end
	end
end)

addHook("ThinkFrame", function()
	for player in players.iterate() do
		if player.mo and player.mo.valid then
			if twodlevel or player.mo.flags2 & MF2_TWOD
			and P_IsObjectOnGround(player.mo) and not (player.pflags & PF_SLIDING) and not P_PlayerInPain(player) and not (player.pflags & PF_SPINNING)
			and not (player.hasnomomentum or player.isxmomentum) then
				TWODFIX(player)
			end
		end
	end
end)