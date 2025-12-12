--// DARKADMIN CORE v2.5 ULTIMATE - FULL MERGE 100% (wino444 OFFICIAL EDITION) 💀🩸🔥

if not getgenv then error("ต้องใช้ Executor ที่รองรับ getgenv()") end

if getgenv().DarkAdmin and getgenv().DarkAdmin.CoreLoaded then
	warn("[DarkAdmin] ป้องกันรันซ้ำ — CORE โหลดแล้ว!")
	return true  -- 🔥 ออกทันที ไม่รันส่วนอื่น!
end

if game.PlaceId ~= 4503309821 then
	warn("[DarkAdmin] ❌ จำกัดเฉพาะแมพ 4503309821 — ไม่รันในแมพนี้!")
	return false  -- 🔥 ออกเลย ไม่โหลดอะไรทั้งนั้น!
end

getgenv().DarkAdmin = getgenv().DarkAdmin or {
	CoreLoaded = false,
	UI = nil,
	Commands = {},
	Prefix = "!",
	DADebug = false,
	VersionDA = "2.5 ULTIMATE",
	Ranks = { Normal = 1, VIP = 2, Owner = 3 },
	TempVIP = {},
	RankDB = {},
	WebhookURL = getgenv().DarkAdmin and getgenv().DarkAdmin.WebhookURL or nil,
}

local DA = getgenv().DarkAdmin

--// [SERVICES]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
	if DA.DADebug then
		print("[DarkAdmin DEBUG]", ...)
	end
end

local function SafePcall(func, ...)
	local success, result = pcall(func, ...)
	if not success then
		warn("[DarkAdmin ERROR]", result)
	end
	return success, result
end

--// [KEY]
DA.wino444 = true
printDebug("คีย์ wino444 ถูกสร้าง")

--// [RANK SYSTEM — แก้ ipairs error 100%!]
local RankDB = {}
local success, loaded = SafePcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/refs/heads/main/RANK_DATA.lua"))()
end)

if success and type(loaded) == "table" then
	RankDB = loaded
	printDebug("โหลด RANK_DATA สำเร็จ")
else
	warn("[DarkAdmin] ไม่สามารถโหลด RANK_DATA — ใช้ fallback")
	RankDB = {}  -- fallback table
end

local NameToRank = {}
if type(RankDB) == "table" then
	for _, data in pairs(RankDB) do  -- 🔥 ใช้ pairs แทน ipairs ป้องกัน error!
		if data and data.Name then
			NameToRank[string.lower(data.Name)] = data.Rank or DA.Ranks.Normal
		end
	end
end

local function GetRankByName(name)
	name = string.lower(name)
	return NameToRank[name] or DA.Ranks.Normal
end

DA.RankDB = {
	DB = RankDB,
	GetRankByName = GetRankByName,
	NameToRank = NameToRank
}

local function SafeGetPlayerRank(plr)
	plr = plr or LocalPlayer
	if plr.Name == "wino444" then return DA.Ranks.Owner end
	local rank = GetRankByName(plr.Name)
	if rank > DA.Ranks.Normal then return rank end
	if DA.TempVIP[plr.UserId] then return DA.Ranks.VIP end
	return DA.Ranks.Normal
end

getgenv().DarkAdmin.SafeGetPlayerRank = SafeGetPlayerRank

--// [WEBHOOK LOGGER]
local webhookUrl = DA.WebhookURL or 'https://discord.com/api/webhooks/1437254096670425168/LWIOvSp6LxWuGYxS0SXKjfblkURER8tMZxPUxU-v0J-50BDYopOmxpd9P-ZZJZKRP6S7'

local function getExecutorName()
	if syn then return "Synapse X"
	elseif secure_load and is_protosmasher_caller then return "ProtoSmasher"
	elseif fluxus then return "Fluxus"
	elseif getexecutorname then return getexecutorname()
	elseif KRNL_LOADED then return "KRNL"
	elseif pebc_execute then return "Script-Ware"
	elseif Cryptic then return "Cryptic"
	elseif Trigon then return "Trigon"
	elseif VegaX then return "Vega X"
	elseif Codex then return "Codex"
	elseif ArceusX then return "Arceus X"
	elseif DELTA then return "DELTA"
	elseif illusion then return "Illusion"
	elseif Cubix then return "Cubix"
	elseif Nebula then return "Nebula"
	elseif Subzero then return "Subzero"
	elseif Evon then return "Evon"
	elseif ReveliX then return "ReveliX"
	elseif RIFT then return "RIFT"
	elseif Alysse then return "Alysse"
	else return "Unknown Executor"
	end
end

local function safeHttpRequest(data)
	return SafePcall(request, data)
end

