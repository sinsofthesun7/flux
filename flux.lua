print("EXECUTED: THANK YOU FOR USING FLUX HUB 💖")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local State = {
    WalkSpeed = 16,
    JumpPower = 50,
}

local Window = Rayfield:CreateWindow({
    Name = "Flux Universal",
    Icon = 0,
    LoadingTitle = "Flux Universal",
    LoadingSubtitle = "by Butcher",
    ConfigurationSaving = { Enabled = true, FolderName = "flux_universal", FileName = "config" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function SafeExec(url, label)
    local ok, err = pcall(function()
    Rayfield:Notify({Title = "Flux", Content = `Loading script {tostring(label)} ...`, Duration = 3})
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        Rayfield:Notify({
            Title   = "Flux",
            Content = label .. " failed to load: " .. tostring(err),
            Duration = 5,
            Image   = 4483362458,
        })
    end
end

local Movement = Window:CreateTab("Movement", "footprints")

Movement:CreateSection("Traversal")

Movement:CreateSlider({
    Name = "Walk Speed",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(v)
        State.WalkSpeed = v
    end,
})

Movement:CreateSlider({
    Name = "Jump Power",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(v)
        State.JumpPower = v
    end,
})

Movement:CreateSection("Flight & Noclip")

Movement:CreateButton({
    Name = "Flight GUI",
    Description = "A standalone flight & noclip library",
    Callback = function()
       SafeExec('https://weinzspace.com/revamp.lua', "Flight & Noclip") 
    end
})

Rayfield:LoadConfiguration()

RunService.Heartbeat:Connect(function()
    local h = GetHumanoid()
    if h then
        h.WalkSpeed = State.WalkSpeed
        if h.UseJumpPower then h.JumpPower = State.JumpPower
        else h.JumpHeight = State.JumpPower end
    end
end)

Rayfield:Notify({
    Title = "Flux",
    Content = "Loaded Successfully! Have fun <3",
    Duration = 4,
})
