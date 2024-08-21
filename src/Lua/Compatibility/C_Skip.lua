-- If you made this, contact j1sk on discord so I can add credits.
local setstuff = false

freeslot("sfx_tf2noo")

local costs = {
	[MT_INVULN_BOX] = 45,
	[MT_ATTRACT_BOX] = 25,
	[MT_FORCE_BOX] = 20,
	[MT_THUNDERCOIN_BOX] = 60,
}

local function autorefund (mo)
	if mo.skipgrace and mo.skipskip then
		mo.skipskip.player.skipscrap = $ + (costs[mo.type] or 0)
		mo.type = MT_THOK
		mo.state = S_INVISIBLE
		mo.tics = TICRATE*2
		mo.flags = 0
		S_StartSound(mo, sfx_tf2noo, mo.skipskip.player)
		S_StopSoundByID(mo.skipskip, sfx_addfil)
		S_StopSoundByID(mo.skipskip, sfx_kc5b)
		S_StopSoundByID(mo.skipskip, sfx_cdpcm8)
	end
end

addHook("MobjThinker", autorefund, MT_INVULN_BOX)
addHook("MobjThinker", autorefund, MT_ATTRACT_BOX)
addHook("MobjThinker", autorefund, MT_FORCE_BOX)
addHook("MobjThinker", autorefund, MT_THUNDERCOIN_BOX)

addHook("ThinkFrame", function()
	if AddSkipMonitor and not setstuff then
		AddSkipMonitor(MT_SKIPSUPERBOX, 69420, "steph my man, expose more of monitor spawning PLEASE", "like why gateskeep your modding environment like this")
		setstuff = true
	end
end)