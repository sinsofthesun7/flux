-- glitched.exe | Rayfield Edition

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================
-- State
-- =====================

-- Hello

local State = {
    Walkspeed       = 16,
    JumpPower       = 50,
    FlySpeed        = 50,
    AimbotFOV       = 150,
    AimbotSmoothing = 0.1,
    LoopWS          = false,
    LoopJP          = false,
    Fly             = false,
    Noclip          = false,
    Aimbot          = false,
    AntiAFK         = false,
    InfJump         = false,
    ESPEnabled      = false,
    TracersEnabled  = false,
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

local function SafeExec(url, label)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        Rayfield:Notify({
            Title   = "glitched.exe",
            Content = label .. " failed to load: " .. tostring(err),
            Duration = 5,
            Image   = 4483362458,
        })
    end
end

-- =====================
-- Rayfield Window
-- =====================

local Window = Rayfield:CreateWindow({
    Name                  = "glitched.exe",
    Icon                  = 0,
    LoadingTitle          = "glitched.exe",
    LoadingSubtitle       = "by glitched",
    Theme                 = "Default",
    DisableRayfieldPrompt = false,
    DisableBuildWarnings  = false,
    ConfigurationSaving   = {
        Enabled    = true,
        FolderName = "glitched_exe",
        FileName   = "config",
    },
    Discord    = { Enabled = false },
    KeySystem  = false,
})

-- =====================
-- TABS
-- =====================

local MovementTab = Window:CreateTab("Movement", "footprints")
local CombatTab   = Window:CreateTab("Combat",   "crosshair")
local VisualsTab  = Window:CreateTab("Visuals",  "eye")
local PlayersTab  = Window:CreateTab("Players",  "users")
local HubsTab     = Window:CreateTab("Hubs",     "layout-grid")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- =====================
-- MOVEMENT TAB
-- =====================

MovementTab:CreateSection("Speed & Jump")

MovementTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {0, 500},
    Increment    = 1,
    Suffix       = "WS",
    CurrentValue = 16,
    Flag         = "WalkspeedSlider",
    Callback     = function(v)
        State.Walkspeed = v
        local h = GetHumanoid()
        if h then h.WalkSpeed = v end
    end,
})

MovementTab:CreateSlider({
    Name         = "Jump Power",
    Range        = {0, 500},
    Increment    = 1,
    Suffix       = "JP",
    CurrentValue = 50,
    Flag         = "JumpPowerSlider",
    Callback     = function(v)
        State.JumpPower = v
        local h = GetHumanoid()
        if h then
            if h.UseJumpPower then h.JumpPower = v else h.JumpHeight = v end
        end
    end,
})

MovementTab:CreateToggle({
    Name         = "Loop Walk Speed",
    CurrentValue = false,
    Flag         = "LoopWS",
    Callback     = function(v)
        State.LoopWS = v
        if LoopWSConn then LoopWSConn:Disconnect() LoopWSConn = nil end
        if v then
            LoopWSConn = RunService.Heartbeat:Connect(function()
                local h = GetHumanoid()
                if h then h.WalkSpeed = State.Walkspeed end
            end)
        end
    end,
})

MovementTab:CreateToggle({
    Name         = "Loop Jump Power",
    CurrentValue = false,
    Flag         = "LoopJP",
    Callback     = function(v)
        State.LoopJP = v
        if LoopJPConn then LoopJPConn:Disconnect() LoopJPConn = nil end
        if v then
            LoopJPConn = RunService.Heartbeat:Connect(function()
                local h = GetHumanoid()
                if h then
                    if h.UseJumpPower then h.JumpPower = State.JumpPower
                    else h.JumpHeight = State.JumpPower end
                end
            end)
        end
    end,
})

MovementTab:CreateSection("Infinite Jump")

MovementTab:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v)
        State.InfJump = v
        if InfJumpConn then InfJumpConn:Disconnect() InfJumpConn = nil end
        if v then
            InfJumpConn = UserInputService.JumpRequest:Connect(function()
                local h = GetHumanoid()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end,
})

MovementTab:CreateSection("Fly")

MovementTab:CreateSlider({
    Name         = "Fly Speed",
    Range        = {10, 300},
    Increment    = 1,
    Suffix       = "SPD",
    CurrentValue = 50,
    Flag         = "FlySpeed",
    Callback     = function(v) State.FlySpeed = v end,
})