local function sendInitEmbed(placeName)
	local embed = {
		title = "🔥 DarkAdmin เริ่มทำงาน",
		description = 
			"🎮 **เกม:** `" .. placeName .. "`\n" ..
			"⏰ **เวลา:** `" .. os.date("%m/%d/%Y %X") .. "`\n" ..
			"💻 **เวอร์ชัน:** `v" .. DA.VersionDA .. "`",
		color = 16711680
	}
	SafePcall(function()
		safeHttpRequest({
			Url = webhookUrl,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({ embeds = {embed} })
		})
	end)
end

local function logPlayerInfo(plr)
	if not plr then return end
	local ping = "N/A"
	SafePcall(function()
		if typeof(plr.GetNetworkPing) == "function" then
			local netPing = plr:GetNetworkPing()
			if typeof(netPing) == "number" then
				ping = math.floor(netPing * 1000) .. " ms"
			end
		end
	end)

	local embed = {
		title = "👤 ผู้ใช้ DarkAdmin",
		description = 
			"🎮 **Display:** `" .. plr.DisplayName .. "`\n" ..
			"🧑‍💻 **Username:** `" .. plr.Name .. "`\n" ..
			"🆔 **ID:** `" .. tostring(plr.UserId) .. "`\n" ..
			"👴 **อายุ:** `" .. plr.AccountAge .. " วัน`\n" ..
			"📡 **Ping:** `" .. ping .. "`\n" ..
			"🖥️ **Executor:** `" .. getExecutorName() .. "`",
		color = 65280,
		footer = { text = os.date("%m/%d/%Y %X") }
	}
	SafePcall(function()
		safeHttpRequest({
			Url = webhookUrl,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({ embeds = {embed} })
		})
	end)
end

spawn(function()
	local placeName = "Unknown"
	local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
	if success and info and info.Name then placeName = info.Name end
	task.wait(0.5); sendInitEmbed(placeName)
	task.wait(1); if LocalPlayer then logPlayerInfo(LocalPlayer) end
end)

--// [MODULE LOADER]
local ModulesLoaded = {}

local function LoadModule(name, url)
	if ModulesLoaded[name] then return true end
	local success, err = SafePcall(function()
		loadstring(game:HttpGet(url))()
	end)
	if success then
		ModulesLoaded[name] = true
		printDebug(name .. " โหลดสำเร็จ")
		return true
	else
		warn("โหลด " .. name .. " ล้มเหลว: " .. tostring(err))
		return false
	end
end

--หลัก
--https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY1.lua
--https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY2.lua
--ทดสอบ
--https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY1%20Test.lua
--https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY2%20Test.lua
LoadModule("COMMANDS LIBRARY1", "https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY1%20Test.lua")
LoadModule("COMMANDS LIBRARY2", "https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY2%20Test.lua")
LoadModule("COMMANDS CONTROLLER", "https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20CONTROLLER%20LIBRARY.lua")
LoadModule("CUSTOM NOTIFY", "https://raw.githubusercontent.com/wino444/DarkAdmin/main/CUSTOM%20NOTIFY.lua")
LoadModule("COLLECT MODULE", "https://raw.githubusercontent.com/wino444/DarkAdmin/main/CollectModule.lua")

--// [NOTIFY SYSTEM]
function DA.Notify(title, text, duration)
	if getgenv().CustomNotify and getgenv().CustomNotify.Show then
		getgenv().CustomNotify.Show(title, text, duration)
	else
		SafePcall(function()
			game.StarterGui:SetCore("SendNotification", {
				Title = title,
				Text = text,
				Duration = duration or 3
			})
		end)
	end
end

--// [SPLIT ARGS — แยก args ทุกคำสั่ง!]
local function splitArgs(input)
	local args = {}
	for word in string.gmatch(input, "%S+") do
		table.insert(args, word)
	end
	return args
end

--// [ADD COMMAND — รองรับ args หลายตัว!]
function DA.AddCommand(name, desc, callback, rank)
	rank = rank or DA.Ranks.Normal
	DA.Commands[name:lower()] = { desc = desc, func = callback, rank = rank }
	printDebug("เพิ่มคำสั่ง:", name, "ระดับ:", rank)
end

