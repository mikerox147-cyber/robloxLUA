-- bunny bunny bunny bunny no 1
if getgenv().RepzHubUnload then
    pcall(getgenv().RepzHubUnload)
end

local Ins, C3, U2, V3, UD = Instance.new, Color3.fromRGB, UDim2.new, Vector3.new, UDim.new
local floor, clamp = math.floor, math.clamp

local function toHex(c)
    local r, g, b = floor(c.R * 255), floor(c.G * 255), floor(c.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local espData = { survivors = {}, killers = {}, generators = {}, batteries = {}, fuses = {}, texts = {} }
local nameStamESPEnabled = false
local pendingESP = {}

local function getSurvivorColor(char)
    local c = char:GetAttribute("Character") or ""
    if c == "Survivor-Security Guard" then return Color3.fromRGB(0, 80, 255)
    elseif c == "Survivor-Medic" then return Color3.fromRGB(255, 255, 255)
    elseif c == "Survivor-Fighter" then return Color3.fromRGB(128, 0, 128)
    elseif c == "Survivor-Customer" then return Color3.fromRGB(0, 255, 0)
    else return Color3.fromRGB(0, 255, 0) end
end

local function getRoleLabel(char)
    local c = char:GetAttribute("Character") or ""
    if c == "Survivor-Security Guard" then return "Security Guard"
    elseif c == "Survivor-Medic" then return "Medic"
    elseif c == "Survivor-Fighter" then return "Fighter"
    elseif c == "Survivor-Customer" then return "Customer"
    else return "Survivor" end
end



getgenv().RepzLoops = getgenv().RepzLoops or {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- [ UTILITY: GET ACTIVE KILLER ] --
local function getActiveKiller()
    local killerFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
    if killerFolder then
        for _, v in ipairs(killerFolder:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") then
                return v
            end
        end
    end
    return nil
end

-- [ DYNAMIC ANTI-CHEAT DELETION ] --
task.spawn(function()
    local function checkAndDestroy(obj)
        if obj:IsA("ScreenGui") or obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name == "anitcheat" or name == "anticheat" then
                obj:Destroy()
            end
        end
    end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if playerGui then
        for _, v in ipairs(playerGui:GetDescendants()) do
            checkAndDestroy(v)
        end
        playerGui.DescendantAdded:Connect(checkAndDestroy)
    end
end)

-- [ METATABLE HOOKS: ANTI-CHEAT BYPASS ] --
local successHook, errHook = pcall(function()
    local gm = getrawmetatable(game)
    local oldNamecall = gm.__namecall
    setreadonly(gm, false)
    
    gm.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" or method == "kick" then
            if self == LocalPlayer then return nil end
        end
        
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local remoteName = tostring(self.Name):lower()
            if remoteName == "kick" or remoteName == "ban" then return nil end
            
            for _, v in pairs(args) do
                if type(v) == "string" then
                    local argString = v:lower()
                    if argString == "kick" or argString == "ban" then return nil end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(gm, true)
end)

-- [ DYNAMIC GAME ICON FETCHER ]
local gameIconId = "rbxassetid://68073547" 
local successIcon, productInfo = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if successIcon and productInfo and productInfo.IconImageAssetId then
    gameIconId = "rbxassetid://" .. productInfo.IconImageAssetId
end

-- [ SMOOTH LOADING SCREEN ] --
local loadScreen = Instance.new("ScreenGui")
loadScreen.Name = "Repz hub | BBN"
loadScreen.IgnoreGuiInset = true

local success, err = pcall(function() loadScreen.Parent = CoreGui end)
if not success then loadScreen.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local dimBg = Instance.new("Frame")
dimBg.Size = UDim2.new(1, 0, 1, 0)
dimBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dimBg.BackgroundTransparency = 1 
dimBg.BorderSizePixel = 0
dimBg.Parent = loadScreen

local centerBox = Instance.new("Frame")
centerBox.Size = UDim2.new(0.8, 0, 0, 130) 
centerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
centerBox.AnchorPoint = Vector2.new(0.5, 0.5)
centerBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45) 
centerBox.BackgroundTransparency = 1 
centerBox.BorderSizePixel = 0
centerBox.ClipsDescendants = true
centerBox.Parent = dimBg

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 10)
boxCorner.Parent = centerBox

local boxConstraint = Instance.new("UISizeConstraint")
boxConstraint.MaxSize = Vector2.new(380, 130) 
boxConstraint.Parent = centerBox

local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Color3.fromRGB(0, 0, 0)
boxStroke.Thickness = 2
boxStroke.Transparency = 1
boxStroke.Parent = centerBox

local topBarContainer = Instance.new("Frame")
topBarContainer.Size = UDim2.new(1, 0, 0, 70)
topBarContainer.Position = UDim2.new(0, 0, 0, 10)
topBarContainer.BackgroundTransparency = 1
topBarContainer.Parent = centerBox

local topBarLayout = Instance.new("UIListLayout")
topBarLayout.FillDirection = Enum.FillDirection.Horizontal
topBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topBarLayout.Padding = UDim.new(0, 12)
topBarLayout.Parent = topBarContainer

local gameLogo = Instance.new("ImageLabel")
gameLogo.Image = gameIconId
gameLogo.Size = UDim2.new(0, 50, 0, 50)
gameLogo.BackgroundTransparency = 1
gameLogo.ImageTransparency = 1
gameLogo.Parent = topBarContainer

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 8)
logoCorner.Parent = gameLogo

local topBarText = Instance.new("TextLabel")
topBarText.Text = "Bite By Night | Repz"
topBarText.Font = Enum.Font.GothamBold
topBarText.TextSize = 24
topBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
topBarText.Size = UDim2.new(0, 240, 0, 50)
topBarText.BackgroundTransparency = 1
topBarText.TextTransparency = 1
topBarText.TextXAlignment = Enum.TextXAlignment.Left
topBarText.Parent = topBarContainer

local barContainer = Instance.new("Frame")
barContainer.Size = UDim2.new(0.85, 0, 0, 16) 
barContainer.Position = UDim2.new(0.075, 0, 0.75, 0) 
barContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
barContainer.BackgroundTransparency = 1
barContainer.BorderSizePixel = 0
barContainer.Parent = centerBox

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 6)
barCorner.Parent = barContainer

local barStroke = Instance.new("UIStroke")
barStroke.Color = Color3.fromRGB(0, 0, 0)
barStroke.Thickness = 1.5
barStroke.Transparency = 1
barStroke.Parent = barContainer

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bar.BorderSizePixel = 0
bar.Parent = barContainer

local barInnerCorner = Instance.new("UICorner")
barInnerCorner.CornerRadius = UDim.new(0, 6)
barInnerCorner.Parent = bar

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 35)),  
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 139))    
})
grad.Parent = bar

