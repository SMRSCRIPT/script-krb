-- ============================================
-- ECONOMY & AUTO-FARM ENGINE - Part 3
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- ============================================
-- ECONOMY SYSTEM
-- ============================================
local EconomySystem = {}
EconomySystem.__index = EconomySystem

function EconomySystem.new(framework)
    local self = setmetatable({}, EconomySystem)
    
    self.Framework = framework
    self.Utility = framework.Utility
    self.UIComponents = UIComponents.new(framework)
    
    -- Settings
    self.Settings = {
        AutoCollect = false,
        AutoATM = false,
        AutoOil = false,
        AutoBuy = false,
        PrioritizeDroppers = true,
        CollectInterval = 0.1,
        ATMInterval = 2,
        OilInterval = 3,
        BuyInterval = 5,
        MinCashReserve = 1000
    }
    
    -- State tracking
    self.PlayerTycoon = nil
    self.Collector = nil
    self.CashAmount = 0
    self.PurchasedButtons = {}
    
    -- Connections
    self.Connections = {}
    self.AutoFarmLoops = {}
    
    self:Initialize()
    
    return self
end

function EconomySystem:Initialize()
    self:CreateUI()
    self:FindPlayerTycoon()
    self:StartMonitoring()
end

function EconomySystem:CreateUI()
    local farmContent = self.Framework:GetContentFrame("Auto-Farm")
    
    if not farmContent then
        warn("Auto-Farm content frame not found!")
        return
    end
    
    -- Collection Section
    local collectionSection = self.UIComponents:CreateSection(farmContent, "💰 Auto Collection", 1)
    
    self.UIComponents:CreateToggle(
        collectionSection,
        "Auto Collect",
        "Automatically collect from your Tycoon collector",
        false,
        function(enabled)
            self.Settings.AutoCollect = enabled
            if enabled then
                self:StartAutoCollect()
            else
                self:StopLoop("AutoCollect")
            end
            self.Framework:Notify(
                "Auto Collect",
                enabled and "تم تفعيل الجمع التلقائي" or "تم إيقاف الجمع التلقائي",
                2,
                enabled and "success" or "info"
            )
        end,
        1
    )
    
    self.UIComponents:CreateToggle(
        collectionSection,
        "Auto ATM Farm",
        "Collect money from ATMs across the map",
        false,
        function(enabled)
            self.Settings.AutoATM = enabled
            if enabled then
                self:StartAutoATM()
            else
                self:StopLoop("AutoATM")
            end
            self.Framework:Notify(
                "Auto ATM",
                enabled and "تم تفعيل جمع ATM" or "تم إيقاف جمع ATM",
                2,
                enabled and "success" or "info"
            )
        end,
        2
    )
    
    self.UIComponents:CreateToggle(
        collectionSection,
        "Auto Oil Farm",
        "Collect oil from drills automatically",
        false,
        function(enabled)
            self.Settings.AutoOil = enabled
            if enabled then
                self:StartAutoOil()
            else
                self:StopLoop("AutoOil")
            end
            self.Framework:Notify(
                "Auto Oil",
                enabled and "تم تفعيل جمع النفط" or "تم إيقاف جمع النفط",
                2,
                enabled and "success" or "info"
            )
        end,
        3
    )
    
    -- Auto Buy Section
    local buySection = self.UIComponents:CreateSection(farmContent, "🛒 Smart Auto-Buy", 2)
    
    self.UIComponents:CreateToggle(
        buySection,
        "Auto Buy Buttons",
        "Automatically purchase Tycoon upgrades",
        false,
        function(enabled)
            self.Settings.AutoBuy = enabled
            if enabled then
                self:StartAutoBuy()
            else
                self:StopLoop("AutoBuy")
            end
            self.Framework:Notify(
                "Auto Buy",
                enabled and "تم تفعيل الشراء التلقائي" or "تم إيقاف الشراء التلقائي",
                2,
                enabled and "success" or "info"
            )
        end,
        1
    )
    
    self.UIComponents:CreateToggle(
        buySection,
        "Prioritize Droppers",
        "Buy money-generating items first",
        true,
        function(enabled)
            self.Settings.PrioritizeDroppers = enabled
        end,
        2
    )
    
    self.UIComponents:CreateSlider(
        buySection,
        "Cash Reserve",
        "Minimum cash to keep before buying",
        0,
        50000,
        1000,
        "$",
        function(value)
            self.Settings.MinCashReserve = value
        end,
        3
    )
    
    -- Performance Section
    local perfSection = self.UIComponents:CreateSection(farmContent, "⚙️ Performance Settings", 3)
    
    self.UIComponents:CreateSlider(
        perfSection,
        "Collect Speed",
        "Delay between collections (lower = faster)",
        0.1,
        2,
        0.1,
        "s",
        function(value)
            self.Settings.CollectInterval = value
        end,
        1
    )
    
    self.UIComponents:CreateSlider(
        perfSection,
        "ATM Interval",
        "Delay between ATM collections",
        1,
        10,
        2,
        "s",
        function(value)
            self.Settings.ATMInterval = value
        end,
        2
    )
    
    self.UIComponents:CreateSlider(
        perfSection,
        "Buy Interval",
        "Delay between purchase attempts",
        2,
        15,
        5,
        "s",
        function(value)
            self.Settings.BuyInterval = value
        end,
        3
    )
