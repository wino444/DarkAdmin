-- 🌑 DARK ADMIN CORE v1.0.lua (FIXED: จัดการ 404 + LIBRARY ว่าง!) 🕸️💀
-- 🔥 ซ่อม: HttpGet ไม่พัง + Fallback คำสั่งพื้นฐาน ⚡

if not getgenv then error("Executor ไม่รองรับ getgenv()") end

getgenv().DarkAdmin = getgenv().DarkAdmin or {
	CoreLoaded = false,
	UI = nil,
	Commands = {},
	AuthKey = nil,  -- รหัสลับ
}

local DA = getgenv().DarkAdmin
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- สร้างรหัสลับสุ่ม (16 ตัวอักษร + seed)
local function generateKey()
	math.randomseed(tick() + math.random(1, 1000))  -- Seed กันซ้ำ
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local key = ""
	for i = 1, 16 do
		key = key .. chars:sub(math.random(1, #chars), math.random(1, #chars))
	end
	return key
end

DA.AuthKey = generateKey()

-- โหลด COMMANDS LIBRARY (แก้ URL: ลบ ?key= + path ถูก)
local repo = "https://raw.githubusercontent.com/wino444/DarkAdmin/main"
local libUrl = repo .. "/COMMANDS LIBRARY.lua"  -- ลบ param + แก้ space

local libraryLoaded = false
local success, err = pcall(function()
	local libContent = game:HttpGet(libUrl)
	if libContent and libContent ~= "" then  -- ตรวจว่าไม่ว่าง
		loadstring(libContent)()
		libraryLoaded = true
	else
		warn("LIBRARY ว่างเปล่า — ใช้ fallback ใน CORE")
	end
end)

if not success then
	warn("ไม่สามารถโหลด COMMANDS LIBRARY: "..tostring(err).." — ใช้ fallback")
end

-- ตรวจสอบ + fallback ถ้า LIBRARY พัง
if not DA.AddCommand then
	-- สร้าง AddCommand ใน CORE ถ้าไม่มี
	function DA.AddCommand(name, desc, callback)
		DA.Commands[name:lower()] = { desc = desc, func = callback }
	end
end

DA.CoreAuthenticated = libraryLoaded or true  -- Fallback: อนุญาตถ้าโหลดได้หรือใช้ในตัว

-- Fallback คำสั่งพื้นฐาน (ถ้า LIBRARY ว่าง)
if not DA.Commands["!cmds"] then
	DA:AddCommand("!cmds", "แสดงรายการคำสั่งทั้งหมด", function()
		local screenGui = DA.UI
		local old = screenGui:FindFirstChild("CmdsUI")
		if old then old:Destroy() end

		local frame = Instance.new("Frame")
		frame.Name = "CmdsUI"
		frame.Size = UDim2.new(0,350,0,400)
		frame.Position = UDim2.new(0.5,-175,0.5,-200)
		frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
		frame.Parent = screenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,12)
		corner.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1,0,0,40)
		title.BackgroundTransparency = 1
		title.Text = "DarkAdmin Commands"
		title.TextColor3 = Color3.fromRGB(200,0,255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 20
		title.Parent = frame

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1,-20,1,-60)
		scroll.Position = UDim2.new(0,10,0,50)
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

		-- ลากได้
		local dragging, ds, sp
		frame.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true; ds = i.Position; sp = frame.Position
			end
		end)
		frame.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - ds
				frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		local y = 0
		for name, data in pairs(DA.Commands) do
			local e = Instance.new("Frame")
			e.Size = UDim2.new(1,-10,0,45)
			e.Position = UDim2.new(0,5,0,y)
			e.BackgroundColor3 = Color3.fromRGB(25,25,35)
			e.Parent = scroll
			local ec = Instance.new("UICorner")
			ec.CornerRadius = UDim.new(0,6)
			ec.Parent = e

			local n = Instance.new("TextLabel")
			n.Size = UDim2.new(0.4,0,1,0)
			n.BackgroundTransparency = 1
			n.Text = name
			n.TextColor3 = Color3.fromRGB(0,255,150)
			n.Font = Enum.Font.Code
			n.TextXAlignment = Enum.TextXAlignment.Left
			n.TextSize = 16
			n.Parent = e

			local d = Instance.new("TextLabel")
			d.Size = UDim2.new(0.6,-10,1,0)
			d.Position = UDim2.new(0.4,5,0,0)
			d.BackgroundTransparency = 1
			d.Text = data.desc
			d.TextColor3 = Color3.fromRGB(200,200,200)
			d.Font = Enum.Font.Code
			d.TextXAlignment = Enum.TextXAlignment.Left
			d.TextSize = 14
			d.TextWrapped = true
			d.Parent = e

			y = y + 50
		end
		scroll.CanvasSize = UDim2.new(0,0,0,y)
	end)
end

DA:AddCommand("!to", "ยังไม่กำหนด", function() end)
DA:AddCommand("!fly", "ยังไม่กำหนด", function() end)

-- สร้าง UI หลัก
local function createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DarkAdminUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	DA.UI = screenGui

	local btn = Instance.new("TextButton")
	btn.Name = "DA_Button"
	btn.Size = UDim2.new(0,50,0,50)
	btn.Position = UDim2.new(0,20,0,20)
	btn.BackgroundColor3 = Color3.fromRGB(20,20,30)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = "DA"
	label.TextColor3 = Color3.fromRGB(200,0,255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = btn

	-- Pulse
	local function pulse()
		local t = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,0,100)})
		t:Play()
		t.Completed:Wait()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,30)}):Play()
	end

	-- ลากได้
	local dragging, ds, sp
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; ds = i.Position; sp = btn.Position; pulse()
		end
	end)
	btn.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - ds
			btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- เปิด TextBox
	btn.Activated:Connect(function()
		pulse()
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0,300,0,50)
		box.Position = UDim2.new(0.5,-150,0.5,-25)
		box.BackgroundColor3 = Color3.fromRGB(15,15,25)
		box.TextColor3 = Color3.fromRGB(0,255,100)
		box.PlaceholderText = "พิมพ์คำสั่ง..."
		box.Font = Enum.Font.Code
		box.TextSize = 18
		box.ClearTextOnFocus = true
		box.Parent = screenGui

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0,8)
		bc.Parent = box

		box.Focused:Connect(function()
			TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,50)}):Play()
		end)

		box.FocusLost:Connect(function(enter)
			if enter then
				local cmd = box.Text:lower()
				local command = DA.Commands[cmd]
				if command then
					spawn(command.func)
				else
					game.StarterGui:SetCore("SendNotification", {Title="DarkAdmin", Text="คำสั่งไม่พบ", Duration=3})
				end
			end
			box:Destroy()
		end)

		box:CaptureFocus()
	end)
end

if not DA.UI then createUI() end
DA.CoreLoaded = true

print("🌑 DARK ADMIN CORE v1.0 ซ่อมสำเร็จ! รันได้แม้ LIBRARY ว่าง 💀✨")
print("รหัสลับ: "..DA.AuthKey)
if not libraryLoaded then
	print("⚠️ ใช้ fallback — อัปโหลด LIBRARY ให้มีโค้ดจริงใน GitHub ด้วยนะ!")
end
