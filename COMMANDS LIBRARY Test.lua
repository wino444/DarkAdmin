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

-- ตารางของที่เก็บได้ (ชื่อภาษาอังกฤษจริง + ชื่อแสดงไทย + ราคา)
local ItemDB = {
	-- { EnglishName, ThaiName, Price }
	{ "Tom Yum Kung", "ต้มยำกุ้ง", "ฟรี" },
	{ "Somtum", "ส้มตำ", "ฟรี" },
	{ "Fried Rice", "ข้าวผัด", "ฟรี" },
	{ "Grilled Fish Veg & Peppers", "ปลาย่างผักและพริก", "ฟรี" },
	{ "Bok Choy Oyster Sauce", "ผักกวางตุ้งน้ำมันหอย", "ฟรี" },
	{ "Girlled Pork", "หมูย่าง", "ฟรี" },
	{ "Chinese steamed dumpling", "เกี๊ยวซ่า", "ฟรี" },
	{ "Steamed stuff bun", "ซาลาเปา", "ฟรี" },
	{ "Sausage", "ไส้กรอก", "ฟรี" },
	{ "LazyChip", "เลซี่ชิป", "ฟรี" },
	{ "M4", "M4", "ฟรี" },
	{ "Revolver", "รีวอลเวอร์", "ฟรี" },
	{ "Gun", "ปืน", "ฟรี" },
	{ "Elitoria RZ750", "Elitoria RZ750", "ฟรี" },
	{ "Elitoria RN750", "Elitoria RN750", "ฟรี" },
	{ "Eltoria RX750", "Eltoria RX750", "ฟรี" },
	{ "Eltoria RS750", "Eltoria RS750", "ฟรี" },
	{ "Police Car", "รถตำรวจ", "ฟรี" },
	{ "Tube", "ท่อ", "ฟรี" },
	{ "Folding Fan", "พัดลมพับ", "ฟรี" },
	{ "Bowl", "ชาม", "ฟรี" },
	{ "Broom", "ไม้กวาด", "ฟรี" },
	{ "BlueLight", "ไฟสีฟ้า", "ฟรี" },
	{ "WhiteLight", "ไฟสีขาว", "ฟรี" },
	{ "GreenLight", "ไฟสีเขียว", "ฟรี" },
	{ "YellowLight", "ไฟสีเหลือง", "ฟรี" },
	{ "RedLight", "ไฟสีแดง", "ฟรี" },
	{ "PinkLight", "ไฟสีชมพู", "ฟรี" },
	{ "VioletLight", "ไฟสีม่วง", "ฟรี" },
	{ "Handcuff", "กุญแจมือ", "ฟรี" },
	{ "Boombox", "บูมบ็อกซ์", "ฟรี" },
	{ "Spray", "สเปรย์", "ฟรี" },
	{ "SlurpeeBig", "สเลอปี้ใหญ่", "ฟรี" },
	{ "Fireflies", "หิ่งห้อย", "ฟรี" },
	{ "Syringe", "เข็มฉีดยา", "ฟรี" },
	{ "Stethoscope", "หูฟังแพทย์", "ฟรี" },
	{ "Pickaxe", "จอบ", "ฟรี" }
}

-- คำสั่ง: get [ชื่อไอเท็ม] (ใช้ชื่ออังกฤษ)
DA.AddCommand("get", "หยิบไอเท็มตามชื่อ (เช่น: get M4)", function(itemName)
	if not itemName or #itemName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อไอเท็ม", 3)
		return
	end
	if not getgenv().AutoCollectModule or not getgenv().AutoCollectModule.CollectItemByName then
		DA.Notify("DarkAdmin", "CollectModule ยังไม่โหลด", 4)
		return
	end

	-- ค้นหาชื่ออังกฤษจากชื่อที่พิมพ์ (case-insensitive)
	local foundEngName = nil
	for _, item in ipairs(ItemDB) do
		if string.lower(item[1]) == string.lower(itemName) then
			foundEngName = item[1]
			break
		end
	end

	if not foundEngName then
		DA.Notify("DarkAdmin", "ไม่พบไอเท็ม: "..itemName, 4)
		return
	end

	local success, err = pcall(function()
		getgenv().AutoCollectModule.CollectItemByName(foundEngName)
	end)
	if success then
		DA.Notify("DarkAdmin", "กำลังหยิบ "..foundEngName.."...", 2)
	else
		DA.Notify("DarkAdmin", "หยิบ "..foundEngName.." ล้มเหลว: "..tostring(err), 4)
	end
end, 1)

