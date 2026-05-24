-- glitched.exe | WindUI Edition

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================
-- State
-- =====================

local State = {
    Walkspeed = 16,
    JumpPower = 50,
    LoopWS = false,
    LoopJP = false,
    Fly = false,
    Noclip = false,
    Aimbot = false,
    AntiAFK = false,
    InfJump = false,
    ESPEnabled = false,
    TracersEnabled = false,
    AimbotFOV = 150,
    AimbotSmoothing = 0.1,
    FlySpeed = 50,
}

local ESPObjects = {}
local FlyBodyVelocity, FlyBodyGyro
local InfJumpConn, AntiAFKConn, LoopWSConn, LoopJPConn

-- =====================
-- Helpers
-- =====================

local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()
    local c = GetCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetRootPart()
    local c = GetCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- =====================
-- WindUI Window
-- =====================

local Window = WindUI:CreateWindow({
    Title = "glitched.exe",
    Icon = "zap",
    Author = "glitched",
    Folder = "glitched_exe",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

local Tabs = {
    Movement = Window:Tab({ Title = "Movement", Icon = "footprints" }),
    Combat   = Window:Tab({ Title = "Combat",   Icon = "crosshair"  }),
    Visuals  = Window:Tab({ Title = "Visuals",  Icon = "eye"        }),
    Players  = Window:Tab({ Title = "Players",  Icon = "users"      }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings"   }),
}

-- =====================
-- MOVEMENT TAB
-- =====================

local MoveSec = Tabs.Movement:Section({ Title = "Speed & Jump" })

MoveSec:Slider({
    Title = "Walk Speed",
    Description = "Set player walk speed",
    Default = 16, Min = 0, Max = 500, Decimals = 0,
    Callback = function(v)
        State.Walkspeed = v
        local h = GetHumanoid()
        if h then h.WalkSpeed = v end
    end,
})

MoveSec:Slider({
    Title = "Jump Power",
    Description = "Set player jump height",
    Default = 50, Min = 0, Max = 500, Decimals = 0,
    Callback = function(v)
        State.JumpPower = v
        local h = GetHumanoid()
        if h then
            if h.UseJumpPower then h.JumpPower = v else h.JumpHeight = v end
        end
    end,
})

MoveSec:Toggle({
    Title = "Loop Walk Speed",
    Description = "Continuously reapply walk speed",
    Default = false,
    Callback = function(v)
        State.LoopWS = v
        if LoopWSConn then LoopWSConn:Disconnect() end
        if v then
            LoopWSConn = RunService.Heartbeat:Connect(function()
                local h = GetHumanoid()
                if h then h.WalkSpeed = State.Walkspeed end
            end)
        end
    end,
})

MoveSec:Toggle({
    Title = "Loop Jump Power",
    Description = "Continuously reapply jump power",
    Default = false,
    Callback = function(v)
        State.LoopJP = v
        if LoopJPConn then LoopJPConn:Disconnect() end
        if v then
            LoopJPConn = RunService.Heartbeat:Connect(function()
                local h = GetHumanoid()
                if h then
                    if h.UseJumpPower then h.JumpPower = State.JumpPower else h.JumpHeight = State.JumpPower end
                end
            end)
        end
    end,
})

-- Inf Jump
local JumpSec = Tabs.Movement:Section({ Title = "Inf Jump" })

JumpSec:Toggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely in the air",
    Default = false,
    Callback = function(v)
        State.InfJump = v
        if InfJumpConn then InfJumpConn:Disconnect() end
        if v then
            InfJumpConn = UserInputService.JumpRequest:Connect(function()
                local h = GetHumanoid()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end,
})

-- Fly
local FlySec = Tabs.Movement:Section({ Title = "Fly" })

FlySec:Slider({
    Title = "Fly Speed",
    Default = 50, Min = 10, Max = 300, Decimals = 0,
    Callback = function(v) State.FlySpeed = v end,
})

local function EnableFly()
    local root = GetRootPart()
    if not root then return end
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVelocity.Parent = root
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyGyro.P = 1e4
    FlyBodyGyro.Parent = root
    RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Input.Value, function()
        if not State.Fly then return end
        local r = GetRootPart()
        if not r then return end
        local cf = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        FlyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
        FlyBodyGyro.CFrame = cf
    end)
end

local function DisableFly()
    RunService:UnbindFromRenderStep("FlyStep")
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
end

FlySec:Toggle({
    Title = "Enable Fly",
    Description = "WASD to move, Space/Ctrl for up/down",
    Default = false,
    Callback = function(v)
        State.Fly = v
        if v then EnableFly() else DisableFly() end
    end,
})

-- Noclip
local NoclipSec = Tabs.Movement:Section({ Title = "Noclip" })

NoclipSec:Toggle({
    Title = "Enable Noclip",
    Description = "Disable collision with all parts",
    Default = false,
    Callback = function(v) State.Noclip = v end,
})

RunService.Stepped:Connect(function()
    if State.Noclip then
        local c = GetCharacter()
        if c then
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)

-- Anti-AFK
local MiscSec = Tabs.Movement:Section({ Title = "Misc" })

MiscSec:Toggle({
    Title = "Anti-AFK",
    Description = "Prevent auto-kick for being idle",
    Default = false,
    Callback = function(v)
        State.AntiAFK = v
        if AntiAFKConn then AntiAFKConn:Disconnect() end
        if v then
            AntiAFKConn = LocalPlayer.Idled:Connect(function()
                -- Fire a fake VirtualUser input to reset idle timer
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end,
})

-- Reapply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.Walkspeed
    if hum.UseJumpPower then hum.JumpPower = State.JumpPower else hum.JumpHeight = State.JumpPower end
end)

-- =====================
-- COMBAT TAB
-- =====================

local AimbotSec = Tabs.Combat:Section({ Title = "Aimbot" })

AimbotSec:Toggle({
    Title = "Enable Aimbot",
    Description = "Hold RMB to lock onto nearest player",
    Default = false,
    Callback = function(v) State.Aimbot = v end,
})

AimbotSec:Slider({
    Title = "FOV Radius",
    Default = 150, Min = 10, Max = 700, Decimals = 0,
    Callback = function(v) State.AimbotFOV = v end,
})

AimbotSec:Slider({
    Title = "Smoothing",
    Description = "Higher = slower lock",
    Default = 10, Min = 1, Max = 100, Decimals = 0,
    Callback = function(v) State.AimbotSmoothing = v / 1000 end,
})

local function GetClosestToCenter()
    local closest, dist = nil, math.huge
    local center = Camera.ViewportSize / 2
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        local sp, vis = Camera:WorldToViewportPoint(root.Position)
        if not vis then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < dist and d <= State.AimbotFOV then
            dist = d
            closest = p
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not State.Aimbot then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local target = GetClosestToCenter()
    if not target then return end
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head then return end
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, head.Position), State.AimbotSmoothing)
end)

