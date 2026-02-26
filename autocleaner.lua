-- StarterPlayerScripts/AutoCleaner.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local mineRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MineBlock")

-- ====== SETTING ======
local GRID = 4              -- ukuran grid blok (stud). Sesuaikan dengan size blokmu.
local WIDTH = 30            -- berapa blok ke kanan
local DEPTH = 1             -- untuk game 2D side scroller biasanya 1 (Z tetap)
local HOVER_HEIGHT = 4      -- tinggi melayang di atas permukaan
local HITS_PER_TICK = 3     -- berapa hit dikirim per iterasi
local HIT_DELAY = 0.06      -- delay antar hit
local MAX_ATTEMPTS = 200    -- anti-stuck
-- =====================

local running = false
local origin: Vector3? = nil

local function snapToGrid(v: Vector3)
	local sx = math.floor((v.X / GRID) + 0.5) * GRID
	local sz = math.floor((v.Z / GRID) + 0.5) * GRID
	return Vector3.new(sx, v.Y, sz)
end

local function rayDown(fromPos: Vector3, ignoreList: {Instance})
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignoreList
	return workspace:Raycast(fromPos, Vector3.new(0, -1000, 0), params)
end

local function hoverTo(hrp: BasePart, worldPos: Vector3)
	-- cara simpel: teleport halus (kalau mau lebih smooth bisa diganti Tween/AlignPosition)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(worldPos + Vector3.new(0, HOVER_HEIGHT, 0))
end

local function mineCell(hrp: BasePart, cellPos: Vector3)
	hoverTo(hrp, cellPos)

	local ignore = {player.Character}

	for _ = 1, MAX_ATTEMPTS do
		local hit = rayDown(hrp.Position, ignore)
		if not hit or not hit.Instance then
			return -- kosong
		end

		local block = hit.Instance
		if not CollectionService:HasTag(block, "Mineable") then
			return -- bukan blok yang boleh dihancurkan
		end

		for _i = 1, HITS_PER_TICK do
			mineRemote:FireServer(block)
			task.wait(HIT_DELAY)
		end

		-- cek lagi: kalau blok sudah hilang/berubah, selesai
		task.wait(HIT_DELAY)
		local hit2 = rayDown(hrp.Position, ignore)
		if (not hit2) or (hit2.Instance ~= block) then
			return
		end
	end
end

local function runCleaner()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart") :: BasePart

	while running do
		for dz = 0, DEPTH - 1 do
			local leftToRight = (dz % 2 == 0)
			for dx = 0, WIDTH - 1 do
				if not running then break end
				local x = leftToRight and dx or (WIDTH - 1 - dx)

				-- untuk 2D: kamu bisa kunci Z = origin.Z, DEPTH=1
				local cell = origin + Vector3.new(x * GRID, 0, dz * GRID)
				mineCell(hrp, cell)
			end
		end

		-- selesai 1 area
		running = false
	end
end

-- panggil Start() / Stop() dari tombol UI kamu
function _G.StartAutoCleaner()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	origin = snapToGrid(hrp.Position)
	running = true
	task.spawn(runCleaner)
end

function _G.StopAutoCleaner()
	running = false
end
