function PTSR:StartCombo(player)
	if player.mo and player.mo.valid and player.ptsr then
		player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
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
			player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
		elseif (player.ptsr.combo_timeleft + amount) < 0 then
			self:EndCombo(player)
		else
			player.ptsr.combo_timeleft = $ + amount
		end
	end
end

addHook("PlayerThink", function(player)
	if not PTSR.IsPTSR() then return end
	if not (player.mo and player.mo.valid) then return end
	
	if player.ptsr.combo_timeleft then
		player.ptsr.combo_active = true
		player.ptsr.combo_timeleft = $ - 1
		
		if not player.ptsr.combo_timeleft then
			player.ptsr.combo_active = false
			player.ptsr.combo_count = 0
		end
	end
	
	player.ptsr.combo_timeleft_prev = player.ptsr.combo_timeleft
end)