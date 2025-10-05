-- https://mb.srb2.org/addons/classic-inspired-spindash.5596/
-- By Snu (On the Message Board)

-- constants
local SPINDASH_REVADD = FRACUNIT/4	-- max is always FRACUNIT
local SPINDASH_DIVISOR = FRACUNIT*32
local SPINDASH_MINDASHMULTIPLIER = FRACUNIT*4/3	-- top_speed is 6 and mininum rev is 8 in the classics, so...
local SPINDASH_MAXDASHMULTIPLIER = FRACUNIT*2	-- and the maximum dash is 12!
local SPINDASH_BOTMASHINITDELAY = TICRATE/8	-- for the first mash
local SPINDASH_BOTMASHDELAY = TICRATE/5	-- for subsequent mashes

-- function to stop ALL spindash rev sounds
local function stopRevSounds(mo)
	for sound = sfx_s3kab, sfx_s3kabf
		S_StopSoundByID(mo, sound)
	end
end

-- function to set mobj frame while keeping frameflags
local function setFrame(mo, frame, sprite, noflags)
	local frameflags = not (noflags) and (mo.frame & ~FF_FRAMEMASK) or 0
	-- ^ if noflags is checked, dont keep frameflags when setting the frame
	
	if (sprite)
		local spr = (mo.player) and "sprite2" or "sprite"	-- players use sprite2
		mo[spr] = sprite
	end
	mo.frame = frame|frameflags
end

-- main thinkframe for the spindash
addHook("ThinkFrame", function()
	for p in players.iterate do
		-- inputs
		local forward_input = (p.cmd.forwardmove > 16)
		if (p.pflags & PF_ANALOGMODE) then forward_input = (abs(p.cmd.forwardmove) > 16 or abs(p.cmd.sidemove) > 16) end	-- analog can use any direction
		p.classicspindash_forward = (forward_input) and ($ and $+1 or 1) or 0
		p.classicspindash_jump = (p.cmd.buttons & BT_JUMP) and ($ and $+1 or 1) or 0	-- i could use p.lastbuttons but it's an easy copypaste with this
		
		-- override PF_STARTDASH
		local mo = p.mo
		if not ((mo and mo.valid) and mo.health) then continue end
		
		if (p.pflags & PF_STARTDASH) then
			mo.classicspindash = true	-- if mods want to support this, this could be an easy identifier
			if (mo.classicspindash_rev == nil) then
				-- init the spindash rev value
				mo.classicspindash_rev = 0
				S_StartSound(mo, sfx_s3kab)
			else
				-- reduce rev value
				local spindash_reduce = FixedDiv(mo.classicspindash_rev, SPINDASH_DIVISOR)
				mo.classicspindash_rev = $ - spindash_reduce
			end
			
			-- mashing forward/jump increases the rev value
			if (p.classicspindash_forward == 1)
			or (p.classicspindash_jump == 1) then
				mo.classicspindash_rev = min(FRACUNIT, $ + SPINDASH_REVADD)
				setFrame(mo, A)	-- reset frame to A
				
				-- play sound
				stopRevSounds(mo)	-- stop previous sounds
				local spindash_sound = sfx_s3kab + ((mo.classicspindash_rev * 15) / FRACUNIT)
				S_StartSound(mo, spindash_sound)
			end
			
			-- re-calculate dashspeed based on rev
			local spindash_mindash = FixedMul(SPINDASH_MINDASHMULTIPLIER, skins[mo.skin].normalspeed)
			local spindash_maxdash = FixedMul(SPINDASH_MAXDASHMULTIPLIER, skins[mo.skin].normalspeed)
			
			local spindash_range = (spindash_maxdash - spindash_mindash)
			p.dashspeed = spindash_mindash + FixedMul(mo.classicspindash_rev, spindash_range)
			S_StopSoundByID(mo, sfx_spndsh)	-- prevent the vanilla spindash sound from playing (if only pitch shifting was a thing...)
			//print("rev: "..((mo.classicspindash_rev * 100) / FRACUNIT).."%")
		else
			-- reset values
			if (mo.classicspindash) then
				mo.classicspindash = nil
				stopRevSounds(mo)	-- stop the rev sounds again
			end
			mo.classicspindash_rev = nil
		end
	end
end)

-- prevent jumping during a spindash
addHook("JumpSpecial", function(p)
	-- spindash check
	if (p.pflags & PF_STARTDASH)
		return true
	end
end)

-- support for bots
addHook("BotTiccmd", function(bot, cmd)
	local p = players[0]
	if not (p and p.valid) then return end
	-- ^ paranoia
	
	-- making my life easier
	local mo = players[0].mo
	local bmo = bot.mo
	
	if (p.pflags & PF_STARTDASH)	-- the player is spindashing
	and (bot.pflags & PF_STARTDASH) then	-- the bot is spindashing
		-- try match the player's rev
		if (bmo.classicspindash_rev < mo.classicspindash_rev) then
			-- init bottics
			if (bmo.classicspindash_bottics == nil) then
				-- have a bit of a delay before trying to match (so the sound doesn't overlap)
				bmo.classicspindash_bottics = SPINDASH_BOTMASHINITDELAY
			end
			
			local bottics = bmo.classicspindash_bottics
			
			-- mash when tics are up
			bmo.classicspindash_bottics = $ and $-1
			if not (bmo.classicspindash_bottics) then
				cmd.forwardmove = 50
				bmo.classicspindash_bottics = SPINDASH_BOTMASHDELAY
			end
		else
			-- remove this
			bmo.classicspindash_bottics = nil
		end
	end
end)