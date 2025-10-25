--[[
  Epic Control Panel for Roblox
  Features: Fly, Noclip, God Mode, Fling All, Fast & Strong Dodge (E), and more!
  Visuals: Gradients, Animations, Particles, Lights, Sounds
--]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

-- Player and GUI setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Load saved keybinds
local binds = {}
local bindData = player:GetAttribute("ButtonBinds")
if bindData then
    binds = HttpService:JSONDecode(bindData)
else
    binds = {
        ["Increase Speed"] = nil, ["Double Jump"] = nil, ["Fly"] = nil,
        ["Desync"] = nil, ["Decrease Speed"] = nil, ["Noclip"] = nil,
        ["Ninja Walk"] = nil, ["Auto Farm Yuba"] = nil, ["God Mode"] = nil,
        ["Auto Collect"] = nil, ["Trail"] = nil, ["Rainbow Aura"] = nil,
        ["Fire Body"] = nil, ["Neon Glow"] = nil, ["Chams"] = nil,
        ["Custom Sky"] = nil, ["Lift"] = nil, ["Invisible"] = nil,
        ["Fling All"] = nil, ["Dodge"] = "E" -- Привязываем Dodge к E по умолчанию
    }
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EpicControlPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 380)
frame.Position = UDim2.new(0.5, -110, 0.5, -190)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(20, 20, 280, 280)
shadow.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.BorderSizePixel = 0
header.Parent = frame

-- Header gradient
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
headerGradient.Parent = header

-- Header text
local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, -40, 1, 0)
headerText.Position = UDim2.new(0, 20, 0, 0)
headerText.Text = "EPIC PANEL"
headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.Font = Enum.Font.GothamBlack
headerText.TextSize = 16
headerText.BackgroundTransparency = 1
headerText.TextTransparency = 0.1
headerText.Parent = header

-- Header glow
local headerGlow = Instance.new("TextLabel")
headerGlow.Size = UDim2.new(1, -40, 1, 0)
headerGlow.Position = UDim2.new(0, 20, 0, 0)
headerGlow.Text = "EPIC PANEL"
headerGlow.TextColor3 = Color3.fromRGB(0, 200, 255)
headerGlow.TextXAlignment = Enum.TextXAlignment.Left
headerGlow.Font = Enum.Font.GothamBlack
headerGlow.TextSize = 16
headerGlow.BackgroundTransparency = 1
headerGlow.TextTransparency = 0.8
headerGlow.TextStrokeTransparency = 0.5
headerGlow.Parent = header

-- Collapse button
local collapseButton = Instance.new("TextButton")
collapseButton.Size = UDim2.new(0, 40, 0, 40)
collapseButton.Position = UDim2.new(1, -40, 0, 0)
collapseButton.Text = ""
collapseButton.BackgroundTransparency = 1
collapseButton.Parent = header

-- Collapse icon
local collapseIcon = Instance.new("ImageLabel")
collapseIcon.Size = UDim2.new(0, 24, 0, 24)
collapseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
collapseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
collapseIcon.BackgroundTransparency = 1
collapseIcon.Image = "rbxassetid://3926309567"
collapseIcon.ImageRectOffset = Vector2.new(284, 4)
collapseIcon.ImageRectSize = Vector2.new(24, 24)
collapseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
collapseIcon.Parent = collapseButton

-- Buttons container
local buttonsContainer = Instance.new("ScrollingFrame")
buttonsContainer.Size = UDim2.new(1, 0, 1, -40)
buttonsContainer.Position = UDim2.new(0, 0, 0, 40)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.ScrollBarThickness = 3
buttonsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
buttonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
buttonsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
buttonsContainer.Parent = frame

-- Buttons layout
local buttonsLayout = Instance.new("UIListLayout")
buttonsLayout.Padding = UDim.new(0, 8)
buttonsLayout.Parent = buttonsContainer

-- Drag functionality
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Collapse/expand
local function toggleCollapse()
    if buttonsContainer.Visible then
        buttonsContainer.Visible = false
        collapseIcon.ImageRectOffset = Vector2.new(284, 28)
        TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 220, 0, 40)}
        ):Play()
    else
        buttonsContainer.Visible = true
        collapseIcon.ImageRectOffset = Vector2.new(284, 4)
        TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 220, 0, 380)}
        ):Play()
    end
end

collapseButton.MouseButton1Click:Connect(toggleCollapse)

