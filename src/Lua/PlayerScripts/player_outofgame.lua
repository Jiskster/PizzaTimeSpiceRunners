-- dont damage (or maybe die) when you're out of the game
local function isPlayerOutOfGame(mobj)
	local player = mobj.player
	
	return player.ptsr.outofgame or false
end

addHook("MobjDamage", isPlayerOutOfGame, MT_PLAYER)

addHook("MobjDeath", isPlayerOutOfGame, MT_PLAYER)

addHook("PlayerThink", function(player)
	if player.ptsr.outofgame then
		player.powers[pw_nocontrol] = 1
	end
end)