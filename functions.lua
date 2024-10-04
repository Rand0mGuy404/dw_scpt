local F = {}

local TS = game:GetService("TweenService")

function F.TweenModel(Player,Vector,SpeedMultiply)
	local distanceTime = (Player.PrimaryPart.Position - Vector).Magnitude
	local Speed = distanceTime/distanceTime*SpeedMultiply
	local tween = TweenInfo.new(Speed)

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = Player:GetPrimaryPartCFrame()

	CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		Player:SetPrimaryPartCFrame(CFrameValue.Value)
	end)

	local tween = TS:Create(CFrameValue, tween, {Value = CFrame.new(Vector)})
	tween:Play()

	tween.Completed:Connect(function()
		CFrameValue:Destroy()
	end)
end

function F.localSound(SoundId,volume)
	local Sound = Instance.new("Sound",game.Players.LocalPlayer.PlayerGui)
	Sound.SoundId = "rbxassetid://"..SoundId Sound.Volume = volume or 1
	Sound:Play()
	Sound.Ended:Connect(function() Sound:Destroy() end)
end

return F
