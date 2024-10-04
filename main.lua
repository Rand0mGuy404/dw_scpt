local __drawer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rand0mGuy404/dw_scpt/blob/main/drawer.lua"))()
local drawer = __drawer.new(workspace.CurrentCamera,__drawer.roots.Terrain)
local __buffer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rand0mGuy404/dw_scpt/blob/main/buffer.lua"))()
local buffer = __buffer.new()
local Funcs = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rand0mGuy404/dw_scpt/blob/main/functions.lua"))()
local ItemList = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rand0mGuy404/dw_scpt/blob/main/itemlist.lua"))()
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
local BaseColor = Color3.new(0.45, 0, 1)
local EnemyColor = Color3.new(1,0,0)
local PlayerColor = Color3.new(0,0,1)
local WorkbenchColor = Color3.new(1,1,1)
local CooldownColor = Color3.new(1,0,0)
--------------------------------------------------------------------------------------------------------------------------------------
local itemPos,ItemId = 0,"AlrGun"
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
local Player = game.Players.LocalPlayer
local TextExtraINFO = "NONE"

drawer:Add(Player.PlayerGui,function(_)
	drawer:Property("Color3", (buffer:get("Cooldown")~=true and BaseColor) or CooldownColor )
	drawer:Property("AlwaysOnTop",true)
	drawer:bakeUICorners(false)
	
	local Baked = drawer:getBakedCorners()
	local Centr = Baked.CenterCF.Position
	
	local length,height,scale = 0.015,0.85,0.65
	
	local C3 = Centr:Lerp(Baked.S2,height)
	local _A,_B = Baked.C3:Lerp(Centr,length),Baked.C2:Lerp(Centr,length)
	local AB = _A:Lerp(_B,0.5)
	local A,B = _A:Lerp(AB,scale),_B:Lerp(AB,scale)
	
	drawer:Line(A,B) drawer:Line(C3,A) drawer:Line(C3,B)
	drawer:Text(AB:Lerp(C3,0.5):Lerp(B,0.15),"EXO-227",20)
	
	drawer:Property("Color3",Color3.new(1,1,1))
	drawer:Text(C3:Lerp(Centr,0.15):Lerp(B,0.15+(string.len(TextExtraINFO)/100)),TextExtraINFO,20)
end)

local function HighlightAll(StorageService,StorageName,callback:(Instance)->(boolean,{}) )
	if StorageService[StorageName] == nil then local t = {}
		for _,H in pairs(workspace:GetDescendants()) do
			local success,result,root = callback(H)
			
			if success == true then
				drawer:Add(root,result)
				table.insert(t,root)
			end
			
		end
		StorageService[StorageName] = t
	else
		for _,v in pairs(StorageService[StorageName]) do
			drawer:Rem(v)
		end
		StorageService[StorageName] = nil
	end
end

local function nearestWorkbench(Pos)
	local function mg(p) return (p-Pos).Magnitude end
	local sort = {}
	for _,v in pairs(workspace.Interactables:GetChildren()) do
		if v.Name == "Workbench" then
			table.insert(sort,v)
		end
	end

	if #sort>1 then
		table.sort(sort,function(a,b)
			return mg(a:GetPivot().Position) < mg(b:GetPivot().Position)
		end)
	end

	return sort[1]
end

buffer:bindUIS()
buffer.Callback.Event:Connect(function(HoldType:number,Keycode:Enum.KeyCode)
	if buffer:get(Enum.KeyCode.LeftAlt) == true and buffer:get("Cooldown")~=true then
		
		if Keycode == Enum.KeyCode.Z and HoldType == 1 then buffer:set("Cooldown",true)
			HighlightAll(drawer:GetStorage(),"HighlightExtra",function(inst)
				if inst:IsA("Humanoid") and inst.Parent:IsA("Model") and inst.Parent.PrimaryPart~= nil and inst.Parent ~= Player.Character then
					task.wait(.1)
					local isPlayer = game.Players:FindFirstChild(inst.Parent.Name) ~= nil
					local Clr = (isPlayer and PlayerColor) or EnemyColor
					Funcs.localSound( (isPlayer and 6676218296) or 6676218124 ,0.1)
					
					return true,function(BasePart)
						drawer:Property("Color3",Clr)
						drawer:Property("AlwaysOnTop",true)
						drawer:Box(BasePart.Position,math.max(BasePart.Size.X,BasePart.Size.Y,BasePart.Size.Z),true,true)
					end,inst.Parent.PrimaryPart
				elseif inst.Name == "Workbench" and inst:IsA("Model") then
					Funcs.localSound(6676218222,0.1)
					return true,function(BasePart)
						drawer:Property("Color3",WorkbenchColor)
						drawer:Property("AlwaysOnTop",true)
						drawer:Box(inst:GetPivot().Position,5,true,true)
					end,inst
				end
				return false,nil,nil
			end)
			task.delay(1,function() buffer:set("Cooldown",false) end)
		elseif Keycode == Enum.KeyCode.V and HoldType == 1 then
			
			task.spawn(function()
				buffer:bindBooleanWait(Enum.KeyCode.V,0.25,function()
					local _,WB = pcall(nearestWorkbench,Player.Character.PrimaryPart.Position)
					WB = WB or workspace.Interactables:FindFirstChild("Workbench")
					
					buffer:set("Cooldown",true) 
					if (WB:GetPivot().Position-Player.Character.PrimaryPart.Position).Magnitude<10 then
						game:GetService("ReplicatedStorage").Interactables.interaction:FireServer(unpack({
							[1] = WB,
							[2] = "workbenchblueprint"..ItemId,
						}
						))
						Funcs.localSound(6676218222,0.1)
					end
					task.delay(1,function() buffer:set("Cooldown",false) end)

				end,function()
					if itemPos>=#ItemList then itemPos=1 else itemPos+=1 end
					local next = ItemList[itemPos]

					Funcs.localSound(6676218222,0.1)
					ItemId = next[1]
					TextExtraINFO = "ITEM: "..next[2]
				end)
			end)
		end
	end
end)

game:GetService("RunService").RenderStepped:Connect(function(delta)
	drawer:NextFrame() task.wait(0.1)
end)