-- Notification system
local function showNotification(text)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(1, 0, 0, 30)
    notification.Position = UDim2.new(0, 0, 1, -30)
    notification.Text = text
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Font = Enum.Font.GothamSemibold
    notification.TextSize = 14
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 1
    notification.TextTransparency = 1
    notification.Parent = frame
    TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.5, TextTransparency = 0}
    ):Play()
    task.delay(2.5, function()
        TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {BackgroundTransparency = 1, TextTransparency = 1}
        ):Play()
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Keybind system
local binding = false
local bindButtonName = ""

local function bindKey(buttonName)
    bindButtonName = buttonName
    binding = true
    showNotification("Press a key to bind: " .. buttonName)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if binding and not gameProcessed then
        binding = false
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            keyName = "MouseButton1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            keyName = "MouseButton2"
        end
        binds[bindButtonName] = keyName
        player:SetAttribute("ButtonBinds", HttpService:JSONEncode(binds))
        showNotification("Bound " .. bindButtonName .. " to " .. keyName)
    end
end)

-- Effect helper function
local function createEffect(part, effectType, color, size, lifetime, speed, soundId)
    if not part then return end
    if effectType == "particles" then
        local effect = Instance.new("ParticleEmitter")
        effect.Texture = "rbxassetid://242845789"
        effect.Color = ColorSequence.new(color)
        effect.LightEmission = 0.7
        effect.Size = NumberSequence.new(size or 0.5)
        effect.Lifetime = NumberRange.new(lifetime or 0.5)
        effect.Speed = NumberRange.new(speed or 5)
        effect.SpreadAngle = Vector2.new(360, 360)
        effect.Rate = 100
        effect.Parent = part
        Debris:AddItem(effect, (lifetime or 0.5) + 0.5)
    elseif effectType == "light" then
        local light = Instance.new("PointLight")
        light.Color = color
        light.Range = 10
        light.Brightness = 5
        light.Parent = part
        Debris:AddItem(light, 2)
    elseif effectType == "sound" then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. (soundId or (color == Color3.fromRGB(255, 50, 50) and "138080962" or "911964470"))
        sound.Volume = 2
        sound.Parent = part
        sound:Play()
        Debris:AddItem(sound, 2)
    elseif effectType == "beam" then
        local attachment0 = Instance.new("Attachment", part)
        local attachment1 = Instance.new("Attachment")
        attachment1.Position = Vector3.new(0, 10, 0)
        attachment1.Parent = workspace
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(color)
        beam.Width0 = 2
        beam.Width1 = 0.5
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = part
        Debris:AddItem(beam, 2)
    end
end

-- FUNCTIONS --
-- Fling All
local flingActive = false
local function toggleFlingAll()
    flingActive = not flingActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if flingActive then
        createEffect(rootPart, "particles", Color3.fromRGB(255, 50, 50), 1, 1, 20)
        createEffect(rootPart, "light", Color3.fromRGB(255, 50, 50))
        createEffect(rootPart, "sound", Color3.fromRGB(255, 50, 50), nil, nil, nil, "138080962")
        showNotification("Fling All: ON")
        coroutine.wrap(function()
            while flingActive do
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character then
                        local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if otherRoot then
                            createEffect(otherRoot, "particles", Color3.fromRGB(255, 100, 100), 0.5, 0.5, 10)
                            local flingVelocity = Instance.new("BodyVelocity")
                            flingVelocity.Velocity = (otherRoot.Position - rootPart.Position).Unit * 150
                            flingVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            flingVelocity.Parent = otherRoot
                            Debris:AddItem(flingVelocity, 0.2)
                        end
                    end
                end
                task.wait(0.7)
            end
        end)()
    else
        showNotification("Fling All: OFF")
    end
end

-- Fly
local flyBodyVelocity, flyBodyGyro
local flyActive = false
local function toggleFly()
    flyActive = not flyActive
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if not flyActive then
        flyActive = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Parent = rootPart
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = rootPart.CFrame
        flyBodyGyro.Parent = rootPart
        createEffect(rootPart, "particles", Color3.fromRGB(0, 215, 0), 0.5, 0.5, 5)
        createEffect(rootPart, "light", Color3.fromRGB(0, 215, 0))
        createEffect(rootPart, "sound", Color3.fromRGB(0, 215, 0), nil, nil, nil, "911964470")
        showNotification("Fly: ON (WASD + Space/Shift)")
        coroutine.wrap(function()
            while flyActive and flyBodyVelocity and flyBodyGyro do
                local moveDirection = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                flyBodyVelocity.Velocity = moveDirection * 50
                flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
                RunService.Heartbeat:Wait()
            end
        end)()
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        showNotification("Fly: OFF")
    end
