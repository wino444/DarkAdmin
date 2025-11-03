--// RANK_DB.lua (โมดูลฐานข้อมูลยศ - เก็บเฉพาะชื่อคนที่มียศ 2=VIP และ 3=Owner)
-- โหลดจาก: https://raw.githubusercontent.com/wino444/DarkAdmin/main/RANK_DB.lua

local RankDB = {
	-- { Name = "ชื่อผู้ใช้", Rank = ระดับ (3 = Owner, 2 = VIP) }
	-- **ไม่มีระดับ 1 (Normal)** - เก็บเฉพาะคนพิเศษเท่านั้น!

	-- === OWNER (ระดับ 3) ===
	{ Name = "wino444", Rank = 3 },
	{ Name = "ojhvhknhj", Rank = 3 },

	-- === VIP (ระดับ 2) ===
	{ Name = "ezwin", Rank = 2 },
	{ Name = "vip_player1", Rank = 2 },
	{ Name = "pro_exploiter", Rank = 2 },
}

-- ตารางชื่อ → ระดับ (ค้นหาเร็วสุด - ไม่ต้องวนลูปทุกครั้ง)
local NameToRank = {}
for _, data in ipairs(RankDB) do
	if data.Name then
		NameToRank[string.lower(data.Name)] = data.Rank
	end
end

-- ฟังก์ชัน: หาระดับจากชื่อ (case-insensitive)
local function GetRankByName(name)
	name = string.lower(name)
	return NameToRank[name] or 1  -- ถ้าไม่มีใน DB → Normal (1)
end

-- ฟังก์ชัน: หา UserId จากชื่อ (ไม่มีไอดีแล้ว → คืน nil)
local function FindUserIdByName(name)
	return nil  -- ไม่มี UserId ใน DB
end

-- ส่งออก
return {
	DB = RankDB,
	GetRankByName = GetRankByName,
	FindUserIdByName = FindUserIdByName,
	NameToRank = NameToRank
}
