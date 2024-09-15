--hacky fix because jisk wants me to use it
local fakeV = {
	__width = 320,
	__height = 200,
	__dupx = 1,
	__dupy = 1
}
function fakeV.width()
	return fakeV.__width
end
function fakeV.height()
	return fakeV.__height
end
function fakeV.dupx()
	return fakeV.__dupx
end
function fakeV.dupy()
	return fakeV.__dupy
end

local MAX_TICS = TICRATE/2
local GO_TO_X = 60*FU
local GO_TO_Y = 25*FU
local GO_TO_S = FU/5

local ranksTable = {
	["D"] = 1,
	["C"] = 2,
	["B"] = 3,
	["A"] = 4,
	["S"] = 5,
	["P"] = 6
}
local scoreYOffset = {
	[0] = 0,
	[1] = -1,
	[2] = -1,
	[3] = -1,
	[4] = -1,
	[5] = 1,
	[6] = 2,
	[7] = 3,
	[8] = 5,
	[9] = 4,
	[10] = 2,
	[11] = 1
}

local toppingsOnScore = {
	[2] = "SCORESHROOM",
	[3] = "SCOREPEPPERONI",
	[4] = "SCOREOLIVE",
	[5] = "SCOREPEPPER"
}

local displayValues = {}

function PTSR.DeductScore(player, score_deducted)
	table.insert(player.ptsr.score_deduct_list, {
		score = abs(score_deducted),
		fuse = 25,
		startfuse = 25,
	}) 
	
	player.score = max(0, $-abs(score_deducted))
end

function PTSR.add_wts_score(player, mobj, score, delay, color)
	local x = 0
	local y = 0
	local s = FU
	local score = score or 100
	local delay = delay or 0

	player.ptsr.score_objects[#player.ptsr.score_objects+1] = {
		score = score,
		tics = -delay,
		color = color or SKINCOLOR_WHITE,
	}

	if displayplayer and displayplayer.valid then
		if player == displayplayer then
			local wts = SG_ObjectTracking(fakeV,player,camera,mobj)

			if wts.onScreen then
				x = wts.x
				y = wts.y
				s = wts.scale/2
			end
			
			displayValues[#displayValues+1] = {
				x = x,
				y = y,
				s = GO_TO_S,
				tics = -delay,
				score = score,
				color = color or SKINCOLOR_WHITE
			}
		end
	end
end

function PTSR.add_xy_score(player, x, y, score, delay, color)
	local s = FU
	local score = score or 100
	local delay = delay or 0

	player.ptsr.score_objects[#player.ptsr.score_objects+1] = {
		score = score,
		tics = -delay,
		color = color or SKINCOLOR_WHITE,
	}
	if displayplayer and displayplayer.valid then
		if player == displayplayer then
			displayValues[#displayValues+1] = {
				x = x,
				y = y,
				s = GO_TO_S,
				tics = -delay,
				score = score,
				color = color or SKINCOLOR_WHITE
			}
		end
	end
end

addHook("PlayerThink", function(p)
	if not (p and p.ptsr) then return end

	for k,data in pairs(p.ptsr.score_objects) do
		data.tics = $+1
		if data.tics > MAX_TICS then
			table.remove(p.ptsr.score_objects, k)
			p.ptsr.current_score = $+data.score
			p.ptsr.score_shakeTime = FU
		end
	end
	
	for i,v in ipairs(p.ptsr.score_deduct_list) do
		if v.fuse >= 0 then
			v.fuse = $ - 1
			
			if v.fuse <= 0 then
				table.remove(p.ptsr.score_deduct_list, i)
				continue
			end
		else
			table.remove(p.ptsr.score_deduct_list, i)
			continue
		end
	end
	
	if #p.ptsr.score_objects == 0
	and p.score ~= p.ptsr.current_score then
		p.ptsr.current_score = p.score
		p.ptsr.score_shakeTime = FU
	end
end)

addHook("ThinkFrame", do
	for k,data in pairs(displayValues) do
		data.tics = $+1
		if data.tics > MAX_TICS
			table.remove(displayValues, k)
		end
	end
end)

