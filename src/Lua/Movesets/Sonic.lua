local SJ_CANCEL_TICS = 10
local SJ_SECOND_TICS = 6

local sonic_vars = {
	useabilities = true,
	groundpound = {
		enabled = false,
		stuntime = 6
	},
	superjump = {
		canmove = true,
		enabled = false,
		cancancel = false,
		cancelled = false,
		canceltic = 0,
	}
}

// simple lerp object for cool effects

mobjinfo[freeslot "MT_SLOWDOWNEFFECT"] = {
	radius = 1,
	height = 1,
	spawnstate = S_THOK,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

addHook("MobjSpawn", function(mo)
	mo.speed = FU/2
end, MT_SLOWDOWNEFFECT)

addHook("MobjThinker", function(mo)
	if not mo.valid then return end

	mo.momx = FixedMul($, mo.speed)
	mo.momy = FixedMul($, mo.speed)
	mo.momz = FixedMul($, mo.speed)

	if mo.disappear then
		local mult = ease.linear(FixedDiv(mo.fuse, mo.maxfuse), 9, 0)
		mo.frame = ($ &~FF_TRANSMASK)|(FF_TRANS10*mult)
	end
end, MT_SLOWDOWNEFFECT)

local strong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

sfxinfo[freeslot "sfx_gploop"].caption = "Ground pound sound."
sfxinfo[freeslot "sfx_grpo"].caption = "SLAM."
sfxinfo[freeslot "sfx_sjcan"].caption = "Super jump cancel!"
sfxinfo[freeslot "sfx_sjrel"].caption = "Super jumped!"

local function spawnDust(mo)
	local amount = 16
	local another_angle = 360*(FU/amount)

	for i = 1,amount do
		local left = amount-(i-1)
		local angle = fixangle(another_angle*left)

		local z = (mo.height/2)-((mo.height/2)*P_MobjFlip(mo))

		local particle = P_SpawnMobjFromMobj(mo, 0,0,z, MT_THOK)
		particle.state = S_SPINDUST1
		P_InstaThrust(particle, angle, 4*FU)
	end
end

local function SJEffect(mo)
	local amount = 32
	local another_angle = 360*(FU/amount)

	local z = (mo.height/2)-((mo.height/2)*P_MobjFlip(mo))

	local spring = P_SpawnMobjFromMobj(mo, 0,0,z, MT_SLOWDOWNEFFECT)
	spring.state = S_YELLOWSPRING
	spring.momz = 32*FU
	spring.fuse = TICRATE
	spring.maxfuse = spring.fuse
	spring.disappear = true

	for i = 1,amount do
		local left = amount-(i-1)
		local angle = fixangle(another_angle*left)

		local particle = P_SpawnMobjFromMobj(mo, 0,0,z, MT_SLOWDOWNEFFECT)
		particle.scale = FU/2
		particle.speed = FU-(FU/4)
		particle.fuse = -1
		particle.color = mo.color
		P_InstaThrust(particle, angle, 16*FU)
		P_SetObjectMomZ(particle, 16*FU)
	end

	S_StartSound(mo, sfx_sjrel)
	S_StartSound(spring, sfx_sprong)
end

local function atFloor(p)
	local height = FixedMul(p.mo.height, p.mo.scale)

	if P_MobjFlip(p.mo) < 0 then
		return p.mo.z+height >= p.mo.ceilingz
	end
	return p.mo.z <= p.mo.floorz
end

local function atCeil(p)
	local height = FixedMul(p.mo.height, p.mo.scale)

	if P_MobjFlip(p.mo) < 0 then
		return p.mo.z <= p.mo.floorz
	end

	return p.mo.z+height >= p.mo.ceilingz
end

local function enableSuperJump(p, power)
	if not (power) then
		power = 13*FU
	end

	local sptsr = p.sonicptsr
	local sj = p.sonicptsr.superjump
	if sj.enabled then return end

	power = FixedMul(power, p.mo.scale)

	P_SetObjectMomZ(p.mo, power)

	sj.enabled = true

	p.pflags = $ & ~(PF_JUMPED|PF_THOKKED)
	p.mo.state = S_PLAY_SPRING

	SJEffect(p.mo)
end

local function superJump(p)
	local sptsr = p.sonicptsr
	local sj = sptsr.superjump

	if not sj.enabled then return end

	if p.mo.eflags & MFE_SPRUNG then
		sj.enabled = false
		return
	end

	if not sj.cancelled then
		if atCeil(p)
		or p.mo.momz*P_MobjFlip(p.mo) <= 0 then
			p.pflags = $|PF_JUMPED|PF_THOKKED
			sj.enabled = false
			return
		end

		if not sj.canmove then
			local div = FU-(FU/8)
			p.mo.momx = FixedMul($, div)
			p.mo.momy = FixedMul($, div)
		end

		if sj.cancancel
		and p.cmd.buttons & BT_SPIN
		and not (p.lastbuttons & BT_SPIN) then
			sj.cancelled = true
			sj.canceltic = SJ_CANCEL_TICS
			S_StartSound(p.mo, sfx_sjcan)
			S_StartSound(p.mo, sfx_spndsh)
		end

		if not sj.cancelled then return end
	end

	p.mo.momx = 0
	p.mo.momy = 0
	p.mo.momz = 0

	local state = S_PLAY_ROLL
	if sj.canceltic <= SJ_SECOND_TICS then
		state = S_PLAY_FALL
	end

	if p.mo.state ~= state then
		p.mo.state = state
	end

	if not (sj.canceltic) then
		P_InstaThrust(p.mo, p.mo.angle, p.runspeed)
		P_SetObjectMomZ(p.mo, 2*FU)

		p.pflags = $|PF_SPINNING|PF_JUMPED|PF_THOKKED
		p.mo.state = S_PLAY_ROLL

		sj.enabled = false
		sj.cancelled = false

		S_StartSound(p.mo, sfx_zoom)
	end

	sj.canceltic = max(0, $-1)
end

local function groundPound(p)
	local sptsr = p.sonicptsr
	local grpo = sptsr.groundpound

	if not grpo.enabled then
		p.powers[pw_strong] = $ & ~strong_flags
		grpo.stuntime = sonic_vars.groundpound.stuntime
		return
	end

	p.powers[pw_strong] = $|strong_flags

	if p.mo.eflags & MFE_SPRUNG then
		grpo.enabled = false
		grpo.stuntime = sonic_vars.groundpound.stuntime
		p.mo.spritexscale = FU
		p.mo.spriteyscale = FU
		p.powers[pw_strong] = $ & ~strong_flags
		S_StopSoundByID(p.mo, sfx_gploop)
		return
	end

	local slope = (p.mo.standingslope and p.mo.standingslope.valid) and p.mo.standingslope
	/*local slopedir = 0
	if slope then
		slopedir = slope.xydirection
		if slope.zdelta*P_MobjFlip(p.mo) < 0 then
			slopedir = $+ANGLE_180
		end
	end*/

	if atFloor(p) then
		S_StopSoundByID(p.mo, sfx_gploop)
		if not slope then
			if grpo.stuntime == sonic_vars.groundpound.stuntime then
				S_StartSound(p.mo, sfx_grpo)
				spawnDust(p.mo)
			end
			grpo.stuntime = max(0, $-1)
			p.mo.momx = 0
			p.mo.momy = 0
			p.mo.momz = 0
			p.pflags = $|PF_FULLSTASIS

			local tweenTime = FixedDiv(grpo.stuntime, sonic_vars.groundpound.stuntime)

			p.mo.spritexscale = FU+ease.incubic(tweenTime, 0, FU/2)
			p.mo.spriteyscale = FU-ease.incubic(tweenTime, 0, FU/2)
		else
			S_StartSound(p.mo, sfx_spndsh)
			S_StartSound(p.mo, sfx_grpo)
			grpo.stuntime = 0
			p.mo.spritexscale = FU
			p.mo.spriteyscale = FU
			p.pflags = $|PF_SPINNING
			p.mo.state = S_PLAY_ROLL
			P_InstaThrust(p.mo, p.drawangle, abs(FixedMul(p.normalspeed, cos(slope.zangle))))
		end
	else
		if not S_SoundPlaying(p.mo, sfx_gploop) then
			S_StartSound(p.mo, sfx_gploop)
		end
		if p.mo.state ~= S_PLAY_SPINDASH then
			p.mo.state = S_PLAY_SPINDASH
		end
		grpo.stuntime = sonic_vars.groundpound.stuntime

		local scale = min(FixedDiv(p.mo.momz*P_MobjFlip(p.mo), -60*FU), FU/3)
		p.mo.spriteyscale = FU+scale
		p.mo.spritexscale = FU-scale
	end


	if not (grpo.stuntime) then
		grpo.enabled = false
		p.powers[pw_strong] = $ & ~strong_flags 
		p.mo.spriteyscale = FU
		p.mo.spritexscale = FU
	end
end

local function resetPlayer(p)
	p.powers[pw_strong] = $ & ~strong_flags
	p.sonicptsr = PTSR_shallowcopy(sonic_vars)
	if p.mo then
		p.mo.spritexscale = FU
		p.mo.spriteyscale = FU
		S_StopSoundByID(p.mo, sfx_gploop)
	end
end

local function manage_c1_spindash(p)
	if not (p.cmd.buttons & BT_CUSTOM1) then return end
	if p.lastbuttons & BT_CUSTOM1 then return end

	local sj = p.sonicptsr.superjump

	local pwr = p.mindash*2

	local dash = p.dashspeed
	local maxdash = p.maxdash
	local mindash = p.mindash

	dash = $-mindash
	maxdash = $-mindash

	pwr = FixedMul($, FixedDiv(dash, maxdash))

	enableSuperJump(p, pwr)
	P_InstaThrust(p.mo, p.mo.angle, pwr*3/2)

	sj.canmove = true
	sj.cancancel = false
end

addHook("PlayerThink", function(p)
	if not (p
	and p.mo
	and p.mo.health
	and not P_PlayerInPain(p)
	and p.mo.skin == "sonic"
	and PTSR:IsPTSR()
	and not (PTSR.ParryList[p.mo])) then
		if p.sonicptsr then
			resetPlayer(p)
		end
		p.sonicptsr = nil
		return
	end

	if not p.sonicptsr then
		p.sonicptsr = PTSR_shallowcopy(sonic_vars)
	end

	if PTSR.HitlagList[p.mo] then return end

	local sptsr = p.sonicptsr
	local grpo = sptsr.groundpound

	if grpo.enabled
	and not atFloor(p) then
		p.mo.momz = $ + FixedMul(P_GetMobjGravity(p.mo), FU*5)
	end

	local sj = sptsr.superjump

	if P_IsObjectOnGround(p.mo)
	and p.pflags & PF_SPINNING
	and p.pflags & PF_STARTDASH
	and not sj.enabled
	and not grpo.enabled then
		manage_c1_spindash(p)
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate do
		if not p.sonicptsr then continue end

		if PTSR.HitlagList[p.mo] then continue end

		local sptsr = p.sonicptsr
		local grpo = sptsr.groundpound
		local sj = sptsr.superjump

		if not atFloor(p) then
			if p.cmd.buttons & BT_SPIN
			and not (p.lastbuttons & BT_SPIN)
			and not grpo.enabled
			and not sj.enabled
			and p.pflags & PF_JUMPED then
				p.powers[pw_strong] = $|strong_flags
				p.mo.state = S_PLAY_SPINDASH
				S_StartSound(p.mo, sfx_spin)
				grpo.enabled = true
				if p.pflags & PF_THOKKED then
					p.mo.momx = 0
					p.mo.momy = 0
				end
				p.pflags = $|PF_THOKKED & ~PF_JUMPED

				P_SetObjectMomZ(p.mo, 19*FU)
			end

			if p.cmd.buttons & BT_CUSTOM1
			and not (p.lastbuttons & BT_CUSTOM1)
			and not grpo.enabled
			and not sj.enabled
			and p.pflags & PF_JUMPED
			and not (p.pflags & PF_THOKKED) then
				enableSuperJump(p)
				sj.cancancel = true
				sj.canmove = false
			end
		end

		groundPound(p)
		superJump(p)
	end
end)

local function manage_jump_spindash(p)
	if p.pflags & PF_JUMPSTASIS then return end
	if p.pflags & PF_JUMPDOWN then return end

	local sj = p.sonicptsr.superjump

	local pwr = p.mindash*2

	local dash = p.dashspeed
	local maxdash = p.maxdash
	local mindash = p.mindash

	dash = $-mindash
	maxdash = $-mindash

	pwr = FixedMul($, FixedDiv(dash, maxdash))

	enableSuperJump(p, pwr)

	sj.canmove = false
	sj.cancancel = true

	return true
end

addHook("JumpSpecial", function(p)
	if not p.sonicptsr then return end
	if PTSR.HitlagList[p.mo] then return end

	if not P_IsObjectOnGround(p.mo) then return end

	if not (p.pflags & PF_SPINNING) then return end
	if not (p.pflags & PF_STARTDASH) then return end

	if manage_jump_spindash(p) then
		return true
	end
end)

PTSR_AddHook("laptp", function(p)
	if not (p and p.sonicptsr) then return end
	resetPlayer(p)
	p.mo.state = S_PLAY_STND
end)