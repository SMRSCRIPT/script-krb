--[[
    War Tycoon Supremacy Framework - Part 1
    Mobile-Optimized UI System
    Author: Senior Luau Developer
    Version: 1.0.0
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- UTILITY MODULE
-- ============================================
local Utility = {}
Utility.__index = Utility

function Utility.new()
    local self = setmetatable({}, Utility)
    return self
end

function Utility:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility:GetScreenSize()
    local ViewportSize = workspace.CurrentCamera.ViewportSize
    return ViewportSize
end

function Utility:ScaleSize(baseSize)
    local viewport = self:GetScreenSize()
    local baseWidth = 1920
    local scale = viewport.X / baseWidth
    return math.max(baseSize * scale, baseSize * 0.7) -- Minimum 70% of base size
end

function Utility:CreateTween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

function Utility:RippleEffect(button, clickPosition)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X - button.AbsolutePosition.X, 0, clickPosition.Y - button.AbsolutePosition.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local rippleCorner = Instance.new("UICorner")
    rippleCorner.CornerRadius = UDim.new(1, 0)
    rippleCorner.Parent = ripple
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    local tween = self:CreateTween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Linear)
    
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(parent)
    local self = setmetatable({}, NotificationManager)
    self.Parent = parent
    self.Notifications = {}
    self.Utility = Utility.new()
    
    self:CreateContainer()
    
    return self
end

function NotificationManager:CreateContainer()
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 300, 1, -20)
    container.Position = UDim2.new(1, -310, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = self.Parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = container
    
    self.Container = container
end

function NotificationManager:Send(title, message, duration, notifType)
    duration = duration or 3
    notifType = notifType or "info" -- info, success, warning, error
    
    local colors = {
        info = Color3.fromRGB(66, 135, 245),
        success = Color3.fromRGB(76, 175, 80),
        warning = Color3.fromRGB(255, 152, 0),
        error = Color3.fromRGB(244, 67, 54)
    }
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors[notifType]
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = notification
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = colors[notifType]
    accent.BorderSizePixel = 0
    accent.Parent = notification
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -50, 0, 35)
    messageLabel.Position = UDim2.new(0, 15, 0, 28)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = notification
    
    -- Animations
    local openTween = self.Utility:CreateTween(notification, {
        Size = UDim2.new(1, 0, 0, 70)
    }, 0.4, Enum.EasingStyle.Back)
    openTween:Play()
    
    -- Close function
    local function closeNotification()
        local closeTween = self.Utility:CreateTween(notification, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        closeTween:Play()
        closeTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close
    task.delay(duration, closeNotification)
    
    table.insert(self.Notifications, notification)
end

-- ============================================
-- MAIN UI FRAMEWORK
-- ============================================
local UIFramework = {}
UIFramework.__index = UIFramework

function UIFramework.new()
    local self = setmetatable({}, UIFramework)
    
    self.Utility = Utility.new()
    self.IsOpen = false
    self.CurrentTab = "Combat"
    self.Tabs = {}
    
    self:Initialize()
    
    return self
end

function UIFramework:Initialize()
    self:CreateScreenGui()
    self:CreateFloatingButton()
    self:CreateMainFrame()
    self:CreateSidebar()
    self:CreateTabContents()
    self:CreateNotificationSystem()
    
    self:SetupResponsiveScaling()
end

function UIFramework:CreateScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WarTycoonSupremacy"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protection against detection
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end
    
    self.ScreenGui = screenGui
end

function UIFramework:CreateFloatingButton()
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Size = UDim2.new(0, self.Utility:ScaleSize(70), 0, self.Utility:ScaleSize(70))
    floatingButton.Position = UDim2.new(1, -90, 0.5, -35)
    floatingButton.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = ""
    floatingButton.AutoButtonColor = false
    floatingButton.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatingButton
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = floatingButton.ZIndex - 1
    shadow.Parent = floatingButton
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 135, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242))
    }
    gradient.Rotation = 45
    gradient.Parent = floatingButton
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "KRB"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = self.Utility:ScaleSize(20)
    label.Font = Enum.Font.GothamBold
    label.Parent = floatingButton
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatingButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    floatingButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            
            local tween = self.Utility:CreateTween(floatingButton, {
                Position = newPosition
            }, 0.1, Enum.EasingStyle.Linear)
            tween:Play()
        end
    end)
    
    -- Click to toggle UI
    floatingButton.MouseButton1Click:Connect(function()
        if not dragging then
            self:ToggleUI()
        end
    end)
    
    -- Hover effects
    floatingButton.MouseEnter:Connect(function()
        local tween = self.Utility:CreateTween(floatingButton, {
            Size = UDim2.new(0, self.Utility:ScaleSize(75), 0, self.Utility:ScaleSize(75))
        }, 0.2, Enum.EasingStyle.Back)
        tween:Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        local tween = self.Utility:CreateTween(floatingButton, {
            Size = UDim2.new(0, self.Utility:ScaleSize(70), 0, self.Utility:ScaleSize(70))
        }, 0.2, Enum.EasingStyle.Back)
        tween:Play()
    end)
    
    self.FloatingButton = floatingButton
