-- DARK ADMIN CORE v1.0 🕸️
-- ตัวหลัก: UI + getgenv + สร้างคีย์ wino444

if not getgenv then error("ต้องใช้ Executor ที่รองรับ getgenv()") end

getgenv().DarkAdmin = getgenv().DarkAdmin or {
	CoreLoaded = false,
	UI = nil,
	Commands = {},
}

local DA = getgenv().DarkAdmin
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- สร้างคีย์ wino444 ไว้ใน getgenv().DarkAdmin
DA.wino444 = true

-- โหลด COMMANDS LIBRARY
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/COMMANDS%20LIBRARY.lua"))()
end)
if not success then
	warn("ไม่สามารถโหลด COMMANDS LIBRARY: "..tostring(err))
	return
end

-- ตรวจสอบว่ามีฟังก์ชัน AddCommand หรือไม่
if not DA.AddCommand then
	error("COMMANDS LIBRARY ต้องมีฟังก์ชัน AddCommand")
end

-- ฟังก์ชันเพิ่มคำสั่ง
function DA.AddCommand(name, desc, callback)
	DA.Commands[name:lower()] = { desc = desc, func = callback }
end

-- สร้าง UI หลัก
local function createMainUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DarkAdminUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
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
		local t1 = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,0,100)})
		t1:Play()
		t1.Completed:Wait()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,30)}):Play()
	end

	local dragging, dragStart, startPos
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = btn.Position
			pulse()
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
					spawn(function() command.func() end)
				else
					game.StarterGui:SetCore("SendNotification", {Title="DarkAdmin", Text="คำสั่งไม่พบ", Duration=3})
				end
			end
			box:Destroy()
		end)

		box:CaptureFocus()
	end)
end

if not DA.UI then
	createMainUI()
end

DA.CoreLoaded = true
print("DARK ADMIN CORE v1.0 โหลดสำเร็จ! คีย์ wino444 ถูกสร้างแล้ว")
