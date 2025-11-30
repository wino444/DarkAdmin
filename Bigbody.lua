getgenv().addAllBackAccessories = function()
    local Catalog = game:GetService("ReplicatedStorage").BloxbizRemotes.CatalogOnApplyToRealHumanoid
    local ids = {121360936156823,118799338103138,107852478332182,101379144205559,80628080423002}
    for _,id in pairs(ids) do
        local args = {
            [1] = {
                ["AccessoryData"] = {  -- ✅ ซ่อมตรงนี้! ต้องมี "AccessoryData"
                    Order = 1,
                    AccessoryType = Enum.AccessoryType.Back,
                    AssetId = id
                }
            }
        }
        Catalog:FireServer(unpack(args))  -- ✅ ใช้ unpack(args) เหมือน SimpleSpy
        wait()
    end
    print("🎉 ทั้งหมดเสร็จ! 👑✨")
end
getgenv().addAllBackAccessories() -- 🚀 รันเลย!
print("⏳ รอ 2 วินาที... เตรียม Custom Rig! ⚙️")
task.wait(2)

-- 🎭 **Custom Rig Configuration - พร้อมครองเซิร์ฟ!** 🎭
_G.HideCharacter = true      -- ซ่อนตัวตน! 👻
_G.FlingEnabled = false      -- ไม่ต้อง Fling! 🛡️
_G.TransparentRig = true     -- โปร่งใสแบบ Ghost! 👻
_G.ToolFling = false         -- ถือ Tool ไว้! 🛠️
_G.AntiFling = false         -- ป้องกัน Fling! 🛡️
_G.CustomHats = true         -- เปิด Custom Hats! 🎩
_G.Scale = 4.2               -- ขนาดยักษ์! 🦖

_G.CH = {
    Torso = {
        Name = "Accessory (Torso)",
        TextureId = "83269599235494",
        Orientation = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
    },
    RightArm = {
        Name = "Accessory (RArm)",
        TextureId = "103757531289975",
        Orientation = CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    LeftArm = {
        Name = "Accessory (LArm)",
        TextureId = "103757531289975",
        Orientation = CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    RightLeg = {
        Name = "Accessory (RLeg)",
        TextureId = "83269599235494",
        Orientation = CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    LeftLeg = {
        Name = "Accessory (LLeg)",
        TextureId = "83269599235494",
        Orientation = CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    Head = {
        Name = "Accessory (big head)", 
        Orientation = CFrame.new(),
    }
}

print("📥 โหลด Oxide Perma... รอสักครู่! ⏳")
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nitro-GT/Oxide/refs/heads/main/LoadstringPerma"))()
task.wait(0.5)