--// [FIND COMMAND — ป้องกันชนกัน 100%!]
local function findCommand(input)
	if not input or #input == 0 then return nil end
	input = string.lower(input)

	local myRank = SafeGetPlayerRank(LocalPlayer)
	local exactMatch = DA.Commands[input]
	if exactMatch and exactMatch.rank <= myRank then
		return input
	end

	local candidates = {}
	for cmd, data in pairs(DA.Commands) do
		if data.rank <= myRank and string.sub(cmd, 1, #input) == input then
			table.insert(candidates, cmd)
		end
	end

	if #candidates == 0 then return nil end
	if #candidates == 1 then return candidates[1] end

	table.sort(candidates, function(a, b) return #a < #b end)
	local suggestions = table.concat(candidates, ", ")
	DA.Notify("DarkAdmin", "⚠️ คำสั่งคลุมเครือ! ลองพิมพ์เต็ม:\n" .. suggestions, 5)
	return nil
end

--// [PARSE & EXECUTE — รองรับ args ทุกคำสั่ง!]
local function executeCommand(input, requirePrefix)
	if requirePrefix and string.sub(input, 1, #DA.Prefix) ~= DA.Prefix then return end
	if requirePrefix then input = string.sub(input, #DA.Prefix + 1) end

	local args = splitArgs(input)
	if #args == 0 then return end

	local cmdName = args[1]:lower()
	local fullCmd = findCommand(cmdName)
	if not fullCmd then return end

	local command = DA.Commands[fullCmd]
	table.remove(args, 1)  -- ลบชื่อคำสั่ง
	spawn(function()
		command.func(table.concat(args, " "))  -- 🔥 ส่ง args เป็น string รวม!
	end)
end

--// [CHAT SYSTEM — ต้องมี Prefix]
LocalPlayer.Chatted:Connect(function(msg)
	executeCommand(msg, true)
end)

--// [MAIN UI — ไม่ต้อง Prefix + รองรับ args ทุกคำสั่ง!]
local function createMainUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DarkAdminUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	DA.UI = screenGui

	local btn = Instance.new("TextButton")
	btn.Name = "DA_Button"
	btn.Size = UDim2.new(0, 50, 0, 50)
	btn.Position = UDim2.new(0, 20, 0, 20)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = "DA"
	label.TextColor3 = Color3.fromRGB(200, 0, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = btn

	local function pulse()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,0,100)}):Play()
		task.delay(0.2, function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,30)}):Play()
		end)
	end

	local dragging, dragStart, startPos
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = i.Position; startPos = btn.Position; pulse()
		end
	end)
	btn.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	btn.Activated:Connect(function()
		pulse()
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 300, 0, 50)
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.Position = UDim2.new(0.5, 0, 0.5, 0)
		box.BackgroundColor3 = Color3.fromRGB(15,15,25)
		box.TextColor3 = Color3.fromRGB(0,255,100)
		box.PlaceholderText = "พิมพ์คำสั่ง... (ไม่ต้อง Prefix)"
		box.Font = Enum.Font.Code
		box.TextSize = 18
		box.ClearTextOnFocus = true
		box.Parent = screenGui

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0,8)
		bc.Parent = box

		local suggestFrame = Instance.new("Frame")
		suggestFrame.Name = "SuggestFrame"
		suggestFrame.Size = UDim2.new(0, 300, 0, 0)
		suggestFrame.Position = UDim2.new(0.5, 0, 0.5, 55)
		suggestFrame.AnchorPoint = Vector2.new(0.5, 0)
		suggestFrame.BackgroundColor3 = Color3.fromRGB(20,20,35)
		suggestFrame.Visible = false
		suggestFrame.Parent = screenGui

		local sc = Instance.new("UICorner")
		sc.CornerRadius = UDim.new(0,8)
		sc.Parent = suggestFrame

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Padding = UDim.new(0,2)
		list.Parent = suggestFrame

		local function updateSuggestions(text)
			local matches = {}
			local myRank = SafeGetPlayerRank(LocalPlayer)
			for cmd, data in pairs(DA.Commands) do
				if data.rank <= myRank and string.find(cmd, text, 1, true) == 1 then
					table.insert(matches, cmd)
				end
			end
			table.sort(matches)

			for _, child in ipairs(suggestFrame:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end

			suggestFrame.Visible = #matches > 0
			suggestFrame.Size = UDim2.new(0, 300, 0, #matches > 0 and 37*#matches or 0)

			for i = 1, math.min(5, #matches) do
				local cmd = matches[i]
				local sbtn = Instance.new("TextButton")
				sbtn.Size = UDim2.new(1, 0, 0, 35)
				sbtn.BackgroundColor3 = Color3.fromRGB(30,30,45)
				sbtn.Text = cmd
				sbtn.TextColor3 = Color3.fromRGB(0,255,150)
				sbtn.Font = Enum.Font.Code
				sbtn.TextSize = 16
				sbtn.AutoButtonColor = false
				sbtn.Parent = suggestFrame

				local c = Instance.new("UICorner")
				c.CornerRadius = UDim.new(0,6)
				c.Parent = sbtn

				sbtn.Activated:Connect(function()
					box.Text = cmd .. " "  -- เพิ่มช่องว่างให้พิมพ์ args
					box:CaptureFocus()
					suggestFrame.Visible = false
				end)
			end
		end

		box.Focused:Connect(function()
			TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,50)}):Play()
		end)

		box.FocusLost:Connect(function(enter)
			if enter then
				executeCommand(box.Text, false)  -- 🔥 รันทั้งคำสั่ง + args!
			end
			box:Destroy()
			suggestFrame:Destroy()
		end)

		box:GetPropertyChangedSignal("Text"):Connect(function()
			updateSuggestions(string.lower(box.Text))
		end)

		box:CaptureFocus()
	end)
