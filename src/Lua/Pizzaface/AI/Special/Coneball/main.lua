freeslot("MT_CONEBALL_HAIL", "S_CONEBALL_HAIL", "S_CONEBALL_HAIL_LAND", "S_CONEBALL_PARTICLE")

freeslot(
	"SPR_CONEBALL_ATTACK",
	"SPR_CONEBALL_COOKIE", -- Default animation.
	"SPR_CONEBALL_DETRANSFORM",
	"SPR_CONEBALL_PINK",
	"SPR_CONEBALL_PROJECTILE_A",
	"SPR_CONEBALL_PROJECTILE_B",
	"SPR_CONEBALL_PROJECTILE_C",
	"SPR_CONEBALL_TRANSFORM"
)

states[S_CONEBALL] = {
    sprite = SPR_CONEBALL_COOKIE,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = 15,
    var2 = 2,
    nextstate = S_CONEBALL
}

mobjinfo[MT_CONEBALL_HAIL] = {
	spawnstate = S_CONEBALL_HAIL,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 30*FU,
	height = 30*FU,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_SPECIAL
}
states[S_CONEBALL_HAIL] = {
    sprite = SPR_CONEBALL_PROJECTILE_A,
    frame = FF_ANIMATE|A,
    tics = -1,
    var1 = 5,
    var2 = 2,
    nextstate = S_CONEBALL_HAIL
}
states[S_CONEBALL_HAIL_LAND] = {
    sprite = SPR_CONEBALL_PROJECTILE_B,
    frame = A,
    tics = -1,
    nextstate = S_CONEBALL_HAIL_LAND
}
states[S_CONEBALL_PARTICLE] = {
    sprite = SPR_CONEBALL_PROJECTILE_C,
    frame = A,
    tics = TICRATE,
    nextstate = S_NULL
}

local STABSPEED = 1

freeslot("SPR_CONA", "S_CONEBALL_PINK", "S_CONEBALL_TRANSFORM", "S_CONEBALL_ATTACK", "S_CONEBALL_DETRANSFORM")
states[S_CONEBALL_TRANSFORM] = {
    sprite = SPR_CONEBALL_TRANSFORM,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = 21,
    var1 = 10,
    var2 = 2,
    nextstate = S_CONEBALL_PINK
}
states[S_CONEBALL_PINK] = {
    sprite = SPR_CONEBALL_PINK,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = 7,
    var2 = 2,
    nextstate = S_CONEBALL_PINK
}
states[S_CONEBALL_ATTACK] = {
    sprite = SPR_CONEBALL_ATTACK,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = 26*STABSPEED,
    var1 = 25,
    var2 = STABSPEED,
    nextstate = S_CONEBALL
}
states[S_CONEBALL_DETRANSFORM] = {
    sprite = SPR_CONEBALL_DETRANSFORM,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = 18,
    var1 = 9,
    var2 = 2,
    nextstate = S_CONEBALL
}

local PHASE = {
    STARTUP = -1,
    TRANSFORM = 0,
    HAIL = 1,
    DETRANSFORM = 2,
    STAB = 3
}


local function isConeball(pizza)
    return PTSR.PFMaskData[pizza.pizzastyle or 1].special == "coneball"
end
local function isConeballingOnSomeone(pizza)
    return (
        isConeball(pizza)
        and pizza.pizza_target
        and pizza.pizza_target.valid
        and pizza.pizza_target.player
        and pizza.pizza_target.gettingConeballedOn
        and pizza.pizza_target.gettingConeballedOn.pizza == pizza
    )
end

PTSR.AddHook("pfpredamage", function (playermo, pizza)
    if isConeball(pizza) then
        -- do this here manually to avoid the invuln condition
		if playermo.player.powers[pw_shield] > 0 then
			return false
		end
		
		local cone = playermo.gettingConeballedOn 
		
        if not playermo.gettingConeballedOn then
            playermo.gettingConeballedOn = {
                pizza = pizza,
                tics = 0,
                phase = PHASE.STARTUP,
                hoverdist = 0
            }
        elseif playermo.gettingConeballedOn.pizza != pizza then
            PTSR.DoParry(playermo, pizza)
        end
		
		if cone then
			local inStabPhase = (cone.phase == PHASE.STAB)
			local inStabFrames = (cone.tics >= (9*STABSPEED) and cone.tics < (18*STABSPEED))
			
			if inStabPhase and inStabFrames then
				return false
			end
		end
		
        return true
    end
end)

