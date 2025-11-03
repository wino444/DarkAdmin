--// 2. COMMANDS LIBRARY.lua (ทุกคำสั่ง rank=1 ยกเว้น invis aura=2)

local DA = getgenv().DarkAdmin
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

-- กำหนดระดับยศ
DA.Ranks = { Normal = 1, VIP = 2, Owner = 3 }
DA.TempVIP = DA.TempVIP or {}

local function printDebug(...)
	if DA.DADebug then print("[DarkAdmin DEBUG]", ...) end
end

if not DA or not DA.wino444 then
    getgenv().DarkAdmin = nil
    warn("การเข้าถึงถูกปฏิเสธ — ไม่มีคีย์")
    return
end

print("ผ่านการยืนยัน(COMMANDS LIBRARY)")

-- ใช้ SafeGetPlayerRank จาก CORE
local function GetPlayerRank(plr)
	return getgenv().DarkAdmin.SafeGetPlayerRank(plr)
end

-- ปรับปรุง DA.AddCommand: rank default = 1
function DA.AddCommand(name, desc, callback, rank)
	rank = rank or 1
	DA.Commands[name:lower()] = { desc = desc, func = callback, rank = rank }
	printDebug("เพิ่มคำสั่งใน LIBRARY:", name, "ระดับ:", rank)
end

-- ฟังก์ชันส่งข้อความไปยัง RBXGeneral
getgenv().sendMessage = function(msg)
	local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if channel then
		channel:SendAsync(msg)
	else
		warn("❌ ไม่พบแชนเนล RBXGeneral")
	end
end

-- คำสั่ง givevip (rank 2)
DA.AddCommand("givevip", "มอบ VIP ชั่วคราวให้ผู้เล่น (ชื่อเต็ม)", function(targetName)
	local myRank = GetPlayerRank(Players.LocalPlayer)
	if myRank < DA.Ranks.VIP then
		DA.Notify("DarkAdmin", "ต้องเป็น VIP ขึ้นไปถึงใช้ได้", 3)
		return
	end

	if not targetName or #targetName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อผู้เล่นเต็ม", 3)
		return
	end

	local target
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name == targetName then
			target = plr
			break
		end
	end

	if not target then
		DA.Notify("DarkAdmin", "ไม่พบผู้เล่น: "..targetName, 3)
		return
	end

	getgenv().sendMessage("givevip "..targetName)
	DA.Notify("DarkAdmin", "ส่งคำขอ VIP ไปยัง "..targetName, 2)
end, 2)

-- คำสั่ง removevip (rank 1)
DA.AddCommand("removevip", "ถอน VIP ชั่วคราว (ชื่อเต็ม)", function(targetName)
	local myRank = GetPlayerRank(Players.LocalPlayer)
	if myRank < DA.Ranks.VIP then
		DA.Notify("DarkAdmin", "ต้องเป็น VIP ขึ้นไปถึงใช้ได้", 3)
		return
	end

	if not targetName or #targetName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อผู้เล่นเต็ม", 3)
		return
	end

	getgenv().sendMessage("removevip "..targetName)
	DA.Notify("DarkAdmin", "ส่งคำขอถอน VIP ไปยัง "..targetName, 2)
end, 2)

-- ตัวรับคำสั่งจากแชท
local function LoadVIPChatListener()
	if getgenv().VIPChatListener then return end
	getgenv().VIPChatListener = TextChatService.MessageReceived:Connect(function(message)
		local text = message.Text
		local sender = message.TextSource
		if not sender or not text then return end

		local senderPlr = Players:GetPlayerByUserId(sender.UserId)
		if not senderPlr then return end

		if text:lower():sub(1, 7) == "givevip " then
			local targetName = text:sub(8)
			if targetName == Players.LocalPlayer.Name then
				local senderRank = GetPlayerRank(senderPlr)
				if senderRank >= DA.Ranks.VIP then
					DA.TempVIP[Players.LocalPlayer.UserId] = true
					DA.Notify("DarkAdmin", "ได้รับ VIP ชั่วคราวจาก "..senderPlr.Name.."!", 3)
				end
			end
		elseif text:lower():sub(1, 9) == "removevip " then
			local targetName = text:sub(10)
			if targetName == Players.LocalPlayer.Name and DA.TempVIP[Players.LocalPlayer.UserId] then
				local senderRank = GetPlayerRank(senderPlr)
				if senderRank >= DA.Ranks.VIP then
					DA.TempVIP[Players.LocalPlayer.UserId] = nil
					DA.Notify("DarkAdmin", "VIP ชั่วคราวถูกถอนโดย "..senderPlr.Name, 3)
				end
			end
		end
	end)
end

LoadVIPChatListener()

-- โหลด OUTFIT STEALER MODULE
local function LoadStealer()
	if not getgenv().StealOutfit or not getgenv().StealClosestOutfit then
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/OUTFIT%20MODULE.lua"))()
		end)
		if not success then
			warn("โหลด Stealer ล้มเหลว:", err)
			return false
		end
	end
	return true
end

