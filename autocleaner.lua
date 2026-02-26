-- [[ ZONHUB - AUTO CLEANER MODULE V5 (STABLE SNAKE SCAN) ]] --
local TargetPage = ...
if not TargetPage then
    warn("Module harus di-load dari ZonIndex!")
    return
end

getgenv().ScriptVersion = "AutoCleaner v5.0"

-- ========================================== --
getgenv().GridSize = getgenv().GridSize or 4.5
getgenv().AutoCleaner = getgenv().AutoCleaner or false
getgenv().CleanHitCount = getgenv().CleanHitCount or 6
getgenv().SweepWidth = getgenv().SweepWidth or 50
getgenv().SweepDepth = getgenv().SweepDepth or 15
getgenv().CleanDelay = getgenv().CleanDelay or 0.16
getgenv().MoveDelay = getgenv().MoveDelay or 0.18
getgenv().CleanerStartX = getgenv().CleanerStartX or 0
getgenv().CleanerStartY = getgenv().CleanerStartY or 0
getgenv().CleanerReturnHome = (getgenv().CleanerReturnHome ~= false)
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local PlayerMovement
pcall(function()
    PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement"))
end)

LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Theme = {
    Item = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    Purple = Color3.fromRGB(140, 80, 255),
    SubText = Color3.fromRGB(200, 200, 200),
    Red = Color3.fromRGB(240, 84, 84),
    Green = Color3.fromRGB(80, 210, 120)
}

local CleanerRunId = 0
local CleanerBusy = false

local function clampMinNumber(value, minValue, fallback)
    local n = tonumber(value)
    if not n then return fallback end
    if n < minValue then return minValue end
    return n
end

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
@@ -173,111 +167,235 @@ local function CreateTextBox(Parent, Text, Default, Var)
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
    local hitboxFolder = workspace:FindFirstChild("Hitbox")
    local myHitbox = hitboxFolder and hitboxFolder:FindFirstChild(LP.Name)
    return myHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
end

local function GetCurrentGrid(refPart)
    local gs = getgenv().GridSize
    return math.floor(refPart.Position.X / gs + 0.5), math.floor(refPart.Position.Y / gs + 0.5)
end

local function TeleportGrid(refPart, gridX, gridY, zPos)
    local gs = getgenv().GridSize
    local worldPos = Vector3.new(gridX * gs, gridY * gs, zPos)

    if refPart then
        refPart.CFrame = CFrame.new(worldPos)
        pcall(function() refPart.Velocity = Vector3.new(0, 0, 0) end)
    end

    if PlayerMovement then
        pcall(function()
            PlayerMovement.Position = worldPos
        end)
    end
end

local remotesFolder = RS:FindFirstChild("Remotes")
local remoteBreak = remotesFolder and remotesFolder:FindFirstChild("PlayerFist")

local function BreakGrid(targetGrid)
    if not remoteBreak then return end

    local hitCount = clampMinNumber(getgenv().CleanHitCount, 1, 1)
    local delayHit = clampMinNumber(getgenv().CleanDelay, 0.01, 0.08)

    for _ = 1, math.floor(hitCount) do
        if not getgenv().AutoCleaner then return end
        remoteBreak:FireServer(targetGrid)
        task.wait(delayHit)
    end
end

-- ========================================== --
-- MENU UI
-- ========================================== --
local InfoLabel = Instance.new("TextLabel", TargetPage)
InfoLabel.Size = UDim2.new(1, -10, 0, 22)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "AutoCleaner V5: berdiri di kiri atas area lalu set titik mulai."
InfoLabel.TextColor3 = Theme.SubText
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

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

-- ========================================== --
-- CLEANER LOOP (SNAKE PATH, STABIL, ANTI-STUTTER)
-- ========================================== --
task.spawn(function()
    while true do
        if not getgenv().AutoCleaner then
            task.wait(0.15)
            continue
        end

        if CleanerBusy then
            task.wait(0.1)
            continue
        end

        if not remoteBreak then
            SetStatus("Remote break tidak ditemukan (Remotes.PlayerFist)", Theme.Red)
            getgenv().AutoCleaner = false
            toggleSync(false)
            task.wait(0.5)
            continue
        end

        local ref = GetReferencePart()
        if not ref then
            SetStatus("Karakter tidak ditemukan", Theme.Red)
            getgenv().AutoCleaner = false
            toggleSync(false)
            task.wait(0.5)
            continue
        end

        CleanerBusy = true
        CleanerRunId += 1
        local runId = CleanerRunId

        local width = math.floor(clampMinNumber(getgenv().SweepWidth, 1, 1))
        local depth = math.floor(clampMinNumber(getgenv().SweepDepth, 1, 1))
        local moveDelay = clampMinNumber(getgenv().MoveDelay, 0.01, 0.12)

        local startX = math.floor(tonumber(getgenv().CleanerStartX) or 0)
        local startY = math.floor(tonumber(getgenv().CleanerStartY) or 0)

        local originalX, originalY = GetCurrentGrid(ref)
        local zPos = ref.Position.Z

        SetStatus("Cleaning " .. width .. "x" .. depth .. "...", Theme.SubText)

        local total = width * depth
        local done = 0

        for row = 0, depth - 1 do
            if runId ~= CleanerRunId or not getgenv().AutoCleaner then break end

            local y = startY - row
            if row % 2 == 0 then
                for col = 0, width - 1 do
                    if runId ~= CleanerRunId or not getgenv().AutoCleaner then break end

                    local x = startX + col
                    TeleportGrid(ref, x, y, zPos)
                    task.wait(moveDelay)
                    BreakGrid(Vector2.new(x, y))

                    done += 1
                    if done % 10 == 0 then
                        SetStatus(string.format("Cleaning... %d/%d", done, total), Theme.SubText)
                    end
                end
            else
                for col = width - 1, 0, -1 do
                    if runId ~= CleanerRunId or not getgenv().AutoCleaner then break end

                    local x = startX + col
                    TeleportGrid(ref, x, y, zPos)
                    task.wait(moveDelay)
                    BreakGrid(Vector2.new(x, y))

                    done += 1
                    if done % 10 == 0 then
                        SetStatus(string.format("Cleaning... %d/%d", done, total), Theme.SubText)
                    end
                end
            end
        end

        local wasStopped = (runId ~= CleanerRunId) or (not getgenv().AutoCleaner)

        if not wasStopped and getgenv().CleanerReturnHome then
            SetStatus("Kembali ke titik awal...", Theme.SubText)
            TeleportGrid(ref, originalX, originalY, zPos)
            task.wait(moveDelay)
        end

        if not wasStopped then
            SetStatus("Selesai membersihkan!", Theme.Green)
            getgenv().AutoCleaner = false
            toggleSync(false)
        else
            SetStatus("Dihentikan", Theme.Red)
        end

        CleanerBusy = false
        task.wait(0.1)
    end
end)
