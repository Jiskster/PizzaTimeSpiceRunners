-- Destroy everything while running
-- only in pizza time tho.
addHook("PlayerCanDamage", function(player, mobj)
	if PTSR.pizzatime and CV_PTSR.killwhilerunning.value and player.speed >= skins[player.mo.skin].runspeed and not mobj.player then
		return true
	end
end)