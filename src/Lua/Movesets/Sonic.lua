local sonic_vars = {
	buttons = 0,
	groundpound = {
		enabled = false,
		stuntime = 6
	}
}

sfxinfo[freeslot "sfx_gploop"].caption = "Ground pound sound."
sfxinfo[freeslot "sfx_grpo"].caption = "SLAM."

local function spawnDust(mo)
	local angle = mo.angle
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

local function groundPound(p)
	local sptsr = p.sonicptsr
	local grpo = sptsr.groundpound

	if not grpo.enabled then
		grpo.stuntime = sonic_vars.groundpound.stuntime
		return
	end

	local strong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

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

	if P_IsObjectOnGround(p.mo) then
		S_StopSoundByID(p.mo, sfx_gploop)
		if not slope then
			if grpo.stuntime == sonic_vars.groundpound.stuntime then
				S_StartSound(p.mo, sfx_grpo)
				spawnDust(p.mo)
			end
			grpo.stuntime = max(0, $-1)
			p.mo.momx = 0
			p.mo.momy = 0
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

addHook("PlayerThink", function(p)
	if not (p
	and p.mo
	and p.mo.health
	and not P_PlayerInPain(p)
	and p.mo.skin == "sonic"
	and PTSR:IsPTSR()) then
		if p.sonicptsr then
			S_StopSound(p.mo, sfx_gploop)
		end
		p.sonicptsr = nil
		return
	end

	if not p.sonicptsr then
		p.sonicptsr = PTSR_shallowcopy(sonic_vars)
	end

	if p.sonicptsr.groundpound.enabled
	and not P_IsObjectOnGround(p.mo) then
		p.mo.momz = $- ((FU/2)*P_MobjFlip(p.mo))
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate do
		if not p.sonicptsr then continue end

		local sptsr = p.sonicptsr
		local grpo = sptsr.groundpound

		if not P_IsObjectOnGround(p.mo)
		and p.cmd.buttons & BT_SPIN
		and not (sptsr.buttons & BT_SPIN)
		and not grpo.enabled
		and p.pflags & PF_JUMPED then
			if p.pflags & PF_THOKKED then
				p.mo.momx = 0
				p.mo.momy = 0
			end
			p.mo.state = S_PLAY_SPINDASH
			S_StartSound(p.mo, sfx_spin)
			grpo.enabled = true
			p.pflags = $|PF_THOKKED

			P_SetObjectMomZ(p.mo, 12*FU)
		end

		groundPound(p)

		sptsr.buttons = p.cmd.buttons
	end
end)