end

-- Noclip
local noclipActive = false
local noclipConnection
local function toggleNoclip()
    noclipActive = not noclipActive
    local character = player.Character
    if not character then return end
    if noclipActive then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            createEffect(rootPart, "particles", Color3.fromRGB(0, 150, 255), 0.3, 0.5, 5)
            createEffect(rootPart, "light", Color3.fromRGB(0, 150, 255))
            createEffect(rootPart, "sound", Color3.fromRGB(0, 150, 255), nil, nil, nil, "911964470")
        end
        showNotification("Noclip: ON")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        showNotification("Noclip: OFF")
    end
end

-- God Mode
local godModeActive = false
local godModeConnection
local auraEffect, auraLight, auraBeam
local function toggleGodMode()
    godModeActive = not godModeActive
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if godModeActive then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        auraEffect = Instance.new("ParticleEmitter")
        auraEffect.Texture = "rbxassetid://242845789"
        auraEffect.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
        auraEffect.LightEmission = 1
        auraEffect.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.5)})
        auraEffect.Lifetime = NumberRange.new(1)
        auraEffect.Speed = NumberRange.new(0)
        auraEffect.SpreadAngle = Vector2.new(360, 360)
        auraEffect.Rate = 100
        auraEffect.Parent = rootPart
        auraLight = Instance.new("PointLight")
        auraLight.Color = Color3.fromRGB(255, 215, 0)
        auraLight.Range = 10
        auraLight.Brightness = 5
        auraLight.Parent = rootPart
        local beamAttachment = Instance.new("Attachment", rootPart)
        beamAttachment.Position = Vector3.new(0, -3, 0)
        auraBeam = Instance.new("Beam")
        auraBeam.Attachment0 = beamAttachment
        auraBeam.Attachment1 = Instance.new("Attachment")
        auraBeam.Attachment1.Position = Vector3.new(0, 10, 0)
        auraBeam.Attachment1.Parent = workspace
        auraBeam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
        auraBeam.Width0 = 2
        auraBeam.Width1 = 0.5
        auraBeam.Transparency = NumberSequence.new(0)
        auraBeam.Parent = rootPart
        coroutine.wrap(function()
            while godModeActive do
                for i = 0.5, 1, 0.05 do
                    auraEffect.Size = NumberSequence.new(i)
                    auraLight.Brightness = 3 + i * 2
                    task.wait(0.05)
                end
                for i = 1, 0.5, -0.05 do
                    auraEffect.Size = NumberSequence.new(i)
                    auraLight.Brightness = 3 + i * 2
                    task.wait(0.05)
                end
            end
        end)()
        godModeConnection = humanoid.HealthChanged:Connect(function()
            humanoid.Health = humanoid.MaxHealth
        end)
        createEffect(rootPart, "sound", Color3.fromRGB(255, 215, 0), nil, nil, nil, "911964470")
        showNotification("God Mode: ON")
    else
        if auraEffect then auraEffect:Destroy() end
        if auraLight then auraLight:Destroy() end
        if auraBeam then auraBeam:Destroy() end
        if godModeConnection then godModeConnection:Disconnect() end
        showNotification("God Mode: OFF")
    end
end

-- Auto Collect
local autoCollectActive = false
local autoCollectConnection
local function toggleAutoCollect()
    autoCollectActive = not autoCollectActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if autoCollectActive then
        autoCollectConnection = RunService.Heartbeat:Connect(function()
            local radius = 20
            for _, drop in ipairs(workspace:GetChildren()) do
                if drop:IsA("Part") and drop:FindFirstChild("Drop") then
                    local distance = (drop.Position - rootPart.Position).Magnitude
                    if distance <= radius then
                        local beam = Instance.new("Beam")
                        local attachment0 = Instance.new("Attachment", drop)
                        local attachment1 = Instance.new("Attachment", rootPart)
                        beam.Attachment0 = attachment0
                        beam.Attachment1 = attachment1
                        beam.Color = ColorSequence.new(Color3.fromRGB(0, 215, 215))
                        beam.Width0 = 0.2
                        beam.Width1 = 0.1
                        beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                        beam.Parent = drop
                        Debris:AddItem(beam, 0.5)
                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Velocity = (rootPart.Position - drop.Position).Unit * 50
                        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bodyVelocity.Parent = drop
                        Debris:AddItem(bodyVelocity, 0.1)
                        firetouchinterest(drop, rootPart, 0)
                        firetouchinterest(drop, rootPart, 1)
                        createEffect(drop, "particles", Color3.fromRGB(0, 215, 215), 0.5, 0.5, 5)
                    end
                end
            end
        end)
        createEffect(rootPart, "sound", Color3.fromRGB(0, 215, 215), nil, nil, nil, "911964470")
        showNotification("Auto Collect: ON")
    else
        if autoCollectConnection then
            autoCollectConnection:Disconnect()
        end
        showNotification("Auto Collect: OFF")
    end
