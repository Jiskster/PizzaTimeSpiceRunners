-- pff ok so this is funny
-- basically i saw that i had translated all of the slope physics functions to Lua
-- so like. i decided to add them to ceiling slopes xd
-- um. yeah obviously maybe using reverse gravity wouldve been better for like. ceiling running.
-- but um. yeah having ceiling slope physics in a non-intrusive way is nice!

local function FV3_Rotate(rotVec, axisVec, angle)
	// Rotate the point (x,y,z) around the vector (u,v,w)
	local ux,uy,uz = FixedMul(axisVec.x, rotVec.x), FixedMul(axisVec.x, rotVec.y), FixedMul(axisVec.x, rotVec.z)
	local vx,vy,vz = FixedMul(axisVec.y, rotVec.x), FixedMul(axisVec.y, rotVec.y), FixedMul(axisVec.y, rotVec.z)
	local wx,wy,wz = FixedMul(axisVec.z, rotVec.x), FixedMul(axisVec.z, rotVec.y), FixedMul(axisVec.z, rotVec.z)
	local sa = sin(angle)
	local ca = cos(angle)
	local ua = ux+vy+wz
	local ax,ay,az = FixedMul(axisVec.x,ua), FixedMul(axisVec.y,ua), FixedMul(axisVec.z,ua)
	local xs,ys,zs = FixedMul(axisVec.x,axisVec.x), FixedMul(axisVec.y,axisVec.y), FixedMul(axisVec.z,axisVec.z)
	local bx,by,bz = FixedMul(rotVec.x,ys+zs), FixedMul(rotVec.y,xs+zs), FixedMul(rotVec.z,xs+ys)
	local cx,cy,cz = FixedMul(axisVec.x,vy+wz), FixedMul(axisVec.y,ux+wz), FixedMul(axisVec.z,ux+vy)
	local dx,dy,dz = FixedMul(bx-cx, ca), FixedMul(by-cy, ca), FixedMul(bz-cz, ca)
	local ex,ey,ez = FixedMul(vz-wy, sa), FixedMul(wx-uz, sa), FixedMul(uy-vx, sa)

	rotVec.x, rotVec.y, rotVec.z = ax+dx+ex, ay+dy+ey, az+dz+ez
end

//
// P_QuantizeMomentumToSlope
//
// When given a vector, rotates it and aligns it to a slope
local function P_QuantizeMomentumToSlope(momentum, slope, reverse)
	local axis = {} // Fuck you, C90.

	if slope.flags & SL_NOPHYSICS then
		return // No physics, no quantizing.
    end

	axis.x = -slope.d.y
	axis.y = slope.d.x
	axis.z = 0

    local zangle = slope.zangle
    if reverse then zangle = InvAngle($) end
	FV3_Rotate(momentum, axis, zangle)
end

//
// P_SlopeLaunch
//
// Handles slope ejection for objects
local function P_CeilingSlopeLaunch(mo, slope)
	if not (slope.flags & SL_NOPHYSICS) // If there's physics, time for launching.
		and (slope.normal.x != 0
		or  slope.normal.y != 0) then
		// Double the pre-rotation Z, then halve the post-rotation Z. This reduces the
		// vertical launch given from slopes while increasing the horizontal launch
		// given. Good for SRB2's gravity and horizontal speeds.
		local slopemom = {}
		slopemom.x = mo.momx
		slopemom.y = mo.momy
		slopemom.z = mo.momz
		P_QuantizeMomentumToSlope(slopemom, slope)

		mo.momx = slopemom.x
		mo.momy = slopemom.y
		mo.momz = slopemom.z
	end
end

// Function to help handle landing on slopes
local function P_CeilingHandleSlopeLanding(thing, slope)
	local mom = {} // Ditto.
	if slope.flags & SL_NOPHYSICS or (slope.normal.x == 0 and slope.normal.y == 0) then // No physics, no need to make anything complicated.
		return
	end

	mom.x = thing.oldmom.x
	mom.y = thing.oldmom.y
	mom.z = thing.oldmom.z

	P_QuantizeMomentumToSlope(mom, slope, true)

    thing.momx = mom.x
    thing.momy = mom.y
end

//
// P_GetWallTransferMomZ
//
// It would be nice to have a single function that does everything necessary for slope-to-wall transfer.
// However, it needs to be seperated out in P_XYMovement to take into account momentum before and after hitting the wall.
// This just performs the necessary calculations for getting the base vertical momentum; the horizontal is already reasonably calculated by P_SlideMove.
local function P_CeilingGetWallTransferMomZ(mo, slope)
	local slopemom = {}
	local axis = {}

	if slope.flags & SL_NOPHYSICS then
		return 0
    end

	// If there's physics, time for launching.
	// Doesn't kill the vertical momentum as much as P_SlopeLaunch does.
	local ang = slope.zangle + ANG15*((slope.zangle > 0) and 1 or -1)
	if ang > ANGLE_90 and ang < ANGLE_180 then
		ang = ((slope.zangle > 0) and ANGLE_90 or InvAngle(ANGLE_90)) // hard cap of directly upwards
    end

	slopemom.x = mo.oldmom.x
	slopemom.y = mo.oldmom.y
	slopemom.z = mo.oldmom.z

	axis.x = -slope.d.y
	axis.y = slope.d.x
	axis.z = 0

	FV3_Rotate(slopemom, axis, ang)

	local transfermomz = slopemom.z

	local relation // Scale transfer momentum based on how head-on it is to the slope.
	if mo.oldmom.x or mo.oldmom.y then // "Guess" the angle of the wall you hit using new momentum
		relation = slope.xydirection - R_PointToAngle2(0, 0, mo.oldmom.x, mo.oldmom.y) + ANGLE_90
	else // Give it for free, I guess.
		relation = ANGLE_90
	end
	transfermomz = FixedMul($, abs(sin(relation)))
	if P_MobjFlip(mo)*(transfermomz - mo.oldmom.z) < 2*FRACUNIT then // Do the actual launch!
		mo.momz = transfermomz
	end