PTSR.AddHook("preparry", function (playermo, pizza)
    if isConeballingOnSomeone(pizza) then
        return true
    end
end)

local function stabby(pizza)
    for p in players.iterate do
        -- print(R_PointToDist2(
        --     R_PointToDist2(p.mo.x, p.mo.y, pizza.x, pizza.y), p.mo.z+p.mo.height/2,
        --     0, pizza.z+pizza.height/2
        -- )/FU)
        if (
            p and p.valid and p.mo and p.mo.valid
            and PTSR.pfCanChase(p)
            and not p.powers[pw_invulnerability]
            and R_PointToDist2(
                R_PointToDist2(p.mo.x, p.mo.y, pizza.x, pizza.y), p.mo.z+p.mo.height/2,
                0, pizza.z+pizza.height/2
            ) < 109*FU
        ) then
            if CV_PTSR.nuhuh.value then
                S_StartSound(p.mo, sfx_spkdth)
            else
				PTSR.pfAITryDamage(pizza, p.mo)
            end
        end
    end
end

PTSR.AddHook("pfprestunthink", function (pizza)
    if isConeballingOnSomeone(pizza) then
        local target = pizza.pizza_target
        if not PTSR.pfCanChase(target.player) then
            target.gettingConeballedOn = nil
            return
        end
        local cone = target.gettingConeballedOn
        if cone.phase == PHASE.STARTUP then
            cone.phase = PHASE.TRANSFORM
            if PTSR.timeover and P_RandomChance(FU/2) then
                -- jump to stabbing
                cone.phase = PHASE.DETRANSFORM
            end
        end
        cone.tics = $ + 1
        -- print(cone.phase)
        if cone.phase == PHASE.TRANSFORM then
            if pizza.state == S_CONEBALL_PINK then
                cone.phase = PHASE.HAIL
                cone.tics = 0
            elseif pizza.state ~= S_CONEBALL_TRANSFORM then
                pizza.state = S_CONEBALL_TRANSFORM
            end
        elseif cone.phase == PHASE.HAIL then
            local modulo = 3
            if PTSR.timeover then
                modulo = 2
            end
            if cone.tics % modulo == 0 then
                local randr = P_RandomRange(50, 400)
                local randx = P_RandomRange(-randr, randr)*FU
                local randy = P_RandomRange(-randr, randr)*FU
                local hail = P_SpawnMobjFromMobj(
                    -- target,
                    -- -randx,
                    -- -randy,
                    -- 1500*FU,
                    pizza,
                    0,
                    0,
                    3*pizza.height/4,
                    MT_CONEBALL_HAIL
                )
                hail.fuse = TICRATE*5
                -- hail.momx = 3*target.momx/2 + -randx/80
                -- hail.momy = 3*target.momy/2 + -randy/80
                hail.momx = 9*target.momx/8 + randx/45
                hail.momy = 9*target.momy/8 + randy/45
                hail.momz = 9*target.momz/8 + P_RandomRange(-10,30)*FU/10
                -- hail.spritexscale = $*2
                -- hail.spriteyscale = $*2
                hail.target = target
            end
            if cone.tics >= TICRATE*3 then
                cone.phase = PHASE.DETRANSFORM
            end
        elseif cone.phase == PHASE.DETRANSFORM then
            if pizza.state == S_CONEBALL then
                cone.phase = PHASE.STAB
                cone.tics = 0
                pizza.momx = target.momx
                pizza.momy = target.momy
                pizza.momz = target.momz
            elseif pizza.state ~= S_CONEBALL_DETRANSFORM then
                pizza.state = S_CONEBALL_DETRANSFORM
            end
        elseif cone.phase == PHASE.STAB then
            if pizza.state ~= S_CONEBALL_ATTACK then
                if cone.tics >= (18*STABSPEED) then
                    target.gettingConeballedOn = nil
                    if not PTSR.timeover then
                        PTSR.DoParry(target, pizza)
                        -- pizza.momx = $*2
                        -- pizza.momy = $*2
                        -- pizza.momz = $*3
                    end
                else
                    pizza.state = S_CONEBALL_ATTACK
                end
            end
			
            if cone.tics >= (9*STABSPEED) and cone.tics < (18*STABSPEED) then
                stabby(pizza)
            end
        end


        if cone.phase ~= PHASE.STAB then
            local dist_mul = max(0, min(cone.hoverdist, 75))
            if cone.phase == PHASE.DETRANSFORM then
                cone.hoverdist = max($-4, 0)
            else
                cone.hoverdist = min($+4, 75)
            end
            P_MoveOrigin(
                pizza,
                target.x + sin(leveltime*ANG2*2)*dist_mul,
                target.y + cos(leveltime*ANG2*2)*dist_mul,
                target.z + dist_mul*FU*P_MobjFlip(target)
            )
            pizza.momx = 0
            pizza.momy = 0
            pizza.momz = 0
        else
            if PTSR.timeover then
                pizza.momx = 95*$/100
                pizza.momy = 95*$/100
                pizza.momz = 95*$/100
            else
                pizza.momx = 9*$/10
                pizza.momy = 9*$/10
                pizza.momz = 9*$/10
            end
        end
        return true
    elseif isConeball(pizza) then
        pizza.pfspeedmulti = 5*FU/3
        if pizza.state == S_CONEBALL_ATTACK then
            pizza.momx = 0
            pizza.momy = 0
            pizza.momz = 0
            if pizza.frame >= J and pizza.frame < S then
                stabby(pizza)
            end
            return true -- finish the attack
        end
        if pizza.state != S_CONEBALL then
            pizza.state = S_CONEBALL
        end
    end
end)

