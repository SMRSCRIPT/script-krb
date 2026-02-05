--[[
    War Tycoon Supremacy Framework - Part 2
    Combat Engine with Physics Prediction
    Author: Senior Luau Developer
    Version: 1.0.0
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- UI COMPONENT FACTORY
-- ============================================
local UIComponents = {}
UIComponents.__index = UIComponents

function UIComponents.new(framework)
    local self = setmetatable({}, UIComponents)
    self.Framework = framework
    self.Utility = framework.Utility
    return self
end

function UIComponents:CreateSection(parent, title, order)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    section.BorderSizePixel = 0
    section.LayoutOrder = order or 1
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 50)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = section
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Size = UDim2.new(1, -20, 0, 35)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionTitle.TextSize = self.Utility:ScaleSize(14)
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -20, 0, 2)
    divider.Position = UDim2.new(0, 10, 0, 40)
    divider.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    divider.BorderSizePixel = 0
    divider.Parent = section
    
    local dividerGradient = Instance.new("UIGradient")
    dividerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 135, 245)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(66, 135, 245))
    }
    dividerGradient.Parent = divider
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, 0, 0, 0)
    contentContainer.Position = UDim2.new(0, 0, 0, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.AutomaticSize = Enum.AutomaticSize.Y
    contentContainer.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentContainer
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentContainer
    
    return contentContainer
end

function UIComponents:CreateToggle(parent, title, description, defaultValue, callback, order)
    local toggle = Instance.new("Frame")
    toggle.Name = title .. "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, self.Utility:ScaleSize(55))
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggle.BorderSizePixel = 0
    toggle.LayoutOrder = order or 1
    toggle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -70, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = self.Utility:ScaleSize(13)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggle
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -70, 0, 18)
    descLabel.Position = UDim2.new(0, 12, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = self.Utility:ScaleSize(10)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = toggle
    
    -- Toggle Switch
    local switchFrame = Instance.new("Frame")
    switchFrame.Name = "Switch"
    switchFrame.Size = UDim2.new(0, self.Utility:ScaleSize(50), 0, self.Utility:ScaleSize(26))
    switchFrame.Position = UDim2.new(1, -self.Utility:ScaleSize(55), 0.5, 0)
    switchFrame.AnchorPoint = Vector2.new(0, 0.5)
    switchFrame.BackgroundColor3 = defaultValue and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(50, 50, 55)
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = toggle
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchFrame
    
    local switchButton = Instance.new("Frame")
    switchButton.Name = "Button"
    switchButton.Size = UDim2.new(0, self.Utility:ScaleSize(22), 0, self.Utility:ScaleSize(22))
    switchButton.Position = defaultValue and UDim2.new(1, -self.Utility:ScaleSize(24), 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    switchButton.AnchorPoint = Vector2.new(0, 0.5)
    switchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchButton.BorderSizePixel = 0
    switchButton.Parent = switchFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = switchButton
    
    local isEnabled = defaultValue
    
    local function updateToggle(enabled)
        isEnabled = enabled
        
        local bgTween = self.Utility:CreateTween(switchFrame, {
            BackgroundColor3 = enabled and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(50, 50, 55)
        }, 0.25)
        bgTween:Play()
        
        local btnTween = self.Utility:CreateTween(switchButton, {
            Position = enabled and UDim2.new(1, -self.Utility:ScaleSize(24), 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.25, Enum.EasingStyle.Back)
        btnTween:Play()
        
        if callback then
            callback(enabled)
        end
    end
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = toggle
    
    clickDetector.MouseButton1Click:Connect(function()
        updateToggle(not isEnabled)
        self.Utility:RippleEffect(toggle, UserInputService:GetMouseLocation())
    end)
    
    clickDetector.MouseEnter:Connect(function()
        local tween = self.Utility:CreateTween(toggle, {
            BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        }, 0.2)
        tween:Play()
    end)
    
    clickDetector.MouseLeave:Connect(function()
        local tween = self.Utility:CreateTween(toggle, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }, 0.2)
        tween:Play()
    end)
    
    return {
        Frame = toggle,
        SetValue = updateToggle,
        GetValue = function() return isEnabled end
    }
end

function UIComponents:CreateSlider(parent, title, description, min, max, default, suffix, callback, order)
    local slider = Instance.new("Frame")
    slider.Name = title .. "Slider"
    slider.Size = UDim2.new(1, 0, 0, self.Utility:ScaleSize(70))
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    slider.BorderSizePixel = 0
    slider.LayoutOrder = order or 1
    slider.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = slider
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.6, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = self.Utility:ScaleSize(13)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.35, 0, 0, 20)
    valueLabel.Position = UDim2.new(1, -12, 0, 8)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default) .. (suffix or "")
    valueLabel.TextColor3 = Color3.fromRGB(66, 135, 245)
    valueLabel.TextSize = self.Utility:ScaleSize(13)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -24, 0, 15)
    descLabel.Position = UDim2.new(0, 12, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = self.Utility:ScaleSize(10)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = slider
    
    -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -24, 0, self.Utility:ScaleSize(8))
    sliderTrack.Position = UDim2.new(0, 12, 1, -self.Utility:ScaleSize(15))
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    -- Slider Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 135, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242))
    }
    fillGradient.Parent = sliderFill
    
    -- Slider Thumb
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Name = "Thumb"
    sliderThumb.Size = UDim2.new(0, self.Utility:ScaleSize(18), 0, self.Utility:ScaleSize(18))
    sliderThumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.BorderSizePixel = 0
    sliderThumb.ZIndex = 2
    sliderThumb.Parent = sliderTrack
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = sliderThumb
    
    local thumbShadow = Instance.new("ImageLabel")
    thumbShadow.Size = UDim2.new(1, 10, 1, 10)
    thumbShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    thumbShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    thumbShadow.BackgroundTransparency = 1
    thumbShadow.Image = "rbxassetid://5554236805"
    thumbShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    thumbShadow.ImageTransparency = 0.6
    thumbShadow.ScaleType = Enum.ScaleType.Slice
    thumbShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    thumbShadow.ZIndex = 1
    thumbShadow.Parent = sliderThumb
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = math.floor(value)
        
        local percentage = (currentValue - min) / (max - min)
        
        valueLabel.Text = tostring(currentValue) .. (suffix or "")
        
        local fillTween = self.Utility:CreateTween(sliderFill, {
            Size = UDim2.new(percentage, 0, 1, 0)
        }, 0.15)
        fillTween:Play()
        
        local thumbTween = self.Utility:CreateTween(sliderThumb, {
            Position = UDim2.new(percentage, 0, 0.5, 0)
        }, 0.15)
        thumbTween:Play()
        
        if callback then
            callback(currentValue)
        end
    end
    
    local function handleInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            
            local function update()
                local mousePos = UserInputService:GetMouseLocation()
                local relativePos = mousePos.X - sliderTrack.AbsolutePosition.X
                local percentage = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
                local value = min + (percentage * (max - min))
                updateSlider(value)
            end
            
            update()
            
            local moveConnection
            moveConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    moveConnection:Disconnect()
                end
            end)
        end
    end
    
    sliderTrack.InputBegan:Connect(handleInput)
    sliderThumb.InputBegan:Connect(handleInput)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos.X - sliderTrack.AbsolutePosition.X
            local percentage = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (percentage * (max - min))
            updateSlider(value)
        end
    end)
    
    sliderThumb.MouseEnter:Connect(function()
        local tween = self.Utility:CreateTween(sliderThumb, {
            Size = UDim2.new(0, self.Utility:ScaleSize(22), 0, self.Utility:ScaleSize(22))
        }, 0.2, Enum.EasingStyle.Back)
        tween:Play()
    end)
    
    sliderThumb.MouseLeave:Connect(function()
        if not dragging then
            local tween = self.Utility:CreateTween(sliderThumb, {
                Size = UDim2.new(0, self.Utility:ScaleSize(18), 0, self.Utility:ScaleSize(18))
            }, 0.2)
            tween:Play()
        end
    end)
    
    return {
        Frame = slider,
        SetValue = updateSlider,
        GetValue = function() return currentValue end
    }
