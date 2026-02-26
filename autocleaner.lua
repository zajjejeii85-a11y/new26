-- [[ ZONHUB - AUTO CLEANER MODULE V4 (WORLD SNAKE SCAN) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "AutoCleaner v3.0" 
getgenv().ScriptVersion = "AutoCleaner v4.0"

-- ========================================== --
getgenv().GridSize = 4.5 
getgenv().CleanDelay = 0.18 -- Dinaikkan sedikit agar sinkron dengan ping server
getgenv().GridSize = 4.5
getgenv().AutoCleaner = false
getgenv().CleanHitCount = 6
getgenv().SweepWidth = 50
getgenv().SweepDepth = 15
getgenv().CleanDelay = 0.16
getgenv().MoveDelay = 0.18
getgenv().CleanerStartX = 0
getgenv().CleanerStartY = 0
getgenv().CleanerReturnHome = true
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") 
local VirtualUser = game:GetService("VirtualUser")

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)
pcall(function()
    PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement"))
end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

getgenv().AutoCleaner = false
getgenv().CleanHitCount = 6  
getgenv().SweepWidth = 50    
getgenv().SweepDepth = 15    
local Theme = {
    Item = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    Purple = Color3.fromRGB(140, 80, 255),
    SubText = Color3.fromRGB(200, 200, 200),
    Red = Color3.fromRGB(240, 84, 84),
    Green = Color3.fromRGB(80, 210, 120)
}

-- ========================================== --
-- FUNGSI UI UTILITY
-- ========================================== --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }
local CleanerRunId = 0
local CleanerBusy = false

local function CreateToggle(Parent, Text, Var) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; Btn.AutoButtonColor = false; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; local T = Instance.new("TextLabel"); T.Parent = Btn; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left; local IndBg = Instance.new("Frame"); IndBg.Parent = Btn; IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = IndBg; local Dot = Instance.new("Frame"); Dot.Parent = IndBg; Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot; Btn.MouseButton1Click:Connect(function() getgenv()[Var] = not getgenv()[Var]; if getgenv()[Var] then Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple else Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) end end) end
local function CreateTextBox(Parent, Text, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 35); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.65, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left; local InputBox = Instance.new("TextBox"); InputBox.Parent = Frame; InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InputBox.Position = UDim2.new(0.7, 0, 0.15, 0); InputBox.Size = UDim2.new(0.25, 0, 0.7, 0); InputBox.Font = Enum.Font.GothamSemibold; InputBox.TextSize = 12; InputBox.TextColor3 = Theme.Text; InputBox.Text = tostring(Default); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(0, 4); IC.Parent = InputBox; InputBox.FocusLost:Connect(function() local val = tonumber(InputBox.Text); if val then getgenv()[Var] = val else InputBox.Text = tostring(getgenv()[Var]) end end); return InputBox end
local function CreateToggle(Parent, Text, Var, OnToggle)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Parent
    Btn.BackgroundColor3 = Theme.Item
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.Text = ""
    Btn.AutoButtonColor = false

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn

    local T = Instance.new("TextLabel")
    T.Parent = Btn
    T.Text = Text
    T.TextColor3 = Theme.Text
    T.Font = Enum.Font.GothamSemibold
    T.TextSize = 12
    T.Size = UDim2.new(1, -40, 1, 0)
    T.Position = UDim2.new(0, 10, 0, 0)
    T.BackgroundTransparency = 1
    T.TextXAlignment = Enum.TextXAlignment.Left

    local IndBg = Instance.new("Frame")
    IndBg.Parent = Btn
    IndBg.Size = UDim2.new(0, 36, 0, 18)
    IndBg.Position = UDim2.new(1, -45, 0.5, -9)
    IndBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(1, 0)
    IC.Parent = IndBg

    local Dot = Instance.new("Frame")
    Dot.Parent = IndBg
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    local DC = Instance.new("UICorner")
    DC.CornerRadius = UDim.new(1, 0)
    DC.Parent = Dot

    local function SyncToggleVisual(value)
        if value then
            Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            IndBg.BackgroundColor3 = Theme.Purple
        else
            Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true)
            Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            IndBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end

    SyncToggleVisual(getgenv()[Var])

    Btn.MouseButton1Click:Connect(function()
        getgenv()[Var] = not getgenv()[Var]
        SyncToggleVisual(getgenv()[Var])
        if OnToggle then OnToggle(getgenv()[Var]) end
    end)

    return SyncToggleVisual
end

