-- [[ ZONHUB - AUTO CLEANER MODULE V2 (SIMPLE SNAKE) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "AutoCleaner v2.0" 

-- ========================================== --
getgenv().GridSize = 4.5 
getgenv().CleanDelay = 0.15 -- Sedikit dinaikkan agar server merespon hit dengan baik
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
getgenv().CleanHitCount = 6  -- Dinaikkan menjadi 6 pukulan sesuai permintaanmu
getgenv().SweepWidth = 50    -- Lebar area ke kanan (berapa blok)
getgenv().SweepDepth = 15    -- Kedalaman ke bawah (berapa blok)

-- ========================================== --
-- FUNGSI UI UTILITY
-- ========================================== --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }

local function CreateToggle(Parent, Text, Var) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; Btn.AutoButtonColor = false; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; local T = Instance.new("TextLabel"); T.Parent = Btn; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left; local IndBg = Instance.new("Frame"); IndBg.Parent = Btn; IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = IndBg; local Dot = Instance.new("Frame"); Dot.Parent = IndBg; Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot; Btn.MouseButton1Click:Connect(function() getgenv()[Var] = not getgenv()[Var]; if getgenv()[Var] then Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple else Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) end end) end
local function CreateTextBox(Parent, Text, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 35); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.65, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left; local InputBox = Instance.new("TextBox"); InputBox.Parent = Frame; InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InputBox.Position = UDim2.new(0.7, 0, 0.15, 0); InputBox.Size = UDim2.new(0.25, 0, 0.7, 0); InputBox.Font = Enum.Font.GothamSemibold; InputBox.TextSize = 12; InputBox.TextColor3 = Theme.Text; InputBox.Text = tostring(Default); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(0, 4); IC.Parent = InputBox; InputBox.FocusLost:Connect(function() local val = tonumber(InputBox.Text); if val then getgenv()[Var] = val else InputBox.Text = tostring(getgenv()[Var]) end end); return InputBox end

-- ========================================== --
-- MEMBANGUN MENU UI (LEBIH SIMPEL)
-- ========================================== --
local InfoLabel = Instance.new("TextLabel", TargetPage)
InfoLabel.Size = UDim2.new(1, -10, 0, 20); InfoLabel.BackgroundTransparency = 1; InfoLabel.Text = "Berdirilah di KIRI ATAS sebelum menyalakan ini."; InfoLabel.TextColor3 = Color3.fromRGB(200,200,200); InfoLabel.Font = Enum.Font.Gotham; InfoLabel.TextSize = 10; InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(TargetPage, "Start Auto Cleaner", "AutoCleaner")
CreateTextBox(TargetPage, "Lebar Area (Berapa Blok ke Kanan)", getgenv().SweepWidth, "SweepWidth")
CreateTextBox(TargetPage, "Kedalaman (Berapa Blok ke Bawah)", getgenv().SweepDepth, "SweepDepth")
CreateTextBox(TargetPage, "Jumlah Hit per Blok", getgenv().CleanHitCount, "CleanHitCount")

-- ========================================== --
-- LOGIKA SNAKE PATTERN CLEANER V2
-- ========================================== --
local Remotes = RS:WaitForChild("Remotes")
local RemoteBreak = Remotes:WaitForChild("PlayerFist")

task.spawn(function()
    while true do
        if getgenv().AutoCleaner then
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
            local RefPart = MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            
            if RefPart then
                -- Ambil koordinat awal tempat kamu berdiri saat Toggle ditekan
                local startZ = RefPart.Position.Z
                local startX = math.floor(RefPart.Position.X / getgenv().GridSize + 0.5)
                local startY = math.floor(RefPart.Position.Y / getgenv().GridSize + 0.5)
                
                local isGoingRight = true

                -- Loop ke bawah sebanyak SweepDepth
                for row = 0, getgenv().SweepDepth - 1 do
                    local currentY = startY - row
                    
                    -- Tentukan blok mana yang akan disapu (Kiri ke Kanan atau sebaliknya)
                    local startCol = isGoingRight and 0 or (getgenv().SweepWidth - 1)
                    local endCol = isGoingRight and (getgenv().SweepWidth - 1) or 0
                    local stepCol = isGoingRight and 1 or -1

                    for col = startCol, endCol, stepCol do
                        if not getgenv().AutoCleaner then break end
                        
                        local targetX = startX + col
                        local newWorldPos = Vector3.new(targetX * getgenv().GridSize, currentY * getgenv().GridSize, startZ)
                        
                        -- 1. Teleport ke blok
                        if MyHitbox then MyHitbox.CFrame = CFrame.new(newWorldPos) end
                        if PlayerMovement then pcall(function() PlayerMovement.Position = newWorldPos end) end
                        
                        task.wait(0.15) -- Tunggu karakter diam sedikit

                        -- 2. Hancurkan Blok & Background
                        local targetGrid = Vector2.new(targetX, currentY)
                        for hit = 1, getgenv().CleanHitCount do
                            if not getgenv().AutoCleaner then break end
                            RemoteBreak:FireServer(targetGrid)
                            task.wait(getgenv().CleanDelay)
                        end
                    end
                    
                    if not getgenv().AutoCleaner then break end
                    -- Balikkan arah untuk baris selanjutnya
                    isGoingRight = not isGoingRight
                end
                
                -- Selesai menyapu area, matikan otomatis
                getgenv().AutoCleaner = false
            end
        end
        task.wait(1)
    end
end)
