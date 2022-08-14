-- toggles
getgenv().clickToggle = false
getgenv().questToggle = false
getgenv().duraToggle = false
getgenv().gangToggle = false
getgenv().eatToggle = false
getgenv().buyToggle = false
getgenv().gloveToggle = false
getgenv().PBToggle = false
getgenv().equipToggle = false
getgenv().depositToggle = false
-- variables
local plr = game:GetService("Players").LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local path = PathfindingService:CreatePath()
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local minStam
local foodName
local covType,toolType
local bagNum, gloveCounter
local deliv = workspace.Quests.QuestLocations.Delivery
local cat = workspace.Quests.QuestLocations.Cat
local briefcase = workspace.Quests.QuestLocations.Briefcase
local keys = plr.PlayerGui.MainGui.Keys:GetChildren()
local pbRadius,pbAngle
local depositConnection
-- tables
local PBConnections = {}
local styleIdles = {
    Sumo = "rbxassetid://5650663387",
    Hitman = "rbxassetid://6527845323",
    Formless = "rbxassetid://8365652669",
    Shadow = "rbxassetid://10391318142",
    Wrestling = "rbxassetid://6337784130",
    Neji = "rbxassetid://5717759261",
    Leg = "rbxassetid://5293891962",
    LightFeather = "rbxassetid://10455623528",
    Muay = "rbxassetid://6340761251",
    Basic = "rbxassetid://10391318142",
    Boxing = "rbxassetid://5292922704",
    Karate = "rbxassetid://5757171053",
    RTKD = "rbxassetid://6068983753",
    Striker = "rbxassetid://7151923743",
    MasteredKarate = "rbxassetid://6723474934",
    Beast = "rbxassetid://6446460446",
    Sword = "rbxassetid://6379981122",
}
-- functions

local function supportEquip(tool) -- function to help find the tool to equip
    for i,v in pairs(plr.Backpack:GetChildren()) do
        if string.find(v.Name,tool,1,true) then
            if string.find(v.Name,tool,1,true) == 1 then
               return v 
            end
        end
    end
    return nil
end
local function getKeyFromIdles(value) -- help findStyle function get the key/style of the idle it found
    local style
    for i,v in pairs(styleIdles) do
        if v == value then
            style = i
        end
    end
    return style
end
local function findStyle(player) -- support auto pb to figure out length to wait before blocking
    local char = player.Character
    for i,v in pairs(char.Humanoid.Animator:GetPlayingAnimationTracks()) do
        if getKeyFromIdles(v.Animation.AnimationId) then
            return getKeyFromIdles(v.Animation.AnimationId)
        end
    end
end
local function block() -- auto block feature used in autoPB
    local args = {
        [1] = "Block",
        [2] = game:GetService("Players").LocalPlayer.Character.LocalHandler.Blocking,
        [3] = true
    }
    game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
    wait(0.1) -- default wait to block just in case :D
    args = {
        [1] = "Block",
        [2] = game:GetService("Players").LocalPlayer.Character.LocalHandler.Blocking,
        [3] = false
    }
    game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
end
local function stringCombineToNumber(str)
    local guiThing = plr.PlayerGui.MainGui
    local table = string.split(string.sub(str,2),",")
    local number = tonumber(table[1])
    if #table > 1 then
        number = tonumber(number..table[2])
    end
    return number