addHook("MobjThinker", function (mo)
    if mo.flags & MF_NOCLIPHEIGHT and not mo.hailLanded then
        local floor = mo.floorz
        if mo.eflags & MFE_VERTICALFLIP then
            floor = mo.ceilingz
        end
        -- print(floor, mo.z, mo.momz * 2)
        if abs(floor - mo.z) < abs(mo.momz*2) then
            mo.flags = $ & ~MF_NOCLIPHEIGHT
        end
        if mo.momz * P_MobjFlip(mo) > 0 then
            mo.renderflags = $ | RF_VERTICALFLIP
        else
            mo.renderflags = $ & ~RF_VERTICALFLIP
        end
    elseif not mo.hailLanded then
        if P_IsObjectOnGround(mo) then
            mo.momx = 0
            mo.momy = 0
            mo.momz = 0
            mo.state = S_CONEBALL_HAIL_LAND
            mo.hailLanded = true
            mo.renderflags = $ & ~RF_VERTICALFLIP
        end
    elseif mo.fuse == 20 then
        mo.flags = $ | MF_NOCLIPHEIGHT
        mo.momz = -P_MobjFlip(mo)*FU/2
    end
end, MT_CONEBALL_HAIL)

local MAXICECREAM = 75*FU
local SOFTMAXICECREAM = 50*FU
local MAXSLOW = 64*FU/1000
addHook("TouchSpecial", function (special, toucher)
    local add = 2*FU
    -- if not special.hailLanded and not P_IsObjectOnGround(toucher) then
    --     add = $ * 4
    -- else
    if PTSR.timeover then
        add = 3*$/2
    end
    if toucher.player and toucher.player.speed > 16*FU then
        add = FixedMul($, toucher.player.speed/16)
    end
    toucher.coneballIcecreamed = min(($ or 0)+add, MAXICECREAM)
    -- if toucher.player and toucher.player.valid
    --     and not special.hailLanded
    --     and not P_PlayerInPain(toucher.player)
    -- then
    --     P_DamageMobj(toucher, special, special)
    -- end
    return true
end, MT_CONEBALL_HAIL)

