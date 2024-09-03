local hooks = {}
hooks.onparry = {}
hooks.canparry = {}
hooks.onlap = {}
hooks.onbonus = {}
hooks.onringbonus = {}
hooks.onlapbonus = {}
hooks.oncombobonus = {}
hooks.onpizzatime = {}
hooks.ondamage = {}
hooks.onparried = {}
hooks.ongameend = {}
hooks.pfthink = {}
hooks.pfprestunthink = {}
hooks.pfdamage = {}
hooks.pfteleport = {}
hooks.pfplayerfind = {}
hooks.pfplayertpfind = {}

local override_register = nil
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
		override_register = v(...)
    end

    if override_register ~= nil then
		local register_copy = override_register
		
		override_register = nil
		return register_copy
    end
end)