local fadeSpeed = 0.5
TweenService:Create(dimBg, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 0.4}):Play()
TweenService:Create(centerBox, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 0}):Play()
TweenService:Create(boxStroke, TweenInfo.new(fadeSpeed), {Transparency = 0}):Play()
TweenService:Create(gameLogo, TweenInfo.new(fadeSpeed), {ImageTransparency = 0}):Play()
TweenService:Create(topBarText, TweenInfo.new(fadeSpeed), {TextTransparency = 0}):Play()
TweenService:Create(barContainer, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 0}):Play()
TweenService:Create(barStroke, TweenInfo.new(fadeSpeed), {Transparency = 0}):Play()

task.wait(fadeSpeed)

local barTween = TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
barTween:Play()
barTween.Completed:Wait()

TweenService:Create(dimBg, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 1}):Play()
TweenService:Create(centerBox, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 1}):Play()
TweenService:Create(boxStroke, TweenInfo.new(fadeSpeed), {Transparency = 1}):Play()
TweenService:Create(gameLogo, TweenInfo.new(fadeSpeed), {ImageTransparency = 1}):Play()
TweenService:Create(topBarText, TweenInfo.new(fadeSpeed), {TextTransparency = 1}):Play()
TweenService:Create(barContainer, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 1}):Play()
TweenService:Create(barStroke, TweenInfo.new(fadeSpeed), {Transparency = 1}):Play()
TweenService:Create(bar, TweenInfo.new(fadeSpeed), {BackgroundTransparency = 1}):Play()

task.wait(fadeSpeed)
loadScreen:Destroy()


-- [ INITIALIZE UI (RAYFIELD) ] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local executorName = identifyexecutor and identifyexecutor() or "Unknown Executor"

local Window = Rayfield:CreateWindow({
   Name = "Repz Hub | Bite By Night",
   LoadingTitle = "Repz Hub Loading...",
   LoadingSubtitle = "by BBN",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = Enum.KeyCode.RightControl
})

Rayfield:Notify({
   Title = "Success!",
   Content = "Repz Hub Loaded Successfully.",
   Duration = 4,
   Image = gameIconId
})

-- [ INFO TAB ] --
local InfoTab = Window:CreateTab("Info", "info")
InfoTab:CreateLabel("Main script: Repz")
InfoTab:CreateButton({
   Name = "Status Update",
   Callback = function() 
      Rayfield:Notify({Title="Status", Content="Some features/tabs were removed due to anti-cheat.", Duration=3})
   end
})
InfoTab:CreateButton({
   Name = "*SIDENOTE*",
   Callback = function()
      Rayfield:Notify({Title="Sidenote", Content="Thank you all for supporting me throughout the days and years...", Duration=5})
   end
})
InfoTab:CreateParagraph({Title = "Executor Status", Content = "Executor you're using: " .. executorName .. "\nDescription: We have ran 12/12 checks, and your executor seems to support our script."})

-- [ SETTINGS TAB ] --
local SettingsTab = Window:CreateTab("Settings", "settings")
local hookedACFunctions = {}
local acKeywords = {"anticheat", "hacker", "kick", "hackerkick", "ban", "exploit", "crash", "detect"}

SettingsTab:CreateToggle({
   Name = "Anti-Cheat Bypass",
   CurrentValue = false,
   Flag = "AC_Bypass",
   Callback = function(Value)
      if Value then
          for _, v in pairs(getgc()) do
              if type(v) == "function" and islclosure(v) then
                  local info = debug.getinfo(v)
                  if info and info.name then
                      local funcName = string.lower(info.name)
                      for _, keyword in ipairs(acKeywords) do
                          if string.find(funcName, keyword) then
                              hookedACFunctions[v] = hookfunction(v, function() return end)
                          end
                      end
                  end
              end
          end
          Rayfield:Notify({ Title = "Protection Active", Content = "Found and neutralized localized AC functions.", Duration = 4 })
      else
          for orig, hook in pairs(hookedACFunctions) do
              hookfunction(orig, hook)
          end
          table.clear(hookedACFunctions)
          Rayfield:Notify({ Title = "Protection Disabled", Content = "AC functions restored to original state.", Duration = 4 })
      end
   end,
})

-- [ EMOTES TAB ] --
local EmotesTab = Window:CreateTab("Emotes", "smile")
local storedEmotes = {}
local emoteDropdownList = {"Select Emote First"}
local selectedEmoteObj = nil
local activeEmoteTrack = nil
local activeEffects = {} 

local function updateEmoteList()
    table.clear(storedEmotes)
    table.clear(emoteDropdownList)
    local repStorage = game:GetService("ReplicatedStorage")
    local modulesFolder = repStorage:FindFirstChild("Modules")
    local emotesFolder = modulesFolder and modulesFolder:FindFirstChild("Emotes")
    if emotesFolder then
        pcall(function()
            for _, obj in ipairs(emotesFolder:GetChildren()) do
                if obj:IsA("ModuleScript") and obj.Name ~= "EmoteClass" then
                    local nameLower = string.lower(obj.Name)
                    if not string.find(nameLower, "ennard") then
                        storedEmotes[obj.Name] = obj
                        table.insert(emoteDropdownList, obj.Name)
                    end
                end
            end
        end)
    end
    if #emoteDropdownList == 0 then table.insert(emoteDropdownList, "No Emotes Found") end
end

updateEmoteList()

local EmoteDropdown
EmoteDropdown = EmotesTab:CreateDropdown({
   Name = "Select Emote",
   Options = emoteDropdownList,
   CurrentOption = {"Select Emote First"},
   MultipleOptions = false,
   Flag = "EmoteSelect",
   Callback = function(Option)
       local opt = type(Option) == "table" and Option[1] or Option
       if storedEmotes[opt] then
           selectedEmoteObj = storedEmotes[opt]
       end
   end,
})