addHook("PlayerThink", function (p)
    if (
        p.valid and p.mo and p.mo.valid
        and p.mo.gettingConeballedOn
    ) then
        local ballin = p.mo.gettingConeballedOn
        if ballin.pizza and ballin.pizza.valid and ballin.pizza.pizza_target ~= p.mo then
            -- we have a bogus coneball data
            p.mo.gettingConeballedOn = nil
        end
    end
    if (
        p.valid and p.mo and p.mo.valid
        and p.mo.coneballIcecreamed
        and p.mo.coneballIcecreamed > 0
    ) then
        if not PTSR.pfCanChase(p) then
            p.mo.coneballIcecreamed = 0
            return
        end

        -- print(p.mo.coneballIcecreamed/FU)

        local mult = FU - FixedMul(FixedDiv(p.mo.coneballIcecreamed, MAXICECREAM), MAXSLOW)
        -- print(p.mo.coneballIcecreamed .. " icecream")
        p.mo.momx = FixedMul($, mult)
        p.mo.momy = FixedMul($, mult)
        -- print(1000*mult/FU)
        -- p.mo.momz = FixedMul($, mult) -- this feels weird and also breaks springs

        local c = 5*FixedMul(P_RandomFixed(), FixedDiv(p.mo.coneballIcecreamed, MAXICECREAM))/FU
        local rdfu = p.mo.radius/p.mo.scale
        for i = 1,c do
            local particle = P_SpawnMobjFromMobj(
                p.mo,
                P_RandomRange(-rdfu, rdfu)*FU,
                P_RandomRange(-rdfu, rdfu)*FU,
                P_RandomRange(0, p.mo.height/p.mo.scale)*FU,
                MT_THOK
            )
            particle.state = S_CONEBALL_PARTICLE
            particle.fuse = -1
            particle.flags = $ & ~MF_NOGRAVITY
        end
        -- if true then return end
        p.mo.coneballIcecreamed = max(0, $ - FU/12)
        if p.mo.coneballIcecreamed > SOFTMAXICECREAM then
            p.mo.coneballIcecreamed = max(0, $ - FU)
        end
        if p.powers[pw_invulnerability] then
            p.mo.coneballIcecreamed = max(0, $ - FU*10)
        end
    end
end)

local dots = {}
local dotplayer = nil

local function getDotCount()
    if
        displayplayer and displayplayer.mo and displayplayer.mo.valid
        and displayplayer.mo.coneballIcecreamed
    then
        return 50*displayplayer.mo.coneballIcecreamed/MAXICECREAM
    end
    return 0
end

local hudf = function (v, p)
    --[[@type videolib]]
    local vv = v
    local dotcount = getDotCount()
    if #dots < dotcount then
        for i=#dots,dotcount-1 do
            local newdot = {
                x = vv.RandomRange(0, 320)*FU,
                y = vv.RandomRange(0, 100)*FU,
                vy = vv.RandomRange(70, 160)*FU/100,
                time = vv.RandomRange(TICRATE, TICRATE*2),
                a = vv.RandomRange(-35, 35)*ANG1
            }
            table.insert(dots, newdot)
        end
    end
    if not #dots then return end
    for _,dot in ipairs(dots) do
        local dotpatch = vv.getSpritePatch(SPR_CONEBALL_PROJECTILE_C, A, 0, dot.a)
        local dist = R_PointToDist2(dot.x, dot.y, 160*FU, 100*FU)
        local flags = 0
        if dist < 40*FU then
            flags = V_70TRANS
        elseif dist < 75*FU then
            flags = V_50TRANS
        elseif dist < 110*FU then
            flags = V_20TRANS
        end
		
		if dotpatch and dotpatch.valid then
			vv.drawScaled(dot.x, dot.y, FU, dotpatch, flags)
		end
    end
end
customhud.SetupItem("PTSR_coneball_icecream", ptsr_hudmodname, hudf, "game", 3)

addHook("ThinkFrame", function ()
    if displayplayer ~= dotplayer then
        dots = {}
        dotplayer = displayplayer
    end
    local dotcount = getDotCount()
    local keepdots = {}
    for _,dot in ipairs(dots) do
        dot.y = $ + dot.vy
        dot.time = $ - 1
        if dotcount > #dots then
            dot.time = $ - 1
        end
        if dot.time < 0 then
            dot.y = $ - dot.time*2*dot.vy
        end
        if dot.y < 205*FU then
            table.insert(keepdots, dot)
        end
    end
    dots = keepdots
end)