-- โหลด CUFF MODULE
local function LoadCuffModule()
	if not getgenv().Cuff or not getgenv().CuffAll then
		printDebug("กำลังโหลด CUFF MODULE จาก GitHub...")
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/CUFF%20MODULE.lua"))()
		end)
		if not success then
			warn("โหลด CUFF MODULE ล้มเหลว: ", err)
			return false
		end
		printDebug("โหลด CUFF MODULE สำเร็จ!")
	end
	return true
end

-- โหลด SAFE GUN MODULE
local function LoadSafeGunModule()
	if not getgenv().SafeGun or not getgenv().UnSafeGun then
		printDebug("กำลังโหลด SAFE GUN MODULE จาก GitHub...")
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/SAFE%20GUN%20MODULE.lua"))()
		end)
		if not success then
			warn("โหลด SAFE GUN MODULE ล้มเหลว: ", err)
			return false
		end
		printDebug("โหลด SAFE GUN MODULE สำเร็จ!")
	end
	return true
end

DA.AddCommand("prefix", "เปลี่ยน Prefix (เช่น: !prefix #)", function(newPrefix)
	if not newPrefix or #newPrefix == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุ Prefix ใหม่", 3)
		return
	end
	DA.Prefix = newPrefix
	printDebug("เปลี่ยน Prefix เป็น:", DA.Prefix)
	DA.Notify("DarkAdmin", "Prefix เปลี่ยนเป็น: "..DA.Prefix, 3)
end, 1)

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

	local myRank = GetPlayerRank(Players.LocalPlayer)

	local function updateResults()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local query = string.lower(searchBox.Text or "")
		local y = 0
		local count = 0

		for name, data in pairs(DA.Commands) do
			if data.rank <= myRank then  -- แสดงเฉพาะที่ใช้ได้
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

DA.AddCommand("to", "วาร์ปไปหาผู้เล่น (ชื่อบางส่วน)", function(targetName)
	if not targetName or #targetName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อผู้เล่น", 3)
		return
	end

	local LocalPlayer = Players.LocalPlayer
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
		DA.Notify("DarkAdmin", "ตัวละครคุณยังไม่โหลด", 3)
		return
	end

	local targetPlayer
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and (string.find(string.lower(plr.Name), string.lower(targetName)) or string.find(string.lower(plr.DisplayName), string.lower(targetName))) then
			targetPlayer = plr
			break
		end
	end

	if not targetPlayer then
		DA.Notify("DarkAdmin", "ไม่พบผู้เล่น: "..targetName, 3)
		return
	end

	local targetChar = targetPlayer.Character
	if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
		DA.Notify("DarkAdmin", "ตัวละครเป้าหมายยังไม่โหลด", 3)
		return
	end

	myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame
	DA.Notify("DarkAdmin", "วาร์ปไปหา "..targetPlayer.DisplayName.." แล้ว!", 2)
end, 1)


-- KaienShield
getgenv().KaienProtectEnabled = false
local protectedParts = {}

local function ApplyKaienShield()
	local Players = game:GetService("Players")
	if not Players.LocalPlayer or not Players.LocalPlayer.Character then return end

	table.clear(protectedParts)

	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and part:FindFirstChild("TouchInterest") then
			local parentModel = part:FindFirstAncestorWhichIsA("Model")
			local shouldProtect = false

			if parentModel then
				if part.Name == "Fire" and parentModel.Name == "Switch" then
					shouldProtect = true
				elseif parentModel.Name == "Ghost" then
					shouldProtect = true
				end
			end

			if shouldProtect and not protectedParts[part] then
				protectedParts[part] = part.CanTouch
				pcall(function()
					part.CanTouch = false
				end)
			end
		end
	end
end

local function RestoreProtectedParts()
	for part, original in pairs(protectedParts) do
		if part and part.Parent then
			pcall(function()
				part.CanTouch = original
			end)
		end
	end
	table.clear(protectedParts)
end

getgenv().KaienProtect = function(enable)
	if enable == nil then return getgenv().KaienProtectEnabled end

	if enable then
		if getgenv().KaienProtectEnabled then return end
		getgenv().KaienProtectEnabled = true

		task.spawn(function()
			repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
			ApplyKaienShield()
			DA.Notify("DarkAdmin", "KaienProtect เปิดแล้ว! ปิดสัมผัสไฟ + ผีทั้งหมด", 2)
		end)
	else
		if not getgenv().KaienProtectEnabled then return end
		getgenv().KaienProtectEnabled = false
		RestoreProtectedParts()
		DA.Notify("DarkAdmin", "KaienProtect ปิดแล้ว! คืนสัมผัสเดิม", 2)
	end
end

DA.AddCommand("kaienshield", "เปิด/ปิดป้องกันไฟใน Switch + ผีทุก Part (ถาวร)", function(arg)
	if arg == "on" or arg == "true" then
		getgenv().KaienProtect(true)
	elseif arg == "off" or arg == "false" then
		getgenv().KaienProtect(false)
	else
		getgenv().KaienProtect(not getgenv().KaienProtect())
		local status = getgenv().KaienProtect() and "เปิด" or "ปิด"
		DA.Notify("DarkAdmin", "KaienShield: "..status, 2)
	end
end, 1)

DA.AddCommand("fly", "ยังไม่กำหนดฟังก์ชัน", function() end, 1)

printDebug("LIBRARY โหลดสำเร็จ! VersionDA =", DA.VersionDA)