local score_hud = function(v, player)
	if not player.ptsr then return end

	-- Pizza hud that's behind the score. (The one that gets toppings depending on rank)
	local xPizzaPos = (24*FU)
	local yPizzaPos = (15*FU)
	
	-- Offset from the pizza hud.
	local xScoreOffset = (34*FU) -- xPizzaPos + this
	local yScoreOffset = (-4*FU) -- yPizzaPos + this
	
	-- Actual score position.
	local xScorePos = (xPizzaPos+xScoreOffset)
	local yScorePos = (yPizzaPos+yScoreOffset)
	
	local xDeductOffset = (24*FU)
	local yDeductOffset = (-4*FU)
	
	-- Score and Pizza HUD shake.
	local xShake = 0
	local yShake = 0
	
	
	fakeV.__width = v.width()
	fakeV.__height = v.height()
	fakeV.__dupx = v.dupx()
	fakeV.__dupy = v.dupy()

	if player.ptsr
	and player.ptsr.score_shakeTime then
		local shakeTime = player.ptsr.score_shakeTime
		local maxTime = player.ptsr.score_shakeDrainTime

		xShake = v.RandomRange(-2, 2)*shakeTime
		yShake = v.RandomRange(-2, 2)*shakeTime
	end

	local frame = 0
	if PTSR.pizzatime then
		frame = (leveltime/2)%12
	end

	-- Draw Pizza Hud.
	v.drawScaled(xPizzaPos+xShake, yPizzaPos+yShake, FU/3, v.cachePatch("SCOREOFPIZZA"..frame), (V_SNAPTOLEFT|V_SNAPTOTOP))

	
	local rankNum = ranksTable[player.ptsr.rank]
	-- Draw toppings on Pizza Hud.
	for i = 1,rankNum do
		if not (toppingsOnScore[i]) then continue end

		v.drawScaled(xPizzaPos+xShake, yPizzaPos+yShake, FU/3, v.cachePatch(toppingsOnScore[i]..frame), V_SNAPTOLEFT|V_SNAPTOTOP)
	end

	-- For bobbing up and down.
	local yOffset = scoreYOffset[frame]*(FU/3) or 0
	
	-- Draw score thats on top of Pizza Hud.
	customhud.CustomFontString(v, xScorePos+xShake, yScorePos+yShake-yOffset, tostring(player.ptsr and player.ptsr.current_score or 0), "SCRPT", (V_SNAPTOLEFT|V_SNAPTOTOP), "center", FRACUNIT/3)
	
	-- Draw score deductions.
	for i,data in ipairs(player.ptsr.score_deduct_list) do
		if not (data.score and data.fuse ~= nil and data.startfuse ~= nil) then continue end
		local fuse_reverse = (data.startfuse-data.fuse)-- counting up (starting from 0)
		local div = FixedDiv(fuse_reverse*FU, data.startfuse*FU) 
		local clmp = max(0, min(div, FU))
		local ese = ease.linear(clmp, 0, -FU*8) -- to up
		
		-- For fading out when fuse is near done.
		local transflag = 0
		if data.fuse <= 9 then
			transflag = $ | (V_90TRANS-(data.fuse*V_10TRANS))
		end
		
		customhud.CustomFontString(v, xScorePos+xDeductOffset, yScorePos+yDeductOffset+ese, "-"..data.score, "STKPT", (V_SNAPTOLEFT|V_SNAPTOTOP|transflag), "right", FRACUNIT/3, SKINCOLOR_RED)
	end
	
	local ox = 0
	local oy = 0

	ox = v.width()/v.dupx()
	oy = v.height()/v.dupy()

	ox = ($-320)*(FU/2)
	oy = ($-200)*(FU/2)

	for k,data in pairs(displayValues) do
		local t = FixedDiv(max(0, data.tics), MAX_TICS)
		local drawX = ease.incubic(t, data.x, GO_TO_X-ox)
		local drawY = ease.incubic(t, data.y, GO_TO_Y-oy)

		customhud.CustomFontString(v,
			drawX,
			drawY,
			tostring(data.score),
			"PTFNT",
			V_PERPLAYER,
			"center",
			data.s,
			data.color)
	end
end

customhud.SetupItem("score", ptsr_hudmodname, score_hud, "game", 0) -- override score hud