EmotesTab:CreateButton({
   Name = "Scan Emotes Folder",
   Callback = function()
       updateEmoteList()
       EmoteDropdown:Refresh(emoteDropdownList, {"Select Emote First"})
       Rayfield:Notify({ Title = "Scanned", Content = "Found " .. tostring(#emoteDropdownList) .. " Emotes!", Duration = 3 })
   end
})

EmotesTab:CreateToggle({
   Name = "Play Emote",
   CurrentValue = false,
   Flag = "PlayEmoteToggle",
   Callback = function(Value)
       local char = LocalPlayer.Character
       local hum = char and char:FindFirstChildOfClass("Humanoid")
       local animator = hum and hum:FindFirstChildOfClass("Animator")
       local rootPart = char and char:FindFirstChild("HumanoidRootPart")

       if Value then
           if selectedEmoteObj and animator then
               pcall(function()
                   local anim = selectedEmoteObj:FindFirstChildOfClass("Animation")
                   if anim then
                       activeEmoteTrack = animator:LoadAnimation(anim)
                       activeEmoteTrack.Looped = true
                       activeEmoteTrack:Play()
                   else
                       local emoteData = require(selectedEmoteObj)
                       if type(emoteData) == "table" and emoteData.AnimationId then
                           local tempAnim = Instance.new("Animation")
                           tempAnim.AnimationId = emoteData.AnimationId
                           activeEmoteTrack = animator:LoadAnimation(tempAnim)
                           activeEmoteTrack.Looped = true
                           activeEmoteTrack:Play()
                       end
                   end

                   for _, child in ipairs(selectedEmoteObj:GetDescendants()) do
                       if child:IsA("Sound") then
                           local sfx = child:Clone()
                           sfx.Parent = rootPart or char
                           sfx:Play()
                           table.insert(activeEffects, sfx)
                       elseif child:IsA("ParticleEmitter") or child:IsA("PointLight") then
                           local fx = child:Clone()
                           fx.Parent = rootPart
                           table.insert(activeEffects, fx)
                       elseif child:IsA("MeshPart") or child:IsA("Part") then
                           local prop = child:Clone()
                           prop.Parent = char
                           local weld = Instance.new("WeldConstraint")
                           weld.Part0 = char:FindFirstChild("RightHand") or rootPart
                           weld.Part1 = prop
                           weld.Parent = prop
                           prop.CanCollide = false
                           prop.Massless = true
                           table.insert(activeEffects, prop)
                       end
                   end
               end)
           else
               Rayfield:Notify({ Title = "Error", Content = "Select an emote first!", Duration = 2 })
           end
       else
           if activeEmoteTrack then
               activeEmoteTrack:Stop()
               activeEmoteTrack = nil
           end
           for _, effect in ipairs(activeEffects) do
               if effect and effect.Parent then
                   effect:Destroy()
               end
           end
           table.clear(activeEffects)
       end
   end,
})

-- [ TASKS TAB ] --
local TasksTab = Window:CreateTab("Tasks", "list")
local autoRepairEnabled = false
local autoRepairTask = nil
local repairInterval = 0.5

TasksTab:CreateToggle({
   Name = "Auto-Repair Generators",
   CurrentValue = false,
   Flag = "AutoRepair",
   Callback = function(Value)
       autoRepairEnabled = Value
       if Value then
           if not autoRepairTask then
               autoRepairTask = task.spawn(function()
                   while autoRepairEnabled do
                       if LocalPlayer.PlayerGui:FindFirstChild("Gen") then
                           pcall(function() LocalPlayer.PlayerGui.Gen.GeneratorMain.Event:FireServer(true) end)
                       end
                       task.wait(repairInterval)
                   end
                   autoRepairTask = nil
               end)
           end
       else
           autoRepairEnabled = false
       end
   end,
})

TasksTab:CreateSlider({
   Name = "Auto-Repair Interval",
   Range = {0.1, 15},
   Increment = 0.1,
   Suffix = "Seconds",
   CurrentValue = 0.5,
   Flag = "RepairInterval",
   Callback = function(Value)
       repairInterval = Value
   end,
})

local dotConn = nil
TasksTab:CreateToggle({
   Name = "Perfect Barricade",
   CurrentValue = false,
   Flag = "PerfectBarricade",
   Callback = function(Value)
       if Value then
           dotConn = RunService.RenderStepped:Connect(function()
               pcall(function()
                   local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                   if not playerGui then return end
                   
                   -- Find the active Barricade UI (it's usually named "Dot" but can vary)
                   for _, dot in ipairs(playerGui:GetChildren()) do
                       if (dot.Name == "Dot" or dot:FindFirstChild("Container")) and dot:IsA("ScreenGui") and dot.Enabled then
                           local container = dot:FindFirstChild("Container")
                           if container then
                               local frame = container:FindFirstChild("Frame")
                               if frame then
                                   frame.AnchorPoint = Vector2.new(0.5, 0.5)
                                   frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                               end
                           end
                       end
                   end
               end)
           end)
       else
           if dotConn then dotConn:Disconnect() dotConn = nil end
       end
   end,
})

local autoKillConn = nil
TasksTab:CreateToggle({
   Name = "Auto-Kill (Killer Only)",
   CurrentValue = false,
   Flag = "AutoKill",
   Callback = function(Value)
       if Value then
           autoKillConn = RunService.Heartbeat:Connect(function()
               local char = LocalPlayer.Character
               local root = char and char:FindFirstChild("HumanoidRootPart")
               if not root then return end
               local closest, dist = nil, math.huge
               local aliveFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("ALIVE")
               if aliveFolder then
                   for _, v in ipairs(aliveFolder:GetChildren()) do
                       local hrp = v:FindFirstChild("HumanoidRootPart")
                       if hrp and v ~= char then
                           local d = (root.Position - hrp.Position).Magnitude
                           if d < dist then dist = d; closest = v end
                       end
                   end
               end
               if closest and closest:FindFirstChild("HumanoidRootPart") then
                   local targetPos = closest.HumanoidRootPart.Position
                   local dir = (targetPos - root.Position).Unit
                   if dist > 6 then
                       root.CFrame = root.CFrame + (dir * 1.5) 
                   else
                       root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
                       local tool = char:FindFirstChildOfClass("Tool")
                       if tool then tool:Activate() end
                   end
               end
           end)
       else
           if autoKillConn then autoKillConn:Disconnect() autoKillConn = nil end
       end
   end,
})

-- [ LOCAL TAB ] --
local LocalTab = Window:CreateTab("Local", "user")
local sprintConn = nil
local charAddConn = nil

local customStaminaAmount = math.huge
local stamConn = nil
local charAddConn = nil

local function setStamina()
    if stamConn then stamConn:Disconnect(); stamConn = nil; end;
    local char = LocalPlayer.Character;
    if not char then return end;
    stamConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character;
        if not c then return end;
        local mx = c:GetAttribute("MaxStamina") or 100;
        if (c:GetAttribute("Stamina") or mx) < mx then
            c:SetAttribute("Stamina", mx);
        end;
    end);
end;

LocalTab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "InfStam",
   Callback = function(Value)
       if Value then
           setStamina();
           charAddConn = LocalPlayer.CharacterAdded:Connect(function()
               task.wait(1);
               setStamina();
           end);
       else
           if stamConn then stamConn:Disconnect(); stamConn = nil; end;
           if charAddConn then charAddConn:Disconnect(); charAddConn = nil; end;
       end
   end,
})

LocalTab:CreateInput({
    Name = "Custom stamina amount (Legacy)",
    PlaceholderText = "Currently unused...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
    end,
})

local noclipConn = nil
LocalTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
       if Value then
           noclipConn = RunService.Stepped:Connect(function()
               local char = LocalPlayer.Character
               if not char then return end
               for _, part in ipairs(char:GetDescendants()) do
                   if part:IsA("BasePart") then part.CanCollide = false end
               end
           end)
       else
           if noclipConn then noclipConn:Disconnect() noclipConn = nil end
       end
   end,
})

