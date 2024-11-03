function PTSR.drawIntermissionBackground(v)	
	local fadeflag = max(PTSR.vote_timeleft - CV_PTSR.voteseconds.value*TICRATE + 9, 0); -- 3rd fade
	
	--thank you luigi for this code :iwantsummadat:
	--drawfill my favorite :kindlygimmesummadat:
	
	v.drawFill(0,0,v.width(),v.height(),
		--even if there is tearing, you wont see the black void
		skincolors[SKINCOLOR_PURPLE].ramp[15]|V_SNAPTOLEFT|V_SNAPTOTOP|fadeflag<<V_ALPHASHIFT
	)
	
	--need the scale before the loops
	local s = FU
	local bgp = v.cachePatch("PTSR_SECRET_BG")
	--this will overflow in 15 minutes + some change
	local timer = FixedDiv(leveltime*FU,2*FU) or 1
	local bgoffx = FixedDiv(timer,2*FU)%(bgp.width*s)
	local bgoffy = FixedDiv(timer,2*FU)%(bgp.height*s)
	for i = 0,(v.width()/bgp.width)+1
		for j = 0,(v.height()/bgp.height)+1
			--Complicated
			local x = 300
			local y = bgp.height*(j-1)
			local f = V_SNAPTORIGHT|V_SNAPTOTOP|fadeflag<<V_ALPHASHIFT
			local c = v.getColormap(nil,pagecolor)
			
			v.drawScaled(((x-bgp.width*(i-1)))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
			v.drawScaled(((x-bgp.width*i))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
		end
	end
end