local function EnableFly()
    local root = GetRootPart()
    if not root then return end
    FlyBodyVelocity            = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity   = Vector3.zero
    FlyBodyVelocity.MaxForce   = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVelocity.Parent     = root
    FlyBodyGyro                = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque      = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyGyro.P              = 1e4
    FlyBodyGyro.Parent         = root
    RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Input.Value, function()
        if not State.Fly then return end
        local r = GetRootPart()
        if not r then return end
        local cf  = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        FlyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
        FlyBodyGyro.CFrame       = cf
    end)
end

local function DisableFly()
    RunService:UnbindFromRenderStep("FlyStep")
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    if FlyBodyGyro     then FlyBodyGyro:Destroy()     FlyBodyGyro     = nil end
end

MovementTab:CreateToggle({
    Name         = "Enable Fly",
    CurrentValue = false,
    Flag         = "FlyToggle",
    Callback     = function(v)
        State.Fly = v
        if v then EnableFly() else DisableFly() end
    end,
})

MovementTab:CreateSection("Noclip")

MovementTab:CreateToggle({
    Name         = "Enable Noclip",
    CurrentValue = false,
    Flag         = "NoclipToggle",
    Callback     = function(v) State.Noclip = v end,
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

MovementTab:CreateSection("Misc")

MovementTab:CreateToggle({
    Name         = "Anti-AFK",
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(v)
        State.AntiAFK = v
        if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
        if v then
            AntiAFKConn = LocalPlayer.Idled:Connect(function()
                local VU = game:GetService("VirtualUser")
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.Walkspeed
    if hum.UseJumpPower then hum.JumpPower = State.JumpPower
    else hum.JumpHeight = State.JumpPower end
end)

-- =====================
-- COMBAT TAB
-- =====================

CombatTab:CreateSection("Aimbot")

CombatTab:CreateToggle({
    Name         = "Enable Aimbot",
    CurrentValue = false,
    Flag         = "AimbotToggle",
    Callback     = function(v) State.Aimbot = v end,
})

CombatTab:CreateSlider({
    Name         = "FOV Radius",
    Range        = {10, 700},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = 150,
    Flag         = "AimbotFOV",
    Callback     = function(v) State.AimbotFOV = v end,
})

CombatTab:CreateSlider({
    Name         = "Smoothing",
    Range        = {1, 100},
    Increment    = 1,
    Suffix       = "",
    CurrentValue = 10,
    Flag         = "AimbotSmooth",
    Callback     = function(v) State.AimbotSmoothing = v / 1000 end,
})

local function GetClosestToCenter()
    local closest, bestDist = nil, math.huge
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
        if d < bestDist and d <= State.AimbotFOV then
            bestDist = d
            closest  = p
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
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, head.Position),
        State.AimbotSmoothing
    )
end)

-- =====================
-- VISUALS TAB
-- =====================

local ESP_COLOR    = Color3.fromRGB(255, 60, 60)
local TRACER_COLOR = Color3.fromRGB(255, 220, 0)

VisualsTab:CreateSection("ESP")

local function CreateESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local bb       = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 130, 0, 36)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    local lbl                   = Instance.new("TextLabel", bb)
    lbl.BackgroundTransparency  = 1
    lbl.Size                    = UDim2.new(1, 0, 1, 0)
    lbl.TextColor3              = ESP_COLOR
    lbl.TextStrokeTransparency  = 0
    lbl.Font                    = Enum.Font.GothamBold
    lbl.TextSize                = 13
    lbl.Text                    = player.Name
    local tracer        = Drawing.new("Line")
    tracer.Visible      = false
    tracer.Color        = TRACER_COLOR
    tracer.Thickness    = 1
    tracer.Transparency = 1
    ESPObjects[player]  = { BB = bb, Tracer = tracer, Label = lbl }
    local function attach()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root and ESPObjects[player] then
            bb.Adornee = root
            bb.Parent  = game:GetService("CoreGui")
        end
    end
    task.spawn(attach)
    player.CharacterAdded:Connect(function() task.spawn(attach) end)
end

local function RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].BB     then ESPObjects[player].BB:Destroy()    end
        if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
        ESPObjects[player] = nil
    end
end

VisualsTab:CreateToggle({
    Name         = "Enable ESP",
    CurrentValue = false,
    Flag         = "ESPToggle",
    Callback     = function(v)
        State.ESPEnabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
        else
            for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
        end
    end,
})