end

function EconomySystem:FindPlayerTycoon()
    -- War Tycoon specific: Find player's tycoon
    local tycoons = Workspace:WaitForChild("Tycoons", 10)
    
    if not tycoons then
        warn("Tycoons folder not found!")
        return
    end
    
    -- Look for tycoon with player's name or that they own
    for _, tycoon in ipairs(tycoons:GetChildren()) do
        if tycoon:IsA("Model") then
            local ownerValue = tycoon:FindFirstChild("Owner") or tycoon:FindFirstChild("OwnerName")
            
            if ownerValue and (ownerValue.Value == LocalPlayer or ownerValue.Value == LocalPlayer.Name) then
                self.PlayerTycoon = tycoon
                self:FindCollector()
                
                self.Framework:Notify(
                    "Tycoon Found",
                    "تم العثور على Tycoon الخاص بك!",
                    3,
                    "success"
                )
                return
            end
        end
    end
    
    -- If not found immediately, wait for claim
    task.spawn(function()
        task.wait(5)
        if not self.PlayerTycoon then
            self.Framework:Notify(
                "Tycoon Not Found",
                "قم بالمطالبة بـ Tycoon أولاً",
                4,
                "warning"
            )
        end
    end)
end

function EconomySystem:FindCollector()
    if not self.PlayerTycoon then return end
    
    -- Common collector names in War Tycoon
    local collectorNames = {"Collector", "Collect", "MoneyCollector", "CashCollector"}
    
    for _, name in ipairs(collectorNames) do
        local collector = self.PlayerTycoon:FindFirstChild(name, true)
        
        if collector and collector:IsA("BasePart") then
            self.Collector = collector
            return
        end
    end
    
    -- Search by proximity to player spawn
    local playerSpawn = self.PlayerTycoon:FindFirstChild("Spawn") or self.PlayerTycoon:FindFirstChild("PlayerSpawn")
    
    if playerSpawn then
        for _, part in ipairs(self.PlayerTycoon:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("collect") then
                self.Collector = part
                return
            end
        end
    end
end

function EconomySystem:GetPlayerCash()
    -- War Tycoon stores cash in leaderstats
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("$")
        
        if cash then
            self.CashAmount = cash.Value
            return cash.Value
        end
    end
    
    return 0
end

function EconomySystem:StartAutoCollect()
    if self.AutoFarmLoops["AutoCollect"] then return end
    
    local loopRunning = true
    self.AutoFarmLoops["AutoCollect"] = loopRunning
    
    task.spawn(function()
        while self.Settings.AutoCollect and loopRunning do
            if not self.Collector then
                self:FindCollector()
            end
            
            if self.Collector then
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    -- Use firetouchinterest for instant collection
                    if firetouchinterest then
                        firetouchinterest(hrp, self.Collector, 0)
                        task.wait(0.01)
                        firetouchinterest(hrp, self.Collector, 1)
                    else
                        -- Fallback: Move player briefly to collector
                        local originalCFrame = hrp.CFrame
                        hrp.CFrame = self.Collector.CFrame
                        task.wait(0.05)
                        hrp.CFrame = originalCFrame
                    end
                end
            end
            
            task.wait(self.Settings.CollectInterval)
        end
    end)
end

function EconomySystem:FindATMs()
    local atms = {}
    
    -- Common ATM locations in War Tycoon
    local atmParents = {Workspace, Workspace:FindFirstChild("Map"), Workspace:FindFirstChild("ATMs")}
    
    for _, parent in ipairs(atmParents) do
        if parent then
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    if obj.Name:lower():find("atm") or obj.Name:lower():find("bank") then
                        -- Find the clickable part
                        local clickPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                        
                        if clickPart then
                            table.insert(atms, clickPart)
                        end
                    end
                end
            end
        end
    end
    
    return atms
end

function EconomySystem:StartAutoATM()
    if self.AutoFarmLoops["AutoATM"] then return end
    
    local loopRunning = true
    self.AutoFarmLoops["AutoATM"] = loopRunning
    
    task.spawn(function()
        while self.Settings.AutoATM and loopRunning do
            local atms = self:FindATMs()
            
            for _, atm in ipairs(atms) do
                if not self.Settings.AutoATM then break end
                
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if hrp and atm.Parent then
                    -- Check if ATM has a ProximityPrompt
                    local prompt = atm:FindFirstChildOfClass("ProximityPrompt")
                    
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    elseif firetouchinterest then
                        -- Alternative: Touch the ATM
                        firetouchinterest(hrp, atm, 0)
                        task.wait(0.01)
                        firetouchinterest(hrp, atm, 1)
                    else
                        -- Fallback: Teleport to ATM
                        local originalCFrame = hrp.CFrame
                        hrp.CFrame = atm.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2)
                        hrp.CFrame = originalCFrame
                    end
                    
                    task.wait(0.5)
                end
            end
            
            task.wait(self.Settings.ATMInterval)
        end
    end)
