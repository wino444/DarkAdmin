-- 🔥 Exploiter's TouchFire Script 🔥
-- Target: workspace.Ghost.UpperTorso.TouchInterest

-- 🔥 แก้ไขสคริปต์ดึงผี: เพิ่ม Players + LocalPlayer + ป้องกัน nil (ส่งเฉพาะส่วนที่ซ่อม) 🔥

local Players = game:GetService("Players")  -- เพิ่มตรงนี้!
local LocalPlayer = Players.LocalPlayer

local target = workspace:WaitForChild("Ghost", 5)
if not target then 
    warn("❌ Ghost หายไปในความมืด... ไม่เจอใน workspace!")
    return 
end

local upperTorso = target:WaitForChild("UpperTorso", 3)
if not upperTorso then 
    warn("💀 UpperTorso หายตัวไปแล้วว่ะ!")
    return 
end

local touchInterest = upperTorso:FindFirstChild("TouchInterest")
if not touchInterest then 
    warn("⚠️ ไม่เจอ TouchInterest! อาจถูก Anti-Touch ลบไปแล้ว!")
    return 
end

-- รอ Character + HRP (ป้องกัน nil)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ถ้าเปิด kaienshield → ชั่วคราวยกเว้น UpperTorso ของ Ghost
if getgenv().KaienProtectEnabled and getgenv().ApplyKaienShield then
	getgenv().ApplyKaienShield(upperTorso) -- ป้องกันทุกอย่าง ยกเว้น Ghost ตัวนี้
end

-- 🚀 ยิงสัมผัสทันที!
firetouchinterest(hrp, upperTorso, 0)
task.wait()
firetouchinterest(hrp, upperTorso, 1)

-- หลังดึงเสร็จ → กลับไปป้องกันเต็ม
task.delay(0.5, function()
	if getgenv().KaienProtectEnabled and getgenv().ApplyKaienShield then
		getgenv().ApplyKaienShield() -- ป้องกันทุกอย่างอีกครั้ง
	end
end)
