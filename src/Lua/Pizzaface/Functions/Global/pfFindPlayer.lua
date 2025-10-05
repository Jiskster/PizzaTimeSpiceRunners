function PTSR.pfFindPlayer(mobj)
	local activeplayers = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid and PTSR.pfCanChase(player) then
			local hookcancel = PTSR.DoHook("pfplayerfind", mobj, player)
			
			if not hookcancel then
				table.insert(activeplayers, player)
			end
		end
	end
	
	for i,player in ipairs(activeplayers) do
		if player.mo and player.mo.valid then
			if not (mobj.pizza_target and mobj.pizza_target.valid) or not PTSR.pfCanChase(mobj.pizza_target.player)then
				mobj.pizza_target = player.mo
			else
				if (mobj.pizza_target and mobj.pizza_target.valid) then
					local dist_nptopizza = R_PointToDist2(mobj.pizza_target.x, mobj.pizza_target.y, mobj.x, mobj.y)
					local dist_newplayertopizza = R_PointToDist2(player.mo.x, player.mo.y, mobj.x, mobj.y)
					
					if dist_newplayertopizza < dist_nptopizza and PTSR.pfCanChase(player) then
						mobj.pizza_target = player.mo
					end
				end
			end
		end	
	end
end
