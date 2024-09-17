local handler_snaptrue = {
	func = function(current, result)
		return result or current
	end,
	initial = false
}
local handler_snapany = {
	func = function(current, result)
		if result ~= nil then
			return result
		else
			return current
		end
	end,
	initial = nil
}
local handler_default = handler_snaptrue

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

rawset(_G, "PTSR_AddHook", function(hooktype, func)
	if hooks[hooktype] then
		table.insert(hooks[hooktype], {
			func = func,
			errored = false
		})
	else
		error("Invalid HookType")
	end
end)

rawset(_G, "PTSR_DoHook", function(hooktype, ...)
	if not hooks[hooktype] then
		error("Invalid HookType")
	end

	local handler = hooks[hooktype].handler or handler_default
	local override = handler.initial

    for i,v in ipairs(hooks[hooktype]) do
		local status, result = pcall(v.func, ...)
		if status then
			override = handler.func(override, result)
		elseif not v.errored then
			v.errored = true
			print("WARNING: Error in PTSR " .. hooktype .. " hook handler #" .. i .. ":")
			print(result)
		end
    end

    return override
end)