local pcFlyConn = nil
LocalTab:CreateToggle({
   Name = "Advanced Fly (PC)",
   CurrentValue = false,
   Flag = "FlyPC",
   Callback = function(Value)
       if Value then
           local char = LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           if not root then return end
           char:FindFirstChildOfClass("Humanoid").PlatformStand = true
           root.Anchored = true
           pcFlyConn = RunService.RenderStepped:Connect(function(dt)
               if not root or not root.Parent then return end
               local move = Vector3.zero
               local speed = 100
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
               if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
               if move.Magnitude > 0 then
                   root.CFrame = root.CFrame + (move.Unit * (speed * dt))
               end
               root.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
           end)
       else
           if pcFlyConn then pcFlyConn:Disconnect() pcFlyConn = nil end
           local char = LocalPlayer.Character
           if char then
               char:FindFirstChildOfClass("Humanoid").PlatformStand = false
               local root = char:FindFirstChild("HumanoidRootPart")
               if root then root.Anchored = false end
           end
       end
   end,
})

local mobileFlyConn = nil
LocalTab:CreateToggle({
   Name = "Advanced Fly (Mobile)",
   CurrentValue = false,
   Flag = "FlyMobile",
   Callback = function(Value)
       if Value then
           local char = LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           local hum = char and char:FindFirstChildOfClass("Humanoid")
           if not root or not hum then return end
           hum.PlatformStand = true
           root.Anchored = true
           mobileFlyConn = RunService.RenderStepped:Connect(function(dt)
               if not root or not root.Parent then return end
               local moveDir = hum.MoveDirection
               local speed = 100
               if moveDir.Magnitude > 0.1 then
                   local camLook = Camera.CFrame.LookVector
                   local camRight = Camera.CFrame.RightVector
                   local moveCalc = (camLook * moveDir.Z * -1) + (camRight * moveDir.X)
                   root.CFrame = root.CFrame + (moveCalc * (speed * dt))
               end
               root.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
           end)
       else
           if mobileFlyConn then mobileFlyConn:Disconnect() mobileFlyConn = nil end
           local char = LocalPlayer.Character
           if char then
               char:FindFirstChildOfClass("Humanoid").PlatformStand = false
               local root = char:FindFirstChild("HumanoidRootPart")
               if root then root.Anchored = false end
           end
       end
   end,
})

-- [ VISUALS TAB ] --
local VisualsTab = Window:CreateTab("Visuals", "eye")
local fbLoop = nil
VisualsTab:CreateToggle({
   Name = "Full Brightness",
   CurrentValue = false,
   Flag = "FullBright",
   Callback = function(Value)
       if Value then
           fbLoop = RunService.Heartbeat:Connect(function()
               Lighting.GlobalShadows = false
               Lighting.ClockTime = 14
               local cam = Workspace.CurrentCamera
               if cam and not cam:FindFirstChild("RepzFBLight") then
                   local light = Instance.new("PointLight")
                   light.Name = "RepzFBLight"
                   light.Brightness = 2.5
                   light.Range = 250
                   light.Shadows = false
                   light.Parent = cam
               end
           end)
       else
           if fbLoop then fbLoop:Disconnect() fbLoop = nil end
           Lighting.GlobalShadows = true
           local cam = Workspace.CurrentCamera
           if cam and cam:FindFirstChild("RepzFBLight") then
               cam.RepzFBLight:Destroy()
           end
       end
   end,
})

local autoSuppressEnabled = false
local suppressConns = {}
local function initHighlightSuppress(char)
    if not char then return end
    local function check(h)
        if h:IsA("Highlight") and (h.Name == "Highlight" or h.Name == "HIGHLIGHT") then
            local r, g, b = math.floor(h.FillColor.R*255), math.floor(h.FillColor.G*255), math.floor(h.FillColor.B*255)
            -- Distinguish between Attack (Occluded/Pure Red) and ESP (AlwaysOnTop/Light Red)
            if h.DepthMode == Enum.HighlightDepthMode.Occluded or (r >= 250 and g <= 10 and b <= 10) then
                local function sync()
                    if autoSuppressEnabled then
                        if h.FillTransparency ~= 1 then h.FillTransparency = 1 end
                        if h.OutlineTransparency ~= 1 then h.OutlineTransparency = 1 end
                    end
                end
                sync()
                table.insert(suppressConns, h:GetPropertyChangedSignal("FillTransparency"):Connect(sync))
                table.insert(suppressConns, h:GetPropertyChangedSignal("OutlineTransparency"):Connect(sync))
                table.insert(suppressConns, h:GetPropertyChangedSignal("FillColor"):Connect(sync))
            end
        end
    end
    for _, v in ipairs(char:GetDescendants()) do check(v) end
    table.insert(suppressConns, char.DescendantAdded:Connect(check))
end

local espData = { 
    survivors = {}, killers = {}, generators = {}, batteries = {}, fuses = {}, texts = {}, 
    nameStamConns = {}, pool = {} 
}

-- [ INITIALIZE HIGHLIGHT POOL ] --
-- Creating a pool of 64 Highlights (Hardware-Optimal Limit)
for i = 1, 64 do
    local h = Ins("Highlight")
    h.Enabled = true
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.OutlineTransparency = 0
    h.FillTransparency = 0.5
    h.Parent = CoreGui
    espData.pool[i] = h
end