end

-- ============================================
-- COMBAT ENGINE
-- ============================================
local CombatEngine = {}
CombatEngine.__index = CombatEngine

function CombatEngine.new(framework)
    local self = setmetatable({}, CombatEngine)
    
    self.Framework = framework
    self.Utility = framework.Utility
    self.UIComponents = UIComponents.new(framework)
    
    -- Settings
    self.Settings = {
        AimbotEnabled = false,
        SilentAimEnabled = false,
        FOVSize = 150,
        PredictionScale = 1.0,
        ShowFOV = true,
        TargetPlayers = true,
        TargetVehicles = true,
        BulletVelocity = 3000, -- Default bullet speed for War Tycoon
        VisibilityCheck = true
    }
    
    -- Target tracking
    self.CurrentTarget = nil
    self.LockedPart = nil
    
    -- FOV Circle
    self.FOVCircle = nil
    
    -- Connections
    self.Connections = {}
    
    self:Initialize()
    
    return self
end

function CombatEngine:Initialize()
    self:CreateUI()
    self:CreateFOVCircle()
    self:StartTargetingSystem()
end

function CombatEngine:CreateUI()
    local combatContent = self.Framework:GetContentFrame("Combat")
    
    if not combatContent then
        warn("Combat content frame not found!")
        return
    end
    
    -- Aimbot Section
    local aimbotSection = self.UIComponents:CreateSection(combatContent, "⚔️ Aimbot System", 1)
    
    self.UIComponents:CreateToggle(
        aimbotSection,
        "Enable Aimbot",
        "Automatically aim at targets within FOV",
        false,
        function(enabled)
            self.Settings.AimbotEnabled = enabled
            self.Framework:Notify(
                "Aimbot",
                enabled and "تم تفعيل Aimbot" or "تم إيقاف Aimbot",
                2,
                enabled and "success" or "info"
            )
        end,
        1
    )
    
    self.UIComponents:CreateToggle(
        aimbotSection,
        "Silent Aim",
        "Hit targets without moving camera",
        false,
        function(enabled)
            self.Settings.SilentAimEnabled = enabled
            self.Framework:Notify(
                "Silent Aim",
                enabled and "تم تفعيل Silent Aim" or "تم إيقاف Silent Aim",
                2,
                enabled and "success" or "info"
            )
        end,
        2
    )
    
    self.UIComponents:CreateToggle(
        aimbotSection,
        "Show FOV Circle",
        "Display targeting circle on screen",
        true,
        function(enabled)
            self.Settings.ShowFOV = enabled
            if self.FOVCircle then
                self.FOVCircle.Visible = enabled
            end
        end,
        3
    )
    
    -- Targeting Section
    local targetSection = self.UIComponents:CreateSection(combatContent, "🎯 Target Settings", 2)
    
    self.UIComponents:CreateToggle(
        targetSection,
        "Target Players",
        "Lock onto enemy players",
        true,
        function(enabled)
            self.Settings.TargetPlayers = enabled
        end,
        1
    )
    
    self.UIComponents:CreateToggle(
        targetSection,
        "Target Vehicles",
        "Lock onto jets, helicopters, and tanks",
        true,
        function(enabled)
            self.Settings.TargetVehicles = enabled
        end,
        2
    )
    
    self.UIComponents:CreateToggle(
        targetSection,
        "Visibility Check",
        "Only target visible enemies",
        true,
        function(enabled)
            self.Settings.VisibilityCheck = enabled
        end,
        3
    )
    
    -- Advanced Section
    local advancedSection = self.UIComponents:CreateSection(combatContent, "⚙️ Advanced Settings", 3)
    
    self.UIComponents:CreateSlider(
        advancedSection,
        "FOV Size",
        "Adjust targeting circle radius",
        0,
        800,
        150,
        "px",
        function(value)
            self.Settings.FOVSize = value
            if self.FOVCircle then
                self.FOVCircle.Radius = value
            end
        end,
        1
    )
    
    self.UIComponents:CreateSlider(
        advancedSection,
        "Prediction Scale",
        "Adjust for fast-moving targets (Jets)",
        0,
        3,
        1,
        "x",
        function(value)
            self.Settings.PredictionScale = value
        end,
        2
    )
    
    self.UIComponents:CreateSlider(
        advancedSection,
        "Bullet Velocity",
        "Your weapon's bullet speed",
        500,
        5000,
        3000,
        " s/s",
        function(value)
            self.Settings.BulletVelocity = value
        end,
        3
    )
