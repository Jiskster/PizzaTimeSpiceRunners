-- Line trigger system.


/*
	v1.2 note:
	instead of making the player increment the laps when triggering the line at
	the start of the level
	
	only increment and teleport when player presses FIRE 
	
	and stop their lap timer and spit out the lap timer when they touch the start
*/
addHook("MobjLineCollide", function(mobj, line)
    if not PTSR.IsPTSR() then return end
	local player = mobj.player
	if player.spectator then return end -- no trolling.

    -- Line Check at End
	if CV_PTSR.collisionsystem.value == 1 then
	
		local SSF_REALEXIT = 1<<7 -- the ssf_exit is wrong lmao
		--local SSF_REALEXIT = SSF_EXIT | SSF_SPECIALSTAGEPIT | SSF_RETURNFLAG -- this is wrong for testing
		
		/* TODO: V2 (Remove this whole comment chunk)
		if (line.frontsector and GetSecSpecial(line.frontsector.special, 4) == 2) 
        or (line.backsector and GetSecSpecial(line.backsector.special, 4) == 2)
        or (line.frontsector and (line.frontsector.specialflags & SSF_REALEXIT)) 
        or (line.backsector and (line.backsector.specialflags & SSF_REALEXIT)) then 
			PTSR.PizzaTimeTrigger(mobj)
		end
		*/
		
		-- Sign at start check.
		if ((line.backsector and line.backsector == PTSR.endsector)
		or (line.frontsector and line.frontsector == PTSR.endsector)) and not player.ptsr_outofgame and not player.spectator
		and player.mo and player.mo.valid and player.lapsdid ~= nil then 
			if player.pizzaface then
				PTSR.StartNewLap(mobj)
				return
			end
			
			player.ptsr_outofgame = 1
			
			if CV_PTSR.forcelap.value then 
				PTSR.StartNewLap(mobj)
			end

			PTSR.DoLapBonus(player)
		end
	end
end, MT_PLAYER)