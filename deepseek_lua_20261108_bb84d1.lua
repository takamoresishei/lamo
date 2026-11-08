--[[
    Blox Fruits Hub — v2
    Adds: Boss Farm, Bone Farm, Sea Events, Halloween, V4 helper, expanded Misc.
    Same executor assumptions as before.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local TeleportService   = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- Remotes
---------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    return warn("[BFHub] Remotes folder not found - join Blox Fruits first.")
end
local CommF = Remotes:WaitForChild("CommF_", 10)
if not CommF then
    return warn("[BFHub] CommF_ not found.")
end

---------------------------------------------------------------------
-- State
---------------------------------------------------------------------
local State = {
    -- Farm
    AutoFarm          = false,
    AutoAttack        = false,
    AutoQuest         = false,
    AutoCollect       = false,
    AutoBoss          = false,
    AutoBone          = false,
    AutoSeaEvent      = false,
    AutoHalloween     = false,
    AutoV4            = false,

    -- Player
    SpeedEnabled      = false,
    SpeedValue        = 16,
    JumpEnabled       = false,
    JumpValue         = 50,
    Fullbright        = false,
    Noclip            = false,

    -- ESP
    ESP_Players       = false,
    ESP_Enemies       = false,
    ESP_Fruits        = false,
    ESP_Bosses        = false,
    ESP_SeaEvents     = false,

    -- Misc
    FruitNotifier     = false,
    AutoBuyFruit      = false,
    AutoHaki          = false,
    AutoRaceSkill     = false,
    WalkOnWater       = false,
}

---------------------------------------------------------------------
-- UI toolkit (same as before)
---------------------------------------------------------------------
local Theme = {
    Bg      = Color3.fromRGB(18, 18, 24),
    Panel   = Color3.fromRGB(26, 26, 34),
    Row     = Color3.fromRGB(34, 34, 44),
    Accent  = Color3.fromRGB(122, 92, 240),
    Accent2 = Color3.fromRGB(96, 170, 255),
    Text    = Color3.fromRGB(232, 232, 240),
    Sub     = Color3.fromRGB(150, 150, 165),
    Danger  = Color3.fromRGB(230, 80, 90),
    Good    = Color3.fromRGB(110, 230, 150),
    Warn    = Color3.fromRGB(255, 160, 70),
}

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in next, props or {} do
        if k ~= "Parent" then inst[k] = v end
    end
    inst.Parent = parent
    return inst
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
end

local guiParent = (typeof(gethui) == "function" and gethui())
    or (function()
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        return cg or LocalPlayer:WaitForChild("PlayerGui")
    end)()

local ScreenGui = new("ScreenGui", {
    Name = "BFHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, guiParent)

-- Notifications
local NotifHolder = new("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 10),
    Size = UDim2.fromOffset(250, 400),
    BackgroundTransparency = 1,
}, ScreenGui)
new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, NotifHolder)

local function notify(text, color)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
    }, NotifHolder)
    corner(f, 6)
    new("UIStroke", {
        Color = color or Theme.Accent,
        Transparency = 0.5,
        Thickness = 1,
    }, f)
    new("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, f)
    task.delay(3.5, function()
        if f.Parent then
            TweenService:Create(f, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
            task.wait(0.25)
            f:Destroy()
        end
    end)
end

---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------
local Win = new("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(600, 440),
    Position = UDim2.new(0.5, -300, 0.5, -220),
    BackgroundColor3 = Theme.Bg,
    BorderSizePixel = 0,
}, ScreenGui)
corner(Win, 10)
new("UIStroke", { Color = Theme.Accent, Transparency = 0.55, Thickness = 1 }, Win)

local TitleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Win)
corner(TitleBar, 10)

new("TextLabel", {
    Text = "Blox Fruits Hub v2",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -90, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, TitleBar)

local closeBtn = new("TextButton", {
    Text = "X", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Theme.Danger, BackgroundColor3 = Theme.Row,
    BorderSizePixel = 0, Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -30, 0.5, -11), AutoButtonColor = false,
}, TitleBar)
corner(closeBtn, 5)

local minBtn = new("TextButton", {
    Text = "-", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Theme.Sub, BackgroundColor3 = Theme.Row,
    BorderSizePixel = 0, Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -58, 0.5, -11), AutoButtonColor = false,
}, TitleBar)
corner(minBtn, 5)

do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Win.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

minBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(Win:GetChildren()) do
        if c ~= TitleBar then c.Visible = not c.Visible end
    end
    Win.Size = Win.Size.Y.Offset > 40 and UDim2.fromOffset(600, 34) or UDim2.fromOffset(600, 440)