end

function EconomySystem:FindOilDrills()
    local drills = {}
    
    -- Find oil drills in the map
    local oilParents = {Workspace, Workspace:FindFirstChild("Map"), Workspace:FindFirstChild("Oil")}
    
    for _, parent in ipairs(oilParents) do
        if parent then
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    if obj.Name:lower():find("oil") or obj.Name:lower():find("drill") or obj.Name:lower():find("pump") then
                        local clickPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                        
                        if clickPart then
                            table.insert(drills, clickPart)
                        end
                    end
                end
            end
        end
    end
    
    return drills
end

function EconomySystem:StartAutoOil()
    if self.AutoFarmLoops["AutoOil"] then return end
    
    local loopRunning = true
    self.AutoFarmLoops["AutoOil"] = loopRunning
    
    task.spawn(function()
        while self.Settings.AutoOil and loopRunning do
            local drills = self:FindOilDrills()
            
            for _, drill in ipairs(drills) do
                if not self.Settings.AutoOil then break end
                
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if hrp and drill.Parent then
                    local prompt = drill:FindFirstChildOfClass("ProximityPrompt")
                    
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    elseif firetouchinterest then
                        firetouchinterest(hrp, drill, 0)
                        task.wait(0.01)
                        firetouchinterest(hrp, drill, 1)
                    end
                    
                    task.wait(0.3)
                end
            end
            
            task.wait(self.Settings.OilInterval)
        end
    end)
end

