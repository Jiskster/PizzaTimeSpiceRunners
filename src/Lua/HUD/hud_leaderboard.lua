--leaderboard goes after & over the voting screen
local placecolor = {
	[1] = V_YELLOWMAP,
	[2] = 0,
	[3] = V_BROWNMAP
}
local rankcolor = {
	["P"] = "\x89",
	["S"] = "\x82",
	["A"] = "\x85",
	["B"] = "\x88",
	["C"] = "\x83",
	["D"] = "\x86",
}

local leaderboard_hud = function(v,p)
	if not PTSR.gameover then return end
	
	if PTSR:inVoteScreen()
	and #PTSR.leaderboard > 0
		local ldr = PTSR.leaderboard
		local lifepatch
		
		for i = 1,3
			if ldr[i] and ldr[i].valid
				local act_vote = clamp(0, PTSR.intermission_tics - PTSR.intermission_act_end - (i*4), 35)
				local tweendiv = clamp(0, FixedDiv(act_vote*FU, 35*FU), 35*FU)
				local tweenx = ease.outexpo(tweendiv, -400*FU, 95*FU)
				local y = 15*FU+((i-1)*60*FU)+25*FU
				local scale = FU*2
				
				lifepatch = v.getSprite2Patch(ldr[i].skin,
					SPR2_LIFE,
					false,
					A,0,0
				)
				v.drawScaled(tweenx-(lifepatch.width*scale/2),
					y,
					scale,
					lifepatch,
					V_SNAPTOLEFT,
					v.getColormap(nil,ldr[i].skincolor)
				)
				
				local placepatch = v.cachePatch("LDRB_"..i)
				v.drawScaled(tweenx-30*FU,
					y-20*FU,
					FU/2,
					placepatch,
					V_SNAPTOLEFT,
					v.getColormap(nil,ldr[i].skincolor)
				)
				
				v.drawString(tweenx-(lifepatch.width*scale/2),
					y+10*FU,
					ldr[i].name,
					V_SNAPTOLEFT|V_ALLOWLOWERCASE|placecolor[i],
					"thin-fixed-center"
				)
				v.drawString(tweenx-(lifepatch.width*scale/2),
					y+18*FU,
					rankcolor[ldr[i].ptsr_rank]..ldr[i].ptsr_rank.."\x80 - "..ldr[i].score,
					V_SNAPTOLEFT|V_ALLOWLOWERCASE,
					"thin-fixed-center"
				)
			end
		end
	end
end

customhud.SetupItem("PTSR_leaderboard", ptsr_hudmodname, leaderboard_hud, "game", 2)