-- คำสั่ง: givetool → เปิด UI (แสดงชื่อไทย + ชื่ออังกฤษ + ราคาเด่นชัด!)
DA.AddCommand("givetool", "เปิด UI เลือกของที่เก็บได้", function()
	local screenGui = DA.UI
	local existing = screenGui:FindFirstChild("GiveToolUI")
	if existing then existing:Destroy() end

	local frame = Instance.new("Frame")
	frame.Name = "GiveToolUI"
	frame.Size = UDim2.new(0, 400, 0, 520)  -- ขยายกว้างขึ้นนิด
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	-- เงา
	local shadow = Instance.new("Frame")
	shadow.Size = UDim2.new(1, 6, 1, 6)
	shadow.Position = UDim2.new(0, -3, 0, -3)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.7
	shadow.ZIndex = frame.ZIndex - 1
	shadow.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "🎁 Give Tool - เลือกของ"
	title.TextColor3 = Color3.fromRGB(200, 0, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.Parent = frame

	-- ช่องค้นหา
	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1, -30, 0, 40)
	searchBox.Position = UDim2.new(0, 15, 0, 55)
	searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	searchBox.PlaceholderText = "🔍 ค้นหาไอเท็ม..."
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
	searchBox.Font = Enum.Font.Code
	searchBox.TextSize = 16
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = frame

	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0, 10)
	sc.Parent = searchBox

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -30, 1, -115)
	scroll.Position = UDim2.new(0, 15, 0, 100)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 0, 180)
	scroll.BorderSizePixel = 0
	scroll.Parent = frame

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = scroll

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 36, 0, 36)
	close.Position = UDim2.new(1, -48, 0, 8)
	close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	close.Text = "✖"
	close.TextColor3 = Color3.fromRGB(255, 100, 100)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 20
	close.AutoButtonColor = false
	close.Parent = frame

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 12)
	cc.Parent = close

	close.Activated:Connect(function()
		frame:Destroy()
	end)

	-- ลาก UI
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- ฟังก์ชันอัปเดต UI (แก้ priceLabel ให้แสดงชัด!)
	local function updateUI()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local query = string.lower(searchBox.Text or "")
		local yOffset = 0

		for _, item in ipairs(ItemDB) do
			local engName, thaiName, price = item[1], item[2], item[3]
			local searchText = string.lower(thaiName.." "..engName)

			if query == "" or string.find(searchText, query) then
				local entry = Instance.new("Frame")
				entry.Size = UDim2.new(1, 0, 0, 70)  -- สูงขึ้นนิด
				entry.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
				entry.BorderSizePixel = 0
				entry.Parent = scroll

				local ec = Instance.new("UICorner")
				ec.CornerRadius = UDim.new(0, 10)
				ec.Parent = entry

				-- ชื่อไทย
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Size = UDim2.new(0.55, 0, 0.5, 0)
				nameLabel.Position = UDim2.new(0, 12, 0, 5)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Text = "🎯 "..thaiName
				nameLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
				nameLabel.Font = Enum.Font.Code
				nameLabel.TextSize = 17
				nameLabel.TextXAlignment = Enum.TextXAlignment.Left
				nameLabel.Parent = entry

				-- ชื่ออังกฤษ
				local engLabel = Instance.new("TextLabel")
				engLabel.Size = UDim2.new(0.55, 0, 0.5, 0)
				engLabel.Position = UDim2.new(0, 12, 0.5, 0)
				engLabel.BackgroundTransparency = 1
				engLabel.Text = "📛 "..engName
				engLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
				engLabel.Font = Enum.Font.Code
				engLabel.TextSize = 14
				engLabel.TextXAlignment = Enum.TextXAlignment.Left
				engLabel.Parent = entry

				-- === ราคาเด่นชัด! (ย้ายไปขวา ไม่ทับปุ่ม) ===
				local priceLabel = Instance.new("TextLabel")
				priceLabel.Size = UDim2.new(0.3, -100, 1, 0)  -- กว้างพอ ไม่ทับปุ่ม
				priceLabel.Position = UDim2.new(0.55, 0, 0, 0)
				priceLabel.BackgroundTransparency = 1
				priceLabel.Text = price == "ฟรี" and "🆓 ฟรี" or "💰 "..price
				priceLabel.TextColor3 = price == "ฟรี" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 215, 0)
				priceLabel.Font = Enum.Font.GothamBold
				priceLabel.TextSize = 18
				priceLabel.TextXAlignment = Enum.TextXAlignment.Right
				priceLabel.TextYAlignment = Enum.TextYAlignment.Center
				priceLabel.Parent = entry

				-- ปุ่มหยิบ (ขยับซ้ายนิด)
				local getBtn = Instance.new("TextButton")
				getBtn.Size = UDim2.new(0, 80, 0, 36)
				getBtn.Position = UDim2.new(1, -92, 0.5, -18)
				getBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
				getBtn.Text = "หยิบ"
				getBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				getBtn.Font = Enum.Font.GothamBold
				getBtn.TextSize = 15
				getBtn.AutoButtonColor = false
				getBtn.Parent = entry

				local bc = Instance.new("UICorner")
				bc.CornerRadius = UDim.new(0, 8)
				bc.Parent = getBtn

				getBtn.Activated:Connect(function()
					if getgenv().AutoCollectModule and getgenv().AutoCollectModule.CollectItemByName then
						spawn(function()
							getgenv().AutoCollectModule.CollectItemByName(engName)
							DA.Notify("DarkAdmin", "หยิบ "..thaiName.." แล้ว! 🛠️", 2)
						end)
					else
						DA.Notify("DarkAdmin", "CollectModule ไม่พร้อม", 3)
					end
				end)

				yOffset = yOffset + 78
			end
		end

		scroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	end

	-- อัปเดตเมื่อพิมพ์
	searchBox:GetPropertyChangedSignal("Text"):Connect(updateUI)
	updateUI() -- ครั้งแรก
