PTSR.hud_states = {}

local function addHudState(name, tics, frames, looping)
	local state = {
		_frame = 1;
		_wait = tics;
		_wait_default = tics; -- Never change this. OR BAD THINGS HAPPEN!
		_name = name:upper();
		_looping = true;
		
		_frames = frames;
	}
	
	if looping == false then
		state._looping = false
	end
	
	PTSR.hud_states[name:upper()] = state
end

function PTSR.getHudStateFrame(name)
	local state = PTSR.hud_states[name]
	
	if state then
		return (state._name .. tostring(state._frame))
	end
end

function PTSR.resetHudState(name)
	local state = PTSR.hud_states[name]
	
	if state then
		state._frame = 1
		state._wait = state._wait_default
	end
end

addHudState("JOHN", 2, 22);
addHudState("REDJOHN", 1, 22);
addHudState("PIZZAFACE_SLEEPING", 2, 17);
addHudState("PIZZAFACE_SHOWTIME", 3, 8, false);

addHook("ThinkFrame", function()
	for name,state in pairs(PTSR.hud_states) do
		if state._wait < 0 then
			continue
		end
		
		state._wait = max(0, $ - 1)
		
		if not (state._wait) then
			state._frame = $ + 1
			
			if (state._frame > state._frames) then
				if (state._looping) then
					state._frame = 1
				else
					state._frame = state._frames
					state._wait = -1 -- pause forever until a reset is called
					continue
				end
			end
			
			state._wait = state._wait_default
		end
	end
end)