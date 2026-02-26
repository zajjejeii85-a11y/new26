-- [[ ZONHUB - GLIDE CLEANER (SWEEP LEFT & NUKE BELOW) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "Glide Cleaner (Left)" 

-- ========================================== --
getgenv().GridSize = 4.5 
getgenv().HitSpamDelay = 0.05 
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser") 

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

getgenv().AutoClearLeft = false
getgenv().GlideSpeed = 50    
getgenv().SweepWidth = 50    

-- ========================================== --
-- FUNGSI UI UTILITY
-- ========================================== --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }

local function CreateToggle(Parent, Text, Var) local Btn = Instance.new("TextButton"); Btn.Parent = Parent; Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; Btn.AutoButtonColor = false; local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn; local T = Instance.new("TextLabel"); T.Parent = Btn; T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left; local IndBg = Instance.new("Frame"); IndBg.Parent = Btn; IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = IndBg; local Dot = Instance.new("Frame"); Dot.Parent = IndBg; Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot; Btn.MouseButton1Click:Connect(function() getgenv()[Var] = not getgenv()[Var]; if getgenv()[Var] then Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple else Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) end end) end
local function CreateTextBox(Parent, Text, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 35); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.65, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left; local InputBox = Instance.new("TextBox"); InputBox.Parent = Frame; InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InputBox.Position = UDim2.new(0.7, 0, 0.15, 0); InputBox.Size = UDim2.new(0.25, 0, 0.7, 0); InputBox.Font = Enum.Font.GothamSemibold; InputBox.TextSize = 12; InputBox.TextColor3 = Theme.Text; InputBox.Text = tostring(Default); local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(0, 4); IC.Parent = InputBox; InputBox.FocusLost:Connect(function() local val = tonumber(InputBox.Text); if val then getgenv()[Var] = val else InputBox.Text = tostring(getgenv()[Var]) end end); return InputBox end
local function CreateSlider(Parent, Text, Min, Max, Default, Var) local Frame = Instance.new("Frame"); Frame.Parent = Parent; Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 45); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Frame; local Label = Instance.new("TextLabel"); Label.Parent = Frame; Label.Text = Text .. ": " .. Default; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 0, 20); Label.Position = UDim2.new(0, 10, 0, 2); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left; local SliderBg = Instance.new("TextButton"); SliderBg.Parent = Frame; SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SliderBg.Position = UDim2.new(0, 10, 0, 28); SliderBg.Size = UDim2.new(1, -20, 0, 6); SliderBg.Text = ""; SliderBg.AutoButtonColor = false; local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = SliderBg; local Fill = Instance.new("Frame"); Fill.Parent = SliderBg; Fill.BackgroundColor3 = Theme.Purple; Fill.Size = UDim2.new(0.5, 0, 1, 0); local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(1,0); FC.Parent = Fill; local Dragging = false; local function Update(input) local SizeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1); local Val = math.floor(Min + ((Max - Min) * SizeX)); Fill.Size = UDim2.new(SizeX, 0, 1, 0); Label.Text = Text .. ": " .. Val; getgenv()[Var] = Val end; SliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; Update(i) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end); UIS.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end) end

-- ========================================== --
-- MENU UI (WORLD NUKER - GLIDE LEFT)
-- ========================================== --
local TitleLabel = Instance.new("TextLabel", TargetPage)
TitleLabel.Size = UDim2.new(1, -10, 0, 25); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "WORLD NUKER (GLIDE LEFT)"; TitleLabel.TextColor3 = Theme.Purple; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 13; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(TargetPage, "Auto Clear (Melayang Ke Kiri)", "AutoClearLeft")
CreateSlider(TargetPage, "Glide Speed", 10, 100, 50, "GlideSpeed")
CreateTextBox(TargetPage, "Jarak Sapuan (Berapa Blok ke Kiri)", getgenv().SweepWidth, "SweepWidth")

-- ========================================== --
-- LOGIKA GLIDE KE KIRI & HANCURKAN BAWAH
-- ========================================== --
local Remotes = RS:WaitForChild("Remotes")
local RemoteBreak = Remotes:WaitForChild("PlayerFist")
local CurrentTween = nil

task.spawn(function()
    while true do
        if getgenv().AutoClearLeft then
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
            local RefPart = MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            
            if RefPart then
                -- 1. Ambil posisi saat ini sebagai titik mulai
                local startZ = RefPart.Position.Z
                local flightY = RefPart.Position.Y -- Kunci ketinggian terbang (tidak akan jatuh)
                local startX = RefPart.Position.X
                
                -- Target blok yang mau dihancurkan adalah 1 grid di bawah kaki
                local currentGridY = math.floor(flightY / getgenv().GridSize + 0.5)
                local targetBlockY = currentGridY - 1 
                
                -- 2. Hitung titik akhir (bergeser ke KIRI sejauh SweepWidth)
                local endX = startX - (getgenv().SweepWidth * getgenv().GridSize)
                
                -- 3. Bekukan karakter agar melayang stabil di udara
                RefPart.Anchored = true 
                RefPart.Velocity = Vector3.new(0,0,0)
                if PlayerMovement then pcall(function() PlayerMovement.InputActive = false end) end
                
                -- 4. Mulai meluncur ke kiri
                local distance = math.abs(startX - endX)
                local timeToTravel = distance / (getgenv().GlideSpeed / 2) 
                
                local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
                CurrentTween = TS:Create(RefPart, tweenInfo, {CFrame = CFrame.new(endX, flightY, startZ)})
                CurrentTween:Play()
                
                -- 5. Spam pukulan ke blok di bawah selama meluncur
                while CurrentTween.PlaybackState == Enum.PlaybackState.Playing and getgenv().AutoClearLeft do
                    local currentGridX = math.floor(RefPart.Position.X / getgenv().GridSize + 0.5)
                    
                    -- Hancurkan tepat di bawah kaki
                    RemoteBreak:FireServer(Vector2.new(currentGridX, targetBlockY))
                    
                    -- Hancurkan juga 1 blok di sebelah kirinya (antisipasi gerak cepat)
                    RemoteBreak:FireServer(Vector2.new(currentGridX - 1, targetBlockY))
                    
                    task.wait(getgenv().HitSpamDelay)
                end
                
                -- Hentikan pergerakan jika selesai atau dimatikan
                if CurrentTween then CurrentTween:Cancel() end
                getgenv().AutoClearLeft = false
                
                -- Kembalikan kontrol normal
                if RefPart then RefPart.Anchored = false end
                if PlayerMovement then pcall(function() PlayerMovement.InputActive = true end) end
            end
        end
        task.wait(0.5)
    end
end)

-- Sistem Pengaman: Un-anchor karakter saat dimatikan manual
spawn(function()
    local lastState = false
    while task.wait(0.1) do
        if lastState == true and getgenv().AutoClearLeft == false then
            if CurrentTween then CurrentTween:Cancel() end
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local RefPart = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name) or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            if RefPart then RefPart.Anchored = false end
            if PlayerMovement then pcall(function() PlayerMovement.InputActive = true end) end
        end
        lastState = getgenv().AutoClearLeft
    end
end)