end

if not DA.UI then createMainUI() end

--// [FINALIZE]
DA.CoreLoaded = true
printDebug("CORE โหลดสำเร็จ! Version:", DA.VersionDA)

--// 🔥 คำสั่ง cmds ของคุณ (ไม่แตะ! แก้แค่ SafeGetPlayerRank)
DA.AddCommand("cmds", "แสดงรายการคำสั่งทั้งหมด + ค้นหาได้", function(searchQuery)
	printDebug("เปิด UI cmds")
	local screenGui = DA.UI
	local existing = screenGui:FindFirstChild("CmdsUI")
	if existing then existing:Destroy() end

	local frame = Instance.new("Frame")
	frame.Name = "CmdsUI"
	frame.Size = UDim2.new(0,380,0,450)
	frame.AnchorPoint = Vector2.new(0.5,0.5)
	frame.Position = UDim2.new(0.5,0,0.5,0)
	frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,12)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,40)
	title.BackgroundTransparency = 1
	title.Text = "DarkAdmin Commands (Prefix: "..DA.Prefix..")"
	title.TextColor3 = Color3.fromRGB(200,0,255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = frame

	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1,-20,0,35)
	searchBox.Position = UDim2.new(0,10,0,45)
	searchBox.BackgroundColor3 = Color3.fromRGB(25,25,35)
	searchBox.PlaceholderText = "ค้นหาคำสั่ง..."
	searchBox.Text = searchQuery or ""
	searchBox.TextColor3 = Color3.fromRGB(200,200,200)
	searchBox.Font = Enum.Font.Code
	searchBox.TextSize = 16
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = frame

	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0,8)
	sc.Parent = searchBox

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1,-20,1,-100)
	scroll.Position = UDim2.new(0,10,0,85)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Color3.fromRGB(100,0,150)
	scroll.Parent = frame

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0,30,0,30)
	close.Position = UDim2.new(1,-40,0,5)
	close.BackgroundColor3 = Color3.fromRGB(100,0,0)
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255,100,100)
	close.Font = Enum.Font.GothamBold
	close.Parent = frame
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0,8)
	cc.Parent = close
	close.Activated:Connect(function() frame:Destroy() end)

	local dragging, ds, sp
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; ds = i.Position; sp = frame.Position
		end
	end)
	frame.InputChanged:Connect(function(i)
		if dragging then
			local d = i.Position - ds
			frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local myRank = SafeGetPlayerRank(LocalPlayer)  -- 🔥 ใช้ SafeGetPlayerRank

	local function updateResults()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local query = string.lower(searchBox.Text or "")
		local y = 0
		local count = 0

		for name, data in pairs(DA.Commands) do
			if data.rank <= myRank then
				local fullCmd = DA.Prefix .. name
				if query == "" or string.find(string.lower(name), query) or string.find(string.lower(data.desc), query) then
					local entry = Instance.new("Frame")
					entry.Size = UDim2.new(1,-10,0,50)
					entry.Position = UDim2.new(0,5,0,y)
					entry.BackgroundColor3 = Color3.fromRGB(25,25,35)
					entry.Parent = scroll

					local ec = Instance.new("UICorner")
					ec.CornerRadius = UDim.new(0,6)
					ec.Parent = entry

					local n = Instance.new("TextLabel")
					n.Size = UDim2.new(0.4,0,1,0)
					n.BackgroundTransparency = 1
					n.Text = fullCmd
					n.TextColor3 = Color3.fromRGB(0,255,150)
					n.Font = Enum.Font.Code
					n.TextXAlignment = Enum.TextXAlignment.Left
					n.TextSize = 16
					n.Parent = entry

					local levelLabel = Instance.new("TextLabel")
					levelLabel.Size = UDim2.new(0.15,0,1,0)
					levelLabel.Position = UDim2.new(0.4,0,0,0)
					levelLabel.BackgroundTransparency = 1
					levelLabel.Text = "[L"..data.rank.."]"
					levelLabel.TextColor3 = data.rank == 1 and Color3.fromRGB(100,255,100) or
					                     data.rank == 2 and Color3.fromRGB(255,200,0) or
					                     Color3.fromRGB(255,0,150)
					levelLabel.Font = Enum.Font.Code
					levelLabel.TextSize = 14
					levelLabel.Parent = entry

					local d = Instance.new("TextLabel")
					d.Size = UDim2.new(0.45,-10,1,0)
					d.Position = UDim2.new(0.55,5,0,0)
					d.BackgroundTransparency = 1
					d.Text = data.desc
					d.TextColor3 = Color3.fromRGB(200,200,200)
					d.Font = Enum.Font.Code
					d.TextXAlignment = Enum.TextXAlignment.Left
					d.TextSize = 14
					d.TextWrapped = true
					d.Parent = entry

					y = y + 55
					count += 1
				end
			end
		end

		scroll.CanvasSize = UDim2.new(0,0,0,y)
		if count == 0 then
			local noResult = Instance.new("TextLabel")
			noResult.Size = UDim2.new(1,0,0,40)
			noResult.BackgroundTransparency = 1
			noResult.Text = "ไม่พบคำสั่งที่ค้นหา"
			noResult.TextColor3 = Color3.fromRGB(255,100,100)
			noResult.Font = Enum.Font.Gotham
			noResult.TextSize = 16
			noResult.Parent = scroll
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(updateResults)
	updateResults()
end, 1)

