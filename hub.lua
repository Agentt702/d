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
    Title = "Shindo Life - All-In-One Hub",
    SubTitle = "Auto Spin, Boss Farm & Auto Quests",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Spin", Icon = "rotate-cw" }),
    Boss = Window:AddTab({ Title = "Boss Farm", Icon = "swords" }),
    Auto = Window:AddTab({ Title = "Automations", Icon = "bot" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- Variables
local elementwanted = {}
local slots = {"kg1", "kg2", "kg3", "kg4"}
local autoSpinEnabled = false

-- Automation Toggles
local autoGreenQuest = false
local autoBossQuest = false
local autoScroll = false
local autoDaily = false
local autoStats = false
local autoRankUp = false

-- Function to get element names
local function getElementNames()
    local bossTab = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main.ingame.Menu.BossTab
    if bossTab then
        local elements = {}
        for _, frame in pairs(bossTab:GetChildren()) do
            if frame:IsA("Frame") and frame.Name then
                table.insert(elements, frame.Name)
            end
        end
        return elements
    end
    return {"boil", "lightning", "fire", "ice", "sand", "crystal", "explosion"}
end

----------------------------------------------------------------
-- 1. Auto Green Quest
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoGreenQuest then
            pcall(function()
                -- البحث عن مهمات خضراء في الـ Workspace واستلامها
                for _, quest in pairs(workspace:GetChildren()) do
                    if quest:FindFirstChild("Mission") and quest.Mission.Value == "Green" then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = quest.CFrame
                            task.wait(0.5)
                            if LocalPlayer:FindFirstChild("startevent") then
                                LocalPlayer.startevent:FireServer("acceptmission", quest)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 2. Auto Boss Quest Farm
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoBossQuest then
            pcall(function()
                -- قبول مهمات البوس والذهاب لهدف القتل
                if LocalPlayer:FindFirstChild("startevent") then
                    LocalPlayer.startevent:FireServer("acceptbossmission")
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 3. Auto Scroll Collector
----------------------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do
        if autoScroll then
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:FindFirstChild("Scroll") or (obj:IsA("Model") and obj.Name:lower():find("scroll")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame()
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj:FindFirstChildWhichIsA("BasePart"), 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj:FindFirstChildWhichIsA("BasePart"), 1)
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 4. Auto Daily Collect
----------------------------------------------------------------
task.spawn(function()
    while task.wait(5) do
        if autoDaily then
            pcall(function()
                if LocalPlayer:FindFirstChild("startevent") then
                    LocalPlayer.startevent:FireServer("dailyreward")
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 5. Auto Stats (توزيع نقاط اللفل تلقائياً)
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoStats then
            pcall(function()
                if LocalPlayer:FindFirstChild("startevent") and LocalPlayer:FindFirstChild("statz") then
                    local statTypes = {"ninjutsu", "taiJutsu", "chi", "health"}
                    for _, stat in pairs(statTypes) do
                        LocalPlayer.startevent:FireServer("stat", stat, 100)
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 6. Auto Rank Up
----------------------------------------------------------------
task.spawn(function()
    while task.wait(2) do
        if autoRankUp then
            pcall(function()
                if LocalPlayer:FindFirstChild("statz") and LocalPlayer.statz:FindFirstChild("lvl") then
                    if LocalPlayer.statz.lvl.Value >= 1000 then
                        if LocalPlayer:FindFirstChild("startevent") then
                            LocalPlayer.startevent:FireServer("rankup")
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- UI CONFIGURATION (FLUENT)
----------------------------------------------------------------
do
    -- --- MAIN TAB (SPIN) ---
    local availableElements = getElementNames()
    
    local ElementDropdown = Tabs.Main:AddDropdown("ElementDropdown", {
        Title = "Select Bloodlines",
        Values = availableElements,
        Multi = true,
        Default = {},
    })
    
    ElementDropdown:OnChanged(function(Value)
        elementwanted = {}
        for element, state in next, Value do
            if state then table.insert(elementwanted, element) end
        end
    end)
    
    local SlotDropdown = Tabs.Main:AddDropdown("SlotDropdown", {
        Title = "Select Slots",
        Values = slots,
        Multi = true,
        Default = {"kg1", "kg2"},
    })
    
    SlotDropdown:OnChanged(function(Value)
        slots = {}
        for slot, state in next, Value do
            if state then table.insert(slots, slot) end
        end
    end)
    
    Tabs.Main:AddToggle("AutoSpinToggle", {
        Title = "Auto Spin",
        Default = false
    }):OnChanged(function(Value)
        autoSpinEnabled = Value
    end)

    -- --- AUTOMATIONS TAB ---
    Tabs.Auto:AddToggle("AutoGreenQuestToggle", {
        Title = "Auto Green Quest Farm",
        Description = "Automatically accept and farm green quests",
        Default = false
    }):OnChanged(function(Value) autoGreenQuest = Value end)

    Tabs.Auto:AddToggle("AutoBossQuestToggle", {
        Title = "Auto Boss Quest Farm",
        Description = "Automatically accept and complete boss quests",
        Default = false
    }):OnChanged(function(Value) autoBossQuest = Value end)

    Tabs.Auto:AddToggle("AutoScrollToggle", {
        Title = "Auto Scroll Collector",
        Description = "Teleport to spawned scrolls in the server",
        Default = false
    }):OnChanged(function(Value) autoScroll = Value end)

    Tabs.Auto:AddToggle("AutoDailyToggle", {
        Title = "Auto Daily Collect",
        Description = "Collect daily rewards automatically",
        Default = false
    }):OnChanged(function(Value) autoDaily = Value end)

    Tabs.Auto:AddToggle("AutoStatsToggle", {
        Title = "Auto Add Stats",
        Description = "Automatically upgrade all stats when leveling up",
        Default = false
    }):OnChanged(function(Value) autoStats = Value end)

    Tabs.Auto:AddToggle("AutoRankToggle", {
        Title = "Auto Rank Up",
        Description = "Automatically ranks up when reaching level 1000",
        Default = false
    }):OnChanged(function(Value) autoRankUp = Value end)
end

-- Addons & Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ShindoLifeHub")
SaveManager:SetFolder("ShindoLifeHub/config")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Shindo Life Hub",
    Content = "Script loaded successfully with all Auto-Farm features!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