end

-- Trail
local trailActive = false
local trailEffect
local function toggleTrail()
    trailActive = not trailActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if trailActive then
        trailEffect = Instance.new("ParticleEmitter")
        trailEffect.Texture = "rbxassetid://242845789"
        trailEffect.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        trailEffect.LightEmission = 0.7
        trailEffect.Size = NumberSequence.new(0.5)
        trailEffect.Lifetime = NumberRange.new(0.5)
        trailEffect.Speed = NumberRange.new(0)
        trailEffect.SpreadAngle = Vector2.new(0, 0)
        trailEffect.Rate = 100
        trailEffect.Parent = rootPart
        local trailLight = Instance.new("PointLight")
        trailLight.Color = Color3.fromRGB(0, 255, 255)
        trailLight.Range = 5
        trailLight.Brightness = 2
        trailLight.Parent = rootPart
        createEffect(rootPart, "sound", Color3.fromRGB(0, 255, 255), nil, nil, nil, "911964470")
        showNotification("Trail: ON")
    else
        if trailEffect then
            trailEffect:Destroy()
        end
        showNotification("Trail: OFF")
    end
end

-- Rainbow Aura
local rainbowAuraActive = false
local rainbowAuraEffect
local function toggleRainbowAura()
    rainbowAuraActive = not rainbowAuraActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if rainbowAuraActive then
        rainbowAuraEffect = Instance.new("ParticleEmitter")
        rainbowAuraEffect.Texture = "rbxassetid://242845789"
        rainbowAuraEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 127, 0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 0, 255))
        })
        rainbowAuraEffect.LightEmission = 1
        rainbowAuraEffect.Size = NumberSequence.new(1)
        rainbowAuraEffect.Lifetime = NumberRange.new(1)
        rainbowAuraEffect.Speed = NumberRange.new(0)
        rainbowAuraEffect.SpreadAngle = Vector2.new(360, 360)
        rainbowAuraEffect.Rate = 100
        rainbowAuraEffect.Parent = rootPart
        createEffect(rootPart, "sound", Color3.fromRGB(255, 0, 255), nil, nil, nil, "911964470")
        showNotification("Rainbow Aura: ON")
    else
        if rainbowAuraEffect then
            rainbowAuraEffect:Destroy()
        end
        showNotification("Rainbow Aura: OFF")
    end
end

-- Fire Body
local fireBodyActive = false
local fireEffect
local function toggleFireBody()
    fireBodyActive = not fireBodyActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if fireBodyActive then
        fireEffect = Instance.new("Fire")
        fireEffect.Color = Color3.fromRGB(255, 100, 0)
        fireEffect.SecondaryColor = Color3.fromRGB(255, 200, 0)
        fireEffect.Size = 5
        fireEffect.Heat = 20
        fireEffect.Parent = rootPart
        createEffect(rootPart, "sound", Color3.fromRGB(255, 100, 0), nil, nil, nil, "138080962")
        showNotification("Fire Body: ON")
    else
        if fireEffect then
            fireEffect:Destroy()
        end
        showNotification("Fire Body: OFF")
    end
end

-- Neon Glow
local neonGlowActive = false
local neonGlowEffect
local function toggleNeonGlow()
    neonGlowActive = not neonGlowActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if neonGlowActive then
        neonGlowEffect = Instance.new("PointLight")
        neonGlowEffect.Color = Color3.fromRGB(0, 255, 255)
        neonGlowEffect.Range = 10
        neonGlowEffect.Brightness = 5
        neonGlowEffect.Parent = rootPart
        local neonParticles = Instance.new("ParticleEmitter")
        neonParticles.Texture = "rbxassetid://242845789"
        neonParticles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        neonParticles.LightEmission = 1
        neonParticles.Size = NumberSequence.new(0.5)
        neonParticles.Lifetime = NumberRange.new(1)
        neonParticles.Speed = NumberRange.new(0)
        neonParticles.SpreadAngle = Vector2.new(360, 360)
        neonParticles.Rate = 50
        neonParticles.Parent = rootPart
        createEffect(rootPart, "sound", Color3.fromRGB(0, 255, 255), nil, nil, nil, "911964470")
        showNotification("Neon Glow: ON")
    else
        if neonGlowEffect then
            neonGlowEffect:Destroy()
        end
        showNotification("Neon Glow: OFF")
    end