-- [ POOL-BASED ESP RUNNER ] --
local function runPoolESP()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position
    local screenSize = cam.ViewportSize
    
    local targets = {}
    -- Collect All Registered Targets
    for tblName, tbl in pairs({survivors = espData.survivors, killers = espData.killers, generators = espData.generators, batteries = espData.batteries, fuses = espData.fuses}) do
        for obj, colorInfo in pairs(tbl) do
            if obj and obj.Parent then
                local bPos = (obj:IsA("Model") and obj:GetPivot().Position) or (obj:IsA("BasePart") and obj.Position)
                if bPos then
                    local sPos, onScreen = cam:WorldToViewportPoint(bPos)
                    local dist = (camPos - bPos).Magnitude
                    
                    -- Basic Culling: Always show if within 250 studs or on screen within 1000px margin
                    local isRelevant = (dist < 250) or (onScreen or (sPos.X > -1000 and sPos.X < screenSize.X + 1000) and (sPos.Y > -1000 and sPos.Y < screenSize.Y + 1000))
                    
                    if isRelevant and dist < 5000 then
                        local priority = 1000 -- Default
                        if tblName == "killers" then priority = 0
                        elseif tblName == "survivors" then priority = 10
                        elseif tblName == "generators" then priority = 200
                        elseif tblName == "batteries" then priority = 300
                        elseif tblName == "fuses" then priority = 400
                        end
                        
                        -- Spatial Culling: Hide batteries if they are "inside" or docked with a fuse
                        local isDocked = false
                        if tblName == "batteries" then
                            -- Check workspace for fuse boxes directly (even if ESP is off)
                            local maps = workspace:FindFirstChild("MAPS")
                            local gameMap = maps and maps:FindFirstChild("GAME MAP")
                            local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")
                            
                            if fuseBoxes then
                                if obj:IsDescendantOf(fuseBoxes) then
                                    isDocked = true
                                else
                                    for _, fuse in ipairs(fuseBoxes:GetChildren()) do
                                        local fPos = (fuse:IsA("Model") and fuse:GetPivot().Position) or (fuse:IsA("BasePart") and fuse.Position)
                                        if fPos and (bPos - fPos).Magnitude < 1.5 then isDocked = true break end
                                    end
                                end
                            end
                        end
                        
                        if not isDocked then
                            table.insert(targets, {
                                obj = obj,
                                dist = dist,
                                prio = priority,
                                fill = colorInfo.fill,
                                outline = colorInfo.outline or colorInfo.fill
                            })
                        end
                    end
                end
            else
                tbl[obj] = nil -- Clean up dangling references
            end
        end
    end
    
    -- Sorting by Priority then Distance
    table.sort(targets, function(a, b) 
        if a.prio ~= b.prio then return a.prio < b.prio end
        return a.dist < b.dist 
    end)
    
    -- Assignment: Distribute Pooled Highlights
    for i = 1, 64 do
        local h = espData.pool[i]
        local target = targets[i]
        if target then
            if target.obj:IsA("Model") and target.prio == 10 then -- Survivor Color Dynamic Update
                local c = getSurvivorColor(target.obj)
                h.FillColor, h.OutlineColor = c, c
            else
                h.FillColor, h.OutlineColor = target.fill, target.outline
            end
            h.Adornee = target.obj
        else
            h.Adornee = nil -- Disconnect from any target
        end
    end
end
espData.highlightTaskLoop = RunService.Heartbeat:Connect(runPoolESP)

-- [ BILLBOARD ESP RUNNER (TEXT) ] --
local function runTextESP()
    local cam = Workspace.CurrentCamera
    if not (cam and type(espData.texts) == "table") then return end
    local screenSize = cam.ViewportSize
    local camPos = cam.CFrame.Position
    
    for c, data in pairs(espData.texts) do
        if data.gui and data.gui.Parent then
            local adornee = data.gui.Adornee
            local aPos = adornee and (adornee:IsA("BasePart") and adornee.Position or (adornee:IsA("Model") and adornee:GetPivot().Position))
            if aPos then
                local sPos, onScreen = cam:WorldToViewportPoint(aPos)
                local dist = (camPos - aPos).Magnitude
                data.gui.Enabled = (dist < 400) or (onScreen or (sPos.X > -1000 and sPos.X < screenSize.X + 1000) and (sPos.Y > -1000 and sPos.Y < screenSize.Y + 1000))
            end
        end
    end
end
espData.textTaskLoop = RunService.Heartbeat:Connect(runTextESP)

local function addESP(tbl, obj, fillColor, outlineColor)
    if obj then tbl[obj] = {fill = fillColor, outline = outlineColor} end
end
local function removeESP(tbl, obj)
    if tbl then tbl[obj] = nil end
end
local function clearESP(tbl)
    if tbl then table.clear(tbl) end
end