end, 1)

DA.AddCommand("copyclosest", "คัดลอกเสื้อจากคนที่อยู่ใกล้สุด", function()
	if not LoadStealer() then
		DA.Notify("DarkAdmin", "โหลด Stealer ล้มเหลว", 4)
		return
	end
	spawn(function()
		local success = getgenv().StealClosestOutfit()
		if success then
			DA.Notify("DarkAdmin", "คัดลอกชุดจากคนใกล้สุดแล้ว!", 3)
		else
			DA.Notify("DarkAdmin", "ไม่สามารถคัดลอกชุดได้", 3)
		end
	end)
end, 1)

DA.AddCommand("copyoutfit", "คัดลอกเสื้อจากชื่อผู้เล่น (เช่น: copyoutfit wino)", function(targetName)
	if not targetName or #targetName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อผู้เล่น", 3)
		return
	end
	if not LoadStealer() then
		DA.Notify("DarkAdmin", "โหลด Stealer ล้มเหลว", 4)
		return
	end
	spawn(function()
		local success = getgenv().StealOutfit(targetName)
		if success then
			DA.Notify("DarkAdmin", "คัดลอกชุดจาก "..targetName.." แล้ว!", 3)
		else
			DA.Notify("DarkAdmin", "ไม่สามารถคัดลอกชุดจาก "..targetName, 3)
		end
	end)
end, 1)

DA.AddCommand("cuff", "จับโจรด้วยชื่อ (เฉพาะ Star > 0)", function(targetName)
	if not targetName or #targetName == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุชื่อโจร", 3)
		return
	end
	if not LoadCuffModule() then
		DA.Notify("DarkAdmin", "โหลด CUFF MODULE ล้มเหลว", 4)
		return
	end
	spawn(function()
		local success = getgenv().Cuff(targetName)
		if success then
			DA.Notify("DarkAdmin", "จับโจร "..targetName.." สำเร็จ!", 3)
		else
			DA.Notify("DarkAdmin", "ไม่สามารถจับ "..targetName.." ได้", 3)
		end
	end)
end, 1)