getgenv().KeyURL = "https://raw.githubusercontent.com/wino444/DarkAdmin/main/key%20connect.lua"
getgenv().ServerURL = nil

local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

-- ดึง URL จาก KeyURL
local function fetchRawURL()
    local success, content = pcall(function() return game:HttpGet(getgenv().KeyURL, true) end)
    if not success or not content or content == "" or content:match("^%s*$") then
        print("ดึงคีย์ล้มเหลว!")
        return false
    end

    content = content:gsub("^%s+", ""):gsub("%s+$", ""):gsub("\r", ""):gsub("\n", "")
    local url = content:match("(wss?://[%w%.%-%:]+)")

    if not url then
        print("ไม่พบ URL ในไฟล์!")
        return false
    end

    getgenv().ServerURL = url
    return true
end

-- WebSocket Detector
local wsApi = WebSocket or WebSocketClient or (syn and syn.websocket)
if not wsApi then
    warn("Executor ไม่รองรับ WebSocket!")
    local noWsGui = Instance.new("ScreenGui", PlayerGui)
    noWsGui.Name = "NoWebSocketWarning"
    local noWsLabel = Instance.new("TextLabel", noWsGui)
    noWsLabel.Size = UDim2.new(0.4, 0, 0.2, 0)
    noWsLabel.Position = UDim2.new(0.3, 0, 0.4, 0)
    noWsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    noWsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    noWsLabel.Text = "Executor ไม่รองรับ WebSocket!"
    noWsLabel.Font = Enum.Font.SourceSansBold
    noWsLabel.TextSize = 20
    task.delay(5, function() noWsGui:Destroy() end)
    return
end

-- ป้องกันรันซ้ำ
if PlayerGui:FindFirstChild("PhantomChatHub") then return end
if getgenv().PhantomChatHubLoaded then return end
getgenv().PhantomChatHubLoaded = true

local connection, connected = nil, false
local connectCooldown = false
local sendCooldown = false

local chatGui = nil
local chatOutputFrame = nil
local toggleButtonGui = nil
local OnlineCountLabel = nil
local ScrollingList = nil
local UIListLayout = nil
local usersTabFrame, usersTabBtn, chatTabFrame, settingsTabFrame, chatTabBtn, settingsTabBtn

local settings = {
    uiScale = 1,
    notificationEnabled = true
}