end

-- Chams
local chamsActive = false
local chamsFolder
local function toggleChams()
    chamsActive = not chamsActive
    if chamsActive then
        chamsFolder = Instance.new("Folder")
        chamsFolder.Name = "ChamsFolder"
        chamsFolder.Parent = workspace
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local humanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local cham = Instance.new("BoxHandleAdornment")
                    cham.Adornee = humanoidRootPart
                    cham.AlwaysOnTop = true
                    cham.ZIndex = 10
                    cham.Size = humanoidRootPart.Size + Vector3.new(0.2, 0.2, 0.2)
                    cham.Color3 = Color3.fromRGB(255, 0, 0)
                    cham.Transparency = 0.5
                    cham.Parent = chamsFolder
                end
            end
        end
        createEffect(player.Character and player.Character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(255, 0, 0), nil, nil, nil, "138080962")
        showNotification("Chams: ON")
    else
        if chamsFolder then
            chamsFolder:Destroy()
        end
        showNotification("Chams: OFF")
    end
end

-- Custom Sky
local customSkyActive = false
local originalSky
local function toggleCustomSky()
    customSkyActive = not customSkyActive
    if customSkyActive then
        originalSky = Lighting.Sky
        Lighting.Sky.SkyboxBk = "rbxassetid://701868563"
        Lighting.Sky.SkyboxDn = "rbxassetid://701868563"
        Lighting.Sky.SkyboxFt = "rbxassetid://701868563"
        Lighting.Sky.SkyboxLf = "rbxassetid://701868563"
        Lighting.Sky.SkyboxRt = "rbxassetid://701868563"
        Lighting.Sky.SkyboxUp = "rbxassetid://701868563"
        createEffect(player.Character and player.Character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(0, 100, 255), nil, nil, nil, "911964470")
        showNotification("Custom Sky: ON")
    else
        if originalSky then
            Lighting.Sky = originalSky
        end
        showNotification("Custom Sky: OFF")
    end
end

-- Lift
local liftActive = false
local liftPlatform
local function toggleLift()
    liftActive = not liftActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if liftActive then
        liftPlatform = Instance.new("Part")
        liftPlatform.Size = Vector3.new(10, 1, 10)
        liftPlatform.Anchored = false
        liftPlatform.CanCollide = true
        liftPlatform.Material = Enum.Material.Concrete
        liftPlatform.Color = Color3.fromRGB(100, 100, 255)
        liftPlatform.Transparency = 0.3
        liftPlatform.Position = rootPart.Position - Vector3.new(0, 3, 0)
        liftPlatform.Parent = workspace
        local liftBodyPosition = Instance.new("BodyPosition")
        liftBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
        liftBodyPosition.Position = liftPlatform.Position + Vector3.new(0, 100, 0)
        liftBodyPosition.D = 100
        liftBodyPosition.P = 2000
        liftBodyPosition.Parent = liftPlatform
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = CFrame.new(liftPlatform.Position)
        bodyGyro.D = 50
        bodyGyro.P = 2000
        bodyGyro.Parent = liftPlatform
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = liftPlatform
        weld.Part1 = rootPart
        weld.Parent = liftPlatform
        createEffect(rootPart, "sound", Color3.fromRGB(100, 100, 255), nil, nil, nil, "911964470")
        showNotification("Lift: ON")
    else
        if liftPlatform then
            liftPlatform:Destroy()
        end
        showNotification("Lift: OFF")
    end
end

-- Invisible
local invisibleActive = false
local originalParts = {}
local originalPositions = {}
local function toggleInvisible()
    invisibleActive = not invisibleActive
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if invisibleActive then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part ~= rootPart then
                table.insert(originalParts, part)
                originalPositions[part] = part.Position
                part.Transparency = 1
                part.CanCollide = false
                part.Position = rootPart.Position - Vector3.new(0, 1000, 0)
            end
        end
        createEffect(rootPart, "sound", Color3.fromRGB(150, 150, 150), nil, nil, nil, "911964470")
        showNotification("Invisible: ON")
    else
        for _, part in ipairs(originalParts) do
            if part and part.Parent then
                part.Transparency = 0
                part.CanCollide = true
                part.Position = originalPositions[part]
            end
        end
        originalParts = {}
        originalPositions = {}
        showNotification("Invisible: OFF")
    end