DA.AddCommand("cuffall", "จับโจรทั้งหมด (เฉพาะ Star > 0)", function()
	if not LoadCuffModule() then
		DA.Notify("DarkAdmin", "โหลด CUFF MODULE ล้มเหลว", 4)
		return
	end
	spawn(function()
		local success = getgenv().CuffAll()
		if success then
			DA.Notify("DarkAdmin", "จับโจรทั้งหมดสำเร็จ!", 3)
		else
			DA.Notify("DarkAdmin", "ไม่พบโจรให้จับ", 3)
		end
	end)
end, 2)

-- คำสั่ง: dupegun → ดันปืนตามช่องว่าง + ดึงกลับ
DA.AddCommand("dupegun", "ดันปืนตามช่องว่าง + ดึงกลับ", function()
	if not getgenv().AutoCollectModule or not getgenv().AutoCollectModule.CollectItemByName then
		DA.Notify("DarkAdmin", "AutoCollectModule ไม่พร้อม", 4)
		return
	end

	local ToolEvent = ReplicatedStorage:WaitForChild("ToolStorage"):WaitForChild("ToolsStorage")
	local LocalPlayer = Players.LocalPlayer

	-- ดึงจำนวนช่องว่าง
	local function GetFreeSlots()
		local storage = LocalPlayer:FindFirstChild("storagetools")
		if not storage then return 0 end
		return math.max(0, 10 - #storage:GetChildren())
	end

	-- เก็บ + เซฟปืน
	local function CollectAndSaveGun()
		getgenv().AutoCollectModule.CollectItemByName("Gun")
		task.wait(0.2)

		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Gun") then
			character.Gun.Parent = LocalPlayer.Backpack
		end

		ToolEvent:FireServer("Save", "Gun")
	end

	-- วนเก็บตามช่องว่าง
	local freeSlots = GetFreeSlots()
	for i = 1, freeSlots do
		CollectAndSaveGun()
		task.wait(0.3)
	end

	-- ดึงกลับทีละตัว
	local storage = LocalPlayer:FindFirstChild("storagetools")
	if storage then
		for i = 1, #storage:GetChildren() do
			ToolEvent:FireServer("Get", "Gun")
			task.wait(0.1)
		end
	end

	DA.Notify("DarkAdmin", "ดัน + ดึง Gun สำเร็จ!", 3)
end, 1)

-- คำสั่ง: safegun → เปิด Safe Gun (ไม่คืนปืน)
DA.AddCommand("safegun", "เปิด Safe Gun (เก็บเมื่อตาย)", function()
	if not LoadSafeGunModule() then
		DA.Notify("DarkAdmin", "โหลด SAFE GUN ล้มเหลว", 4)
		return
	end
	getgenv().SafeGun(true)
	DA.Notify("DarkAdmin", "Safe Gun เปิดแล้ว!", 3)
end, 1)

-- คำสั่ง: unsafegun → ปิด Safe Gun
DA.AddCommand("unsafegun", "ปิด Safe Gun", function()
	if not LoadSafeGunModule() then
		DA.Notify("DarkAdmin", "โหลด SAFE GUN ล้มเหลว", 4)
		return
	end
	getgenv().UnSafeGun()
	DA.Notify("DarkAdmin", "Safe Gun ปิดแล้ว!", 3)
end, 1)

DA.AddCommand("spawnfirefly", "ปล่อยหิ่งห้อยจำนวน X (เช่น: !spawnfirefly 4000)", function(amount)
	if not amount or #amount == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุจำนวน (เช่น: !spawnfirefly 4000)", 3)
		return
	end
	
	local shots = tonumber(amount)
	if not shots or shots <= 0 then
		DA.Notify("DarkAdmin", "จำนวนไม่ถูกต้อง", 3)
		return
	end

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

	-- หาหรือ Equip Fireflies
	local function getFireflies()
		local tool = character:FindFirstChild("Fireflies")
		if not tool then
			local backpack = LocalPlayer:FindFirstChild("Backpack")
			if backpack and backpack:FindFirstChild("Fireflies") then
				tool = backpack.Fireflies
				tool.Parent = character
			end
		end
		return tool
	end

	-- ยิงตามจำนวน
	local function fireFast(shots)
		local tool = getFireflies()
		if not tool then
			DA.Notify("DarkAdmin", "ไม่มี Fireflies!", 3)
			return
		end

		task.spawn(function()
			for i = 1, shots do
				if tool and tool:FindFirstChild("RemoteEvent") then
					tool.RemoteEvent:FireServer()
				end
			end
			-- ปล่อย Tool หลังยิงครบ
			pcall(function()
				tool.Parent = LocalPlayer.Backpack
			end)
			DA.Notify("DarkAdmin", "ปล่อยหิ่งห้อย "..shots.." ตัว!", 2)
		end)
	end

	fireFast(shots)
end, 1)

local HouseRemote = game:GetService("ReplicatedStorage"):WaitForChild("House")

DA.AddCommand("sell", "ขายบ้านจำนวน X รอบ (เช่น: !sell 100)", function(amount)
	if not amount or #amount == 0 then
		DA.Notify("DarkAdmin", "กรุณาระบุจำนวนรอบ (เช่น: !Sell 100)", 3)
		return
	end

	local rounds = tonumber(amount)
	if not rounds or rounds <= 0 then
		DA.Notify("DarkAdmin", "จำนวนรอบไม่ถูกต้อง", 3)
		return
	end
	
	task.spawn(function()
		for i = 1, rounds do
			HouseRemote:FireServer("Sell")
		end
		DA.Notify("DarkAdmin", "ขายบ้านสำเร็จ "..rounds.." รอบ!", 2)
	end)
end, 1)

DA.AddCommand("boomcolor", "เปลี่ยนสี Boombox แบบวนลูป (เร็วสุด!)", function()
	-- ตรวจสอบ DRadio_Script
	local radioScript = workspace:FindFirstChild("DRadio_Script")
	if not radioScript then
		DA.Notify("DarkAdmin", "ไม่พบ DRadio_Script ใน Workspace!", 4)
		return
	end

	local colorRemote = radioScript:FindFirstChild("Color")
	if not colorRemote then
		DA.Notify("DarkAdmin", "ไม่พบ RemoteEvent 'Color'!", 4)
		return
	end

	-- ลิสต์สี
	local colors = {
		BrickColor.new(1013), -- Neon Orange
		BrickColor.new(331),  -- Bright yellow
		BrickColor.new(1020), -- Hot pink
		BrickColor.new(1016), -- Bright red
		BrickColor.new(1009), -- Bright green
		BrickColor.new(106),  -- Bright blue
		BrickColor.new(1015), -- Lavender
		BrickColor.new(330),  -- Bright violet
	}

	-- ตรวจสอบว่ากำลังรันอยู่หรือยัง
	if getgenv()._BoomboxLoopRunning then
		DA.Notify("DarkAdmin", "กำลังเปลี่ยนสีอยู่แล้ว!", 3)
		return
	end

	getgenv()._BoomboxLoopRunning = true

	DA.Notify("DarkAdmin", "เริ่มเปลี่ยนสี Boombox!", 2)

	task.spawn(function()
		while getgenv()._BoomboxLoopRunning do
			for _, color in ipairs(colors) do
				if not getgenv()._BoomboxLoopRunning then break end
				colorRemote:FireServer(color)
				task.wait(0.001) -- เร็วสุด!
			end
		end
	end)
end, 1)

DA.AddCommand("stopboom", "หยุดเปลี่ยนสี Boombox", function()
	if not getgenv()._BoomboxLoopRunning then
		DA.Notify("DarkAdmin", "ไม่ได้เปิดลูปอยู่", 3)
		return
	end

	getgenv()._BoomboxLoopRunning = false
	DA.Notify("DarkAdmin", "หยุดเปลี่ยนสีแล้ว!", 2)
end, 1)

DA.AddCommand("bghost", "ดึงผีมา(ตัวเราเอง)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/bghost.lua"))()
end, 1)

