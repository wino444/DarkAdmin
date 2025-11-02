-- 🔥 Exploiter's TouchFire Script 🔥
-- Target: workspace.Ghost.UpperTorso.TouchInterest

local target = workspace:WaitForChild("Ghost", 5) -- รอ Ghost โหลด
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

-- 🚀 ยิงสัมผัสทันที!
firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, upperTorso, 0)
wait() -- รอให้ trigger
firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, upperTorso, 1)