end

function UIFramework:CreateMainFrame()
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, self.Utility:ScaleSize(800), 0, self.Utility:ScaleSize(500))
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(66, 135, 245)
    stroke.Thickness = 2
    stroke.Transparency = 0.7
    stroke.Parent = mainFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, self.Utility:ScaleSize(50))
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 12)
    topBarCorner.Parent = topBar
    
    local topBarBottomCover = Instance.new("Frame")
    topBarBottomCover.Size = UDim2.new(1, 0, 0, 12)
    topBarBottomCover.Position = UDim2.new(0, 0, 1, -12)
    topBarBottomCover.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    topBarBottomCover.BorderSizePixel = 0
    topBarBottomCover.Parent = topBar
    
    -- Title with gradient
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "WAR TYCOON SUPREMACY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = self.Utility:ScaleSize(18)
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(66, 135, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    titleGradient.Parent = title
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(0, 200, 0, 15)
    subtitle.Position = UDim2.new(0, 20, 0, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Mobile Optimized Framework v1.0"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.TextSize = self.Utility:ScaleSize(10)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = topBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, self.Utility:ScaleSize(45), 0, self.Utility:ScaleSize(45))
    closeButton.Position = UDim2.new(1, -self.Utility:ScaleSize(50), 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(0, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = self.Utility:ScaleSize(20)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.AutoButtonColor = false
    closeButton.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    
    closeButton.MouseEnter:Connect(function()
        local tween = self.Utility:CreateTween(closeButton, {
            BackgroundColor3 = Color3.fromRGB(255, 77, 64)
        }, 0.2)
        tween:Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        local tween = self.Utility:CreateTween(closeButton, {
            BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        }, 0.2)
        tween:Play()
    end)
    
    self.MainFrame = mainFrame
    self.TopBar = topBar
end

function UIFramework:CreateSidebar()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, self.Utility:ScaleSize(200), 1, -self.Utility:ScaleSize(50))
    sidebar.Position = UDim2.new(0, 0, 0, self.Utility:ScaleSize(50))
    sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = sidebar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = sidebar
    
    local tabs = {
        {Name = "Combat", Icon = "⚔️"},
        {Name = "Auto-Farm", Icon = "🌾"},
        {Name = "Visuals", Icon = "👁️"},
        {Name = "Misc", Icon = "⚙️"}
    }
    
    for i, tabData in ipairs(tabs) do
        local tabButton = self:CreateTabButton(tabData.Name, tabData.Icon, i)
        tabButton.Parent = sidebar
    end
    
    self.Sidebar = sidebar
end

function UIFramework:CreateTabButton(tabName, icon, order)
    local button = Instance.new("TextButton")
    button.Name = tabName .. "Button"
    button.Size = UDim2.new(1, 0, 0, self.Utility:ScaleSize(50))
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, 0)
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = self.Utility:ScaleSize(18)
    iconLabel.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 45, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tabName
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = self.Utility:ScaleSize(14)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    button.MouseButton1Click:Connect(function()
        self:SwitchTab(tabName)
        self.Utility:RippleEffect(button, UserInputService:GetMouseLocation())
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabName then
            local tween = self.Utility:CreateTween(button, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            }, 0.2)
            tween:Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabName then
            local tween = self.Utility:CreateTween(button, {
                BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            }, 0.2)
            tween:Play()
        end
    end)
    
    self.Tabs[tabName] = {
        Button = button,
        Indicator = indicator,
        Label = label
    }
    
    return button
end

function UIFramework:CreateTabContents()
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -self.Utility:ScaleSize(210), 1, -self.Utility:ScaleSize(60))
    contentFrame.Position = UDim2.new(0, self.Utility:ScaleSize(210), 0, self.Utility:ScaleSize(60))
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = self.MainFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentFrame
    
    -- Create scroll frame for each tab
    local tabNames = {"Combat", "Auto-Farm", "Visuals", "Misc"}
    
    for _, tabName in ipairs(tabNames) do
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = tabName .. "Content"
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(66, 135, 245)
        scrollFrame.Visible = (tabName == "Combat")
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Parent = contentFrame
        
        local scrollLayout = Instance.new("UIListLayout")
        scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        scrollLayout.Padding = UDim.new(0, 10)
        scrollLayout.Parent = scrollFrame
        
        self.Tabs[tabName].Content = scrollFrame
    end
    
    self.ContentFrame = contentFrame