-- สร้าง UI (สีดำเขียวถาวร, ไม่มีธีม)
local function createChatUI()
    if chatGui and chatGui.Parent then return chatGui end
    local existing = PlayerGui:FindFirstChild("PhantomChatHub")
    if existing then chatGui = existing return chatGui end

    chatGui = Instance.new("ScreenGui")
    chatGui.Name = "PhantomChatHub"
    chatGui.ResetOnSpawn = false
    chatGui.Enabled = false
    chatGui.Parent = PlayerGui

    local chatFrame = Instance.new("Frame", chatGui)
    chatFrame.Size = UDim2.new(0.6 * settings.uiScale, 0, 0.7 * settings.uiScale, 0)
    chatFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    chatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    chatFrame.Active = true
    chatFrame.Draggable = true

    local title = Instance.new("TextLabel", chatFrame)
    title.Text = "Phantom Chat Hub(DA)"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 24

    -- แท็บบาร์
    local tabBar = Instance.new("Frame", chatFrame)
    tabBar.Size = UDim2.new(1, 0, 0.08, 0)
    tabBar.Position = UDim2.new(0, 0, 0.1, 0)
    tabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    chatTabBtn = Instance.new("TextButton", tabBar)
    chatTabBtn.Text = "แชทสาธารณะ"
    chatTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
    chatTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    chatTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatTabBtn.Font = Enum.Font.SourceSansBold
    chatTabBtn.TextSize = 18

    usersTabBtn = Instance.new("TextButton", tabBar)
    usersTabBtn.Text = "รายชื่อ"
    usersTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
    usersTabBtn.Position = UDim2.new(0.33, 0, 0, 0)
    usersTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    usersTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    usersTabBtn.Font = Enum.Font.SourceSansBold
    usersTabBtn.TextSize = 18

    settingsTabBtn = Instance.new("TextButton", tabBar)
    settingsTabBtn.Text = "ตั้งค่า"
    settingsTabBtn.Size = UDim2.new(0.34, 0, 1, 0)
    settingsTabBtn.Position = UDim2.new(0.66, 0, 0, 0)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    settingsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTabBtn.Font = Enum.Font.SourceSansBold
    settingsTabBtn.TextSize = 18

    -- แท็บแชท
    chatTabFrame = Instance.new("Frame", chatFrame)
    chatTabFrame.Size = UDim2.new(1, 0, 0.82, 0)
    chatTabFrame.Position = UDim2.new(0, 0, 0.18, 0)
    chatTabFrame.BackgroundTransparency = 1
    chatTabFrame.Visible = true

    chatOutputFrame = Instance.new("ScrollingFrame", chatTabFrame)  
    chatOutputFrame.Name = "ChatScroll"  
    chatOutputFrame.Size             = UDim2.new(1, -20, 0.65, -10)  
    chatOutputFrame.Position         = UDim2.new(0, 10, 0, 5)  
    chatOutputFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  
    chatOutputFrame.BorderSizePixel  = 0  
    chatOutputFrame.CanvasSize       = UDim2.new(0, 0, 0, 0)  
    chatOutputFrame.ScrollBarThickness = 8  
    chatOutputFrame.BackgroundTransparency = 0.1  
    pcall(function() chatOutputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y end)  

    local chatListLayout = Instance.new("UIListLayout", chatOutputFrame)
    chatListLayout.Padding = UDim.new(0, 6)
    chatListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local chatInput = Instance.new("TextBox", chatTabFrame)
    chatInput.PlaceholderText = "พิมพ์ข้อความแชท..."
    chatInput.Size = UDim2.new(0.7, -10, 0.1, 0)
    chatInput.Position = UDim2.new(0, 10, 0.78, 5)
    chatInput.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    chatInput.TextColor3 = Color3.fromRGB(0, 255, 255)
    chatInput.Font = Enum.Font.SourceSans
    chatInput.TextSize = 18

    local sendBtn = Instance.new("TextButton", chatTabFrame)
    sendBtn.Text = "ส่ง"
    sendBtn.Size = UDim2.new(0.3, -10, 0.1, 0)
    sendBtn.Position = UDim2.new(0.7, 0, 0.78, 5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.SourceSansBold
    sendBtn.TextSize = 18

    sendBtn.MouseButton1Click:Connect(function()
        if sendCooldown then return end
        if not connection or not connected then return end
        sendCooldown = true
        task.delay(2, function() sendCooldown = false end)

        local msg = chatInput.Text
        if msg == "" then return end

        connection:Send("chat " .. msg)
        chatInput.Text = ""
    end)

    -- แท็บรายชื่อ (ทุกคนเห็นปุ่ม แต่เปิดได้เฉพาะ VIP+)
    usersTabFrame = Instance.new("Frame", chatFrame)
    usersTabFrame.Size = UDim2.new(1, 0, 0.82, 0)
    usersTabFrame.Position = UDim2.new(0, 0, 0.18, 0)
    usersTabFrame.BackgroundTransparency = 1
    usersTabFrame.Visible = false

    OnlineCountLabel = Instance.new("TextLabel", usersTabFrame)
    OnlineCountLabel.BackgroundTransparency = 1
    OnlineCountLabel.Position = UDim2.new(0, 10, 0, 5)
    OnlineCountLabel.Size = UDim2.new(1, -20, 0, 40)
    OnlineCountLabel.Font = Enum.Font.GothamBold
    OnlineCountLabel.Text = "DA ออนไลน์: 0 คน "
    OnlineCountLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    OnlineCountLabel.TextSize = 20

    ScrollingList = Instance.new("ScrollingFrame", usersTabFrame)
    ScrollingList.Position = UDim2.new(0, 10, 0, 50)
    ScrollingList.Size = UDim2.new(1, -20, 1, -60)
    ScrollingList.BackgroundTransparency = 1
    ScrollingList.BorderSizePixel = 0
    ScrollingList.ScrollBarThickness = 6
    ScrollingList.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
    ScrollingList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingList.ScrollingEnabled = true

    UIListLayout = Instance.new("UIListLayout", ScrollingList)
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- แท็บตั้งค่า
    settingsTabFrame = Instance.new("Frame", chatFrame)
    settingsTabFrame.Size = UDim2.new(1, 0, 0.82, 0)
    settingsTabFrame.Position = UDim2.new(0, 0, 0.18, 0)
    settingsTabFrame.BackgroundTransparency = 1
    settingsTabFrame.Visible = false

    local settingsScroll = Instance.new("ScrollingFrame", settingsTabFrame)
    settingsScroll.Size = UDim2.new(1, -20, 1, -10)
    settingsScroll.Position = UDim2.new(0, 10, 0, 5)
    settingsScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    settingsScroll.BackgroundTransparency = 0.1
    settingsScroll.BorderSizePixel = 0
    settingsScroll.ScrollBarThickness = 8
    settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local settingsList = Instance.new("UIListLayout", settingsScroll)
    settingsList.Padding = UDim.new(0, 10)
    settingsList.SortOrder = Enum.SortOrder.LayoutOrder

    -- UI Scale
    local uiLabel = Instance.new("TextLabel", settingsScroll)
    uiLabel.Size = UDim2.new(1, 0, 0, 30)
    uiLabel.BackgroundTransparency = 1
    uiLabel.Text = "UI Scale: " .. settings.uiScale
    uiLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    uiLabel.Font = Enum.Font.SourceSans
    uiLabel.TextSize = 18

    local uiBox = Instance.new("TextBox", uiLabel)
    uiBox.Size = UDim2.new(0.3, 0, 1, 0)
    uiBox.Position = UDim2.new(0.7, 0, 0, 0)
    uiBox.Text = tostring(settings.uiScale)
    uiBox.FocusLost:Connect(function()
        local n = tonumber(uiBox.Text)
        if n and n >= 0.8 and n <= 1.5 then
            settings.uiScale = n
            chatFrame.Size = UDim2.new(0.6 * n, 0, 0.7 * n, 0)
            uiLabel.Text = "UI Scale: " .. n
        else
            uiBox.Text = tostring(settings.uiScale)
        end
    end)

    -- Notification Toggle
    local notifLabel = Instance.new("TextLabel", settingsScroll)
    notifLabel.Size = UDim2.new(1, 0, 0, 30)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "แจ้งเตือนข้อความใหม่: " .. (settings.notificationEnabled and "เปิด" or "ปิด")
    notifLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    notifLabel.Font = Enum.Font.SourceSans
    notifLabel.TextSize = 18

    local notifToggle = Instance.new("TextButton", notifLabel)
    notifToggle.Size = UDim2.new(0.2, 0, 1, 0)
    notifToggle.Position = UDim2.new(0.8, 0, 0, 0)
    notifToggle.Text = "Toggle"
    notifToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notifToggle.MouseButton1Click:Connect(function()
        settings.notificationEnabled = not settings.notificationEnabled
        notifLabel.Text = "แจ้งเตือนข้อความใหม่: " .. (settings.notificationEnabled and "เปิด" or "ปิด")
    end)

    -- สลับแท็บ (ตรวจสอบสิทธิ์ทุกครั้งที่กดแท็บรายชื่อ)
    local function switchTab(tab)
        if tab == "users" then
            local DA = getgenv().DarkAdmin
            if not DA or not DA.SafeGetPlayerRank then
                showNotification("ยังไม่โหลด DarkAdmin!")
                return
            end

            local rank = DA.SafeGetPlayerRank(LocalPlayer)
            if rank < DA.Ranks.VIP then
                showNotification("คุณไม่มีสิทธิ์ดูรายชื่อราชันย์ \nต้องเป็น VIP หรือ TempVIP เท่านั้น!", 6)
                return
            end
        end

        chatTabFrame.Visible = (tab == "chat")
        usersTabFrame.Visible = (tab == "users")
        settingsTabFrame.Visible = (tab == "settings")

        chatTabBtn.BackgroundColor3 = (tab == "chat") and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
        usersTabBtn.BackgroundColor3 = (tab == "users") and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
        settingsTabBtn.BackgroundColor3 = (tab == "settings") and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)
    end

    chatTabBtn.MouseButton1Click:Connect(function() switchTab("chat") end)
    usersTabBtn.MouseButton1Click:Connect(function() switchTab("users") end)
    settingsTabBtn.MouseButton1Click:Connect(function() switchTab("settings") end)

    -- ปุ่มเปิด/ปิด UI (ลากได้)
    if not toggleButtonGui or not toggleButtonGui.Parent then
        toggleButtonGui = Instance.new("ScreenGui")
        toggleButtonGui.Name = "ToggleChatButton"
        toggleButtonGui.ResetOnSpawn = false
        toggleButtonGui.Parent = PlayerGui

        local toggleButton = Instance.new("TextButton", toggleButtonGui)
        toggleButton.Size = UDim2.new(0, 50, 0, 50)
        toggleButton.Position = UDim2.new(1, -60, 0, 10)
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        toggleButton.Text = "Chat"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.Font = Enum.Font.SourceSansBold
        toggleButton.TextSize = 20
        toggleButton.BorderSizePixel = 0

        Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)

        -- ทำให้ลากได้
        local dragging = false
        local dragInput, dragStart, startPos

        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = toggleButton.Position
            end
        end)

        toggleButton.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        toggleButton.MouseButton1Click:Connect(function()
            chatGui.Enabled = not chatGui.Enabled
            toggleButton.Text = chatGui.Enabled and "Close" or "Chat"
            if chatGui.Enabled then switchTab("chat") end
        end)
    end

    return chatGui