DA.AddCommand("getitemback", "เอาไอเทมกลับทุก 1 วิ เมื่อติดคุก", function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = Players.LocalPlayer

	local Remote = ReplicatedStorage:FindFirstChild("GetItemBack")
	if not Remote then
		DA.Notify("DarkAdmin", "ไม่พบ Remote: GetItemBack", 4)
		return
	end

	local InJail = LocalPlayer:FindFirstChild("InJail")
	if not InJail then
		DA.Notify("DarkAdmin", "ไม่มี InJail ในตัวละคร", 4)
		return
	end

	-- ปิดลูปเก่า (ถ้ามี)
	if getgenv()._GetItemBackLoop then
		getgenv()._GetItemBackLoop:Disconnect()
	end

	getgenv()._GetItemBackLoop = task.spawn(function()
		while task.wait(1) do
			if InJail.Value == true then
				Remote:FireServer()
			end
		end
	end)

	DA.Notify("DarkAdmin", "เปิด GetItemBack (Loop) ทุก 1 วิ!", 2)
end, 1)

DA.AddCommand("stopgetitem", "ปิดระบบเอาไอเทมกลับ", function()
	if getgenv()._GetItemBackLoop then
		getgenv()._GetItemBackLoop:Disconnect()
		getgenv()._GetItemBackLoop = nil
		DA.Notify("DarkAdmin", "ปิด GetItemBack แล้ว!", 2)
	else
		DA.Notify("DarkAdmin", "ไม่ได้เปิดระบบอยู่", 3)
	end
end, 1)