end

function CombatEngine:CreateFOVCircle()
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 64
    circle.Radius = self.Settings.FOVSize
    circle.Filled = false
    circle.Transparency = 1
    circle.Color = Color3.fromRGB(66, 135, 245)
    circle.Visible = self.Settings.ShowFOV
    circle.ZIndex = 1000
    
    self.FOVCircle = circle
    
    -- Update circle position
    local connection = RunService.RenderStepped:Connect(function()
        if circle then
            local viewportSize = Camera.ViewportSize
            circle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            circle.Radius = self.Settings.FOVSize
            circle.Visible = self.Settings.ShowFOV
            
            -- Color based on target lock
            if self.CurrentTarget then
                circle.Color = Color3.fromRGB(76, 175, 80) -- Green when locked
            else
                circle.Color = Color3.fromRGB(66, 135, 245) -- Blue when searching
            end
        end
    end)
    
    table.insert(self.Connections, connection)
end

function CombatEngine:GetCharacterParts(character)
    if not character then return {} end
    
    local parts = {}
    
    -- Priority parts for aiming
    local priorityParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
    
    for _, partName in ipairs(priorityParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    
    return parts
end

function CombatEngine:GetVehicleParts(vehicle)
    local parts = {}
    
    -- Look for vehicle seats and engine parts
    for _, descendant in ipairs(vehicle:GetDescendants()) do
        if descendant:IsA("VehicleSeat") or descendant.Name:lower():find("engine") or descendant.Name:lower():find("cockpit") then
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
    end
    
    -- If no specific parts found, use any BasePart
    if #parts == 0 then
        for _, descendant in ipairs(vehicle:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "Handle" then
                table.insert(parts, descendant)
                if #parts >= 5 then break end
            end
        end
    end
    
    return parts
end

function CombatEngine:IsVisible(targetPart)
    if not self.Settings.VisibilityCheck then return true end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local ray = Ray.new(origin, direction)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {character, Camera})
    
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

function CombatEngine:GetScreenPosition(worldPosition)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPosition)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function CombatEngine:IsInFOV(targetPart)
    local screenPos, onScreen = self:GetScreenPosition(targetPart.Position)
    
    if not onScreen then return false end
    
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local distance = (screenPos - center).Magnitude
    
    return distance <= self.Settings.FOVSize
