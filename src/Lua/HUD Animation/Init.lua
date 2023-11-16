rawset(_G, 'animationtable', {})
rawset(_G, 'PTAnimFunctions', {})

// Stuff for each animation

local function ChangeAnimation(self, name, tps, totalframes, loop, startCallback, finishCallback)
	self.frame = 1
	self.name = name
	self.tps = tps
	self.loop = loop
	self.frames = totalframes
	self.startCallback = startCallback
	self.finishCallback = finishCallback

	self.display_name = name..1
end

// Animation Defination

PTAnimFunctions.NewAnimation = function(tag, name, tps, totalframes, loop, startCallback, finishCallback)
	if not (tag and name and tps and totalframes and loop) return end
	if animationtable[tag] animationtable[tag] = nil end
	local animation = {}

	animation.name = name
	animation.tps = tps
	animation.loop = loop
	animation.frame = 1
	animation.frames = totalframes
	animation.startCallback = startCallback
	animation.finishCallback = finishCallback

	animation.display_name = name..1

	animation.ChangeAnimation = ChangeAnimation
	animationtable[tag] = animation
end