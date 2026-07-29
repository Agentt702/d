-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
--
-- Stay safe:
--   • Never log in on unofficial Roblox sites or lookalike domains.
--   • Real Roblox links use roblox.com (check the .com ending).
--   • Treat fake Roblox login / "claim reward" pages as phishing.
-- [[ End Rscripts Risk Notice ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Infinite Spin & Boss Farm - Shindo Life",
    SubTitle = "Auto spin and boss farmer",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Boss = Window:AddTab({ Title = "Boss Farm", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Variables
local tpsrv = game:GetService("TeleportService")
local elementwanted = {}
local slots = {"kg1", "kg2", "kg3", "kg4"}
local autoSpinEnabled = false

-- Boss Farm Variables
local autoBossEnabled = false
local selectedBoss = "All Bosses"
local bossList = {"All Bosses", "Tails", "Sengoku", "Reaper", "Jokei", "Borumki"} -- أمثلة لبعض زعماء شيندو

-- Function to get all element names from BossTab
local function getElementNames()
    local player = game:GetService("Players").LocalPlayer
    local bossTab = player.PlayerGui.Main.ingame.Menu.BossTab
    
    if bossTab then
        local elements = {}
        for _, frame in pairs(bossTab:GetChildren()) do
            if frame:IsA("Frame") and frame.Name then
                table.insert(elements, frame.Name)
            end
        end
        return elements
    end
    return {"boil", "lightning", "fire", "ice", "sand", "crystal", "explosion"} -- fallback
end

-- Function to start auto spin
local function startAutoSpin()
    print("Auto spin started!")
    
    repeat task.wait() until game:isLoaded()
    repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("startevent")
    
    print("Game loaded, starting to spin...")
    game:GetService("Players").LocalPlayer.startevent:FireServer("band", "\128")
    
    while autoSpinEnabled do
        task.wait(0.3)
        
        -- Check if we got any desired elements
        for _, slot in pairs(slots) do
            if game:GetService("Players").LocalPlayer.statz.main[slot] and game:GetService("Players").LocalPlayer.statz.main[slot].Value then
                local currentElement = game:GetService("Players").LocalPlayer.statz.main[slot].Value
                
                local isWanted = false
                for _, element in pairs(elementwanted) do
                    if currentElement == element then
                        isWanted = true
                        break
                    end
                end
                
                if isWanted then
                    print("Got " .. currentElement .. " in " .. slot .. "!")
                    game:GetService("Players").LocalPlayer.startevent:FireServer("band", "Eye")
                    task.wait(1)
                    game.Players.LocalPlayer:Kick("Got " .. currentElement .. " in " .. slot .. "!")
                    return
                end
            end
        end
        
        -- Check if any slot has low spins
        if game:GetService("Players").LocalPlayer.statz.spins and game:GetService("Players").LocalPlayer.statz.spins.Value <= 1 then
            tpsrv:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
        
        -- Spin all slots
        for _, slot in pairs(slots) do
            game:GetService("Players").LocalPlayer.startevent:FireServer("spin", slot)
        end
    end
end

-- Function to stop auto spin
local function stopAutoSpin()
    autoSpinEnabled = false
    getgenv().atspn = false
end

-- Function for Boss Farming Loop
local function startBossFarm()
    print("Boss Farm started!")
    while autoBossEnabled do
        task.wait(1)
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end

            -- البحث عن الزعماء في الـ Workspace أو مجلد الأعداء
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if selectedBoss == "AllBosses" or v.Name == selectedBoss then
                        -- الانتقال لموقع الزعيم وضربه
                        character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        
                        -- إرسال ضربة أو استخدام حدث القتال الخاص باللعبة إذا توفر
                        if player:FindFirstChild("startevent") then
                            player.startevent:FireServer("mouse1", true)
                        end
                    end
                end
            end
        end)
    end
end

do
    -- --- MAIN TAB ---
    local availableElements = getElementNames()
    
    local ElementDropdown = Tabs.Main:AddDropdown("ElementDropdown", {
        Title = "Select Bloodlines",
        Description = "Choose which bloodlines to auto-spin for",
        Values = availableElements,
        Multi = true,
        Default = {},
    })
    
    ElementDropdown:OnChanged(function(Value)
        elementwanted = {}
        for element, state in next, Value do
            if state then
                table.insert(elementwanted, element)
            end
        end
    end)
    
    local SlotDropdown = Tabs.Main:AddDropdown("SlotDropdown", {
        Title = "Select Slots",
        Description = "Choose which slots to spin",
        Values = slots,
        Multi = true,
        Default = {"kg1", "kg2"},
    })
    
    SlotDropdown:OnChanged(function(Value)
        slots = {}
        for slot, state in next, Value do
            if state then
                table.insert(slots, slot)
            end
        end
    end)
    
    local AutoSpinToggle = Tabs.Main:AddToggle("AutoSpinToggle", {
        Title = "Auto Spin",
        Description = "Automatically spin for selected bloodlines",
        Default = false
    })
    
    AutoSpinToggle:OnChanged(function()
        autoSpinEnabled = Options.AutoSpinToggle.Value
        if autoSpinEnabled then
            getgenv().atspn = true
            Fluent:Notify({ Title = "Auto Spin", Content = "Started auto spinning", Duration = 3 })
            task.spawn(startAutoSpin)
        else
            stopAutoSpin()
            Fluent:Notify({ Title = "Auto Spin", Content = "Stopped auto spinning", Duration = 3 })
        end
    end)
    
    Tabs.Main:AddButton({
        Title = "Manual Spin",
        Description = "Spin once manually",
        Callback = function()
            if game:GetService("Players").LocalPlayer:FindFirstChild("startevent") then
                for _, slot in pairs(slots) do
                    game:GetService("Players").LocalPlayer.startevent:FireServer("spin", slot)
                end
                Fluent:Notify({ Title = "Manual Spin", Content = "Spun all selected slots", Duration = 2 })
            end
        end
    })

    -- --- BOSS TAB ---
    local BossDropdown = Tabs.Boss:AddDropdown("BossDropdown", {
        Title = "Select Boss",
        Description = "Choose the boss you want to farm",
        Values = bossList,
        Multi = false,
        Default = 1,
    })

    BossDropdown:OnChanged(function(Value)
        selectedBoss = Value
    end)

    local AutoBossToggle = Tabs.Boss:AddToggle("AutoBossToggle", {
        Title = "Auto Farm Boss",
        Description = "Automatically teleport to and attack the selected boss",
        Default = false
    })

    AutoBossToggle:OnChanged(function()
        autoBossEnabled = Options.AutoBossToggle.Value
        if autoBossEnabled then
            Fluent:Notify({ Title = "Boss Farm", Content = "Started boss farming", Duration = 3 })
            task.spawn(startBossFarm)
        else
            Fluent:Notify({ Title = "Boss Farm", Content = "Stopped boss farming", Duration = 3 })
        end
    end)

    Tabs.Boss:AddButton({
        Title = "Teleport to Boss",
        Description = "Instant teleport to the active boss",
        Callback = function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    Fluent:Notify({ Title = "Teleport", Content = "Teleported to boss: " .. v.Name, Duration = 2 })
                    return
                end
            end
            Fluent:Notify({ Title = "Error", Content = "No active boss found!", Duration = 2 })
        end
    })
end

-- Addons setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("InfiniteSpin")
SaveManager:SetFolder("InfiniteSpin/shindo-life")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Infinite Spin",
    Content = "Script loaded successfully with Boss Farm!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