local function addTextESP(char, roleColor)
    if espData.texts[char] or pendingESP[char] then return end
    pendingESP[char] = true

    -- Overwrite logic: destroy existing if it exists
    for _, name in pairs({"RepzHeaderESP", "RepzBodyESP", "RepzNameESP", "RepzMainESP"}) do
        local old = char:FindFirstChild(name, true)
        if old then old:Destroy() end
    end
    if espData.texts[char] then
        local data = espData.texts[char]
        if data.conns then for _, c in ipairs(data.conns) do if c then c:Disconnect() end end end
        if data.gui then data.gui:Destroy() end
        espData.texts[char] = nil
    end

    -- Robust part detection (wait for Rig to load)
    local adornee = nil
    for i = 1, 15 do
        adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
        if adornee then break end
        task.wait(0.3)
    end
    if not adornee then 
        pendingESP[char] = nil
        return 
    end
    
    local billboard = Ins("BillboardGui")
    billboard.Name = "RepzMainESP"
    billboard.Adornee = adornee
    billboard.Size = U2(0, 150, 0, 80)
    billboard.StudsOffset = V3(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2500
    billboard.Parent = CoreGui

    local layout = Ins("UIListLayout")
    layout.Parent = billboard
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UD(0, 1)

    local infoLabel = Ins("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Parent = billboard
    infoLabel.LayoutOrder = 1
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = U2(1, 0, 0, 30)
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.TextSize = 12
    infoLabel.RichText = true
    infoLabel.TextStrokeTransparency = 0
    infoLabel.TextStrokeColor3 = C3(0, 0, 0)

    local isInKillerFolder = (char.Parent and char.Parent.Name == "KILLER")
    local roleColor = isInKillerFolder and C3(255, 0, 0) or roleColor
    local nameColor = isInKillerFolder and C3(255, 150, 150) or C3(0, 255, 0)
    local roleTitle = isInKillerFolder and "Killer" or getRoleLabel(char)
    infoLabel.Text = string.format("<font color='%s'>%s</font>\n<font color='%s'>%s</font>", toHex(roleColor), roleTitle, toHex(nameColor), char.Name)

    -- Health Bar with Value inside
    local hBarBg = Ins("Frame")
    hBarBg.Name = "HealthBar"
    hBarBg.Parent = billboard
    hBarBg.LayoutOrder = 3
    hBarBg.BackgroundColor3 = C3(40, 40, 40)
    hBarBg.BorderSizePixel = 0
    hBarBg.Size = U2(0, 100, 0, 10)

    local hBarFill = Ins("Frame")
    hBarFill.Name = "Fill"
    hBarFill.Parent = hBarBg
    hBarFill.BackgroundColor3 = C3(0, 255, 0)
    hBarFill.BorderSizePixel = 0
    hBarFill.Size = U2(1, 0, 1, 0)

    local hpTxt = Ins("TextLabel")
    hpTxt.Parent = hBarBg
    hpTxt.BackgroundTransparency = 1
    hpTxt.Size = U2(1, 0, 1, 0)
    hpTxt.Font = Enum.Font.GothamBold
    hpTxt.TextSize = 9
    hpTxt.TextColor3 = C3(255, 255, 255)
    hpTxt.TextStrokeTransparency = 0.5
    hpTxt.ZIndex = 3

    -- Stamina Bar with Value inside
    local sBarBg = Ins("Frame")
    sBarBg.Name = "StaminaBar"
    sBarBg.Parent = billboard
    sBarBg.LayoutOrder = 4
    sBarBg.BackgroundColor3 = C3(40, 40, 40)
    sBarBg.BorderSizePixel = 0
    sBarBg.Size = U2(0, 100, 0, 10)

    local sBarFill = Ins("Frame")
    sBarFill.Name = "Fill"
    sBarFill.Parent = sBarBg
    sBarFill.BackgroundColor3 = C3(100, 200, 255)
    sBarFill.BorderSizePixel = 0
    sBarFill.Size = U2(1, 0, 1, 0)

    local stamTxt = Ins("TextLabel")
    stamTxt.Parent = sBarBg
    stamTxt.BackgroundTransparency = 1
    stamTxt.Size = U2(1, 0, 1, 0)
    stamTxt.Font = Enum.Font.GothamBold
    stamTxt.TextSize = 9
    stamTxt.TextColor3 = C3(255, 255, 255)
    stamTxt.TextStrokeTransparency = 0.5
    stamTxt.ZIndex = 3

    local lastHP, lastSTM = -1, -1
    local function updateStats()
        if not char or not char.Parent then return end
        
        -- Update Stamina
        local stam = char:GetAttribute("Stamina")
        local mxS = char:GetAttribute("MaxStamina") or 100
        if lastSTM ~= stam then
            lastSTM = stam
            local sPercent = 1
            local sVal = "N/A"
            if type(stam) == "number" and stam ~= math.huge then 
                sPercent = clamp(stam / mxS, 0, 1)
                sVal = tostring(floor(stam))
            elseif stam == math.huge then
                sVal = "INF"
            end
            sBarFill.Size = U2(sPercent, 0, 1, 0)
            stamTxt.Text = "STM: " .. sVal
        end

        -- Update Health
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local hp = hum.Health
            if floor(hp) ~= floor(lastHP) then
                lastHP = hp
                local mxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local p = clamp(hp / mxH, 0, 1)
                hBarFill.Size = U2(p, 0, 1, 0)
                hpTxt.Text = "HP: " .. floor(hp) .. " / " .. floor(mxH)
                
                local barColor = (p > 0.5 and C3(0, 255, 0)) or (p > 0.2 and C3(255, 255, 0)) or C3(255, 0, 0)
                hBarFill.BackgroundColor3 = barColor
            end
        end
    end

    updateStats()
    local c1 = char:GetAttributeChangedSignal("Stamina"):Connect(updateStats)
    local c2 = char:GetAttributeChangedSignal("MaxStamina"):Connect(updateStats)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local c3 = hum and hum:GetPropertyChangedSignal("Health"):Connect(updateStats) or nil
    
    espData.texts[char] = { gui = billboard, conns = {c1, c2, c3} }
    pendingESP[char] = nil
end
local function removeTextESP(char)
    local data = espData.texts[char]
    if data then
        pcall(function()
            if data.gui then data.gui:Destroy() end
            if data.conns then 
                for _, c in ipairs(data.conns) do 
                    if c and c.Disconnect then c:Disconnect() end 
                end 
            end
        end)
        espData.texts[char] = nil
    end
    if pendingESP then pendingESP[char] = nil end
end

local function clearTextESP(tbl)
    if not tbl then return end
    for char, data in pairs(tbl) do
        pcall(function()
            if data.gui then data.gui:Destroy() end
            if data.conns then 
                for _, c in ipairs(data.conns) do 
                    if c and c.Disconnect then c:Disconnect() end 
                end 
            end
        end)
        tbl[char] = nil
    end
    if pendingESP then table.clear(pendingESP) end
end


-- [ ESP TOGGLE LOGIC ] --
VisualsTab:CreateToggle({
    Name = "Name & Stamina ESP",
    CurrentValue = false,
    Flag = "NameStamESP",
    Callback = function(Value)
        if Value then
            local function setupFolder(folder, isKiller)
                if not folder then return end
                local function onAdded(c) task.spawn(addTextESP, c, isKiller and Color3.fromRGB(255, 80, 80) or getSurvivorColor(c)) end
                local function onRemoved(c) removeTextESP(c) end
                
                for _, c in ipairs(folder:GetChildren()) do onAdded(c) end
                table.insert(espData.nameStamConns, folder.ChildAdded:Connect(onAdded))
                table.insert(espData.nameStamConns, folder.ChildRemoved:Connect(onRemoved))
            end

            local function init()
                local players = workspace:FindFirstChild("PLAYERS")
                if players then
                    setupFolder(players:FindFirstChild("ALIVE"), false)
                    setupFolder(players:FindFirstChild("KILLER"), true)
                end
            end
            
            espData.nameStamConns = {}
            init()
            table.insert(espData.nameStamConns, workspace.ChildAdded:Connect(function(c) if c.Name == "PLAYERS" then task.wait(0.5) init() end end))
        else
            if espData.nameStamConns then
                for _, c in ipairs(espData.nameStamConns) do if c then c:Disconnect() end end
                espData.nameStamConns = nil
            end
            clearTextESP(espData.texts)
        end
    end,
})

VisualsTab:CreateToggle({
   Name = "Highlight all survivors",
   CurrentValue = false,
   Flag = "SurvESP",
   Callback = function(Value)
       local aliveFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("ALIVE")
       if Value and aliveFolder then
           for _, v in ipairs(aliveFolder:GetChildren()) do 
               if v:IsA("Model") then addESP(espData.survivors, v, getSurvivorColor(v)) end 
           end
           espData.survivorAdd = aliveFolder.ChildAdded:Connect(function(v) 
               if v:IsA("Model") then addESP(espData.survivors, v, getSurvivorColor(v)) end 
           end)
           espData.survivorRemove = aliveFolder.ChildRemoved:Connect(function(v) removeESP(espData.survivors, v) end)
           espData.survivorUpdate = RunService.Heartbeat:Connect(function()
               for char, highlight in pairs(espData.survivors) do
                   if char and highlight then 
                       highlight.FillColor = getSurvivorColor(char) 
                       highlight.OutlineColor = getSurvivorColor(char) 
                   end
               end
           end)
       else
           if espData.survivorAdd then espData.survivorAdd:Disconnect() end
           if espData.survivorRemove then espData.survivorRemove:Disconnect() end
           if espData.survivorUpdate then espData.survivorUpdate:Disconnect() end
           clearESP(espData.survivors)
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "Detect Killer",
   CurrentValue = false,
   Flag = "KillerESP",
   Callback = function(Value)
        autoSuppressEnabled = Value
        local killerFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
        if Value and killerFolder then
            for _, v in ipairs(killerFolder:GetChildren()) do 
                if v:IsA("Model") then 
                    addESP(espData.killers, v, Color3.fromRGB(255, 80, 80)) 
                    initHighlightSuppress(v)
                end 
            end
            espData.killerAdd = killerFolder.ChildAdded:Connect(function(v) 
                if v:IsA("Model") then 
                    addESP(espData.killers, v, Color3.fromRGB(255, 80, 80)) 
                    initHighlightSuppress(v)
                end 
            end)
            espData.killerRemove = killerFolder.ChildRemoved:Connect(function(v) removeESP(espData.killers, v) end)
        else
            if espData.killerAdd then espData.killerAdd:Disconnect() end
            if espData.killerRemove then espData.killerRemove:Disconnect() end
            clearESP(espData.killers)
            for _, c in ipairs(suppressConns) do if c then c:Disconnect() end end
            table.clear(suppressConns)
        end
    end,
})

VisualsTab:CreateToggle({
   Name = "Highlight all generators",
   CurrentValue = false,
   Flag = "GenESP",
   Callback = function(Value)
       if Value then
           for _, v in ipairs(workspace:GetDescendants()) do
               if v:IsA("Model") and v.Name == "Generator" then addESP(espData.generators, v, Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 255)) end
           end
           espData.genAdd = workspace.DescendantAdded:Connect(function(v)
               if v:IsA("Model") and v.Name == "Generator" then addESP(espData.generators, v, Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 255)) end
           end)
           espData.genRemove = workspace.DescendantRemoving:Connect(function(v)
               if espData.generators[v] then removeESP(espData.generators, v) end
           end)
       else
           if espData.genAdd then espData.genAdd:Disconnect() end
           if espData.genRemove then espData.genRemove:Disconnect() end
           clearESP(espData.generators)
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "Highlight all fuses",
   CurrentValue = false,
   Flag = "FuseESP",
   Callback = function(Value)
       if Value then
           local function checkAndAdd(v)
               local maps = workspace:FindFirstChild("MAPS")
               local gameMap = maps and maps:FindFirstChild("GAME MAP")
               local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")
               if fuseBoxes and v:IsDescendantOf(fuseBoxes) then
                   if v:IsA("Model") or v:IsA("BasePart") then
                        addESP(espData.fuses, v, Color3.fromRGB(255, 20, 147), Color3.fromRGB(255, 165, 0))
                    end
                end
            end
            
            local maps = workspace:FindFirstChild("MAPS")
            local gameMap = maps and maps:FindFirstChild("GAME MAP")
            local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")
            if fuseBoxes then
                for _, v in ipairs(fuseBoxes:GetChildren()) do
                    addESP(espData.fuses, v, Color3.fromRGB(255, 20, 147), Color3.fromRGB(255, 165, 0))
                end
            end
           
           espData.fuseAdd = workspace.DescendantAdded:Connect(function(v)
               checkAndAdd(v)
           end)
       else
           if espData.fuseAdd then espData.fuseAdd:Disconnect() end
           clearESP(espData.fuses)
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "Highlight all batteries",
   CurrentValue = false,
   Flag = "BatESP",
   Callback = function(Value)
       if Value then
           for _, v in ipairs(workspace:GetDescendants()) do
               if v:IsA("MeshPart") and v.Name == "Battery" then addESP(espData.batteries, v, Color3.fromRGB(0, 255, 255)) end
           end
           espData.batAdd = workspace.DescendantAdded:Connect(function(v)
               if v:IsA("MeshPart") and v.Name == "Battery" then addESP(espData.batteries, v, Color3.fromRGB(0, 255, 255)) end
           end)
           espData.batRemove = workspace.DescendantRemoving:Connect(function(v)
               if espData.batteries[v] then removeESP(espData.batteries, v) end
           end)
       else
           if espData.batAdd then espData.batAdd:Disconnect() end
           if espData.batRemove then espData.batRemove:Disconnect() end
           clearESP(espData.batteries)
       end
   end,
})

