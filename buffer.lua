local buffer = {}

local run = game:GetService("RunService")

function buffer.new()
	local core = {
		Callback = Instance.new("BindableEvent"),
		Storage = {}
	}
	
	function core:get(any)
		return self.Storage[any]
	end
	
	function core:bindUIS()
		assert(run:IsClient(),"bindUserInputService only for Client!")
		
		local UIS = game:GetService("UserInputService")
		
		UIS.InputBegan:Connect(function(input,gameplay)
			self.Storage[input.KeyCode] = true
			self.Callback:Fire(1,input.KeyCode)
		end)
		
		UIS.InputEnded:Connect(function(input,gameplay)
			self.Storage[input.KeyCode] = false
			self.Callback:Fire(0,input.KeyCode)
		end)
	end
	
	function core:bindBooleanWait(any,time:number,success:()->(),fail:()->()) : thread
		return task.spawn(function()
			local t,step,r = 0,100,true
			repeat
				r = self:get(any)
				t+=1 task.wait(1/step)
			until t == time*step or r == false
			if r == false then fail() else success() end
		end)
	end
	
	function core:addTimed(any,lifetime,value)
		if self.Storage[any]==nil then
			self:set(any,value)
			task.delay(lifetime,self:set(any,nil))
		end
	end
	
	function core:set(any,value)
		self.Storage[any] = value
	end
	
	return core
end

return buffer
