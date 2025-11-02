-- LocalScript (StarterGui)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("BloxbizRemotes"):WaitForChild("CatalogOnApplyToRealHumanoid")
local UserInputService = game:GetService("UserInputService")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "ScaleChanger"

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Name = "MainFrame"
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ปรับขนาดตัว (ทีละส่วน) ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- ฟังก์ชันสร้าง Slider
local function CreateSlider(name, yPos, min, max, default)
	local Frame = Instance.new("Frame", MainFrame)
	Frame.Size = UDim2.new(0.9, 0, 0, 50)
	Frame.Position = UDim2.new(0.05, 0, yPos, 0)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.Position = UDim2.new(0, 0, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name .. ": " .. default
	Label.TextColor3 = Color3.fromRGB(200, 200, 200)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local SliderBG = Instance.new("Frame", Frame)
	SliderBG.Size = UDim2.new(1, 0, 0, 8)
	SliderBG.Position = UDim2.new(0, 0, 0.6, 0)
	SliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	SliderBG.BorderSizePixel = 0
	Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(0, 4)

	local SliderFill = Instance.new("Frame", SliderBG)
	SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	SliderFill.BorderSizePixel = 0
	Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

	local SliderButton = Instance.new("TextButton", SliderBG)
	SliderButton.Size = UDim2.new(0, 18, 2.5, 0)
	SliderButton.Position = UDim2.new((default - min) / (max - min), -9, -0.75, 0)
	SliderButton.Text = ""
	SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SliderButton.AutoButtonColor = false
	Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(1, 0)

	local dragging = false
	local value = default

	SliderButton.MouseButton1Down:Connect(function()
		dragging = true
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	game:GetService("RunService").RenderStepped:Connect(function()
		if dragging then
			local mouseX = UserInputService:GetMouseLocation().X
			local sliderPos = SliderBG.AbsolutePosition.X
			local sliderSize = SliderBG.AbsoluteSize.X
			local ratio = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)
			value = min + (max - min) * ratio
			SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
			SliderButton.Position = UDim2.new(ratio, -9, -0.75, 0)
			Label.Text = string.format("%s: %.2f", name, value)
		end
	end)

	return function() return value end
end

-- Sliders
local GetHeight = CreateSlider("Height", 0.15, 0.5, 1.5, 1)
local GetWidth = CreateSlider("Width", 0.3, 0.5, 1.5, 1)
local GetDepth = CreateSlider("Depth", 0.45, 0.5, 1.5, 1)
local GetBodyType = CreateSlider("BodyType", 0.6, 0, 1.5, 1)
local GetProportion = CreateSlider("Proportion", 0.75, 0, 1.5, 1)
-- ปุ่ม Apply
local ApplyBtn = Instance.new("TextButton", MainFrame)
ApplyBtn.Size = UDim2.new(0.4, 0, 0, 35)
ApplyBtn.Position = UDim2.new(0.1, 0, 0.9, 0)
ApplyBtn.Text = "Apply"
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.TextSize = 18
ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 10)

-- ปุ่ม Reset
local ResetBtn = Instance.new("TextButton", MainFrame)
ResetBtn.Size = UDim2.new(0.4, 0, 0, 35)
ResetBtn.Position = UDim2.new(0.55, 0, 0.9, 0)
ResetBtn.Text = "Reset"
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 18
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 10)

-- กด Apply
ApplyBtn.MouseButton1Click:Connect(function()
	local args = {
		{
			BodyScale = {
				HeightScale = GetHeight(),
				WidthScale = GetWidth(),
				DepthScale = GetDepth(),
				BodyTypeScale = GetBodyType(),
				ProportionScale = GetProportion(),
				HeadScale = 1
			}
		}
	}
	Remote:FireServer(unpack(args))
end)

-- กด Reset
ResetBtn.MouseButton1Click:Connect(function()
	local args = {
		{
			BodyScale = {
				HeightScale = 1,
				WidthScale = 1,
				DepthScale = 1,
				BodyTypeScale = 1,
				ProportionScale = 1,
				HeadScale = 1
			}
		}
	}
	Remote:FireServer(unpack(args))
end)