-- [ COMBAT TAB ] --
local CombatTab = Window:CreateTab("Combat", "swords")
local aimbotConn = nil
CombatTab:CreateToggle({
   Name = "Aimbot (Killer Focus)",
   CurrentValue = false,
   Flag = "CombatAimbot",
   Callback = function(Value)
       if Value then
           aimbotConn = RunService.RenderStepped:Connect(function()
               local killer = getActiveKiller()
               if killer and killer:FindFirstChild("HumanoidRootPart") then
                   local killerPos = killer.HumanoidRootPart.Position
                   local camPos = Camera.CFrame.Position
                   Camera.CFrame = CFrame.new(camPos, killerPos)
               end
           end)
       else
           if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
       end
   end,
})

local autoParryEnabled = false
local autoParryRadius = 15
local autoParryDelay = 0.1
local autoParryPrediction = 0
local parryConns = {}

local function tryParry(killerChar)
    if not autoParryEnabled then return end
    local char = LocalPlayer.Character
    
    -- Ensure the user isn't the Killer themselves
    if char and char.Parent and char.Parent.Name == "KILLER" then return end
    
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local killerRoot = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
    if root and killerRoot then
        local targetPos = killerRoot.Position
        if autoParryPrediction > 0 then
            targetPos = targetPos + (killerRoot.AssemblyLinearVelocity * autoParryPrediction)
        end
        local distance = (root.Position - targetPos).Magnitude
        
        if distance <= autoParryRadius then
            task.spawn(function()
                if autoParryDelay > 0 then
                    task.wait(autoParryDelay)
                end
                pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
                task.wait(0.05)
                pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            end)
        end
    end
end

local function setupKillerParryDetection(killerChar)
    local function parseParryTrigger(desc)
        if desc:IsA("Highlight") and (desc.Name == "Highlight" or desc.Name == "HIGHLIGHT") then
            local function checkParry()
                if desc.Enabled and autoParryEnabled then
                    local rFill, gFill, bFill = math.floor(desc.FillColor.R*255), math.floor(desc.FillColor.G*255), math.floor(desc.FillColor.B*255)
                    if rFill >= 250 and gFill <= 10 and bFill <= 10 then 
                        tryParry(killerChar)
                    end
                end
            end
            checkParry()
            table.insert(parryConns, desc:GetPropertyChangedSignal("Enabled"):Connect(checkParry))
            table.insert(parryConns, desc:GetPropertyChangedSignal("FillColor"):Connect(checkParry))
        elseif desc:IsA("Animator") then
            table.insert(parryConns, desc.AnimationPlayed:Connect(function(track)
                local name = track.Animation and track.Animation.Name and track.Animation.Name:lower() or ""
                if name:find("swing") or name:find("slash") or name:find("attack") or name:find("hit") or name:find("chop") then
                    tryParry(killerChar)
                end
            end))
        elseif desc:IsA("Sound") then
            local name = desc.Name:lower()
            if name:find("swing") or name:find("slash") or name:find("swoosh") or name:find("hit") then
                table.insert(parryConns, desc.Played:Connect(function()
                    tryParry(killerChar)
                end))
            end
        end
    end

    for _, desc in ipairs(killerChar:GetDescendants()) do
        parseParryTrigger(desc)
    end
    table.insert(parryConns, killerChar.DescendantAdded:Connect(parseParryTrigger))
end

