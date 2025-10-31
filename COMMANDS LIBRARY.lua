
-- COMMANDS LIBRARY.lua
-- ต้องผ่าน DARK ADMIN CORE + รหัสลับเท่านั้น!

local DA = getgenv().DarkAdmin
if not DA then return end

-- ดึงรหัสลับจาก URL
local url = debug.info(1, "s") -- ไม่ได้จริง แต่ใช้แทน
local args = {}
for arg in (game:HttpGetAsync(url):gmatch("[^&]+")) do
	local k, v = arg:match("([^=]+)=([^&]+)")
	if k then args[k] = v end
end

local receivedKey = args.key
if not receivedKey or receivedKey ~= DA.AuthKey then
	warn("การเข้าถึง COMMANDS LIBRARY ถูกปฏิเสธ — ไม่มีรหัสลับ!")
	return
end

-- ยืนยันตัวตนสำเร็จ
DA.CoreAuthenticated = true

function DA.AddCommand(name, desc, callback)
	DA.Commands[name:lower()] = { desc = desc, func = callback }
end

-- คำสั่ง !cmds
DA.AddCommand("!cmds", "แสดงรายการคำสั่งทั้งหมด", function()
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

DA.AddCommand("!to", "ยังไม่กำหนด", function() end)
DA.AddCommand("!fly", "ยังไม่กำหนด", function() end)

print("COMMANDS LIBRARY โหลดสำเร็จ — ผ่านการยืนยันตัวตน!")