end)

closeBtn.MouseButton1Click:Connect(function()
    for k in pairs(State) do
        if type(State[k]) == "boolean" then State[k] = false end
    end
    ScreenGui:Destroy()
end)

local Sidebar = new("Frame", {
    Position = UDim2.fromOffset(0, 34),
    Size = UDim2.new(0, 140, 1, -34),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, Win)

local Content = new("Frame", {
    Position = UDim2.fromOffset(140, 34),
    Size = UDim2.new(1, -140, 1, -34),
    BackgroundColor3 = Theme.Bg,
    BorderSizePixel = 0,
}, Win)

---------------------------------------------------------------------
-- Widgets
---------------------------------------------------------------------
local tabs = {}

local function addTab(name)
    local btn = new("TextButton", {
        Text = name, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = Theme.Sub, BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0, Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.fromOffset(8, 8 + #tabs * 36), AutoButtonColor = false,
    }, Sidebar)
    corner(btn, 6)

    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(), Visible = false,
    }, Content)

    local layout = new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    table.insert(tabs, { Button = btn, Page = page })
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.Button.TextColor3 = Theme.Sub
            t.Page.Visible = false
        end
        btn.TextColor3 = Theme.Accent2
        page.Visible = true
    end)
    return page
end

local function addLabel(page, text, color)
    return new("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = color or Theme.Sub, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
end

local function addToggle(page, text, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Row, BorderSizePixel = 0,
    }, page)
    corner(row, 6)

    new("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = Theme.Text, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local track = new("Frame", {
        Size = UDim2.fromOffset(34, 16), Position = UDim2.new(1, -44, 0.5, -8),
        BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
    }, row)
    corner(track, 8)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Theme.Sub, BorderSizePixel = 0,
    }, track)
    corner(knob, 6)

    local state = default and true or false
    local function render()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
            BackgroundColor3 = state and Theme.Accent or Theme.Sub,
        }):Play()
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Theme.Accent:Lerp(Theme.Panel, 0.65) or Theme.Panel,
        }):Play()
    end

    local hit = new("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 5,
    }, row)

    hit.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then task.spawn(callback, state) end
    end)

    render()
    return row
end

local function addButton(page, text, callback, color)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0, Text = text, Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = color or Theme.Text, AutoButtonColor = false,
    }, page)
    corner(btn, 6)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Accent }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Row }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
    return btn
end

local function addSlider(page, text, min, max, default, callback)
    local value = default or min
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Theme.Row, BorderSizePixel = 0,
    }, page)
    corner(row, 6)

    new("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = Theme.Text, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valLbl = new("TextLabel", {
        Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Theme.Accent2, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local bar = new("Frame", {
        Size = UDim2.new(1, -20, 0, 5), Position = UDim2.fromOffset(10, 34),
        BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
    }, row)
    corner(bar, 3)

    local fill = new("Frame", {
        Size = UDim2.fromScale((value - min) / (max - min), 1),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    }, bar)
    corner(fill, 3)

    local hit = new("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, -9), ZIndex = 5,
    }, bar)

    local dragging = false
    local function setFromX(x)
        local abs = bar.AbsolutePosition.X
        local w = bar.AbsoluteSize.X
        if w <= 0 then return end
        local a = math.clamp((x - abs) / w, 0, 1)
        value = math.floor(min + (max - min) * a + 0.5)
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
        valLbl.Text = tostring(value)
        if callback then callback(value) end
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