end

function CombatEngine:PredictPosition(targetPart)
    -- Physics Prediction Formula: P = P0 + V * t
    -- Where:
    -- P = Predicted position
    -- P0 = Current position
    -- V = Velocity
    -- t = Time (distance / bullet velocity)
    
    local currentPos = targetPart.Position
    local velocity = targetPart.AssemblyLinearVelocity
    
    -- Calculate time for bullet to reach target
    local distance = (currentPos - Camera.CFrame.Position).Magnitude
    local bulletTime = distance / self.Settings.BulletVelocity
    
    -- Apply prediction scale for fast targets (jets, helicopters)
    local scaledTime = bulletTime * self.Settings.PredictionScale
    
    -- Calculate predicted position
    local predictedPos = currentPos + (velocity * scaledTime)
    
    return predictedPos
end

function CombatEngine:GetBestTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    
    -- Check players
    if self.Settings.TargetPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local parts = self:GetCharacterParts(character)
                    
                    for _, part in ipairs(parts) do
                        if self:IsInFOV(part) and self:IsVisible(part) then
                            local screenPos = self:GetScreenPosition(part.Position)
                            local viewportSize = Camera.ViewportSize
                            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                            local distance = (screenPos - center).Magnitude
                            
                            if distance < bestDistance then
                                bestDistance = distance
                                bestTarget = part
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Check vehicles
    if self.Settings.TargetVehicles then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("jet") or obj.Name:lower():find("heli") or obj.Name:lower():find("tank") or obj:FindFirstChildOfClass("VehicleSeat")) then
                local parts = self:GetVehicleParts(obj)
                
                for _, part in ipairs(parts) do
                    if self:IsInFOV(part) and self:IsVisible(part) then
                        local screenPos = self:GetScreenPosition(part.Position)
                        local viewportSize = Camera.ViewportSize
                        local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                        local distance = (screenPos - center).Magnitude
                        
                        if distance < bestDistance then
                            bestDistance = distance
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

function CombatEngine:AimAt(targetPart)
    if not targetPart then return end
    
    local predictedPos = self:PredictPosition(targetPart)
    local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    
    if self.Settings.SilentAimEnabled then
        -- Silent aim: Don't move camera, just adjust shot
        -- This will be handled by the weapon hook (Part 3)
        self.LockedPart = targetPart
    else
        -- Normal aim: Smoothly move camera
        Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, 0.2)
    end
end

function CombatEngine:StartTargetingSystem()
    local connection = RunService.RenderStepped:Connect(function()
        if self.Settings.AimbotEnabled then
            local target = self:GetBestTarget()
            self.CurrentTarget = target
            
            if target then
                self:AimAt(target)
            else
                self.LockedPart = nil
            end
        else
            self.CurrentTarget = nil
            self.LockedPart = nil
        end
    end)
    
    table.insert(self.Connections, connection)
end

function CombatEngine:GetLockedTarget()
    return self.LockedPart
end

function CombatEngine:Cleanup()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    
    if self.FOVCircle then
        self.FOVCircle:Remove()
    end
end

-- ============================================
-- INTEGRATE WITH FRAMEWORK
-- ============================================
local function InitializeCombat(framework)
    local combat = CombatEngine.new(framework)
    
    framework:Notify(
        "Combat System",
        "تم تحميل نظام القتال بنجاح!",
        3,
        "success"
    )
    
    return combat
end

-- Return the initialization function
return InitializeCombat
