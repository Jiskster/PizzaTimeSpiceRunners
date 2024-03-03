local portal_time = 25 -- tics
local minspritescale = FRACUNIT/32
local maxspritescale = FRACUNIT

freeslot("MT_PIZZAPORTAL", "S_PIZZAPORTAL", "SPR_P3PT", "sfx_lapin", "sfx_lapout", "sfx_yuck34")

mobjinfo[MT_PIZZAPORTAL] = {
	--$Name "Pizza Portal"
    --$Sprite SPR_P3PT
    --$Category "Spice Runners"
	doomednum = 1417,
	spawnstate = S_PIZZAPORTAL,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 64*FU,
	height = 144*FU,
	flags = MF_SPECIAL|MF_NOCLIP|MF_NOGRAVITY
}

states[S_PIZZAPORTAL] = {
    sprite = SPR_P3PT,
    frame = A|FF_PAPERSPRITE|FF_FULLBRIGHT,
    tics = -1,
    nextstate = S_PIZZAPORTAL
}

local function cancelEspioTeleport(mobj)
	if chaotix then
		if mobj.espio_teleport then
			mobj.espio_teleport = false
			mobj.espio_teleport_state = nil
			mobj.state = S_PLAY_FALL
		end
	end
end

-- yay, placing portals without zone builder!
addHook("MapLoad", function(map)
	if mapheaderinfo[map].ptsr_maxportals and tonumber(mapheaderinfo[map].ptsr_maxportals) then
		local maxportals = tonumber(mapheaderinfo[map]["ptsr_maxportals"])
		for i=1, maxportals do
			local portal_x = mapheaderinfo[map]["ptsr_portal("..i..")_x"]
			local portal_y = mapheaderinfo[map]["ptsr_portal("..i..")_y"]
			local portal_z = mapheaderinfo[map]["ptsr_portal("..i..")_z"]

			local portal_angle = mapheaderinfo[map]["ptsr_portal("..i..")_angle"]

			if portal_x ~= nil and portal_y ~= nil and portal_z ~= nil
			and tonumber(portal_x) and tonumber(portal_y) and tonumber(portal_z) then
				local portal = P_SpawnMobj(portal_x*FU, portal_y*FU, portal_z*FU, MT_PIZZAPORTAL)

				-- give angle
				if portal_angle and tonumber(portal_angle) then
					portal.angle = FixedAngle(portal_angle*FRACUNIT) + ANGLE_90
				end
			else
				print("\x85\PTSR: Invalid Portal Parameters, ID: ["..i.."]")
			end
		end
	end
end)

addHook("TouchSpecial", function(special, toucher)
	local tplayer = toucher.player
	
	if PTSR_DoHook("onlap", toucher) == true then
		return
	end
	
	if toucher and toucher.valid and tplayer and tplayer.valid then
		local lastlap_perplayer = (tplayer.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value)
		if not toucher.pizza_in and not toucher.pizza_out and PTSR.pizzatime and not lastlap_perplayer then -- start lap portal in sequence
			toucher.pizza_in = portal_time
			S_StartSound(toucher, sfx_lapin)
			S_StartSound(special, sfx_yuck34)
		end
	end
	
	return true
end, MT_PIZZAPORTAL)

addHook("MobjThinker", function(mobj)
	local float_offset = sin(leveltime*FRACUNIT*500)*10
	mobj.spriteyoffset = float_offset
	
	if mobj.spawnpoint then
		mobj.angle = FixedAngle(mobj.spawnpoint.angle*FRACUNIT) + ANGLE_90 -- give me the right angle dumbass papersprite
	end
	
	if displayplayer and displayplayer.valid then
		if (displayplayer.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) or not PTSR.pizzatime then
			mobj.frame = $|FF_TRANS50
		else
			mobj.frame = $ & ~FF_TRANS50
		end
	end
end, MT_PIZZAPORTAL)

-- pizza portal enter animations
-- the easings are the opposites because the counter is going down, ex: out being in and in being out
addHook("MobjThinker", function(mobj)
	local player = mobj.player
	if player.spectator or player.pizzaface then return end
	
	if mobj.pizza_in then
		local hudst = player["PT@hudstuff"]
		local div = FixedDiv(mobj.pizza_in*FRACUNIT, portal_time*FRACUNIT)
		local ese = ease.outquint(div, minspritescale, maxspritescale)
		mobj.pizza_in = $ - 1

		mobj.spritexscale = ese
		mobj.spriteyscale = ese
		player.powers[pw_nocontrol] = 1
		
		L_SpeedCap(mobj, 0)
		
		cancelEspioTeleport(mobj)

		if not mobj.pizza_in then -- start lap portal out sequence
			mobj.pizza_out = portal_time
			
			
			PTSR.DoLapBonus(player)
			
			hudst.anim_active = true
			hudst.anim = 1
			
			PTSR.StartNewLap(mobj)
			
			local angle_frompotal = mapheaderinfo[gamemap].ptsr_lapangle 
			if angle_frompotal and tonumber(angle_frompotal) then
				mobj.angle = FixedAngle(tonumber(angle_frompotal)*FRACUNIT)
			end
			
			S_StartSound(mobj, sfx_lapout)
		end
	end
	
	if mobj.pizza_out then
		local div = FixedDiv(mobj.pizza_out*FRACUNIT, portal_time*FRACUNIT)
		local ese = ease.inquint(div, maxspritescale, minspritescale)
		mobj.pizza_out = $ - 1
		
		mobj.spritexscale = ese
		mobj.spriteyscale = ese
	end	
end, MT_PLAYER)