-- === ฟังก์ชันยิงรีโมท (แยกออกมา ใช้ได้หลายที่!) ===
getgenv().ApplyBodyScale = function(scales)
	local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("BloxbizRemotes")
	if not Remote then warn("ไม่พบ BloxbizRemotes") return end
	Remote = Remote:FindFirstChild("CatalogOnApplyToRealHumanoid")
	if not Remote then warn("ไม่พบ CatalogOnApplyToRealHumanoid") return end

	local args = {{
		["BodyScale"] = {
			["BodyTypeScale"] = scales.BodyTypeScale or 1,
			["DepthScale"] = scales.DepthScale or 1,
			["HeadScale"] = scales.HeadScale or 1,
			["HeightScale"] = scales.HeightScale or 1,
			["WidthScale"] = scales.WidthScale or 1,
			["ProportionScale"] = scales.ProportionScale or 0
		}
	}}

	Remote:FireServer(unpack(args))
end

DA.AddCommand("scale", "เปิด UI ปรับขนาดตัวละคร (เรียลไทม์)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/scale.lua"))()
end, 1)

DA.AddCommand("small", "ทำให้ตัวละครเล็ก (BodyTypeScale=0)", function()
	if not getgenv().ApplyBodyScale then
		DA.Notify("DarkAdmin", "ไม่พบฟังก์ชัน ApplyBodyScale! โหลด UI Scale ก่อน", 4)
		return
	end

	local smallScales = {
		BodyTypeScale = 0,
		DepthScale = 0.5,
		HeadScale = 0.5,
		HeightScale = 0.5,
		WidthScale = 0.5,
		ProportionScale = 0
	}

	getgenv().ApplyBodyScale(smallScales)
	DA.Notify("DarkAdmin", "ตัวเล็กแล้ว! (BodyTypeScale = 0)", 2)
end)

DA.AddCommand("tall", "ทำให้ตัวละครสูง (HeightScale=1.5)", function()
	if not getgenv().ApplyBodyScale then
		DA.Notify("DarkAdmin", "ไม่พบฟังก์ชัน ApplyBodyScale! โหลด UI Scale ก่อน", 4)
		return
	end

	local tallScales = {
		BodyTypeScale = 1,
		DepthScale = 1,
		HeadScale = 1,
		HeightScale = 1.5,
		WidthScale = 1,
		ProportionScale = 0
	}

	getgenv().ApplyBodyScale(tallScales)
	DA.Notify("DarkAdmin", "ตัวสูงแล้ว! (HeightScale = 1.5)", 2)
end, 1)




-- invis aura ระดับ 2
DA.AddCommand("invisaura", "เปิด UI Invisible Kill Aura (ซ่อนปืน + ไม่ขยับ)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/Kill%20Aura.lua"))()
end, 2)

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