function EconomySystem:FindBuyButtons()
    if not self.PlayerTycoon then return {} end
    
    local buttons = {}
    local buttonsFolder = self.PlayerTycoon:FindFirstChild("Buttons") or self.PlayerTycoon:FindFirstChild("PurchaseButtons")
    
    local searchArea = buttonsFolder or self.PlayerTycoon
    
    for _, obj in ipairs(searchArea:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            -- Look for button indicators
            local isButton = obj.Name:lower():find("button") or 
                           obj.Name:lower():find("buy") or 
                           obj.Name:lower():find("purchase")
            
            if isButton then
                local head = obj:FindFirstChild("Head") or obj:FindFirstChild("Button") or (obj:IsA("BasePart") and obj)
                
                if head and head:IsA("BasePart") then
                    -- Check if already purchased
                    if not self.PurchasedButtons[obj] then
                        -- Try to find cost
                        local cost = 0
                        local costLabel = obj:FindFirstChild("Cost", true) or obj:FindFirstChild("Price", true)
                        
                        if costLabel and costLabel:IsA("TextLabel") then
                            local costText = costLabel.Text:match("%d+")
                            cost = tonumber(costText) or 0
                        end
                        
                        -- Check if it's a dropper (money generator)
                        local isDropper = obj.Name:lower():find("dropper") or 
                                        obj.Name:lower():find("generator") or 
                                        obj.Name:lower():find("money")
                        
                        table.insert(buttons, {
                            Object = obj,
                            Head = head,
                            Cost = cost,
                            IsDropper = isDropper,
                            Priority = isDropper and 1 or 2
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by priority (droppers first) then by cost (cheapest first)
    table.sort(buttons, function(a, b)
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        end
        return a.Cost < b.Cost
    end)
    
    return buttons
end

function EconomySystem:StartAutoBuy()
    if self.AutoFarmLoops["AutoBuy"] then return end
    
    local loopRunning = true
    self.AutoFarmLoops["AutoBuy"] = loopRunning
    
    task.spawn(function()
        while self.Settings.AutoBuy and loopRunning do
            local currentCash = self:GetPlayerCash()
            local buttons = self:FindBuyButtons()
            
            for _, buttonData in ipairs(buttons) do
                if not self.Settings.AutoBuy then break end
                
                local availableCash = currentCash - self.Settings.MinCashReserve
                
                if availableCash >= buttonData.Cost then
                    local character = LocalPlayer.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and buttonData.Head.Parent then
                        -- Try different purchase methods
                        if firetouchinterest then
                            firetouchinterest(hrp, buttonData.Head, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, buttonData.Head, 1)
                        else
                            -- Teleport method
                            local originalCFrame = hrp.CFrame
                            hrp.CFrame = buttonData.Head.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.15)
                            hrp.CFrame = originalCFrame
                        end
                        
                        -- Mark as purchased
                        self.PurchasedButtons[buttonData.Object] = true
                        
                        self.Framework:Notify(
                            "Purchase",
                            string.format("تم شراء: %s ($%d)", buttonData.Object.Name, buttonData.Cost),
                            2,
                            "success"
                        )
                        
                        task.wait(1)
                        currentCash = self:GetPlayerCash()
                    end
                end
            end
            
            task.wait(self.Settings.BuyInterval)
        end
    end)
end

function EconomySystem:StopLoop(loopName)
    if self.AutoFarmLoops[loopName] then
        self.AutoFarmLoops[loopName] = false
        self.AutoFarmLoops[loopName] = nil
    end
end

function EconomySystem:StartMonitoring()
    -- Monitor tycoon ownership
    local connection = RunService.Heartbeat:Connect(function()
        if not self.PlayerTycoon then
            self:FindPlayerTycoon()
        end
    end)
    
    table.insert(self.Connections, connection)
end

function EconomySystem:Cleanup()
    for loopName, _ in pairs(self.AutoFarmLoops) do
        self:StopLoop(loopName)
    end
    
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
end

-- ============================================
-- WEAPON MODIFICATIONS SYSTEM
-- ============================================
local WeaponMods = {}
WeaponMods.__index = WeaponMods

function WeaponMods.new(framework)
    local self = setmetatable({}, WeaponMods)
    
    self.Framework = framework
    self.Utility = framework.Utility
    self.UIComponents = UIComponents.new(framework)
    
    -- Settings
    self.Settings = {
        NoRecoil = false,
        InfiniteAmmo = false,
        RapidFire = false,
        NoSpread = false
    }
    
    -- Hooks
    self.OriginalFunctions = {}
    self.Connections = {}
    
    self:Initialize()
    
    return self
end

function WeaponMods:Initialize()
    self:CreateUI()
    self:SetupWeaponHooks()
end

function WeaponMods:CreateUI()
    local miscContent = self.Framework:GetContentFrame("Misc")
    
    if not miscContent then
        warn("Misc content frame not found!")
        return
    end
    
    -- Weapon Mods Section
    local weaponSection = self.UIComponents:CreateSection(miscContent, "🔫 Weapon Modifications", 1)
    
    self.UIComponents:CreateToggle(
        weaponSection,
        "No Recoil",
        "Remove weapon recoil for perfect accuracy",
        false,
        function(enabled)
            self.Settings.NoRecoil = enabled
            self.Framework:Notify(
                "No Recoil",
                enabled and "تم تفعيل إزالة الارتداد" or "تم إيقاف إزالة الارتداد",
                2,
                enabled and "success" or "info"
            )
        end,
        1
    )
    
    self.UIComponents:CreateToggle(
        weaponSection,
        "Infinite Ammo",
        "Never run out of ammunition",
        false,
        function(enabled)
            self.Settings.InfiniteAmmo = enabled
            if enabled then
                self:EnableInfiniteAmmo()
            end
            self.Framework:Notify(
                "Infinite Ammo",
                enabled and "تم تفعيل الذخيرة اللانهائية" or "تم إيقاف الذخيرة اللانهائية",
                2,
                enabled and "success" or "info"
            )
        end,
        2
    )
    
    self.UIComponents:CreateToggle(
        weaponSection,
        "No Spread",
        "Remove bullet spread for pinpoint accuracy",
        false,
        function(enabled)
            self.Settings.NoSpread = enabled
            self.Framework:Notify(
                "No Spread",
                enabled and "تم تفعيل إزالة التشتت" or "تم إيقاف إزالة التشتت",
                2,
                enabled and "success" or "info"
            )
        end,
        3
    )
    
    self.UIComponents:CreateToggle(
        weaponSection,
        "Rapid Fire",
        "Increase weapon fire rate",
        false,
        function(enabled)
            self.Settings.RapidFire = enabled
            self.Framework:Notify(
                "Rapid Fire",
                enabled and "تم تفعيل الإطلاق السريع" or "تم إيقاف الإطلاق السريع",
                2,
                enabled and "success" or "info"
            )
        end,
        4
    )
end

function WeaponMods:SetupWeaponHooks()
    -- Monitor for weapons being equipped
    local function onCharacterAdded(character)
        character.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then
                task.wait(0.1)
                self:ModifyWeapon(tool)
            end
        end)
        
        -- Check existing tools
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                self:ModifyWeapon(tool)
            end
        end
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    
    -- Also monitor backpack
    local backpack = LocalPlayer:WaitForChild("Backpack")
    backpack.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            self:ModifyWeapon(tool)
        end
    end)