end

-- Notification
local lastNotifTime = 0
local function showNotification(text)
    if tick() - lastNotifTime < 3 then return end
    lastNotifTime = tick()

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "PhantomNotification"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = PlayerGui

    local notifFrame = Instance.new("Frame", notifGui)
    notifFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
    notifFrame.Position = UDim2.new(0.35, 0, 0.05, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifFrame.BorderSizePixel = 0

    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)

    local notifLabel = Instance.new("TextLabel", notifFrame)
    notifLabel.Size = UDim2.new(1, 0, 1, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = text
    notifLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    notifLabel.Font = Enum.Font.SourceSansBold
    notifLabel.TextSize = 20
    notifLabel.TextWrapped = true

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9113391805"
    sound.Volume = 0.5
    sound.Parent = SoundService
    sound:Play()

    task.delay(3, function()
        sound:Destroy()
        notifGui:Destroy()
    end)
end

-- เพิ่มข้อความแชท
local function addChatMessage(text)
    if not chatOutputFrame then return end
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -10, 0, 24)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    msgLabel.Font = Enum.Font.Code
    msgLabel.TextSize = 16
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.Text = tostring(text)
    msgLabel.Parent = chatOutputFrame

    if not chatGui.Enabled and settings.notificationEnabled then
        showNotification("มีข้อความมาใหม่!")
    end

    pcall(function()
        chatOutputFrame.CanvasPosition = Vector2.new(0, chatOutputFrame.AbsoluteCanvasSize.Y)
    end)