end

// https://yourlogicalfallacyis.com/slippery-slope
// Handles sliding down slopes, like if they were made of butter :)
local function P_CeilingButteredSlope(mo, slope)
	local thrust

	if not slope then
		return
	end

	if slope.flags & SL_NOPHYSICS then
		return // No physics, no butter.
	end

	if mo.flags & (MF_NOCLIPHEIGHT|MF_NOGRAVITY) then
		return // don't slide down slopes if you can't touch them or you're not affected by gravity
	end

	if mo.player then
		if abs(slope.zdelta) < FRACUNIT/4 and not (mo.player.pflags & PF_SPINNING) then
			return // Don't slide on non-steep slopes unless spinning
		end

		if abs(slope.zdelta) < FRACUNIT/2 and not (mo.player.rmomx or mo.player.rmomy) then
			return // Allow the player to stand still on slopes below a certain steepness
		end
	end

	thrust = sin(slope.zangle) * 3 / 2 * (mo.eflags & MFE_VERTICALFLIP and 1 or -1)

	if mo.player and (mo.player.pflags & PF_SPINNING) then
		local mult = 0
		if mo.momx or mo.momy then
			local angle = R_PointToAngle2(0, 0, mo.momx, mo.momy) - slope.xydirection

			if -1*P_MobjFlip(mo) * slope.zdelta < 0 then
				angle = InvAngle($)
			end

			mult = cos(angle)
		end

		thrust = FixedMul(thrust, FRACUNIT*2/3 + mult/8)
	end

	if mo.momx or mo.momy then // Slightly increase thrust based on the object's speed
		thrust = FixedMul(thrust, FRACUNIT+P_AproxDistance(mo.momx, mo.momy)/16)
	end
	// This makes it harder to zigzag up steep slopes, as well as allows greater top speed when rolling down

	// Let's get the gravity strength for the object...
	thrust = FixedMul(thrust, abs(P_GetMobjGravity(mo)))

	// ... and its friction against the ground for good measure (divided by original friction to keep behaviour for normal slopes the same).
	thrust = FixedMul(thrust, FixedDiv(mo.friction, 29*FRACUNIT/32))

	P_Thrust(mo, slope.xydirection, thrust)
end

local function P_GetSlopeZAt(slope, x, y)
    local dist = FixedMul(x - slope.o.x, slope.d.x) +
                 FixedMul(y - slope.o.y, slope.d.y)

    return slope.o.z + FixedMul(dist, slope.zdelta)
end

-- Returns the height of the sector ceiling at (x, y)
local function P_GetSectorCeilingZAt(sector, x, y)
    return sector.c_slope and P_GetSlopeZAt(sector.c_slope, x, y) or sector.ceilingheight
end

-- Returns the height of the FOF bottom at (x, y)
local function P_GetFFloorBottomZAt(ffloor, x, y)
    return ffloor.b_slope and P_GetSlopeZAt(ffloor.b_slope, x, y) or ffloor.bottomheight
end

local function slopeFinder(mo)
	local sec = mo.subsector.sector
	local slope = sec.c_slope or nil
	local height = P_GetSectorCeilingZAt(sec, mo.x, mo.y)
	for fof in sec.ffloors() do
		local nheight = P_GetFFloorBottomZAt(fof, mo.x, mo.y)
		if mo.z < nheight and nheight < height then
			slope = fof.b_slope or nil
			height = nheight
		end
	end
	return slope, height
end

addHook("MobjMoveBlocked", function(mo, thing, line)
    if line and mo and mo.valid and mo.player then
        mo.player.hitwall = true
    end
end, MT_PLAYER)

local function stop(player)
    if player.ceilingslop then
        if player.hitwall then
            P_CeilingGetWallTransferMomZ(player.mo, player.ceilingslop)
        else
            P_CeilingSlopeLaunch(player.mo, player.ceilingslop)
        end
        player.ceilingslop = nil
    end
    player.stickceil = false
end

addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid) then return end
	
	player.mo.oldmom = $ or {}
	player.mo.oldmom.x = player.mo.momx
	player.mo.oldmom.y = player.mo.momy
	player.mo.oldmom.z = player.mo.momz
end)
addHook("ThinkFrame", function() 
	for player in players.iterate do
		if not (player.mo and player.mo.valid) then continue end
		
		if not (player.mo.eflags & MFE_VERTICALFLIP) then			
			if player.mo.z + player.mo.height >= player.mo.ceilingz then
				local slope = slopeFinder(player.mo)
				if slope then
					if not (player.ceilingslop and player.ceilingslop == slope) then
						player.ceilingslop = slope
						if not player.stickceil then
							P_CeilingHandleSlopeLanding(player.mo, slope)
						end
					end
					P_CeilingButteredSlope(player.mo, slope)
					player.stickceil = true
				end
				
				if R_PointToDist2(0,0, player.mo.momx, player.mo.momy) < 11*FU or player.hitwall then
					stop(player)
				end
				if not slope then player.ceilingslop = nil end

				if player.stickceil then
					player.mo.momz = 0
				end
			else
				stop(player)
			end

			player.hitwall = false
		end
	end 
end)