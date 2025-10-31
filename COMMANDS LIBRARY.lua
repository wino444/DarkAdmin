-- COMMANDS LIBRARY.lua
-- ตรวจสอบคีย์ wino444 ก่อนทำงาน

local DA = getgenv().DarkAdmin

-- ตรวจสอบว่ามี wino444 หรือไม่
if not DA.wino444 then
	warn("การเข้าถึงถูกปฏิเสธ — ไม่มีคีย์ wino444 (ไม่ได้โหลดผ่าน CORE)")
	return
end

-- ฟังก์ชันเพิ่มคำสั่ง
function DA.AddCommand(name, desc, callback)
	DA.Commands[name:lower()] = { desc = desc, func = callback }
end

-- คำสั่ง !cmds
DA.AddCommand("!cmds", "แสดงรายการคำสั่งทั้งหมด", function()
	local screenGui = DA.UI
	local existing = screenGui:FindFirstChild("CmdsUI")
	if existing then existing:Destroy() end

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
	game:GetService("UserInputService").InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local y = 0
	for name, data in pairs(DA.Commands) do
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1,-10,0,45)
		entry.Position = UDim2.new(0,5,0,y)
		entry.BackgroundColor3 = Color3.fromRGB(25,25,35)
		entry.Parent = scroll

		local ec = Instance.new("UICorner")
		ec.CornerRadius = UDim.new(0,6)
		ec.Parent = entry

		local n = Instance.new("TextLabel")
		n.Size = UDim2.new(0.4,0,1,0)
		n.BackgroundTransparency = 1
		n.Text = name
		n.TextColor3 = Color3.fromRGB(0,255,150)
		n.Font = Enum.Font.Code
		n.TextXAlignment = Enum.TextXAlignment.Left
		n.TextSize = 16
		n.Parent = entry

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
		d.Parent = entry

		y = y + 50
	end
	scroll.CanvasSize = UDim2.new(0,0,0,y)
end)

DA.AddCommand("!to", "ยังไม่กำหนดฟังก์ชัน", function() end)
DA.AddCommand("!fly", "ยังไม่กำหนดฟังก์ชัน", function() end)

print("COMMANDS LIBRARY โหลดแล้ว! ผ่านการยืนยัน wino444")