end

-- Increase Speed
local function increaseSpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 2
            createEffect(character:FindFirstChild("HumanoidRootPart"), "particles", Color3.fromRGB(0, 120, 215), 0.5, 0.5, 5)
            createEffect(character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(0, 120, 215), nil, nil, nil, "911964470")
            showNotification("Speed increased!")
        end
    end
end

-- Decrease Speed
local function decreaseSpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed / 2
            createEffect(character:FindFirstChild("HumanoidRootPart"), "particles", Color3.fromRGB(120, 0, 215), 0.5, 0.5, 5)
            createEffect(character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(120, 0, 215), nil, nil, nil, "911964470")
            showNotification("Speed decreased!")
        end
    end
end

-- Double Jump
local function doubleJump()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 50
            local canDoubleJump = true
            humanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    canDoubleJump = true
                end
            end)
            UserInputService.JumpRequest:Connect(function()
                if canDoubleJump and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    canDoubleJump = false
                    createEffect(character:FindFirstChild("HumanoidRootPart"), "particles", Color3.fromRGB(215, 0, 0), 0.5, 0.5, 5)
                    createEffect(character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(215, 0, 0), nil, nil, nil, "911964470")
                end
            end)
            showNotification("Double Jump: ON")
        end
    end
end

-- Desync
local desyncActive = false
local desyncConnection
local originalCFrame
local function toggleDesync()
    desyncActive = not desyncActive
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if desyncActive then
        originalCFrame = rootPart.CFrame
        desyncConnection = RunService.Heartbeat:Connect(function()
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.CFrame = originalCFrame
            humanoid:Move(
                Vector3.new(humanoid.MoveDirection.X * 50, 0, humanoid.MoveDirection.Z * 50),
                false
            )
        end)
        createEffect(rootPart, "particles", Color3.fromRGB(215, 215, 0), 0.3, 0.5, 5)
        createEffect(rootPart, "sound", Color3.fromRGB(215, 215, 0), nil, nil, nil, "911964470")
        showNotification("Desync: ON")
    else
        if desyncConnection then
            desyncConnection:Disconnect()
        end
        showNotification("Desync: OFF")
    end
end

-- Ninja Walk
local ninjaWalkActive = false
local originalWalkSpeed = 16
local ninjaWalkSpeed = 32
local function toggleNinjaWalk()
    ninjaWalkActive = not ninjaWalkActive
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if ninjaWalkActive then
        originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = ninjaWalkSpeed
        createEffect(character:FindFirstChild("HumanoidRootPart"), "particles", Color3.fromRGB(150, 0, 150), 0.3, 0.3, 5)
        createEffect(character:FindFirstChild("HumanoidRootPart"), "sound", Color3.fromRGB(150, 0, 150), nil, nil, nil, "911964470")
        showNotification("Ninja Walk: ON")
    else
        humanoid.WalkSpeed = originalWalkSpeed
        showNotification("Ninja Walk: OFF")
    end
end

-- Auto Farm Yuba
local autoFarmActive = false
local autoFarmConnection
local function toggleAutoFarmYuba()
    autoFarmActive = not autoFarmActive
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if autoFarmActive then
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            local yuba = workspace:FindFirstChild("Yuba") or workspace:FindFirstChild("Boss")
            if not yuba then
                for _, model in ipairs(workspace:GetChildren()) do
                    if model:FindFirstChild("Humanoid") and
                       (model.Name:lower():find("yuba") or model.Name:lower():find("boss")) then
                        yuba = model
                        break
                    end
                end
            end
            if yuba then
                local yubaRoot = yuba:FindFirstChild("HumanoidRootPart") or yuba:FindFirstChild("Torso")
                if yubaRoot then
                    humanoid:MoveTo(yubaRoot.Position)
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end
                end
            end
        end)
        createEffect(rootPart, "sound", Color3.fromRGB(255, 100, 0), nil, nil, nil, "138080962")
        showNotification("Auto Farm: ON")
    else
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
        end
        showNotification("Auto Farm: OFF")
    end
end

-- Fast & Strong Dodge (уклонение на кнопку E)
local dodgeCooldown = false