VisualsTab:CreateToggle({
    Name         = "Enable Tracers",
    CurrentValue = false,
    Flag         = "TracerToggle",
    Callback     = function(v) State.TracersEnabled = v end,
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
            if objs.BB     then objs.BB.Enabled    = false end
            if objs.Tracer then objs.Tracer.Visible = false end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if State.ESPEnabled then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

-- =====================
-- PLAYERS TAB
-- =====================

PlayersTab:CreateSection("Teleport to Player")

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then return { "No players found" } end
    return names
end

local SelectedPlayer = nil

local PlayerDropdown = PlayersTab:CreateDropdown({
    Name          = "Select Player",
    Options       = GetPlayerNames(),
    CurrentOption = { GetPlayerNames()[1] },
    Flag          = "TeleportDropdown",
    Callback      = function(v)
        SelectedPlayer = v[1] ~= "No players found" and v[1] or nil
    end,
})

PlayersTab:CreateButton({
    Name     = "Teleport",
    Callback = function()
        if not SelectedPlayer then
            Rayfield:Notify({ Title = "glitched.exe", Content = "No player selected.", Duration = 3, Image = 4483362458 })
            return
        end
        local target = Players:FindFirstChild(SelectedPlayer)
        if not target then return end
        local tRoot  = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = GetRootPart()
        if tRoot and myRoot then
            myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
            Rayfield:Notify({ Title = "glitched.exe", Content = "Teleported to " .. SelectedPlayer, Duration = 2, Image = 4483362458 })
        end
    end,
})

PlayersTab:CreateButton({
    Name     = "↻ Refresh Player List",
    Callback = function()
        local names = GetPlayerNames()
        PlayerDropdown:Set(names[1])
        SelectedPlayer = nil
        Rayfield:Notify({ Title = "glitched.exe", Content = "Player list refreshed.", Duration = 2, Image = 4483362458 })
    end,
})

Players.PlayerAdded:Connect(function()
    local names = GetPlayerNames()
    PlayerDropdown:Set(names[1])
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    local names = GetPlayerNames()
    PlayerDropdown:Set(names[1])
    SelectedPlayer = nil
end)

-- =====================
-- HUBS TAB
-- =====================

HubsTab:CreateSection("Admin & Commands")

HubsTab:CreateButton({
    Name        = "Infinite Yield",
    Description = "Feature-rich admin command hub",
    Callback    = function()
        Rayfield:Notify({ Title = "glitched.exe", Content = "Loading Infinite Yield...", Duration = 3, Image = 4483362458 })
        SafeExec("https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua", "Infinite Yield")
    end,
})

HubsTab:CreateSection("Utility")

HubsTab:CreateButton({
    Name        = "Dex Explorer",
    Description = "Explore and edit the game's DataModel",
    Callback    = function()
        Rayfield:Notify({ Title = "glitched.exe", Content = "Loading Dex Explorer...", Duration = 3, Image = 4483362458 })
        SafeExec("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", "Dex Explorer")
    end,
})

HubsTab:CreateButton({
    Name        = "Remote Spy",
    Description = "Monitor all RemoteEvent and RemoteFunction calls",
    Callback    = function()
        Rayfield:Notify({ Title = "glitched.exe", Content = "Loading Remote Spy...", Duration = 3, Image = 4483362458 })
        SafeExec("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua", "Remote Spy")
    end,
})

HubsTab:CreateSection("Movement Hubs")

HubsTab:CreateButton({
    Name        = "WalkSpeed GUI",
    Description = "Standalone speed/jump GUI",
    Callback    = function()
        Rayfield:Notify({ Title = "glitched.exe", Content = "Loading WalkSpeed GUI...", Duration = 3, Image = 4483362458 })
        SafeExec("https://raw.githubusercontent.com/RandomGamingDev/roblox-scripts/main/Speed%20GUI.lua", "WalkSpeed GUI")
    end,
})

-- =====================
-- SETTINGS TAB
-- =====================

SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateDropdown({
    Name          = "Theme",
    Options       = { "Default", "ocean", "Amethyst", "Green", "Light" },
    CurrentOption = { "Default" },
    Flag          = "ThemeDropdown",
    Callback      = function(v)
        Rayfield:SetTheme(v[1])
    end,
})

SettingsTab:CreateSection("Config")

Rayfield:LoadConfiguration()

-- =====================
-- Ready
-- =====================

Rayfield:Notify({
    Title    = "glitched.exe",
    Content  = "Loaded successfully!",
    Duration = 4,
    Image    = 4483362458,
})
