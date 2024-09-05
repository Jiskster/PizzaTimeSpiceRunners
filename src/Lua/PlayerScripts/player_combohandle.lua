PTSR.combotween = 10
PTSR.combo_outro_tics = 4*TICRATE

local function getComboRank(combo)
	local very = (combo/5+1)/16

	local deplete = (16*5)*very
	combo = $ - deplete

	return combo/5+1,very
end

function PTSR:StartCombo(player)
	if player.mo and player.mo.valid and player.ptsr then
		player.ptsr.combo_outro_tics = 0
		player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
		player.ptsr.combo_elapsed = 0
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

function PTSR:FillCombo(player)
	PTSR:AddComboTime(player, player.ptsr.combo_maxtime)
end

function PTSR:ClearCombo(player)
	player.ptsr.combo_count = 0
	player.ptsr.combo_timeleft = 0
	player.ptsr.combo_active = false
end

function PTSR:EndCombo(player)
	player.ptsr.combo_outro_count = player.ptsr.combo_count
	PTSR:ClearCombo(player)

	local x = player.ptsr.combo_outro_count
	local score = x*250
	
	P_AddPlayerScore(player, score)

	if not player.ptsr.outofgame then
		player.ptsr.combo_timesfailed = $ + 1
	end
	
	if not PTSR.gameover then
		PTSR.add_xy_score(player, 50*FU, 110*FU, score, 3*TICRATE)
		player.ptsr.combo_outro_tics = PTSR.combo_outro_tics
	else
		player.ptsr.current_score = score
	end
	S_StartSound(nil, sfx_s1c5, player)
	player.ptsr.combo_rank, player.ptsr.combo_rank_very = getComboRank(player.ptsr.combo_outro_count)
end

function PTSR:AddComboTime(player, amount)
	if self.PlayerHasCombo(player) then
		if (player.ptsr.combo_timeleft + amount) > player.ptsr.combo_maxtime then
			player.ptsr.combo_tweentime = PTSR.combotween
			player.ptsr.combo_timeleft_prev = player.ptsr.combo_timeleft
			player.ptsr.combo_timeleft = player.ptsr.combo_maxtime
		elseif (player.ptsr.combo_timeleft + amount) <= 0 then
			PTSR:EndCombo(player)
		else
			player.ptsr.combo_tweentime = PTSR.combotween
			player.ptsr.combo_timeleft_prev = player.ptsr.combo_timeleft
			player.ptsr.combo_timeleft = $ + amount
		end
	end
end

function PTSR.CanComboTimeDecrease(player)
	if player.mo and player.mo.valid then
		return not (player.mo.pizza_in or player.mo.pizza_out or player.ptsr.treasure_got)
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
			PTSR:EndCombo(player)
		end
	end
	
	if player.ptsr.combo_outro_tics then
		player.ptsr.combo_outro_tics = $ - 1
		player.ptsr.combo_elapsed = 0
	end
end)