end

function UIFramework:CreateNotificationSystem()
    self.NotificationManager = NotificationManager.new(self.ScreenGui)
end

function UIFramework:SwitchTab(tabName)
    self.CurrentTab = tabName
    
    for name, tabData in pairs(self.Tabs) do
        local isActive = (name == tabName)
        
        -- Update button appearance
        local targetColor = isActive and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(30, 30, 35)
        local targetTextColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        local buttonTween = self.Utility:CreateTween(tabData.Button, {
            BackgroundColor3 = targetColor
        }, 0.3)
        buttonTween:Play()
        
        local labelTween = self.Utility:CreateTween(tabData.Label, {
            TextColor3 = targetTextColor
        }, 0.3)
        labelTween:Play()
        
        -- Update indicator
        local indicatorTween = self.Utility:CreateTween(tabData.Indicator, {
            Size = isActive and UDim2.new(0, 3, 0, 40) or UDim2.new(0, 3, 0, 0)
        }, 0.3, Enum.EasingStyle.Back)
        indicatorTween:Play()
        
        -- Show/hide content
        if tabData.Content then
            tabData.Content.Visible = isActive
        end
    end
end

function UIFramework:ToggleUI()
    self.IsOpen = not self.IsOpen
    
    if self.IsOpen then
        self.MainFrame.Visible = true
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        local tween = self.Utility:CreateTween(self.MainFrame, {
            Size = UDim2.new(0, self.Utility:ScaleSize(800), 0, self.Utility:ScaleSize(500))
        }, 0.4, Enum.EasingStyle.Back)
        tween:Play()
        
        -- Hide floating button
        local floatTween = self.Utility:CreateTween(self.FloatingButton, {
            Position = UDim2.new(1, 20, 0.5, -35)
        }, 0.3)
        floatTween:Play()
    else
        local tween = self.Utility:CreateTween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.3)
        tween:Play()
        
        tween.Completed:Connect(function()
            self.MainFrame.Visible = false
        end)
        
        -- Show floating button
        local floatTween = self.Utility:CreateTween(self.FloatingButton, {
            Position = UDim2.new(1, -90, 0.5, -35)
        }, 0.3)
        floatTween:Play()
    end
end

function UIFramework:SetupResponsiveScaling()
    local function updateScale()
        local viewport = self.Utility:GetScreenSize()
        local isMobile = self.Utility:IsMobile()
        
        if isMobile then
            -- Adjust for mobile
            local scale = math.min(viewport.X / 800, viewport.Y / 500)
            self.MainFrame.Size = UDim2.new(0, viewport.X * 0.95, 0, viewport.Y * 0.85)
        end
    end
    
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    updateScale()
end

function UIFramework:GetContentFrame(tabName)
    if self.Tabs[tabName] and self.Tabs[tabName].Content then
        return self.Tabs[tabName].Content
    end
    return nil
end

function UIFramework:Notify(title, message, duration, notifType)
    self.NotificationManager:Send(title, message, duration, notifType)
end

-- ============================================
-- INITIALIZE FRAMEWORK
-- ============================================
local Framework = UIFramework.new()

-- Welcome notification
task.wait(0.5)
Framework:Notify("مرحباً!", "تم تحميل War Tycoon Supremacy Framework بنجاح", 4, "success")

return Framework