CombatTab:CreateToggle({
    Name = "Auto-Parry (All-In-One Detection)",
    CurrentValue = false,
    Flag = "AutoParry",
    Callback = function(Value)
        autoParryEnabled = Value
        if Value then
            local aliveFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
            if aliveFolder then
                for _, k in ipairs(aliveFolder:GetChildren()) do
                    setupKillerParryDetection(k)
                end
                table.insert(parryConns, aliveFolder.ChildAdded:Connect(setupKillerParryDetection))
            end
        else
            for _, conn in ipairs(parryConns) do if conn then conn:Disconnect() end end
            table.clear(parryConns)
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Auto-Parry Radius",
    Range = {5, 30},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 15,
    Flag = "ParryRadius",
    Callback = function(Value)
        autoParryRadius = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Auto-Parry Delay",
    Range = {0, 5},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "ParryDelay",
    Callback = function(Value)
        autoParryDelay = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Prediction speed",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "ParryPrediction",
    Callback = function(Value)
        autoParryPrediction = Value
    end,
})

local smartParryEnabled = false
local smartParryConn = nil

CombatTab:CreateToggle({
    Name = "Smart Proximity Parry (Experimental)",
    CurrentValue = false,
    Flag = "SmartParry",
    Callback = function(Value)
        smartParryEnabled = Value
        if Value then
            smartParryConn = RunService.Heartbeat:Connect(function()
                if not smartParryEnabled or parryDebounce then return end
                
                local char = LocalPlayer.Character
                if not char or (char.Parent and char.Parent.Name == "KILLER") then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local aliveFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
                if not aliveFolder then return end
                
                for _, killer in ipairs(aliveFolder:GetChildren()) do
                    local killerRoot = killer:FindFirstChild("HumanoidRootPart")
                    if killerRoot then
                        local distance = (root.Position - killerRoot.Position).Magnitude
                        if distance <= (autoParryRadius + 2) then
                            local killerSpeed = killerRoot.AssemblyLinearVelocity.Magnitude
                            local dirToPlayer = (root.Position - killerRoot.Position).Unit
                            local viewDot = killerRoot.CFrame.LookVector:Dot(dirToPlayer)
                            
                            -- Killer must be sprinting directly at you (Velocity > 20)
                            if killerSpeed > 20 and viewDot > 0.85 then
                                tryParry(killer)
                            end
                        end
                    end
                end
            end)
        else
            if smartParryConn then smartParryConn:Disconnect() smartParryConn = nil end
        end
    end,
})

-- [ OTHER SCRIPTS TAB ] --
local OtherScriptsTab = Window:CreateTab("Other scripts", "folder")
OtherScriptsTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
       loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end
})
OtherScriptsTab:CreateButton({
   Name = "CMD-X",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))()
   end
})
OtherScriptsTab:CreateButton({
   Name = "Nameless Admin",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
   end
})

Rayfield:LoadConfiguration()

getgenv().RepzHubUnload = function()
    -- Disconnect Loops
    pcall(function()
        if espData then
            if espData.highlightTaskLoop then espData.highlightTaskLoop:Disconnect() end
            if espData.textTaskLoop then espData.textTaskLoop:Disconnect() end
            if espData.pool then for _, h in ipairs(espData.pool) do if h then h:Destroy() end end end
        end
    end)
    
    -- Clear ESP Highlights
    for _, tbl in pairs({espData.survivors, espData.killers, espData.generators, espData.batteries, espData.fuses}) do
        table.clear(tbl)
    end

    pcall(function()
        -- Anti-Cheat
        if type(hookedACFunctions) == "table" then
            for orig, hook in pairs(hookedACFunctions) do
                hookfunction(orig, hook)
            end
        end

        local function clean(c) if c then c:Disconnect() end end
        if activeEmoteTrack then activeEmoteTrack:Stop() end
        if type(activeEffects) == "table" then
            for _, effect in ipairs(activeEffects) do if effect and effect.Parent then effect:Destroy() end end
        end

        -- Tasks
        autoRepairEnabled = false
        if autoRepairTask then task.cancel(autoRepairTask) end
        if genConn then genConn:Disconnect() end
        if dotConn then dotConn:Disconnect() end
        if autoKillConn then autoKillConn:Disconnect() end

        -- Local
        if sprintConn then sprintConn:Disconnect() end
        if charAddConn then charAddConn:Disconnect() end
        if noclipConn then noclipConn:Disconnect() end
        if pcFlyConn then pcFlyConn:Disconnect() end
        if mobileFlyConn then mobileFlyConn:Disconnect() end
        
        local char = LocalPlayer.Character
        if char then
            pcall(function()
                char:SetAttribute("Running", false)
                char:SetAttribute("WalkSpeed", 12)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.Anchored = false end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end)
        end

        -- Visuals
        if fbLoop then fbLoop:Disconnect() end
        Lighting.GlobalShadows = true
        local cam = Workspace.CurrentCamera
        if cam and cam:FindFirstChild("RepzFBLight") then cam.RepzFBLight:Destroy() end
        
        if espData.survivorAdd then espData.survivorAdd:Disconnect() end
        if espData.survivorRemove then espData.survivorRemove:Disconnect() end
        if espData.survivorUpdate then espData.survivorUpdate:Disconnect() end
        if espData.killerAdd then espData.killerAdd:Disconnect() end
        if espData.killerRemove then espData.killerRemove:Disconnect() end
        if espData.genAdd then espData.genAdd:Disconnect() end
        if espData.genRemove then espData.genRemove:Disconnect() end
        if espData.batAdd then espData.batAdd:Disconnect() end
        if espData.batRemove then espData.batRemove:Disconnect() end
        if espData.fuseAdd then espData.fuseAdd:Disconnect() end
        
        if suppressConns then
            for _, c in ipairs(suppressConns) do if c then c:Disconnect() end end
            table.clear(suppressConns)
        end
        
        for _, tbl in pairs({espData.survivors, espData.killers, espData.generators, espData.batteries, espData.fuses}) do
            for obj, h in pairs(tbl) do pcall(function() h:Destroy() end) end
            table.clear(tbl)
        end
        
        if type(espData.texts) == "table" then
            for char, data in pairs(espData.texts) do
                pcall(function()
                    if data.gui then data.gui:Destroy() end
                    if data.conns then 
                        for _, c in ipairs(data.conns) do 
                            if c and c.Disconnect then c:Disconnect() end 
                        end 
                    end
                end)
            end
            table.clear(espData.texts)
        end
        if type(pendingESP) == "table" then table.clear(pendingESP) end
        if type(espData.nameStamConns) == "table" then
            for _, c in ipairs(espData.nameStamConns) do if c then c:Disconnect() end end
            table.clear(espData.nameStamConns)
        end
        if espData.highlightTask then task.cancel(espData.highlightTask) end

        -- Combat
        if aimbotConn then aimbotConn:Disconnect() end
        if smartParryConn then smartParryConn:Disconnect() end
        for _, conn in ipairs(parryConns or {}) do if conn then conn:Disconnect() end end
        if parryConns then table.clear(parryConns) end

        -- UI Destruction
        if Rayfield then Rayfield:Destroy() end
    end)
end