local function dodge()
    if dodgeCooldown or not player.Character then return end

    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then return end

    -- Проверка, что персонаж на земле или в движении
    if humanoid:GetState() ~= Enum.HumanoidStateType.Running and
       humanoid:GetState() ~= Enum.HumanoidStateType.Landed then
        return
    end

    dodgeCooldown = true

    -- Визуальные эффекты (частицы и звук)
    createEffect(rootPart, "particles", Color3.fromRGB(255, 255, 0), 1.5, 0.5, 30)
    createEffect(rootPart, "sound", Color3.fromRGB(255, 255, 0), nil, nil, nil, "911964470")

    -- Направление уклонения (вперёд, с учётом направления взгляда)
    local dodgeDirection = rootPart.CFrame.LookVector * 50  -- Увеличена сила импульса
    dodgeDirection = Vector3.new(dodgeDirection.X, 0, dodgeDirection.Z)

    -- Применяем импульс с прыжком вверх
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = dodgeDirection + Vector3.new(0, 25, 0)  -- Увеличена высота прыжка
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart

    -- Убираем импульс через 0.1 секунды (для резкости)
    task.delay(0.1, function()
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
    end)

    -- Кулдаун 1.5 секунды
    task.delay(1.5, function()
        dodgeCooldown = false
    end)

    showNotification("Fast & Strong Dodge!")
end

-- Привязка уклонения к кнопке E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        dodge()
    end
end)

-- Button creation function
local function createButton(buttonData)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.AutoButtonColor = false
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = buttonsContainer

    -- Button gradient
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, buttonData.Color),
        ColorSequenceKeypoint.new(1, buttonData.Color:Lerp(Color3.fromRGB(20, 20, 20), 0.7))
    }
    buttonGradient.Rotation = 90
    buttonGradient.Parent = button

    -- Button corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    -- Button shadow
    local buttonShadow = Instance.new("ImageLabel")
    buttonShadow.Size = UDim2.new(1, 8, 1, 8)
    buttonShadow.Position = UDim2.new(0, -4, 0, -4)
    buttonShadow.BackgroundTransparency = 1
    buttonShadow.Image = "rbxassetid://1316045217"
    buttonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    buttonShadow.ImageTransparency = 0.8
    buttonShadow.ScaleType = Enum.ScaleType.Slice
    buttonShadow.SliceCenter = Rect.new(20, 20, 280, 280)
    buttonShadow.Parent = button

    -- Button icon
    local buttonIcon = Instance.new("ImageLabel")
    buttonIcon.Size = UDim2.new(0, 28, 0, 28)
    buttonIcon.Position = UDim2.new(0, 12, 0.5, 0)
    buttonIcon.AnchorPoint = Vector2.new(0, 0.5)
    buttonIcon.BackgroundTransparency = 1
    buttonIcon.Image = buttonData.Icon
    buttonIcon.ImageRectOffset = buttonData.IconOffset
    buttonIcon.ImageRectSize = Vector2.new(24, 24)
    buttonIcon.ImageColor3 = Color3.fromRGB(220, 220, 220)
    buttonIcon.Parent = button

    -- Button text
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, -50, 1, 0)
    buttonText.Position = UDim2.new(0, 50, 0, 0)
    buttonText.Text = buttonData.Text
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Font = Enum.Font.GothamSemibold
    buttonText.TextSize = 14
    buttonText.BackgroundTransparency = 1
    buttonText.Parent = button

    -- Bind text
    local bindText = Instance.new("TextLabel")
    bindText.Size = UDim2.new(0, 60, 1, 0)
    bindText.Position = UDim2.new(1, -60, 0, 0)
    bindText.Text = binds[buttonData.Text] or "None"
    bindText.TextColor3 = Color3.fromRGB(180, 180, 180)
    bindText.TextXAlignment = Enum.TextXAlignment.Right
    bindText.Font = Enum.Font.Gotham
    bindText.TextSize = 12
    bindText.BackgroundTransparency = 1
    bindText.Parent = button

    -- Hover animation
    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.1}
        ):Play()
        TweenService:Create(
            buttonIcon,
            TweenInfo.new(0.2),
            {ImageColor3 = Color3.fromRGB(255, 255, 255)}
        ):Play()
        TweenService:Create(
            buttonText,
            TweenInfo.new(0.2),
            {TextColor3 = Color3.fromRGB(255, 255, 220)}
        ):Play()
    end)

    -- Leave animation
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3}
        ):Play()
        TweenService:Create(
            buttonIcon,
            TweenInfo.new(0.2),
            {ImageColor3 = Color3.fromRGB(220, 220, 220)}
        ):Play()
        TweenService:Create(
            buttonText,
            TweenInfo.new(0.2),
            {TextColor3 = Color3.fromRGB(255, 255, 255)}
        ):Play()
    end)

    -- Click animation
    button.MouseButton1Down:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, -16, 0, 45)}
        ):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, -16, 0, 50)}
        ):Play()
    end)

    -- Bind key
    button.MouseButton2Click:Connect(function()
        bindKey(buttonData.Text)
    end)

    -- Update bind text
    local function updateBindText()
        bindText.Text = binds[buttonData.Text] or "None"
    end

    -- Key press detection
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and binds[buttonData.Text] then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyName = "MouseButton1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyName = "MouseButton2"
            end
            if keyName == binds[buttonData.Text] then
                buttonData.Action()
                TweenService:Create(
                    button,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(1, -16, 0, 45)}
                ):Play()
                task.wait(0.1)
                TweenService:Create(
                    button,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(1, -16, 0, 50)}
                ):Play()
            end
        end
    end)

    -- Click action
    button.MouseButton1Click:Connect(function()
        buttonData.Action()
    end)

    updateBindText()