---------------------------------------------------------------------
-- Game helpers (extended)
---------------------------------------------------------------------
local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getEnemies()
    local out = {}
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return out end
    for _, e in ipairs(folder:GetChildren()) do
        local hum = e:FindFirstChildOfClass("Humanoid")
        local hrp = e:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            out[#out + 1] = { model = e, hrp = hrp, hum = hum }
        end
    end
    return out
end

-- Bosses are often in ReplicatedStorage or Workspace under "Bosses" / named models.
local function getBosses()
    local out = {}
    local candidates = {}

    local wsBosses = Workspace:FindFirstChild("Bosses")
    if wsBosses then
        for _, v in ipairs(wsBosses:GetChildren()) do table.insert(candidates, v) end
    end

    for _, v in ipairs(Workspace:GetChildren()) do
        if string.find(v.Name, "Boss", 1, true)
            or string.find(v.Name, "[Boss]", 1, true) then
            table.insert(candidates, v)
        end
    end

    local rsBosses = ReplicatedStorage:FindFirstChild("Bosses")
    if rsBosses then
        for _, v in ipairs(rsBosses:GetChildren()) do table.insert(candidates, v) end
    end

    for _, obj in ipairs(candidates) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                out[#out + 1] = { model = obj, hrp = hrp, hum = hum }
            end
        end
    end
    return out
end

local function getBoneMobs()
    local out = {}
    local hs = Workspace:FindFirstChild("Haunted Castle")
        or Workspace:FindFirstChild("HauntedCastle")
        or Workspace:FindFirstChild("Cursed Ship")
    if not hs then
        -- Fallback: scan all enemies for bone-related names
        for _, e in ipairs(getEnemies()) do
            local n = e.model.Name:lower()
            if string.find(n, "skeleton", 1, true)
                or string.find(n, "mummy", 1, true)
                or string.find(n, "ghost", 1, true)
                or string.find(n, "reaper", 1, true) then
                out[#out + 1] = e
            end
        end
        return out
    end

    for _, e in ipairs(hs:GetDescendants()) do
        if e:IsA("Model") then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local hrp = e:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                out[#out + 1] = { model = e, hrp = hrp, hum = hum }
            end
        end
    end
    return out
end

local function getSeaEvents()
    local out = {}
    local names = {
        "Sea Beast", "Ship Raid", "Rumbling Waters", "Terror Shark",
        "Leviathan", "Piranha", "Rough Sea", "Storm", "Haunted Shipwreck",
    }
    for _, obj in ipairs(Workspace:GetChildren()) do
        for _, n in ipairs(names) do
            if string.find(obj.Name, n, 1, true) then
                out[#out + 1] = obj
                break
            end
        end
    end
    return out
end

local function getHalloweenObjects()
    local out = {}
    local names = {
        "Candy", "CandyCorn", "Candy Corn", "Halloween", "Werewolf",
        "JackOLantern", "Jack-O-Lantern", "Spooky", "Haunted",
    }
    for _, obj in ipairs(Workspace:GetDescendants()) do
        for _, n in ipairs(names) do
            if string.find(obj.Name, n, 1, true) then
                out[#out + 1] = obj
                break
            end
        end
    end
    return out
end

local cachedQuest, lastQuestFetch = nil, 0
local function getQuestName()
    if os.time() - lastQuestFetch < 5 then return cachedQuest end
    lastQuestFetch = os.time()
    local ok, q = pcall(function() return CommF:InvokeServer("GetQuest") end)
    cachedQuest = nil
    if ok and q then
        if type(q) == "table" then
            cachedQuest = q.Name or q.QuestName
        elseif type(q) == "string" then
            cachedQuest = q
        end
    end
    return cachedQuest
end

local function pickTargetFrom(list)
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, e in ipairs(list) do
        local d = (e.hrp.Position - hrp.Position).Magnitude
        if d < bestD then best, bestD = e, d end
    end
    return best
end

local function pickTarget()
    local hrp = getHRP()
    if not hrp then return nil end
    local questName = getQuestName()
    local best, bestD = nil, math.huge
    for _, e in ipairs(getEnemies()) do
        if not questName or string.find(e.model.Name, questName, 1, true) then
            local d = (e.hrp.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = e, d end
        end
    end
    if not best then
        for _, e in ipairs(getEnemies()) do
            local d = (e.hrp.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = e, d end
        end
    end
    return best
end

local function equipAndAttack()
    local char = getChar()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool.Parent = char end)
            end
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
        end
    end
end

local function collectChests()
    if type(firetouchinterest) ~= "function" then return end
    local hrp = getHRP()
    if not hrp then return end

    local function try(part)
        if part:IsA("BasePart") then
            local n = part.Name:lower()
            if string.find(n, "chest", 1, true) or string.find(n, "crate", 1, true) then
                pcall(firetouchinterest, hrp, part, 0)
                pcall(firetouchinterest, hrp, part, 1)
            end
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        try(obj)
        if obj:IsA("Model") or obj:IsA("Folder") then
            for _, c in ipairs(obj:GetChildren()) do try(c) end
        end
    end
end

local function tweenToCFrame(targetCF, speed)
    local hrp = getHRP()
    if not hrp then return end
    speed = speed or 200
    local dist = (targetCF.Position - hrp.Position).Magnitude
    if dist < 3 then return end
    local t = dist / speed
    local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    tween.Completed:Wait()
end

---------------------------------------------------------------------
-- ESP (extended: bosses + sea events)
---------------------------------------------------------------------
local FRUITS = {
    "Rocket", "Spin", "Chop", "Spring", "Bomb", "Smoke", "Spike", "Flame",
    "Falcon", "Ice", "Sand", "Dark", "Diamond", "Light", "Rubber", "Barrier",
    "Magma", "Door", "Buddha", "Love", "Spider", "Sound", "Phoenix", "Portal",
    "Rumble", "Paw", "Gravity", "Dough", "Shadow", "Venom", "Control", "Spirit",
    "Dragon", "Leopard", "Kitsune", "Yeti", "Gas", "Blizzard", "Pain", "T-Rex",
    "Creation", "Eagle", "Mammoth",
}

local function getPart(inst)
    if inst:IsA("BasePart") then return inst end
    local handle = inst:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle end
    return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function scanFruits()
    local out = {}
    local function check(obj)
        if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name
            for _, f in ipairs(FRUITS) do
                if string.find(n, f, 1, true) then
                    out[#out + 1] = obj
                    return true
                end
            end
        end
        return false
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if not check(obj) and (obj:IsA("Folder") or obj:IsA("Model")) then
            for _, child in ipairs(obj:GetChildren()) do check(child) end
        end
    end
    return out
end

local function makeBillboard(part, color, labelText)
    local bb = new("BillboardGui", {
        Name = "BFHubESP", Size = UDim2.fromOffset(150, 36),
        StudsOffset = Vector3.new(0, 2.6, 0), AlwaysOnTop = true,
        MaxDistance = 1000, Adornee = part,
    }, part)

    new("TextLabel", {
        Name = "Name", Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundTransparency = 1, Text = labelText,
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = color, TextStrokeTransparency = 0.4,
    }, bb)

    new("TextLabel", {
        Name = "Dist", Size = UDim2.new(1, 0, 0.45, 0),
        Position = UDim2.new(0, 0, 0.55, 0), BackgroundTransparency = 1,
        Text = "", Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = Color3.fromRGB(220, 220, 220), TextStrokeTransparency = 0.4,
    }, bb)

    return bb
end

local espGuis = {}

local function espTick()
    local desired = {}

    if State.ESP_Players then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then desired[hrp] = "Players" end
            end
        end
    end

    if State.ESP_Enemies then
        for _, e in ipairs(getEnemies()) do desired[e.hrp] = "Enemies" end
    end

    if State.ESP_Fruits then
        for _, inst in ipairs(scanFruits()) do
            local part = getPart(inst)
            if part then desired[part] = "Fruits" end
        end
    end

    if State.ESP_Bosses then
        for _, b in ipairs(getBosses()) do desired[b.hrp] = "Bosses" end
    end

    if State.ESP_SeaEvents then
        for _, ev in ipairs(getSeaEvents()) do
            local part = getPart(ev)
            if part then desired[part] = "SeaEvents" end
        end
    end

    for part, kind in pairs(desired) do
        if not espGuis[part] or not espGuis[part].Parent then
            local color
            if kind == "Players" then color = Theme.Danger
            elseif kind == "Enemies" then color = Theme.Warn
            elseif kind == "Bosses" then color = Color3.fromRGB(255, 60, 180)
            elseif kind == "SeaEvents" then color = Color3.fromRGB(80, 200, 255)
            else color = Theme.Good end
            local text = part.Parent and part.Parent.Name or part.Name
            espGuis[part] = makeBillboard(part, color, text)
        end
    end

    for part, gui in pairs(espGuis) do
        if not desired[part] or not part.Parent then
            if gui and gui.Parent then gui:Destroy() end
            espGuis[part] = nil
        end
    end
end

---------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------
local farmPage     = addTab("Farm")
local bossPage     = addTab("Boss Farm")
local bonePage     = addTab("Bone Farm")
local seaPage      = addTab("Sea Events")
local halPage      = addTab("Halloween")
local v4Page       = addTab("V4")
local playerPage   = addTab("Player")
local tpPage       = addTab("Teleport")
local espPage      = addTab("ESP")
local miscPage     = addTab("Misc")

tabs[1].Button.TextColor3 = Theme.Accent2
tabs[1].Page.Visible = true

---------------------------------------------------------------------
-- Farm tab
---------------------------------------------------------------------
addLabel(farmPage, "AUTOMATION")

addToggle(farmPage, "Auto Farm", false, function(on)
    State.AutoFarm = on
    notify("Auto Farm " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addToggle(farmPage, "Auto Attack", false, function(on)
    State.AutoAttack = on
end)

addToggle(farmPage, "Auto Quest", false, function(on)
    State.AutoQuest = on
end)

addToggle(farmPage, "Auto Collect Chests", false, function(on)
    State.AutoCollect = on
    if on and type(firetouchinterest) ~= "function" then
        notify("Executor lacks firetouchinterest", Theme.Danger)
    end
end)

addButton(farmPage, "Teleport to Quest Target", function()
    local t = pickTarget()
    local hrp = getHRP()
    if t and hrp then
        hrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 3)
    else
        notify("No target found", Theme.Warn)
    end
end)

---------------------------------------------------------------------
-- Boss Farm tab
---------------------------------------------------------------------
addLabel(bossPage, "BOSS AUTOMATION")

addToggle(bossPage, "Auto Farm Bosses", false, function(on)
    State.AutoBoss = on
    notify("Boss Farm " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addLabel(bossPage, "BOSS TELEPORTS", Theme.Accent2)

local BOSSES = {
    "Gorilla King", "Yeti", "Ice Admiral", "Thunder God", "Cursed Captain",
    "Darkbeard", "Greybeard", "rip_indra", "Dough King", "Cake Prince",
    "Soul Reaper", "Dragon", "Longma", "Stone", "Island Empress",
    "Captain Elephant", "Beautiful Pirate", "Terrorshark", "Leviathan",
}

for _, name in ipairs(BOSSES) do
    addButton(bossPage, name, function()
        local target
        for _, b in ipairs(getBosses()) do
            if string.find(b.model.Name, name, 1, true) then
                target = b
                break
            end
        end
        if target then
            tweenToCFrame(target.hrp.CFrame * CFrame.new(0, 0, 6), 300)
            notify("Teleported to " .. target.model.Name, Theme.Accent2)
        else
            notify(name .. " not found", Theme.Warn)
        end
    end)
end

---------------------------------------------------------------------
-- Bone Farm tab
---------------------------------------------------------------------
addLabel(bonePage, "BONE AUTOMATION")

addToggle(bonePage, "Auto Farm Bones", false, function(on)
    State.AutoBone = on
    notify("Bone Farm " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addButton(bonePage, "Teleport to Haunted Castle", function()
    local hs = Workspace:FindFirstChild("Haunted Castle")
        or Workspace:FindFirstChild("HauntedCastle")
        or Workspace:FindFirstChild("Cursed Ship")
    local hrp = getHRP()
    if hs and hrp then
        local part = getPart(hs)
        if part then
            tweenToCFrame(part.CFrame + Vector3.new(0, 10, 0), 250)
            notify("Teleported to bone area", Theme.Accent2)
        end
    else
        notify("Haunted Castle not found", Theme.Warn)
    end
end)

addButton(bonePage, "Teleport to Nearest Bone Mob", function()
    local t = pickTargetFrom(getBoneMobs())
    local hrp = getHRP()
    if t and hrp then
        hrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 4)
    else
        notify("No bone mobs found", Theme.Warn)
    end
end)

---------------------------------------------------------------------
-- Sea Events tab
---------------------------------------------------------------------
addLabel(seaPage, "SEA EVENT AUTOMATION")

addToggle(seaPage, "Auto Sea Events", false, function(on)
    State.AutoSeaEvent = on
    notify("Sea Events " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addLabel(seaPage, "QUICK ACTIONS", Theme.Accent2)

addButton(seaPage, "Teleport to Nearest Sea Event", function()
    local events = getSeaEvents()
    if #events == 0 then
        notify("No sea events active", Theme.Warn)
        return
    end
    local hrp = getHRP()
    if not hrp then return end
    local best, bestD = nil, math.huge
    for _, ev in ipairs(events) do
        local part = getPart(ev)
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = ev, d end
        end
    end
    if best then
        local part = getPart(best)
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0, 15, 0)
            notify("Teleported to " .. best.Name, Theme.Accent2)
        end
    end
end)

addButton(seaPage, "List Active Sea Events", function()
    local events = getSeaEvents()
    if #events == 0 then
        notify("No sea events active", Theme.Warn)
        return
    end
    for _, ev in ipairs(events) do
        notify("Sea Event: " .. ev.Name, Theme.Accent2)
    end
end)

---------------------------------------------------------------------
-- Halloween tab
---------------------------------------------------------------------
addLabel(halPage, "HALLOWEEN EVENT")

addToggle(halPage, "Auto Halloween (Candy)", false, function(on)
    State.AutoHalloween = on
    notify("Halloween Farm " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addLabel(halPage, "QUICK ACTIONS", Theme.Accent2)

addButton(halPage, "Teleport to Nearest Candy", function()
    local objs = getHalloweenObjects()
    local hrp = getHRP()
    if not hrp then return end
    local best, bestD = nil, math.huge
    for _, obj in ipairs(objs) do
        local part = getPart(obj)
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < bestD then best, bestD = obj, d end
        end
    end
    if best then
        local part = getPart(best)
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            notify("Teleported to " .. best.Name, Theme.Accent2)
        end
    else
        notify("No candy/Halloween objects found", Theme.Warn)
    end
end)

addButton(halPage, "List Halloween Objects", function()
    local objs = getHalloweenObjects()
    if #objs == 0 then
        notify("No Halloween objects found", Theme.Warn)
        return
    end
    for i = 1, math.min(#objs, 10) do
        notify("Halloween: " .. objs[i].Name, Theme.Accent2)
    end
end)

---------------------------------------------------------------------
-- V4 tab
---------------------------------------------------------------------
addLabel(v4Page, "RACE V4 AWAKENING")

addToggle(v4Page, "Auto V4 Trial", false, function(on)
    State.AutoV4 = on
    notify("V4 Trial helper " .. (on and "enabled" or "disabled"),
        on and Theme.Good or Theme.Sub)
end)

addLabel(v4Page, "TRIAL INFO", Theme.Accent2)
addLabel(v4Page, "Requires: V3 race, Mirror Fractal, Blue Gear, 3+ players for group trials.", Theme.Sub)

addButton(v4Page, "Teleport to Temple of Time", function()
    local temple = Workspace:FindFirstChild("Temple of Time")
        or Workspace:FindFirstChild("TempleOfTime")
    local hrp = getHRP()
    if temple and hrp then
        local part = getPart(temple)
        if part then
            tweenToCFrame(part.CFrame + Vector3.new(0, 10, 0), 300)
            notify("Teleported to Temple of Time", Theme.Accent2)
        end
    else
        notify("Temple of Time not found", Theme.Warn)
    end
end)

addButton(v4Page, "Teleport to Mirage Island", function()
    local mirage = Workspace:FindFirstChild("Mirage Island")
        or Workspace:FindFirstChild("MirageIsland")
    local hrp = getHRP()
    if mirage and hrp then
        local part = getPart(mirage)
        if part then
            tweenToCFrame(part.CFrame + Vector3.new(0, 20, 0), 300)
            notify("Teleported to Mirage Island", Theme.Accent2)
        end
    else
        notify("Mirage Island not active", Theme.Warn)
    end
end)

addButton(v4Page, "Look at Moon (for Mirage step)", function()
    local hrp = getHRP()
    if hrp then
        -- Roughly face upward; the moon is in the sky.
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(0, 500, -500))
        notify("Looking at moon", Theme.Accent2)
    end
end)

addButton(v4Page, "Activate Race V3 (skill)", function()
    local char = getChar()
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Most executors can fire the race skill via the humanoid or keybind.
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            notify("Attempted race skill activation", Theme.Accent2)
        end
    end
end)

---------------------------------------------------------------------
-- Player tab
---------------------------------------------------------------------
addLabel(playerPage, "MOVEMENT")

addToggle(playerPage, "Walk Speed", false, function(on)
    State.SpeedEnabled = on
    if not on then
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    end
end)
addSlider(playerPage, "Speed Value", 16, 300, 16, function(v)
    State.SpeedValue = v
end)

addToggle(playerPage, "Jump Power", false, function(on)
    State.JumpEnabled = on
    if not on then
        local hum = getHum()
        if hum then
            pcall(function() hum.UseJumpPower = true end)
            hum.JumpPower = 50
        end
    end
end)
addSlider(playerPage, "Jump Value", 50, 500, 50, function(v)
    State.JumpValue = v
end)

addLabel(playerPage, "VISUAL")

local savedLighting = nil
addToggle(playerPage, "Fullbright", false, function(on)
    State.Fullbright = on
    if on then
        savedLighting = {
            Brightness = Lighting.Brightness,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
        }
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
    elseif savedLighting then
        Lighting.Brightness = savedLighting.Brightness
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
        savedLighting = nil
    end
end)

addToggle(playerPage, "Noclip", false, function(on)
    State.Noclip = on
end)

---------------------------------------------------------------------
-- Teleport tab
---------------------------------------------------------------------
addLabel(tpPage, "TRAVEL")

addButton(tpPage, "Teleport to Spawn", function()
    pcall(function() CommF:InvokeServer("TravelMain") end)
    notify("Teleporting to spawn", Theme.Accent2)
end)

addLabel(tpPage, "ISLANDS")

local ISLANDS = {
    "Starter Island", "Marine Ford", "Pirate Village", "Desert", "Frozen Village",
    "Colosseum", "Jungle", "Cafe", "Snow Mountain", "Magma Village",
    "Underwater City", "Fishman Island", "Sky Town", "Upper Sky", "Prison",
    "Kingdom of Rose", "Cursed Ship", "Ice Castle", "Forgotten Island", "Port Town",
    "Haunted Castle", "Hot and Cold", "Sea of Treats", "Cake Island", "Chocolate Island",
    "Candy Cane Land", "Graveyard", "Snow Island", "Hydra Island", "Great Tree",
    "Castle on the Sea", "Tiki Outpost", "Floating Turtle", "Mansion",
    "Temple of Time", "Mirage Island",
}

for _, name in ipairs(ISLANDS) do
    addButton(tpPage, name, function()
        pcall(function() CommF:InvokeServer("TravelIsland", name) end)
        notify("Teleporting: " .. name, Theme.Accent2)
    end)
end

---------------------------------------------------------------------
-- ESP tab
---------------------------------------------------------------------
addLabel(espPage, "HIGHLIGHTS")

addToggle(espPage, "Player ESP", false, function(on) State.ESP_Players = on end)
addToggle(espPage, "Enemy ESP", false, function(on) State.ESP_Enemies = on end)
addToggle(espPage, "Fruit ESP", false, function(on) State.ESP_Fruits = on end)
addToggle(espPage, "Boss ESP", false, function(on) State.ESP_Bosses = on end)
addToggle(espPage, "Sea Event ESP", false, function(on) State.ESP_SeaEvents = on end)

---------------------------------------------------------------------
-- Misc tab (expanded)
---------------------------------------------------------------------
addLabel(miscPage, "UTILITY")

addToggle(miscPage, "Fruit Notifier", false, function(on)
    State.FruitNotifier = on
end)

addToggle(miscPage, "Auto Buy Fruit (stock)", false, function(on)
    State.AutoBuyFruit = on
    if on then
        task.spawn(function()
            while State.AutoBuyFruit and ScreenGui.Parent do
                pcall(function()
                    local stock = CommF:InvokeServer("GetFruits")
                    if stock then
                        for _, f in pairs(stock) do
                            CommF:InvokeServer("PurchaseRawFruit", f.Name)
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

addToggle(miscPage, "Auto Haki (Buso/Ken)", false, function(on)
    State.AutoHaki = on
    if on then
        task.spawn(function()
            while State.AutoHaki and ScreenGui.Parent do
                pcall(function()
                    CommF:InvokeServer("Buso")
                    CommF:InvokeServer("Ken")
                end)
                task.wait(1)
            end
        end)
    end
end)

addToggle(miscPage, "Walk on Water", false, function(on)
    State.WalkOnWater = on
end)

addButton(miscPage, "Rejoin Server", function()
    notify("Rejoining...", Theme.Accent2)
    task.wait(0.5)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

addButton(miscPage, "Server Hop (random low player)", function()
    notify("Server hopping...", Theme.Accent2)
    pcall(function()
        local servers = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = game:GetService("HttpService"):JSONDecode(servers)
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
        notify("No suitable server found", Theme.Warn)
    end)
end)

addButton(miscPage, "Print Character Info", function()
    local char = getChar()
    if not char then
        notify("No character", Theme.Warn)
        return
    end
    local hum = getHum()
    notify(("HP %d | Speed %.0f | Pos %s"):format(
        hum and hum.Health or 0,
        hum and hum.WalkSpeed or 0,
        tostring(getHRP() and getHRP().Position or "?")))
    print("[BFHub] Character:", char.Name, "HP:", hum and hum.Health)
end)

addButton(miscPage, "Redeem All Codes", function()
    local codes = {
        "SUB2GAMERROBOT_EXP1", "Sub2OfficialNoobie", "FruitNotifier",
        "THEGREATACE", "ADMIN", "Chandler", "Starcodeheo", "BloxFruits",
        "Fudd10", "Fudd10_V2", "BIGNEWS", "SUB2NOOBMASTER123",
        "Sub2Daigrock", "Axiore", "TantaiGaming", "STRAWHATMAINE",
        "Magicbus", "KittGaming", "Sub2Fer999", "Enyu_is_Pro",
        "JCWK", "Starcodeheo", "Fudd10", "BloxFruits",
    }
    for _, code in ipairs(codes) do
        pcall(function() CommF:InvokeServer("Redeem", code) end)
    end
    notify("Redeemed codes", Theme.Good)
end)

---------------------------------------------------------------------
-- Background loops
---------------------------------------------------------------------

-- Auto attack / farm attack
task.spawn(function()
    while ScreenGui.Parent do
        if State.AutoAttack or State.AutoFarm or State.AutoBoss
            or State.AutoBone or State.AutoSeaEvent or State.AutoHalloween then
            pcall(equipAndAttack)
        end
        task.wait(0.1)
    end
end)

-- Auto farm teleport
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.2)
        if State.AutoFarm then
            local target = pickTarget()
            local hrp = getHRP()
            if target and hrp then
                pcall(function()
                    hrp.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 3)
                end)
            end
        end
    end
end)

-- Auto boss farm
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.3)
        if State.AutoBoss then
            local bosses = getBosses()
            local target = pickTargetFrom(bosses)
            local hrp = getHRP()
            if target and hrp then
                pcall(function()
                    hrp.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 5)
                end)
            end
        end
    end
end)

-- Auto bone farm
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.3)
        if State.AutoBone then
            local mobs = getBoneMobs()
            local target = pickTargetFrom(mobs)
            local hrp = getHRP()
            if target and hrp then
                pcall(function()
                    hrp.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 4)
                end)
            end
        end
    end
end)

-- Auto sea events
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        if State.AutoSeaEvent then
            local events = getSeaEvents()
            local hrp = getHRP()
            if #events > 0 and hrp then
                local best, bestD = nil, math.huge
                for _, ev in ipairs(events) do
                    local part = getPart(ev)
                    if part then
                        local d = (part.Position - hrp.Position).Magnitude
                        if d < bestD then best, bestD = ev, d end
                    end
                end
                if best then
                    local part = getPart(best)
                    if part then
                        pcall(function()
                            hrp.CFrame = part.CFrame + Vector3.new(0, 15, 0)
                        end)
                    end
                end
            end
        end
    end
end)

-- Auto Halloween
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.4)
        if State.AutoHalloween then
            local objs = getHalloweenObjects()
            local hrp = getHRP()
            if #objs > 0 and hrp then
                local best, bestD = nil, math.huge
                for _, obj in ipairs(objs) do
                    local part = getPart(obj)
                    if part then
                        local d = (part.Position - hrp.Position).Magnitude
                        if d < bestD then best, bestD = obj, d end
                    end
                end
                if best then
                    local part = getPart(best)
                    if part then
                        pcall(function()
                            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        end)
                    end
                end
            end
        end
    end
end)

-- Auto V4 trial (basic: face moon / interact with door if nearby)
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if State.AutoV4 then
            local hrp = getHRP()
            if hrp then
                -- Look at moon periodically (Mirage step)
                pcall(function()
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(0, 500, -500))
                end)
            end
        end
    end
end)

-- Auto quest
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(2)
        if State.AutoQuest then
            pcall(function() CommF:InvokeServer("StartQuest") end)
        end
    end
end)

-- Auto collect
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        if State.AutoCollect then
            pcall(collectChests)
        end
    end
end)

-- Player stats enforcement
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if not hum then return end
    if State.SpeedEnabled then
        hum.WalkSpeed = State.SpeedValue
    end
    if State.JumpEnabled then
        pcall(function() hum.UseJumpPower = true end)
        hum.JumpPower = State.JumpValue
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    local char = getChar()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Walk on water
RunService.Stepped:Connect(function()
    if not State.WalkOnWater then return end
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
        local hit, pos = Workspace:FindPartOnRay(ray, char)
        if hit and hit.Name == "Water" then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end
end)

-- ESP sync
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        pcall(espTick)
    end
end)

-- ESP distance labels
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.3)
        local hrp = getHRP()
        if hrp then
            for part, gui in pairs(espGuis) do
                if gui and gui.Parent then
                    local dist = gui:FindFirstChild("Dist")
                    if dist then
                        dist.Text = string.format("%d studs", math.floor((part.Position - hrp.Position).Magnitude))
                    end
                end
            end
        end
    end
end)

-- Fruit notifier
local seenFruits = {}
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(2)
        if State.FruitNotifier then
            for _, obj in ipairs(scanFruits()) do
                if not seenFruits[obj] then
                    seenFruits[obj] = true
                    notify("Fruit spawned: " .. obj.Name, Theme.Good)
                end
            end
        end
        for obj in pairs(seenFruits) do
            if not obj.Parent then seenFruits[obj] = nil end
        end
    end
end)

notify("Blox Fruits Hub v2 loaded", Theme.Accent2)