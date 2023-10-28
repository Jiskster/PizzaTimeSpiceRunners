addHook('NetVars', function(net)
	animationtable = net($)
end)

addHook('ThinkFrame', function()
	// Animation Thinker
	for _,self in pairs(animationtable)
		if self.bar continue end
		if not (leveltime % self.tps)
			if self.frame < self.frames
				self.frame = $+1
			elseif self.loop
				self.frame = 1

				if self.finishCallback
					self:finishCallback()
				end
			elseif self.finishCallback
				self:finishCallback()
			end

			self.display_name = self.name..self.frame
		end
	end
end)