end

-- Button data
local buttons = {
    {
        Text = "Fling All",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(284, 284),
        Color = Color3.fromRGB(255, 50, 50),
        Action = toggleFlingAll
    },
    {
        Text = "Fly",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(4, 284),
        Color = Color3.fromRGB(0, 215, 0),
        Action = toggleFly
    },
    {
        Text = "Noclip",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(244, 4),
        Color = Color3.fromRGB(0, 150, 255),
        Action = toggleNoclip
    },
    {
        Text = "God Mode",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(4, 4),
        Color = Color3.fromRGB(255, 215, 0),
        Action = toggleGodMode
    },
    {
        Text = "Auto Collect",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(284, 324),
        Color = Color3.fromRGB(0, 215, 215),
        Action = toggleAutoCollect
    },
    {
        Text = "Trail",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(4, 28),
        Color = Color3.fromRGB(0, 255, 255),
        Action = toggleTrail
    },
    {
        Text = "Rainbow Aura",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(364, 28),
        Color = Color3.fromRGB(255, 0, 255),
        Action = toggleRainbowAura
    },
    {
        Text = "Fire Body",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(284, 284),
        Color = Color3.fromRGB(255, 100, 0),
        Action = toggleFireBody
    },
    {
        Text = "Neon Glow",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(324, 324),
        Color = Color3.fromRGB(0, 255, 255),
        Action = toggleNeonGlow
    },
    {
        Text = "Chams",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(204, 324),
        Color = Color3.fromRGB(255, 0, 0),
        Action = toggleChams
    },
    {
        Text = "Custom Sky",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(4, 364),
        Color = Color3.fromRGB(0, 100, 255),
        Action = toggleCustomSky
    },
    {
        Text = "Lift",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(284, 4),
        Color = Color3.fromRGB(100, 100, 255),
        Action = toggleLift
    },
    {
        Text = "Invisible",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(364, 324),
        Color = Color3.fromRGB(150, 150, 150),
        Action = toggleInvisible
    },
    {
        Text = "Increase Speed",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(284, 28),
        Color = Color3.fromRGB(0, 120, 215),
        Action = increaseSpeed
    },
    {
        Text = "Double Jump",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(364, 4),
        Color = Color3.fromRGB(215, 0, 0),
        Action = doubleJump
    },
    {
        Text = "Desync",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(204, 284),
        Color = Color3.fromRGB(215, 215, 0),
        Action = toggleDesync
    },
    {
        Text = "Ninja Walk",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(204, 4),
        Color = Color3.fromRGB(150, 0, 150),
        Action = toggleNinjaWalk
    },
    {
        Text = "Auto Farm",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(364, 284),
        Color = Color3.fromRGB(255, 100, 0),
        Action = toggleAutoFarmYuba
    },
    {
        Text = "Fast & Strong Dodge (E)",
        Icon = "rbxassetid://3926305904",
        IconOffset = Vector2.new(4, 244),
        Color = Color3.fromRGB(255, 255, 0),
        Action = function() end -- Уклонение работает по нажатию E
    }
}

-- Create buttons
for _, buttonData in ipairs(buttons) do
    createButton(buttonData)
end

-- Update scroll size
buttonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    buttonsContainer.CanvasSize = UDim2.new(0, 0, 0, buttonsLayout.AbsoluteContentSize.Y + 10)
end)
