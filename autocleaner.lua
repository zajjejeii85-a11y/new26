-- [[ ZONHUB - WORLD NUKER V5 (SMOOTH CAMERA & MAX SPEED PUNCH) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "World Nuker v5.0" 

-- ========================================== --
getgenv().GridSize = 4.5 
local InternalWidth = 100 -- Jarak sapuan otomatis (100 blok)
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser") 

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

getgenv().AutoClearWorld = false
getgenv().GlideSpeed = 50    

-- ========================================== --
-- FUNGSI UI UTILITY
-- ========================================== --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }

local function CreateToggle(Parent, Text, Var) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; Btn.AutoButtonColor = false; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; local T = Instance.new("TextLabel"); T.Parent = Btn; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left; local IndBg = Instance.new("Frame"); IndBg.Parent = Btn; IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = IndBg; local Dot = Instance.new("Frame"); Dot.Parent = IndBg; Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot; Btn.MouseButton1Click:Connect(function() getgenv()[Var] = not getgenv()[Var]; if getgenv()[Var] then Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple else Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) end end) end
local function CreateSlider(Parent, Text, Min, Max, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 45); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text .. ": " .. Default; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 0, 20); Label.Position = UDim2.new(0, 10, 0, 2); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left; local SliderBg = Instance.new("TextButton"); SliderBg.Parent = Frame; SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SliderBg.Position = UDim2.new(0, 10, 0, 28); SliderBg.Size = UDim2.new(1, -20, 0, 6); SliderBg.Text = ""; SliderBg.AutoButtonColor = false; local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = SliderBg; local Fill = Instance.new("Frame"); Fill.Parent = SliderBg; Fill.BackgroundColor3 = Theme.Purple; Fill.Size = UDim2.new(0.5, 0, 1, 0); local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(1,0); FC.Parent = Fill; local Dragging = false; local function Update(input) local SizeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1); local Val = math.floor(Min + ((Max - Min) * SizeX)); Fill.Size = UDim2.new(SizeX, 0, 1, 0); Label.Text = Text .. ": " .. Val; getgenv()[Var] = Val end; SliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; Update(i) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end); UIS.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end) end

-- ========================================== --
-- MENU UI (SUPER SIMPEL SEPERTI CX.FARM)
-- ========================================== --
local TitleLabel = Instance.new("TextLabel", TargetPage)
TitleLabel.Size = UDim2.new(1, -10, 0, 20); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "WORLD NUKER"; TitleLabel.TextColor3 = Theme.Purple; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 12; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(TargetPage, "Auto Clear World", "AutoClearWorld")
CreateSlider(TargetPage, "Glide Speed", 10, 100, 50, "GlideSpeed")

-- ========================================== --
-- LOGIKA V5 (RENDERSTEPPED GLIDE & MAX HIT)
-- ========================================== --
local Remotes = RS:WaitForChild("Remotes")
local RemoteBreak = Remotes:WaitForChild("PlayerFist")
local NukeConnection = nil

local function StopNuker()
    if NukeConnection then
        NukeConnection:Disconnect()
        NukeConnection = nil
    end
    local HitboxFolder = workspace:FindFirstChild("Hitbox")
    local RefPart = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name) or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
    if RefPart then RefPart.Anchored = false end
    if PlayerMovement then pcall(function() PlayerMovement.InputActive = true end) end
end

task.spawn(function()
    local lastState = false
    while task.wait(0.1) do
        -- Deteksi saat tombol dinyalakan
        if getgenv().AutoClearWorld and not lastState then
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local RefPart = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name) or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            
            if RefPart then
                -- Persiapan Awal
                RefPart.Anchored = true
                if PlayerMovement then pcall(function() PlayerMovement.InputActive = false end) end
                
                local startZ = RefPart.Position.Z
                local currentWorldX = RefPart.Position.X
                local startGridX = math.floor(currentWorldX / getgenv().GridSize + 0.5)
                local currentGridY = math.floor(RefPart.Position.Y / getgenv().GridSize + 0.5)
                
                local minWorldX = startGridX * getgenv().GridSize
                local maxWorldX = (startGridX + InternalWidth) * getgenv().GridSize
                local direction = 1 -- 1 = Kanan, -1 = Kiri

                -- RenderStepped Loop (Dijalankan setiap frame, ~60 FPS)
                NukeConnection = RunService.RenderStepped:Connect(function(deltaTime)
                    if not getgenv().AutoClearWorld then return StopNuker() end

                    -- 1. Kalkulasi Pergerakan Mulus (Glide)
                    local speed = getgenv().GlideSpeed
                    currentWorldX = currentWorldX + (speed * direction * deltaTime)

                    -- 2. Cek Batas Ujung (Mundur & Turun 1 Blok)
                    if direction == 1 and currentWorldX >= maxWorldX then
                        direction = -1
                        currentGridY = currentGridY - 1
                        currentWorldX = maxWorldX -- Kunci agar tidak kelewatan batas
                    elseif direction == -1 and currentWorldX <= minWorldX then
                        direction = 1
                        currentGridY = currentGridY - 1
                        currentWorldX = minWorldX
                    end

                    -- 3. Update Posisi Kamera & Karakter (Melayang 1 Blok di Atas Target)
                    local safeY = currentGridY + 1
                    RefPart.CFrame = CFrame.new(currentWorldX, safeY * getgenv().GridSize, startZ)

                    -- 4. Pukulan Secepat Mungkin (Tembak tiap frame ke area bawah kaki)
                    local activeGridX = math.floor(currentWorldX / getgenv().GridSize + 0.5)
                    
                    -- Hancurkan blok tepat di bawah kaki
                    RemoteBreak:FireServer(Vector2.new(activeGridX, currentGridY))
                    -- Hancurkan blok 1 langkah di depannya agar bersih maksimal saat ngebut
                    RemoteBreak:FireServer(Vector2.new(activeGridX + direction, currentGridY))
                end)
            end
        -- Deteksi saat tombol dimatikan
        elseif not getgenv().AutoClearWorld and lastState then
            StopNuker()
        end
        lastState = getgenv().AutoClearWorld
    end
end)
