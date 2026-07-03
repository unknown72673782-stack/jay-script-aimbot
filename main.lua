-- JayJay's Aimbot - Red Glow (Wallbang ESP + Smooth Aim)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = " JayJay's Aimbot",
    LoadingTitle = "JayJay's Aimbot",
    LoadingSubtitle = "DADDY LOVES U",
})

local HomeTab = Window:CreateTab(" Home", 4483362458)
local MainTab = Window:CreateTab(" Main", 4483362458)
local VisualsTab = Window:CreateTab(" Visuals", 4483362458)
local DonateTab = Window:CreateTab(" Donate", 4483362458)

-- Home
HomeTab:CreateLabel("👑 Owner: THEYFWJJTOFINE (@Gameboy_TJ02)")
HomeTab:CreateButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/bz4HnVXmd")
        Rayfield:Notify({Title = "Discord", Content = "Link copied!", Duration = 5})
    end
})

-- Donate
DonateTab:CreateLabel("Support the dev")
DonateTab:CreateLabel("Cash App: $Jayhem9")
DonateTab:CreateButton({
    Name = "Copy Cash App",
    Callback = function()
        setclipboard("$Jayhem9")
        Rayfield:Notify({Title = "Cash App", Content = "$Jayhem9 copied!", Duration = 4})
    end
})

-- Settings
local espEnabled = false
local showHealth = true
local showDevice = true
local aimlockEnabled = false
local smoothAimEnabled = true
local lockedTarget = nil
local lockSpeed = 0.40
local espColor = Color3.fromRGB(255, 0, 80)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local espObjects = {}

local function isValidTarget(p)
    local s,r = pcall(function()
        if not p or not p.Character then return false end
        local h = p.Character:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end)
    return s and r or false
end

local function getTargetPosition(p)
    local s,r = pcall(function()
        if not p or not p.Character then return nil end
        local head = p.Character:FindFirstChild("Head")
        if head then return head.Position + Vector3.new(0, 0.35, 0) end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if root then return root.Position + Vector3.new(0, 2.8, 0) end
        return nil
    end)
    return s and r or nil
end

local function getClosestToCrosshair()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and isValidTarget(p) then
            local pos = getTargetPosition(p)
            if pos then
                local sp, on = Camera:WorldToViewportPoint(pos)
                if on then
                    local d = (Vector2.new(sp.X,sp.Y) - center).Magnitude
                    if d < dist and d < 250 then
                        dist = d
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

local function getDevice(p)
    if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "Console (PS5/Xbox)"
    elseif UserInputService.TouchEnabled then
        return "Mobile"
    else
        return "PC"
    end
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 and aimlockEnabled then
        if lockedTarget then
            lockedTarget = nil
        else
            local target = getClosestToCrosshair()
            if target then lockedTarget = target end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if aimlockEnabled and lockedTarget and isValidTarget(lockedTarget) then
        local pos = getTargetPosition(lockedTarget)
        if pos then
            local dir = (pos - Camera.CFrame.Position).Unit
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + dir)
            local finalSpeed = smoothAimEnabled and lockSpeed or 0.35
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, finalSpeed)
        else
            lockedTarget = nil
        end
    end
end)

MainTab:CreateToggle({
    Name = "Aimlock (Right Click DADDY)",
    CurrentValue = false,
    Callback = function(v)
        aimlockEnabled = v
        if not v then lockedTarget = nil end
    end
})

MainTab:CreateToggle({
    Name = "Smooth Aim (Harder to Detect)",
    CurrentValue = true,
    Callback = function(v)
        smoothAimEnabled = v
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Boxes",
    CurrentValue = false,
    Callback = function(v) espEnabled = v end
})

VisualsTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Callback = function(v) showHealth = v end
})

VisualsTab:CreateToggle({
    Name = "Show Device",
    CurrentValue = true,
    Callback = function(v) showDevice = v end
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 80),
    Callback = function(value)
        espColor = value
    end
})

-- ESP with better wall penetration
local function createESPForPlayer(p)
    local char = p.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- This makes it see through walls
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.05
    hl.OutlineColor = espColor
    hl.FillColor = espColor
    hl.Enabled = espEnabled
    hl.Parent = Camera

    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.new(0,160,0,70)
    bb.StudsOffset = Vector3.new(0,4,0)
    bb.AlwaysOnTop = true
    bb.Enabled = espEnabled
    bb.Parent = hl

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 15
    label.Parent = bb

    espObjects[p] = {highlight = hl, billboard = bb, label = label}
end

local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        if isValidTarget(p) then
            if not espObjects[p] then createESPForPlayer(p) end
            local data = espObjects[p]
            if data then
                local text = p.Name
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if showHealth and hum then
                    text = text .. "\n[" .. math.floor(hum.Health) .. " HP]"
                end
                if showDevice then
                    text = text .. "\n[" .. getDevice(p) .. "]"
                end
                data.label.Text = text
                data.highlight.Enabled = espEnabled
                data.billboard.Enabled = espEnabled
                data.highlight.OutlineColor = espColor
                data.highlight.FillColor = espColor
            end
        elseif espObjects[p] then
            pcall(function() espObjects[p].highlight:Destroy() end)
            espObjects[p] = nil
        end
    end
end

task.spawn(function()
    while true do
        updateESP()
        task.wait(0.25)
    end
end)

Rayfield:Notify({Title = " JayJay's Aimbot", Content = "esp better", Duration = 5}) 