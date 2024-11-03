function PTSR.drawVoteScreenTimer(v)
	if PTSR.isVoteOver() then return end
	
	local timercolor = SKINCOLOR_PINK 
	
	-- flash red for a frame when vote is almost done
	if PTSR.vote_timeleft and (PTSR.vote_timeleft <= 5*TICRATE) and (PTSR.vote_timeleft % TICRATE == (TICRATE - 1)) then
		timercolor = SKINCOLOR_RED
	end
	
	-- bounce code
	local offset = 0
	local anim_lasts = 5	
	if (PTSR.vote_timeleft % TICRATE) >= (TICRATE - anim_lasts) then
		offset = (PTSR.vote_timeleft % TICRATE) - (TICRATE - anim_lasts)
	end
	
	if PTSR.vote_timeleft and not paused then
		if (PTSR.vote_timeleft <= 5*TICRATE) then
			if (PTSR.vote_timeleft % TICRATE == 0) then
				S_StartSound(nil, sfx_s257)
			elseif (PTSR.vote_timeleft % TICRATE == 28) then
				S_StartSoundAtVolume(nil, sfx_s257, 70)
			end
		end
	end
	
	customhud.CustomFontString(v, 160*FU, 15*FU - offset*FU, tostring(PTSR.vote_timeleft/TICRATE), "PTFNT", V_SNAPTOTOP, "center", FRACUNIT/2, timercolor)
end