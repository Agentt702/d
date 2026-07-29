-- [[ Rscripts Risk Notice ]]
-- Updated for Shindo Life [249]
-- [[ End Rscripts Risk Notice ]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Shindo Life [249] - Fixed Hub",
    SubTitle = "Working Auto Quests & Farm",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Spin", Icon = "rotate-cw" }),
    Auto = Window:AddTab({ Title = "Automations", Icon = "bot" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Helpers
local function getStartEvent()
    return LocalPlayer:FindFirstChild("startevent") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("startevent"))
end

local function safeTeleport(targetCFrame)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 300 -- سرعة طيران آمنة لمنع الكيك
        local info = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- Automation Flags
local autoGreenQuest = false
local autoBossQuest = false
local autoScroll = false
local autoDaily = false
local autoStats = false
local autoRankUp = false

----------------------------------------------------------------
-- 1. Auto Green Quest
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1.5) do
        if autoGreenQuest then
            pcall(function()
                local event = getStartEvent()
                if not event then return end

                for _, folder in pairs(workspace:GetChildren()) do
                    if folder.Name == "Missions" or folder:FindFirstChild("Mission") then
                        for _, quest in pairs(folder:GetChildren()) do
                            if quest:FindFirstChild("Head") and quest:FindFirstChild("Talk") then
                                safeTeleport(quest.Head.CFrame)
                                task.wait(1)
                                fireclickdetector(quest.Talk.ClickDetector)
                                task.wait(0.5)
                                event:FireServer("acceptmission")
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 2. Auto Boss Quest
----------------------------------------------------------------
task.spawn(function()
    while task.wait(2) do
        if autoBossQuest then
            pcall(function()
                local event = getStartEvent()
                if event then
                    event:FireServer("acceptbossmission")
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 3. Auto Scroll Collector
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoScroll then
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Scroll" or obj:FindFirstChild("Scroll") or obj.Name:lower():find("scroll") then
                        local part = obj:FindFirstChildWhichIsA("BasePart") or obj
                        if part then
                            local tw = safeTeleport(part.CFrame)
                            if tw then tw.Completed:Wait() end
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
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
                local event = getStartEvent()
                if event then
                    event:FireServer("dailyreward")
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- 5. Auto Add Stats
----------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoStats then
            pcall(function()
                local event = getStartEvent()
                if event then
                    local stats = {"ninjutsu", "taiJutsu", "chi", "health"}
                    for _, stat in pairs(stats) do
                        event:FireServer("stat", stat, 50)
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
    while task.wait(3) do
        if autoRankUp then
            pcall(function()
                local statz = LocalPlayer:FindFirstChild("statz")
                local event = getStartEvent()
                if statz and statz:FindFirstChild("lvl") and event then
                    if statz.lvl.Value >= 1000 then
                        event:FireServer("rankup")
                    end
                end
            end)
        end
    end
end)

----------------------------------------------------------------
-- UI SETUP
----------------------------------------------------------------
do
    Tabs.Auto:AddToggle("AutoGreenQuestToggle", {
        Title = "Auto Green Quest Farm",
        Default = false
    }):OnChanged(function(Value) autoGreenQuest = Value end)

    Tabs.Auto:AddToggle("AutoBossQuestToggle", {
        Title = "Auto Boss Quest Farm",
        Default = false
    }):OnChanged(function(Value) autoBossQuest = Value end)

    Tabs.Auto:AddToggle("AutoScrollToggle", {
        Title = "Auto Scroll Collector",
        Default = false
    }):OnChanged(function(Value) autoScroll = Value end)

    Tabs.Auto:AddToggle("AutoDailyToggle", {
        Title = "Auto Daily Collect",
        Default = false
    }):OnChanged(function(Value) autoDaily = Value end)

    Tabs.Auto:AddToggle("AutoStatsToggle", {
        Title = "Auto Add Stats",
        Default = false
    }):OnChanged(function(Value) autoStats = Value end)

    Tabs.Auto:AddToggle("AutoRankToggle", {
        Title = "Auto Rank Up",
        Default = false
    }):OnChanged(function(Value) autoRankUp = Value end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ShindoFix249")
SaveManager:SetFolder("ShindoFix249/config")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Shindo Life [249]",
    Content = "Script is fixed & ready!",
    Duration = 5
})