-- =====================
-- VISUALS TAB
-- =====================

local ESPSec = Tabs.Visuals:Section({ Title = "ESP" })

local ESP_COLOR = Color3.fromRGB(255, 60, 60)
local TRACER_COLOR = Color3.fromRGB(255, 220, 0)

local function CreateESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 120, 0, 36)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    local lbl = Instance.new("TextLabel", bb)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextColor3 = ESP_COLOR
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Text = player.Name
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = TRACER_COLOR
    tracer.Thickness = 1
    tracer.Transparency = 1
    ESPObjects[player] = { BB = bb, Tracer = tracer, Label = lbl }
    local function attach()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root and ESPObjects[player] then
            bb.Adornee = root
            bb.Parent = game:GetService("CoreGui")
        end
    end
    task.spawn(attach)
    player.CharacterAdded:Connect(function() task.spawn(attach) end)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].BB then ESPObjects[player].BB:Destroy() end
        if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
        ESPObjects[player] = nil
    end
end

ESPSec:Toggle({
    Title = "Enable ESP",
    Description = "Show player names and health",
    Default = false,
    Callback = function(v)
        State.ESPEnabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
        else
            for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
        end
    end,
})

ESPSec:Toggle({
    Title = "Enable Tracers",
    Description = "Draw lines from screen bottom to players",
    Default = false,
    Callback = function(v) State.TracersEnabled = v end,
})

RunService.RenderStepped:Connect(function()
    for player, objs in pairs(ESPObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local sp, vis = Camera:WorldToViewportPoint(root.Position)
            if objs.BB then
                objs.BB.Enabled = State.ESPEnabled and vis
                if objs.Label then
                    objs.Label.Text = player.Name .. " [" .. math.floor(hum.Health) .. "HP]"
                end
            end
            if objs.Tracer then
                objs.Tracer.Visible = State.TracersEnabled and vis
                if State.TracersEnabled and vis then
                    local vs = Camera.ViewportSize
                    objs.Tracer.From = Vector2.new(vs.X / 2, vs.Y)
                    objs.Tracer.To   = Vector2.new(sp.X, sp.Y)
                end
            end
        else
            if objs.BB then objs.BB.Enabled = false end
            if objs.Tracer then objs.Tracer.Visible = false end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if State.ESPEnabled then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

-- =====================
-- PLAYERS TAB (Teleport)
-- =====================

local TpSec = Tabs.Players:Section({ Title = "Teleport to Player" })

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then names = { "No players found" } end
    return names
end

local PlayerDropdown

PlayerDropdown = TpSec:Dropdown({
    Title = "Select Player",
    Description = "Choose a player to teleport to",
    Values = GetPlayerNames(),
    Default = 1,
    Callback = function(_) end, -- selection stored internally
})

TpSec:Button({
    Title = "Teleport",
    Description = "Teleport to selected player",
    Callback = function()
        local selected = PlayerDropdown:GetValue()
        if not selected or selected == "No players found" then return end
        local target = Players:FindFirstChild(selected)
        if not target then return end
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local myRoot = GetRootPart()
        if tRoot and myRoot then
            myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

TpSec:Button({
    Title = "↻ Refresh Player List",
    Description = "Update the list after players join or leave",
    Callback = function()
        PlayerDropdown:SetValues(GetPlayerNames())
    end,
})

-- Auto-refresh on player join/leave
Players.PlayerAdded:Connect(function()
    PlayerDropdown:SetValues(GetPlayerNames())
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    PlayerDropdown:SetValues(GetPlayerNames())
end)

-- =====================
-- SETTINGS TAB
-- =====================

local ThemeSec = Tabs.Settings:Section({ Title = "Theme" })

ThemeSec:Dropdown({
    Title = "UI Theme",
    Values = { "Dark", "Light", "Darker" },
    Default = 1,
    Callback = function(v)
        Window:SetTheme(v)
    end,
})

Tabs.Settings:Section({ Title = "Info" }):Label({
    Title = "glitched.exe — WindUI Edition",
})

WindUI:Notify({
    Title = "glitched.exe",
    Content = "Script loaded successfully!",
    Duration = 4,
})
