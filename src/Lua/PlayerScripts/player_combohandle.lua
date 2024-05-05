PTSR.combotween = 10
PTSR.combo_outro_tics = 6*TICRATE

function PTSR:StartCombo(player)
	if player.mo and player.mo.valid and player.ptsr then
		player.ptsr.combo_outro_tics = 0
		player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
		player.ptsr.combo_times_started = $ + 1
	end
end

function PTSR.PlayerHasCombo(player)
	return player.ptsr.combo_timeleft > 0
end

function PTSR:AddCombo(player, amount)
	if self.PlayerHasCombo(player) then
		player.ptsr.combo_count = $ + (amount or 1)
	else
		self:StartCombo(player)
		player.ptsr.combo_count = $ + (amount or 1)
	end
end

function PTSR:EndCombo(player)
	player.ptsr.combo_count = 0
	player.ptsr.combo_timeleft = 0
	player.ptsr.combo_active = false
end

function PTSR:AddComboTime(player, amount)
	if self.PlayerHasCombo(player) then
		if (player.ptsr.combo_timeleft + amount) > player.ptsr.combo_maxtime then
			player.ptsr.combo_tweentime = PTSR.combotween
			player.ptsr.combo_timeleft_prev = player.ptsr.combo_timeleft
			player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
		elseif (player.ptsr.combo_timeleft + amount) < 0 then
			self:EndCombo(player)
		else
			player.ptsr.combo_tweentime = PTSR.combotween
			player.ptsr.combo_timeleft_prev = player.ptsr.combo_timeleft
			player.ptsr.combo_timeleft = $ + amount
		end
	end
end

function PTSR.CanComboTimeDecrease(player)
	if player.mo and player.mo.valid then
		return not (player.mo.pizza_in or player.mo.pizza_out)
	end
	
	return false
end

addHook("PlayerThink", function(player)
	if not PTSR.IsPTSR() then return end
	if not (player.mo and player.mo.valid) then return end
	
	if player.ptsr.combo_tweentime then
		player.ptsr.combo_tweentime = $ - 1
	end
	
	if player.ptsr.combo_timeleft and PTSR.CanComboTimeDecrease(player) then
		player.ptsr.combo_active = true
		player.ptsr.combo_timeleft = $ - 1
		player.ptsr.combo_elapsed = $ + 1
		
		if not player.ptsr.combo_timeleft then
			player.ptsr.combo_outro_count = player.ptsr.combo_count
			PTSR:EndCombo(player)
			
			
			if not player.ptsr.outofgame then
				player.ptsr.combo_timesfailed = $ + 1
			end
			
			player.ptsr.combo_outro_tics = PTSR.combo_outro_tics
			S_StartSound(player.mo, sfx_s1c5, player)
		end
	end
	
	if player.ptsr.combo_outro_tics then
		player.ptsr.combo_outro_tics = $ - 1
		player.ptsr.combo_elapsed = $ + 1
		
		if not player.ptsr.combo_outro_tics then
			player.ptsr.combo_elapsed = 0
		end
	end
end)