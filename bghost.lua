-- 🔥 Exploiter's TouchFire Script 🔥
-- Target: workspace.Ghost.UpperTorso.TouchInterest

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

-- ถ้าเปิด kaienshield → ชั่วคราวยกเว้น UpperTorso ของ Ghost
if getgenv().KaienProtectEnabled then
	getgenv().ApplyKaienShield(upperTorso) -- ป้องกันทุกอย่าง ยกเว้น Ghost ตัวนี้
end

-- 🚀 ยิงสัมผัสทันที!
firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart, upperTorso, 0)
task.wait()
firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart, upperTorso, 1)

-- หลังดึงเสร็จ → กลับไปป้องกันเต็ม (ไม่ต้อง exclude)
task.delay(0.5, function()
	if getgenv().KaienProtectEnabled then
		getgenv().ApplyKaienShield() -- ป้องกันทุกอย่างอีกครั้ง
	end
end)