end

function WeaponMods:ModifyWeapon(tool)
    if not tool:IsA("Tool") then return end
    
    -- Find weapon scripts
    local weaponScript = tool:FindFirstChild("GunScript") or 
                        tool:FindFirstChild("WeaponScript") or 
                        tool:FindFirstChild("MainScript")
    
    if weaponScript then
        -- Hook into recoil
        task.spawn(function()
            while tool.Parent and self.Settings.NoRecoil do
                -- Find and modify recoil values
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        if obj.Name:lower():find("recoil") then
                            obj.Value = 0
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
    
    -- Monitor ammo
    if self.Settings.InfiniteAmmo then
        local ammoValue = tool:FindFirstChild("Ammo", true) or 
                         tool:FindFirstChild("CurrentAmmo", true) or
                         tool:FindFirstChild("Magazine", true)
        
        if ammoValue and (ammoValue:IsA("NumberValue") or ammoValue:IsA("IntValue")) then
            local maxAmmo = ammoValue.Value
            
            local connection = ammoValue:GetPropertyChangedSignal("Value"):Connect(function()
                if self.Settings.InfiniteAmmo then
                    ammoValue.Value = maxAmmo
                end
            end)
            
            table.insert(self.Connections, connection)
        end
    end
    
    -- Modify spread
    task.spawn(function()
        while tool.Parent and self.Settings.NoSpread do
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    if obj.Name:lower():find("spread") or obj.Name:lower():find("accuracy") then
                        obj.Value = 0
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    
    -- Rapid fire
    if self.Settings.RapidFire then
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                if obj.Name:lower():find("firerate") or obj.Name:lower():find("delay") or obj.Name:lower():find("cooldown") then
                    obj.Value = obj.Value * 0.5 -- 50% faster
                end
            end
        end
    end
end

function WeaponMods:EnableInfiniteAmmo()
    -- Continuously monitor all tools
    task.spawn(function()
        while self.Settings.InfiniteAmmo do
            local character = LocalPlayer.Character
            
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        local ammoValue = tool:FindFirstChild("Ammo", true) or 
                                        tool:FindFirstChild("CurrentAmmo", true) or
                                        tool:FindFirstChild("Magazine", true)
                        
                        if ammoValue and (ammoValue:IsA("NumberValue") or ammoValue:IsA("IntValue")) then
                            if ammoValue.Value < 999 then
                                ammoValue.Value = 999
                            end
                        end
                    end
                end
            end
            
            task.wait(0.1)
        end
    end)
end

function WeaponMods:Cleanup()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
end

-- ============================================
-- INITIALIZE SYSTEMS (Add to main script)
-- ============================================
local function InitializeEconomy(framework)
    local economy = EconomySystem.new(framework)
    local weaponMods = WeaponMods.new(framework)
    
    framework:Notify(
        "Economy System",
        "تم تحميل نظام الاقتصاد والأسلحة!",
        3,
        "success"
    )
    
    return {
        Economy = economy,
        WeaponMods = weaponMods
    }
end

-- At the end of your main script, add:
-- local Systems = InitializeEconomy(Framework)
