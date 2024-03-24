local hooks = {}
hooks.onparry = {}
hooks.onlap = {}
hooks.onbonus = {}
hooks.onringbonus = {}
hooks.onlapbonus = {}
hooks.onpizzatime = {}
hooks.pfthink = {}
hooks.pfdamage = {}

local override_register = false
/*
	It's called override_register because a common use of hooks is to override
	Ingame actions.
*/

addHook("NetVars", function(net)
	override_register = net($)
end)


rawset(_G, "PTSR_AddHook", function(hooktype, func)
	if hooks[hooktype] then
		table.insert(hooks[hooktype], func)
	else
		error("Invalid HookType")
	end
end)

rawset(_G, "PTSR_DoHook", function(hooktype, ...)
	if not hooks[hooktype] then
		error("Invalid HookType")
	end
	
    for i,v in ipairs(hooks[hooktype]) do
        if v(...) == true then
            override_register = true
        end
    end

    if override_register == true then
        override_register = false
        return true
    else
        return false
    end
end)

