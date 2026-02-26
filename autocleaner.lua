-- ========================================== --
-- LOGIKA V3.1 (SMOOTHER + MORE RELIABLE HITS)
-- ========================================== --
local Remotes = RS:WaitForChild("Remotes")
local RemoteBreak = Remotes:WaitForChild("PlayerFist")

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- TUNING (boleh Anda expose ke UI kalau mau)
getgenv().SafeYOffset = getgenv().SafeYOffset or 0.65   -- < 1 grid supaya lebih dekat (mengurangi miss)
getgenv().StabilizeHB  = getgenv().StabilizeHB  or 2    -- heartbeats untuk stabilisasi setelah teleport
getgenv().FinisherHits = getgenv().FinisherHits or 2    -- extra pukulan kecil agar “habis”
getgenv().MinHitDelay  = getgenv().MinHitDelay  or 0.12 -- batas bawah agar tidak terlalu spam
getgenv().UsePlayerMovementWhenHitbox = getgenv().UsePlayerMovementWhenHitbox or false

local function hb(n)
	for _ = 1, n do
		RunService.Heartbeat:Wait()
	end
end

local function getPingSeconds()
	local ok, item = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]
	end)
	if ok and item then
		local s = item:GetValueString() -- biasanya "XX ms"
		local ms = tonumber(s:match("(%d+)%s*ms")) or tonumber(s:match("(%d+%.?%d*)")) or 60
		return ms / 1000
	end
	return 0.06
end

local function setPos(MyHitbox, worldPos)
	if MyHitbox then
		MyHitbox.CFrame = CFrame.new(worldPos)
		pcall(function() MyHitbox.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
		pcall(function() MyHitbox.Velocity = Vector3.new(0,0,0) end)
	else
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(worldPos)
			pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
			pcall(function() hrp.Velocity = Vector3.new(0,0,0) end)
		end
	end

	-- Hindari double-control kalau ada Hitbox (biasanya bikin stutter)
	if PlayerMovement and (not MyHitbox or getgenv().UsePlayerMovementWhenHitbox) then
		pcall(function() PlayerMovement.Position = worldPos end)
	end
end

local function punchTileReliable(targetX, targetY, startZ, MyHitbox)
	local ping = getPingSeconds()
	local hitDelay = math.max(getgenv().CleanDelay, getgenv().MinHitDelay, ping * 0.55)

	local grid = Vector2.new(targetX, targetY)
	local totalHits = (getgenv().CleanHitCount or 6) + (getgenv().FinisherHits or 0)

	for i = 1, totalHits do
		if not getgenv().AutoCleaner then break end
		RemoteBreak:FireServer(grid)

		-- “refresh position” setiap beberapa hit untuk mengurangi miss karena rubberband
		if i % 3 == 0 then
			local safeWorldPos = Vector3.new(
				targetX * getgenv().GridSize,
				(targetY + getgenv().SafeYOffset) * getgenv().GridSize,
				startZ
			)
			setPos(MyHitbox, safeWorldPos)
		end

		task.wait(hitDelay)
	end

	-- jeda kecil agar perubahan tile sempat direplikasi
	task.wait(math.max(0.05, ping * 0.25))
end

task.spawn(function()
	while true do
		if getgenv().AutoCleaner then
			local HitboxFolder = workspace:FindFirstChild("Hitbox")
			local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
			local RefPart = MyHitbox or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))

			if RefPart then
				local startZ = RefPart.Position.Z
				local startX = math.floor(RefPart.Position.X / getgenv().GridSize + 0.5)
				local startY = math.floor(RefPart.Position.Y / getgenv().GridSize + 0.5)

				local isGoingRight = true

				for row = 0, (getgenv().SweepDepth - 1) do
					if not getgenv().AutoCleaner then break end

					local targetY = startY - row
					local startCol = isGoingRight and 0 or (getgenv().SweepWidth - 1)
					local endCol   = isGoingRight and (getgenv().SweepWidth - 1) or 0
					local stepCol  = isGoingRight and 1 or -1

					for col = startCol, endCol, stepCol do
						if not getgenv().AutoCleaner then break end

						local targetX = startX + col

						-- posisi aman (lebih dekat dari 1 tile penuh)
						local safeWorldPos = Vector3.new(
							targetX * getgenv().GridSize,
							(targetY + getgenv().SafeYOffset) * getgenv().GridSize,
							startZ
						)

						setPos(MyHitbox, safeWorldPos)
						hb(getgenv().StabilizeHB) -- stabilisasi (lebih mulus daripada wait(0.2) statis)

						punchTileReliable(targetX, targetY, startZ, MyHitbox)
					end

					isGoingRight = not isGoingRight
				end

				getgenv().AutoCleaner = false
			end
		end

		task.wait(0.5)
	end
end)