local function CreateTextBox(Parent, Text, Default, Var)
    local Frame = Instance.new("Frame")
    Frame.Parent = Parent
    Frame.BackgroundColor3 = Theme.Item
    Frame.Size = UDim2.new(1, -10, 0, 35)

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Text = Text
    Label.TextColor3 = Theme.Text
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local InputBox = Instance.new("TextBox")
    InputBox.Parent = Frame
    InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InputBox.Position = UDim2.new(0.65, 0, 0.15, 0)
    InputBox.Size = UDim2.new(0.3, 0, 0.7, 0)
    InputBox.Font = Enum.Font.GothamSemibold
    InputBox.TextSize = 12
    InputBox.TextColor3 = Theme.Text
    InputBox.Text = tostring(Default)
    InputBox.ClearTextOnFocus = false

    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(0, 4)
    IC.Parent = InputBox

    InputBox.FocusLost:Connect(function()
        local val = tonumber(InputBox.Text)
        if val then
            getgenv()[Var] = val
        else
            InputBox.Text = tostring(getgenv()[Var])
        end
    end)

    return InputBox
end

local function CreateButton(Parent, Text, Color, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Parent
    Btn.BackgroundColor3 = Color or Theme.Purple
    Btn.Size = UDim2.new(1, -10, 0, 34)
    Btn.Text = Text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.AutoButtonColor = false

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn

    Btn.MouseButton1Click:Connect(Callback)
    return Btn
end

local function GetReferencePart()
    local HitboxFolder = workspace:FindFirstChild("Hitbox")
    local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
    return MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
end

local function GetCurrentGrid(refPart)
    return math.floor(refPart.Position.X / getgenv().GridSize + 0.5), math.floor(refPart.Position.Y / getgenv().GridSize + 0.5)
end

local function TeleportGrid(refPart, gridX, gridY, zPos)
    local worldPos = Vector3.new(gridX * getgenv().GridSize, gridY * getgenv().GridSize, zPos)
    if refPart then
        refPart.CFrame = CFrame.new(worldPos)
        pcall(function() refPart.Velocity = Vector3.new(0, 0, 0) end)
    end
    if PlayerMovement then
        pcall(function() PlayerMovement.Position = worldPos end)
    end
end

-- ========================================== --
-- MENU UI 
-- ========================================== --
local InfoLabel = Instance.new("TextLabel", TargetPage)
InfoLabel.Size = UDim2.new(1, -10, 0, 20); InfoLabel.BackgroundTransparency = 1; InfoLabel.Text = "Berdirilah di KIRI ATAS sebelum menyalakan ini."; InfoLabel.TextColor3 = Color3.fromRGB(200,200,200); InfoLabel.Font = Enum.Font.Gotham; InfoLabel.TextSize = 10; InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Size = UDim2.new(1, -10, 0, 22)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "AutoCleaner V4: berdiri di kiri atas area lalu set titik mulai."
InfoLabel.TextColor3 = Theme.SubText
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(TargetPage, "Start Auto Cleaner", "AutoCleaner")
CreateTextBox(TargetPage, "Lebar Area (Berapa Blok ke Kanan)", getgenv().SweepWidth, "SweepWidth")
CreateTextBox(TargetPage, "Kedalaman (Berapa Blok ke Bawah)", getgenv().SweepDepth, "SweepDepth")
CreateTextBox(TargetPage, "Jumlah Hit per Blok", getgenv().CleanHitCount, "CleanHitCount")
local StatusLabel = Instance.new("TextLabel", TargetPage)
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Theme.SubText
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local function SetStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or Theme.SubText
end

local toggleSync = CreateToggle(TargetPage, "Start Auto Cleaner", "AutoCleaner", function(state)
    if not state then
        CleanerRunId += 1
        SetStatus("Stopped", Theme.Red)
    else
        SetStatus("Preparing...", Theme.SubText)
    end
end)

CreateToggle(TargetPage, "Kembali ke titik awal setelah selesai", "CleanerReturnHome")
CreateTextBox(TargetPage, "Lebar area (blok)", getgenv().SweepWidth, "SweepWidth")
CreateTextBox(TargetPage, "Kedalaman area (blok)", getgenv().SweepDepth, "SweepDepth")
CreateTextBox(TargetPage, "Hit tiap blok", getgenv().CleanHitCount, "CleanHitCount")
CreateTextBox(TargetPage, "Delay hit (detik)", getgenv().CleanDelay, "CleanDelay")
CreateTextBox(TargetPage, "Delay pindah (detik)", getgenv().MoveDelay, "MoveDelay")

CreateButton(TargetPage, "Set titik mulai dari posisi sekarang", Theme.Purple, function()
    local ref = GetReferencePart()
    if not ref then
        SetStatus("Gagal set titik mulai: karakter tidak ditemukan", Theme.Red)
        return
    end

    local gx, gy = GetCurrentGrid(ref)
    getgenv().CleanerStartX = gx
    getgenv().CleanerStartY = gy
    SetStatus("Titik mulai disimpan di (" .. gx .. ", " .. gy .. ")", Theme.Green)
end)

CreateButton(TargetPage, "Stop sekarang", Theme.Red, function()
    getgenv().AutoCleaner = false
    CleanerRunId += 1
    toggleSync(false)
    SetStatus("Dihentikan manual", Theme.Red)
end)