end

-- อัปเดตจำนวนออนไลน์
local function updateOnlineCount(count)
    if OnlineCountLabel then
        OnlineCountLabel.Text = "DA ออนไลน์: " .. count .. " คน "
    end
end

-- อัปเดตรายชื่อ
local function updateUserList(message)
    if not ScrollingList or not UIListLayout then return end
    for _, child in pairs(ScrollingList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    for line in message:gmatch("[^\n]+") do
        if line:find("รายชื่อราชันย์") or line:find("รวมทั้งหมด") or line:find("ราชวงศ์") or line:find("ความมืดยังว่างเปล่า") then
            continue
        end

        local name = line:match("%*%*(.-)%*%*")
        if name then
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 24)
            l.BackgroundTransparency = 1
            l.Text = name
            l.TextColor3 = Color3.fromRGB(255, 120, 120)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 18
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.Parent = ScrollingList
        end
    end

    ScrollingList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- handleMessage
local function handleMessage(msg)
    if not msg then return end

    local success, data = pcall(HttpService.JSONDecode, HttpService, msg)
    if success and type(data) == "table" then
        if data.type == "auth_success" then
            task.delay(1, function()
                if connected and connection then
                    connection:Send("!listonline")
                    connection:Send("!online")
                end
            end)
        elseif data.chat then
            addChatMessage(data.chat)
        elseif data.type == "online_count" then
            updateOnlineCount(data.total or 0)
        elseif data.type == "online_full_list" and data.message then
            updateOnlineCount(data.total or 0)
            updateUserList(data.message)
        end
    else
        if type(msg) == "string" and msg:find(":") then
            addChatMessage(msg)
        end
    end
end

-- connect
createChatUI()
function connectToHub()
    if connection and connected then return end
    if connectCooldown then return end
    connectCooldown = true
    task.delay(3, function() connectCooldown = false end)

    if not getgenv().ServerURL then
        if not fetchRawURL() then
            task.wait(5)
            connectToHub()
            return
        end
    end

    local success, sock = pcall(wsApi.connect, getgenv().ServerURL)
    if not success or not sock then
        task.wait(5)
        connectToHub()
        return
    end

    connection, connected = sock, true

    if connection.OnMessage then
        connection.OnMessage:Connect(function(raw) pcall(handleMessage, raw) end)
    else
        task.spawn(function()
            while connected do
                local ok, msg = pcall(function() return connection:Recv() end)
                if ok and msg then pcall(handleMessage, msg) end
                task.wait(0.1)
            end
        end)
    end

    connection.OnClose:Connect(function()
        connected = false
        task.wait(3)
        connectToHub()
    end)

    local auth = {name = Players.LocalPlayer.Name, userId = Players.LocalPlayer.UserId}
    connection:Send(HttpService:JSONEncode(auth))
end

-- อัปเดตทุก 20 วินาที (ใช้แค่ 1 ลูป)
task.spawn(function()
    while true do
        task.wait(20)
        if connected and connection and connection.Send then
            pcall(function() connection:Send("!online") end)
            task.wait(3)
            pcall(function() connection:Send("!listonline") end)
        end
    end
end)

-- เริ่มเชื่อมต่อ
task.spawn(function()
    fetchRawURL()
    task.wait(1)
    connectToHub()
end)

--// FINALIZE
DA.CoreLoaded = true
printDebug("CORE โหลดสำเร็จ! Version:", DA.VersionDA)

return true
