-- UI แจ้งเตือนแบบกำหนดเอง (เวอร์ชั่นเต็ม)

if not getgenv then error("ต้องใช้ Executor ที่รองรับ getgenv()") end

getgenv().CustomNotify = getgenv().CustomNotify or {
	UI = nil,
	Container = nil
}

local CN = getgenv().CustomNotify
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- สร้าง UI หลัก
local function createNotifyUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CustomNotifyUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	CN.UI = screenGui

	CN.Container = Instance.new("Frame")
	CN.Container.Name = "NotifyContainer"
	CN.Container.Size = UDim2.new(0, 300, 0, 0)
	CN.Container.Position = UDim2.new(1, -320, 0, 20)
	CN.Container.BackgroundTransparency = 1
	CN.Container.Parent = screenGui

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.Padding = UDim.new(0, 10)
	list.Parent = CN.Container
end

-- ฟังก์ชันแสดงแจ้งเตือน
function CN.Show(title, text, duration)
	duration = duration or 3

	local notify = Instance.new("Frame")
	notify.Size = UDim2.new(1, 0, 0, 70)
	notify.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	notify.BorderSizePixel = 0
	notify.Parent = CN.Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notify

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 25)
	titleLabel.Position = UDim2.new(0, 10, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Notify"
	titleLabel.TextColor3 = Color3.fromRGB(200, 0, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notify

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 0, 30)
	textLabel.Position = UDim2.new(0, 10, 0, 33)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text or ""
	textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 14
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextWrapped = true
	textLabel.Parent = notify

	notify.Position = UDim2.new(1, 20, 0, 0)
	local enter = TweenService:Create(notify, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0)})
	enter:Play()

	delay(duration, function()
		local exit = TweenService:Create(notify, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 0)})
		exit:Play()
		exit.Completed:Wait()
		notify:Destroy()
	end)
end

-- สร้าง UI
if not CN.UI then
	createNotifyUI()
end

print("CUSTOM NOTIFY โหลดแล้ว! ใช้ CN.Show('หัวข้อ', 'ข้อความ', เวลา)")
