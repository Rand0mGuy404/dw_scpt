local drawer = { roots = { ["PlayerGui"] = game.Players.LocalPlayer.PlayerGui , ["Terrain"] = workspace.Terrain , ["Camera"] = workspace.Camera } }
function drawer.new(Camera,Root)
	local Controller = {
		__self = Instance.new("WireframeHandleAdornment",game.Players.LocalPlayer.PlayerGui),
		PropertyList = {"Color3","Transparency","AlwaysOnTop"},
		ToRender = {},BakedCorners={C0=nil,C1=nil,C2=nil,C3=nil,D01=0,D02=0,CenterCF=CFrame.new()},UIButtons={},Storage={},
		CurrentCamera = Camera
	}
	Controller.__self.Name = " "
	Controller.__self.Adornee = workspace:WaitForChild("Terrain")

	--------------------------------------------------
	function Controller:Box(Position,Sz,IsCrossed,hasDistance)
		local At = CFrame.new(Position,self.CurrentCamera.CFrame.Position)

		local corners = {
			At.Position + (At.RightVector*Sz+At.UpVector*Sz),
			At.Position + (-At.RightVector*Sz+At.UpVector*Sz),
			At.Position + (At.RightVector*Sz-At.UpVector*Sz),
			At.Position + (-At.RightVector*Sz-At.UpVector*Sz),
		}

		self.__self:AddLine(corners[1],corners[2])
		self.__self:AddLine(corners[3],corners[4])
		self.__self:AddLine(corners[1],corners[3])
		self.__self:AddLine(corners[2],corners[4])

		if IsCrossed then
			self.__self:AddLine(corners[1],corners[4])
			self.__self:AddLine(corners[2],corners[3])	
		end

		if hasDistance then
			Controller.__self:AddText(
				At.Position +
					(At.UpVector * (Sz + 1)) + 
					(At.RightVector * Sz), 
				math.round((Position-self.CurrentCamera.CFrame.Position).Magnitude) 
			)
		end
	end
	
	function Controller:GetStorage()
		return self.Storage
	end

	function Controller:Arrow(Origin,Direction,Offset)
		local At = CFrame.lookAlong(Origin,Direction)

		At += At.LookVector * Offset

		local function diamond(v,ofst) return {At.Position + (At.UpVector * v + ofst),At.Position + (-At.RightVector * v + ofst),At.Position + (-At.UpVector * v + ofst),At.Position + (At.RightVector * v + ofst)} end

		local D0,D1,D2,P0 = diamond(1,Vector3.zero),diamond(1,At.LookVector * 3),diamond(3,At.LookVector * 3),At.Position + (At.LookVector * 6)

		self.__self:AddLine(D0[1],D0[2])
		self.__self:AddLine(D0[2],D0[3])
		self.__self:AddLine(D0[3],D0[4])
		self.__self:AddLine(D0[4],D0[1])

		self.__self:AddLine(D0[1],D1[1])
		self.__self:AddLine(D0[2],D1[2])
		self.__self:AddLine(D0[3],D1[3])
		self.__self:AddLine(D0[4],D1[4])

		self.__self:AddLine(D1[1],D1[2])
		self.__self:AddLine(D1[2],D1[3])
		self.__self:AddLine(D1[3],D1[4])
		self.__self:AddLine(D1[4],D1[1])

		self.__self:AddLine(D1[1],D2[1])
		self.__self:AddLine(D1[2],D2[2])
		self.__self:AddLine(D1[3],D2[3])
		self.__self:AddLine(D1[4],D2[4])

		self.__self:AddLine(D2[1],D2[2])
		self.__self:AddLine(D2[2],D2[3])
		self.__self:AddLine(D2[3],D2[4])
		self.__self:AddLine(D2[4],D2[1])

		self.__self:AddLine(D2[1],P0)
		self.__self:AddLine(D2[2],P0)
		self.__self:AddLine(D2[3],P0)
		self.__self:AddLine(D2[4],P0)

	end

	function Controller:Property(Property,Value)
		if table.find(self.PropertyList,Property) then
			self.__self[Property] = Value
		end
	end

	function Controller:Add(Target,Function)
		self.ToRender[Target] = Function
	end

	function Controller:Rem(Target)
		self.ToRender[Target] = nil
	end

	function Controller:NextFrame()
		Controller.__self:Clear()

		for Part,Func in pairs(self.ToRender) do
			if Part.Parent ~= nil then
				Func(Part)
			else
				self.ToRender[Part] = nil
			end
		end

	end

	function Controller:bakeUICorners(drawBorders)
		local Cam : Camera = self.CurrentCamera
		local VSize = Cam.ViewportSize
		local distance = 0.01 -- distance in front of the camere

		local Ray0 = Cam:ViewportPointToRay(VSize.X,VSize.Y,1)
		local Ray1 = Cam:ViewportPointToRay(0,VSize.Y,1)
		local Ray2 = Cam:ViewportPointToRay(0,0,1)
		local Ray3 = Cam:ViewportPointToRay(VSize.X,0,1)
		local RayC = Cam:ViewportPointToRay(math.round(VSize.X/2),math.round(VSize.Y/2),1)

		local point0 = Ray0.Origin+Ray0.Direction*distance
		local point1 = Ray1.Origin+Ray1.Direction*distance
		local point2 = Ray2.Origin+Ray2.Direction*distance
		local point3 = Ray3.Origin+Ray3.Direction*distance
		local pointC = RayC.Origin+RayC.Direction

		local CCF = CFrame.lookAlong(pointC,RayC.Unit.Direction)

		self.BakedCorners = {C0=point0,C1=point1,C2=point2,C3=point3,D01=(point1-point0).Magnitude,D02=(point2-point0).Magnitude,CenterCF=CCF}

		if drawBorders == true then
			self.__self:AddLine(point0, point1)
			self.__self:AddLine(point1, point2)
			self.__self:AddLine(point2, point3)
			self.__self:AddLine(point3, point0)
		end
	end

	function Controller:ProcessClick(Position:Vector2)

		for TXT, ButtonData in pairs(self.UIButtons) do
			local C0, C2 = self.CurrentCamera:WorldToViewportPoint(ButtonData.C0), self.CurrentCamera:WorldToViewportPoint(ButtonData.C2)

			if Position.X <= C0.X and Position.X >= C2.X and Position.Y <= C0.Y and Position.Y >= C2.Y then
				print('Button clicked: ' .. TXT)
				ButtonData.func(self.Storage)
			end
		end
	end


	function Controller:Button(Text, Size, Position, func)
		local Baked = self.BakedCorners

		local top = Baked.C0:Lerp(Baked.C1, 1-Position.X)
		local bottom = Baked.C3:Lerp(Baked.C2, 1-Position.X)
		local Pos = bottom:Lerp(top, Position.Y)

		local Xs = ( (Size.Y/2) * Baked.D01)/2
		local Ys = ( (Size.X) * Baked.D02)
		local UV,RV = Baked.CenterCF.UpVector,Baked.CenterCF.RightVector

		local C0 = Pos - (UV*Xs) + (RV*Ys/2)
		local C1 = Pos - (UV*Xs) - (RV*Ys/2)
		local C2 = Pos + (UV*Xs) - (RV*Ys/2)
		local C3 = Pos + (UV*Xs) + (RV*Ys/2)

		self.__self:AddLine( C0 , C1 )
		self.__self:AddLine( C1 , C2 )

		self.__self:AddLine( C2 , C3 )
		self.__self:AddLine( C3 , C0 )

		Controller.__self:AddText( C0:Lerp(C2,0.5) ,Text)

		self.UIButtons[Text] = {
			C0=C0,C1=C1,C2=C2,C3=C3,func=func
		}
	end


	return Controller
end
