-- [[ ZONHUB - AUTO CLEANER MODULE (SNAKE PATTERN) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "AutoCleaner v1.0" 

-- ========================================== --
getgenv().GridSize = 4.5 
getgenv().CleanDelay = 0.1 
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") 

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

getgenv().AutoCleaner = false
getgenv().CleanHitCount = 4 -- Jumlah hit untuk break dirt + background
getgenv().StartX = 0
getgenv().EndX = 20
getgenv().StartY = 0
getgenv().EndY = -10

-- ========================================== --
-- FUNGSI UI UTILITY
-- ========================================== --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }

local function CreateToggle(Parent, Text, Var) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; Btn.AutoButtonColor = false; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; local T = Instance.new("TextLabel"); T.Parent = Btn; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left; local IndBg = Instance.new("Frame"); IndBg.Parent = Btn; IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = IndBg; local Dot = Instance.new("Frame"); Dot.Parent = IndBg; Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot; Btn.MouseButton1Click:Connect(function() getgenv()[Var] = not getgenv()[Var]; if getgenv()[Var] then Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple else Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) end end) end
local function CreateTextBox(Parent, Text, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 35); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.5, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left; local InputBox = Instance.new("TextBox"); InputBox.Parent = Frame; InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InputBox.Position = UDim2.new(0.6, 0, 0.15, 0); InputBox.Size = UDim2.new(0.35, 0, 0.7, 0); InputBox.Font = Enum.Font.GothamSemibold; InputBox.TextSize = 12; InputBox.TextColor3 = Theme.Text; InputBox.Text = tostring(Default); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(0, 4); IC.Parent = InputBox; InputBox.FocusLost:Connect(function() local val = tonumber(InputBox.Text); if val then getgenv()[Var] = val else InputBox.Text = tostring(getgenv()[Var]) end end); return InputBox end
local function CreateButton(Parent, Text, Callback) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Purple; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = Text; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; Btn.MouseButton1Click:Connect(Callback) end

-- ========================================== --
-- MEMBANGUN MENU UI 
-- ========================================== --
CreateToggle(TargetPage, "Start Auto Cleaner", "AutoCleaner")

local BoxStartX = CreateTextBox(TargetPage, "Start X (Kiri)", getgenv().StartX, "StartX")
local BoxStartY = CreateTextBox(TargetPage, "Start Y (Atas)", getgenv().StartY, "StartY")
CreateButton(TargetPage, "Set Point A (Kiri Atas) ke Posisi Saat Ini", function()
    local HitboxFolder = workspace:FindFirstChild("Hitbox")
    local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
    local RefPart = MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
    if RefPart then
        getgenv().StartX = math.floor(RefPart.Position.X / getgenv().GridSize + 0.5)
        getgenv().StartY = math.floor(RefPart.Position.Y / getgenv().GridSize + 0.5)
        BoxStartX.Text = tostring(getgenv().StartX)
        BoxStartY.Text = tostring(getgenv().StartY)
    end
end)

local BoxEndX = CreateTextBox(TargetPage, "End X (Kanan)", getgenv().EndX, "EndX")
local BoxEndY = CreateTextBox(TargetPage, "End Y (Bawah)", getgenv().EndY, "EndY")
CreateButton(TargetPage, "Set Point B (Kanan Bawah) ke Posisi Saat Ini", function()
    local HitboxFolder = workspace:FindFirstChild("Hitbox")
    local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
    local RefPart = MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
    if RefPart then
        getgenv().EndX = math.floor(RefPart.Position.X / getgenv().GridSize + 0.5)
        getgenv().EndY = math.floor(RefPart.Position.Y / getgenv().GridSize + 0.5)
        BoxEndX.Text = tostring(getgenv().EndX)
        BoxEndY.Text = tostring(getgenv().EndY)
    end
end)

-- ========================================== --
-- LOGIKA SNAKE PATTERN CLEANER
-- ========================================== --
local Remotes = RS:WaitForChild("Remotes")
local RemoteBreak = Remotes:WaitForChild("PlayerFist")

task.spawn(function()
    while true do
        if getgenv().AutoCleaner then
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
            local startZ = MyHitbox and MyHitbox.Position.Z or 0

            if MyHitbox then
                local currentY = getgenv().StartY
                local goingRight = true

                -- Loop menurun dari Start Y sampai End Y
                while currentY >= getgenv().EndY and getgenv().AutoCleaner do
                    
                    -- Tentukan titik mulai X dan akhir X berdasarkan arah
                    local startScanX = goingRight and getgenv().StartX or getgenv().EndX
                    local endScanX = goingRight and getgenv().EndX or getgenv().StartX
                    local stepX = goingRight and 1 or -1

                    for x = startScanX, endScanX, stepX do
                        if not getgenv().AutoCleaner then break end

                        -- 1. Teleport karakter ke grid target
                        local newWorldPos = Vector3.new(x * getgenv().GridSize, currentY * getgenv().GridSize, startZ)
                        MyHitbox.CFrame = CFrame.new(newWorldPos)
                        if PlayerMovement then pcall(function() PlayerMovement.Position = newWorldPos end) end
                        
                        task.wait(0.1) -- Jeda kecil agar karakter menetap

                        -- 2. Pukul berulang kali untuk hancurkan foreground & background
                        local targetGrid = Vector2.new(x, currentY)
                        for hit = 1, getgenv().CleanHitCount do
                            if not getgenv().AutoCleaner then break end
                            RemoteBreak:FireServer(targetGrid)
                            task.wait(getgenv().CleanDelay)
                        end
                    end

                    -- Pindah ke baris bawahnya
                    currentY = currentY - 1 
                    
                    -- Putar balik arah (kiri ke kanan -> kanan ke kiri)
                    goingRight = not goingRight 
                end
                
                -- Matikan otomatis jika sudah selesai sampai bawah
                getgenv().AutoCleaner = false 
            end
        end
        task.wait(1)
    end
end)
