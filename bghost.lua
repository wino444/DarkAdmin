-- bghost.lua (GitHub)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local target = workspace:FindFirstChild("Ghost")
if not target then 
    warn("❌ Ghost หายไปในความมืด... ไม่เจอใน workspace!")
    return 
end

local upperTorso = target:FindFirstChild("UpperTorso")
if not upperTorso or not upperTorso:IsA("BasePart") then 
    warn("💀 UpperTorso หายตัวไปแล้วว่ะ!")
    return 
end

local touch = upperTorso:FindFirstChild("TouchInterest") or upperTorso:FindFirstChildWhichIsA("TouchTransmitter")
if not touch then 
    warn("⚠️ ไม่เจอ TouchInterest! อาจถูก Anti-Touch ลบไปแล้ว!")
    return 
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart", 5)
if not hrp then return end

-- ปลดล็อก CanTouch (ถ้าถูกปิด)
pcall(function() upperTorso.CanTouch = true end)

-- ยิงสัมผัส
pcall(function()
    firetouchinterest(hrp, upperTorso, 0)
    task.wait()
    firetouchinterest(hrp, upperTorso, 1)
end)
