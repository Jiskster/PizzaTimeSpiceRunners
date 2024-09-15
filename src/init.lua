freeslot("TOL_PTSR")
freeslot("sfx_pizzah", "sfx_pizzao", "sfx_coneba", "sfx_pepdie", "sfx_lap2", "sfx_pzprry",
		 "sfx_prepr1", "sfx_prepr2", "sfx_prepr3", "MT_PT_PARRY", "S_PT_PARRY", "SPR_PRRY")
freeslot("sfx_evlagh")

for i = 0, 2
	sfxinfo[sfx_prepr1 + i].caption = "Boink"
end

sfxinfo[sfx_pizzah].caption = "Pizzaface laughs"
sfxinfo[sfx_coneba].caption = "Coneball laughs"
sfxinfo[sfx_pepdie].caption = "Death"
sfxinfo[sfx_lap2].caption = "New lap!"

rawset(_G, "FUNC_PTSR", {}) -- functions

freeslot("MT_PIZZAMASK", "S_PIZZAFACE", "S_CONEBALL", "S_PF_EGGMAN", "S_SUMMADAT_PF", "SPR_PZAT", "SPR_CONB", "SPR_SMAD", "sfx_smdah", "S_GOOCH_PF", "SPR_PZAD")
freeslot("sfx_nrmlfc","S_NORMALFACE_PF","SPR_NMFC")
freeslot("S_KIMIZZA_PF", "SPR_KMZA")

mobjinfo[MT_PIZZAMASK] = {
	doomednum = -1,
	spawnstate = S_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY
}

states[S_PIZZAFACE] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = P,
    var2 = 2,
    nextstate = S_PIZZAFACE
}

states[S_CONEBALL] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = H,
    var2 = 2,
    nextstate = S_CONEBALL
}

states[S_PF_EGGMAN] = {
    sprite = SPR_EGGM,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_PF_EGGMAN
}

states[S_SUMMADAT_PF] = {
    sprite = SPR_SMAD,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_SUMMADAT_PF
}

states[S_NORMALFACE_PF] = {
    sprite = SPR_NMFC,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_NORMALFACE_PF
}

states[S_KIMIZZA_PF] = {
    sprite = SPR_KMZA,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = 1,
    var2 = 1,
    nextstate = S_KIMIZZA_PF
}

states[S_GOOCH_PF] = {
    sprite = SPR_PZAD,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = R,
    var2 = 3,
    nextstate = S_GOOCH_PF
}

--this is UGLY.
dofile "SaxAnimation/Init.lua"
dofile "SaxAnimation/UpdatePerFrame.lua"

dofile "Libraries/customhudlib.lua"

dofile "Libraries/hooksystem.lua"

dofile "Libraries/sglib"

customhud.SetupFont("PTFNT", -1, 4)
customhud.SetupFont("SCRPT", -2, 4)
customhud.SetupFont("COMBO", -1, 4)
customhud.SetupFont("SMNPT", -1, 4)
customhud.SetupFont("STKPT", -1, 4)
customhud.SetupFont("PTLAP")

dofile "main_game.lua"

/*
-- SAXA HERE HI I DO DA TITLECARDIANERY
dofile "titlecards.lua"
*/

dofile "Functions/get_ringcount.lua"
dofile "Functions/is_ptsr.lua"
dofile "Functions/speedcap_xy.lua"

dofile "Init/initmap.lua"

dofile "consolethings.lua"

dofile "Hooks/PlayerThinks.lua"
dofile "Hooks/PlayerDeath.lua"
dofile "Hooks/PlayerTweaks.lua"
dofile "Hooks/LineTriggerSystem.lua"

dofile "PlayerScripts/player_resetplayervars.lua"
dofile "PlayerScripts/player_parry.lua"
dofile "PlayerScripts/player_killwhilerunning.lua"
dofile "PlayerScripts/player_ringdrophandle.lua"
dofile "PlayerScripts/player_outofgame.lua"
dofile "PlayerScripts/player_lapend.lua"

dofile "PlayerScripts/player_laptp.lua"
dofile "PlayerScripts/pmo_startnewlap.lua"
dofile "PlayerScripts/pmo_pizzatimetrigger.lua"
dofile "PlayerScripts/player_combohandle.lua"

dofile "PlayerScripts/player_scorehud"

dofile "Libraries/libs.lua"
dofile "exit_handle.lua"
dofile "Hooks/music_handle.lua"
dofile "pizzaface.lua"

dofile "HUD/name_tags.lua"

dofile "HUD/main_hud.lua"
dofile "HUD/hud_doorfade.lua"
dofile "HUD/hud_bar.lua"
dofile "HUD/hud_itspizzatime.lua"
dofile "HUD/hud_tooltips.lua"
dofile "HUD/hud_lap.lua"
dofile "HUD/hud_rank.lua"
dofile "HUD/hud_faceswap.lua"
dofile "HUD/hud_gamemode.lua"
dofile "HUD/hud_overtimemulti.lua"
dofile "HUD/hud_untilend.lua"
dofile "HUD/hud_fade.lua"
dofile "HUD/hud_combo.lua"
dofile "HUD/hud_overtime.lua"
dofile "HUD/hud_leaderboard.lua"
dofile "HUD/hud_rankings.lua"
dofile "HUD/hud_score.lua"
dofile "HUD/hud_time.lua"
dofile "HUD/hud_hurryup.lua"
dofile "HUD/hud_pfviewpoint.lua"

dofile "discord_botleaderboard.lua"

dofile "Gimmicks/exitsign_init.lua"
dofile "Gimmicks/exitsign_thinkers.lua"
dofile "Gimmicks/pizzaportal.lua"
dofile "Gimmicks/deathring.lua"
dofile "Gimmicks/alivedustdevil.lua"
dofile "Gimmicks/powerbubble.lua"
dofile "Gimmicks/johnpillar.lua"
dofile "Gimmicks/doors.lua"
dofile "Gimmicks/keys.lua"
dofile "Gimmicks/treasures.lua"
dofile "Gimmicks/escapeclock.lua"

dofile "InbuiltModeScripts/elimination.lua"
dofile "InbuiltModeScripts/juggernaut.lua"

dofile "Hooks/intermission.lua"

dofile "Compatibility/C_Surge.lua"
dofile "Compatibility/C_Skip.lua"
dofile "Compatibility/C_Mach.lua"