end
local funcs = { -- list of functions
    autoQuest = function() -- done
        while questToggle do
            local char = plr.Character or plr.CharacterAdded:Wait()
            local quest = char:FindFirstChild("Quest")
            if quest ~= nil then
                if quest.PlayerQuest.Value == "Cat" or quest.PlayerQuest.Value == "Briefcase" or quest.PlayerQuest.Value == "Delivery" then
                    local loc =  quest.Location.Value
                    if quest.PlayerQuest.Value == "Briefcase" then
                        local case = briefcase:FindFirstChild(tostring(loc)).Case
                        local pp = briefcase:FindFirstChild(tostring(loc)).ProximityPrompt
                        repeat 
                            char.HumanoidRootPart.CFrame = case.CFrame 
                            fireproximityprompt(pp,32)
                            wait()
                        until char:FindFirstChild("Quest") == nil or quest.Objective.Value
                    else
                        if quest.PlayerQuest.Value == "Cat" then
                            local place = cat[tostring(loc)]
                            local pp = place.ProximityPrompt
                            repeat 
                                char.HumanoidRootPart.CFrame = place.CFrame 
                                fireproximityprompt(pp,10)
                                wait()
                            until char:FindFirstChild("Quest") == nil or quest.Objective.Value
                        else
                            local place = deliv[tostring(loc)]
                            repeat 
                                char.HumanoidRootPart.CFrame = place.CFrame + place.CFrame.UpVector * -2
                                firetouchinterest(char.HumanoidRootPart,place,0)
                                firetouchinterest(char.HumanoidRootPart,place,1)
                                wait()
                            until char:FindFirstChild("Quest") == nil or quest.Objective.Value
                        end
                    end
                else
                    quest:Destroy()
                end
            else
                local args = {
                    [1] = "Quest"
                }
                game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                char.ChildAdded:Wait()
            end
            wait()
        end
    end,
    autoDeposit = function() -- check but prob works
        if depositToggle then
            depositConnection = plr.PlayerGui.MainGui.Cash.Changed:Connect(function()
                local guiThing = plr.PlayerGui.MainGui
                local number = stringCombineToNumber(guiThing.Cash.Text)
                local bankNumber = stringCombineToNumber(guiThing.Bank.Cash.Text)
                local moneyToDeposit = number
                if (number + bankNumber) > 300000 then
                    moneyToDeposit = 300000 - bankNumber
                else
                    if bankNumber >= 300000 then
                        moneyToDeposit =0
                    end
                end
                local args = {
                [1] = "Deposit",
                [2] = moneyToDeposit
                }
                game:GetService("ReplicatedStorage").Bank:InvokeServer(unpack(args))
            end)    
        else
            if depositConnection ~= nil then
                depositConnection:Disconnect()
            end
        end
    end,
    autoDura = function() -- done
        while duraToggle do
            for i,v in pairs(workspace.TrainingStations:GetChildren()) do 
                fireproximityprompt(v.Main.ProximityPrompt,5)
            end  
            wait(1/workspace:GetRealPhysicsFPS())
        end
        
    end,
    autoEat = function() -- done
        while eatToggle do
            for i,v in pairs(plr.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.Name == foodName then 
                    local char = plr.Character
                    char.Humanoid:EquipTool(v)
                    char:FindFirstChild(v.Name):Activate()
                    break;
                end
            end
            if foodName == "Burger" or foodName == "Ramen" then
                wait(540)
            else
                plr.PlayerGui.MainGui.Boosts.ChildRemoved:Wait()
            end
        end
    end,
    autoBuyFood = function() -- done
        while buyToggle do
            for i,v in pairs(workspace.Items:GetDescendants()) do
                if string.find(v.Name, foodName) then 
                    fireproximityprompt(v.Head.ProximityPrompt,12)
                end
            end
            wait(1/workspace:GetRealPhysicsFPS())
        end
    end,
    autoGloves = function() -- done
        while gloveToggle do
            local char = plr.Character
            local bag = workspace["Punching Bags"]:GetChildren()[bagNum]
            if char:FindFirstChild("LeftGloves") then
                wait(1/workspace:GetRealPhysicsFPS())
                continue
            else
                if char:FindFirstChild("Combat") then
                    char.Humanoid:UnequipTools()
                end
            end
            if char:FindFirstChild(foodName) and char:FindFirstChild("LeftGloves") then
                char.Humanoid:UnequipTools()
                char.Humanoid:EquipTool(plr.Backpack.Combat)
            end
            if plr.Backpack:FindFirstChild("Gloves") then
                -- walk
                local success,error = pcall(function()
                    path:ComputeAsync(char.HumanoidRootPart.Position, bag.HumanoidRootPart.Position)
                end)
                if success then
                    for i,v in ipairs(path:GetWaypoints()) do
                        if v.Action == Enum.PathWaypointAction.Jump then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        char.Humanoid:MoveTo(v.Position)
                        char.Humanoid.MoveToFinished:Wait()
                    end
                end
                if not char:FindFirstChild("Gloves") then 
                    char.Humanoid:EquipTool(plr.Backpack:FindFirstChild("Gloves"))
                end
                if not char:FindFirstChild("LeftGloves") then
                    char:FindFirstChild("Gloves"):Activate()
                end
                char.Humanoid:UnequipTools()
                char.Humanoid:EquipTool(plr.Backpack.Combat)
            else
                gloveCounter = 0
                for i,v in pairs(workspace.Items:GetDescendants()) do
                    if v.Name == "Gloves $75" then
                        if gloveCounter == 0 then
                            gloveCounter = gloveCounter + 1
                        else
                            local success,error = pcall(function()
                                path:ComputeAsync(char.HumanoidRootPart.Position, v.Head.Position)
                            end)
                            if success then
                                for i,v in ipairs(path:GetWaypoints()) do
                                    if v.Action == Enum.PathWaypointAction.Jump then
                                        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                    char.Humanoid:MoveTo(v.Position)
                                    char.Humanoid.MoveToFinished:Wait()
                                end
                            end
                            fireproximityprompt(v.Head.ProximityPrompt,12)
                        end
                    end
                end
            end
            wait(1/workspace:GetRealPhysicsFPS())
        end
    end,
    autoClick = function() -- done
        while clickToggle do
            local char = plr.Character
            if  plr.Stamina.Value <= minStam then
                repeat wait() until plr.Stamina.Value >= tonumber(string.split(plr.PlayerGui.MainGui.StatusFrame.Stamina.stat.Text,"/")[2])
            else
                if char:FindFirstChild("Meditate") then
                    for i,v in pairs(keys) do
                        if v.Visible then
                            VIM:SendKeyEvent(true,Enum.KeyCode[string.upper(v.Name)],false,game)
                            VIM:SendKeyEvent(false,Enum.KeyCode[string.upper(v.Name)],false,game)
                        end
                    end
                else
                    if char:FindFirstChild("Gloves") then wait(1/workspace:GetRealPhysicsFPS()) continue end
                    if covType == "Gloves" and not equipToggle then 
                        if not char:FindFirstChild("LeftGloves") then 
                            wait(1/workspace:GetRealPhysicsFPS()) 
                            continue 
                        end
                    end
                    VIM:SendMouseButtonEvent(1, 1, 0, true, game, 1)
                    VIM:SendMouseButtonEvent(1, 1, 0, false, game, 1)
                end
                wait(1/workspace:GetRealPhysicsFPS())
            end
        end
    end,
    autoPB = function() -- done
        if PBToggle then
            for i,v in pairs(game:GetService("Players"):GetChildren()) do
                if v == plr then continue end
                PBConnections[v:FindFirstChild("Combo")] = v.Combo.Changed:Connect(function()
                    if v.Combo.Value == 1 then return end
                    local yourHuman = v.Character
                    local otherHuman = plr.Character -- variable names flipped due to laziness
                    if (yourHuman.HumanoidRootPart.Position - otherHuman.HumanoidRootPart.Position).Magnitude <= tonumber(pbRadius) then
                        local dot = (yourHuman.Head.Position - otherHuman.Head.Position).Unit:Dot(otherHuman.Head.CFrame.LookVector)
                        if dot >= (-math.cos(math.rad(pbAngle))) -1 and dot <= math.cos(math.rad(pbAngle)) + 1 then
                            local style = findStyle(v)
                            if style == "Basic" or style == "LightFeather" or style == "Boxing" or style == "Hitman" or style == "Wrestling" or style == "Muay" or style == "Shadow" or style == "Karate" then -- put all styles and waits here
                                delay(0.2,function()
                                    block()
                                end)
                            else
                                if style == "Sumo" or style == "Leg" then
                                    delay(0.3,function()
                                        block()
                                    end)
                                else
                                    if style == "RTKD" or style == "Neji" or style == "Formless" then
                                        delay(0.1,function()
                                            block()
                                        end)
                                    end
                                end -- breaks if game is running too long lmao
                            end
                        end
                    end
                end)
            end
        else
            for i,v in pairs(PBConnections) do
                v:Disconnect()
            end
        end
    end,
    autoEquip = function() -- done
        while equipToggle do
            local char = plr.Character
            local yes
            yes = supportEquip(toolType)
            if yes and not char:FindFirstChild(yes.Name) then
                char:WaitForChild("Humanoid"):EquipTool(yes)
            end
            wait(1/workspace:GetRealPhysicsFPS())
        end
    end,
    delMouse = function() -- done
        pcall(function()
            game:GetService("UserInputService").MouseIconEnabled = true
            game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
            plr.PlayerGui.MouseGui:Destroy()  
        end)
    end,
    AntiAFK = function() -- done
        pcall(function()
            for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
                v:Disable()
            end
        end)
        
    end,
}
local function findFunc(name) -- function to find functions within the table from a string
    for i,v in pairs(funcs) do
        if string.find(i,name) then return i end
    end
end
local Window = OrionLib:MakeWindow({Name = "Tatakai V DOGSHIT", HidePremium = true}) -- gui creation
local Tab = Window:MakeTab({
	Name = "Farms",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab:AddToggle({ -- Toggle for non tool trainings
	Name = "Coventional Grind",
	Default = false,
	Callback = function(Value)
        if covType == "Pullups" then
            duraToggle = Value
            funcs[findFunc("Dura")]()
        else
            if covType == "Gloves" then
                gloveToggle = Value
                funcs[findFunc("Gloves")]()
            else
                if covType == "Money" then
                    questToggle = Value
                    funcs[findFunc("Quest")]()
                end
            end
        end
    end
})
Tab:AddDropdown({
	Name = "Type",
	Default = "Pullups",
	Options = {"Pullups","Gloves", "Money","Gang"},
	Callback = function(Value)
		covType = Value
	end    
})
Tab:AddDropdown({
	Name = "Bag Select (ignore if not doing bags)",
	Default = 1,
	Options = {1,2,3,4,5,6,7,8},
	Callback = function(Value)
		bagNum = Value
	end    
})
Tab:AddToggle({
	Name = "Auto Deposit",
	Default = false,
	Callback = function(Value)
        depositToggle = Value
        funcs[findFunc("Deposit")]()
    end
})
Tab:AddToggle({
	Name = "Tool Grind",
	Default = false,
	Callback = function(Value)
        equipToggle = Value
		funcs[findFunc("Equip")]()
    end
})
Tab:AddDropdown({
	Name = "Tool",
	Default = "Squat",
	Options = {"Squat","Situp", "Pushup","Meditate","Jumping Rope","20 KG Dumbbell","50 KG Dumbbell","100 KG Dumbbell","200 KG Dumbbell","One-Hand", "Handstand","Burpee"},
	Callback = function(Value)
		toolType = Value
	end    
})
local Tab2 = Window:MakeTab({
    Name = "Mouse/Click",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab2:AddSlider({
	Name = "Minimum Stamina",
	Min = 0,
	Max = 1000,
	Default = 50,
	Color = Color3.fromRGB(0, 247, 255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		minStam = Value
	end    
})
Tab2:AddBind({
	Name = "Auto Click",
	Default = Enum.KeyCode.T,
	Hold = false,
	Callback = function()
		clickToggle = not clickToggle
        local title = "Auto Click" .. " " .. tostring(clickToggle)
        OrionLib:MakeNotification({
            Name = title,
            Content = "KADO A BITCH AND A HALF NO CAP",
            Image = "rbxassetid://4483345998",
            Time = 10
        })
        funcs[findFunc("Click")]()
	end    
})
Tab2:AddButton({
	Name = "Fix Mouse",
	Callback = function()
        funcs[findFunc("Mouse")]()
  	end    
})
local Tab3 = Window:MakeTab({
	Name = "Food",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab3:AddToggle({
	Name = "Auto Eat",
	Default = false,
	Callback = function(Value)
	    eatToggle = Value
        OrionLib:MakeNotification({
            Name = "Bro.",
            Content = "WHICH FUCKING RETARD WANTS TO EAT ANYTHING ASIDE FROM RAMEN, BURGER OR PROTEIN",
            Image = "rbxassetid://4483345998",
            Time = 10
        })
        funcs[findFunc("Eat")]()
    end
})
Tab3:AddToggle({
    Name = "Auto Buy",
    Default = false,
    Callback = function(Value)
        buyToggle = Value
        OrionLib:MakeNotification({
            Name = "DIE U A WHOLE ASS BITCH",
            Content = "I BET U FUCK BLOCKS OF CHEESE EVERYDAY U MANWHORE",
            Image = "rbxassetid://4483345998",
            Time = 10
        })
        funcs[findFunc("Buy")]()
    end
})
Tab3:AddDropdown({
	Name = "Food to auto eat/buy",
	Default = "Protein Shake",
	Options = {"Protein Shake","Burger","Ramen"},
	Callback = function(Value)
		foodName = Value
	end    
})
local Tab4 = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab4:AddToggle({
    Name = "Auto PB",
    Default = false,
    Callback = function(Value)
        PBToggle = Value
        if not PBToggle then
            OrionLib:MakeNotification({
                Name = "W GAME",
                Content = "games so bad that half the time animations aren't loaded so if it dont work prob that's why",
                Image = "rbxassetid://4483345998",
                Time = 7
            })
        end
        funcs[findFunc("PB")]()
    end
})
Tab4:AddSlider({
	Name = "Auto PB Range",
	Min = 5,
	Max = 20,
	Default = 12,
	Color = Color3.fromRGB(89, 0, 255),
	Increment = .5,
	ValueName = "",
	Callback = function(Value)
		pbRadius = Value
	end    
})
Tab4:AddSlider({
	Name = "Auto PB Angle (from where they're looking)",
	Min = 0,
	Max = 180,
	Default = 45,
	Color = Color3.fromRGB(89, 0, 255),
	Increment = .5,
	ValueName = "",
	Callback = function(Value)
		pbAngle = Value
	end    
})
Tab4:AddButton({
	Name = "Anti AFK",
	Callback = function()
        funcs[findFunc("AFK")]()
        OrionLib:MakeNotification({
            Name = "Anti AFK",
            Content = "YOU FUCKING SUCK KADO SUCK MY DICK YOU STUPID FAGGOT ACTUALLY",
            Image = "rbxassetid://4483345998",
            Time = 10
        })
  	end    
})
plr.CharacterAdded:Connect(function(char) -- after death keep farmin money
    wait(6)
    funcs[findFunc("Quest")]()
end)
OrionLib:Init()
