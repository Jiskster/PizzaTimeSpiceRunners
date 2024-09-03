local rank_hud = function(v, player)
	local rankpos = {
		x = 110*FRACUNIT,
		y = 20*FRACUNIT
	}
	if not PTSR.IsPTSR() then return end
	
	if player.ptsr.pizzaface then return end

	--get the percent to next rank
	local per = (PTSR.maxrankpoints)/8
	local percent = per
	local score = 0
	local rank = player.ptsr.rank
	
	if (rank == "D")
		score = player.score
	elseif (rank == "C")
		score = player.score-(per)
	elseif (rank == "B")
		score = player.score-(per*2)
		percent = $*2
	elseif (rank == "A")
		score = player.score-(per*4)
		percent = $*4
	/*
	elseif (rank == "S")
		score = player.score-(PTSR.maxrankpoints)
		percent = $*8
	*/
	end
	--

	if player.ptsr.rank then
		local scale = ease.linear(player.ptsr.rank_scaleTime, FU/3, (FU/3)*2)
	
		v.drawScaled(rankpos.x, rankpos.y,scale, PTSR.r2p(v,player.ptsr.rank), V_SNAPTOLEFT|V_SNAPTOTOP)		
		--luigi budd: the fill
		if per
		and (player.ptsr.rank ~= "P")
			local patch = PTSR.r2f(v,player.ptsr.rank)
			local max = percent
			local erm = FixedDiv(score,max)
			
			local scale2 = patch.height*FU-(FixedMul(erm,patch.height*FU))
			
 			if scale2 < 0 then scale2 = FU end
			
			v.drawCropped(rankpos.x,rankpos.y+(scale2/3),
				scale,scale,
				patch,
				V_SNAPTOLEFT|V_SNAPTOTOP, 
				nil,
				0,scale2,
				patch.width*FU,patch.height*FU
			)
			
		end
	end
end

customhud.SetupItem("PTSR_rank", ptsr_hudmodname, rank_hud, "game", 0)