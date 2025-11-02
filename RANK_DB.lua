--// RANK_DB.lua (โมดูลฐานข้อมูลยศ - ตรวจสอบเฉพาะชื่อ! ไอดีแค่ตกแต่ง)
-- โหลดจาก: https://raw.githubusercontent.com/wino444/DarkAdmin/main/RANK_DB.lua

local RankDB = {
	-- [UserId] = { Name = "ชื่อผู้ใช้", Rank = ระดับ (2 = VIP, 3 = Owner) }
	-- **ไอดีไม่บังคับใส่ครบทุกคน** - ถ้าไม่มีไอดี ก็ใส่แค่ชื่อได้เลย!

	-- เจ้าของหลัก (wino444) - ระดับ Owner
	[111111111] = { Name = "wino444", Rank = 3 },

	-- VIP ตัวอย่าง (บางคนมีไอดี บางคนไม่มี - ไม่เป็นไร!)
	[222222222] = { Name = "ezwin", Rank = 2 },
	-- [ไม่มีไอดี] = { Name = "vip_player1", Rank = 2 },  -- ใส่แบบนี้ได้! ระบบจะข้ามไอดี
	-- [ไม่มีไอดี] = { Name = "pro_exploiter", Rank = 2 },

	-- Owner เพิ่มเติม
	[555555555] = { Name = "ojhvhknhj", Rank = 3 },
}

-- ตารางชื่อ → ระดับ (สำหรับตรวจสอบเร็วสุด - ไม่ต้องวนลูปทุกครั้ง)
local NameToRank = {}
for userid, data in pairs(RankDB) do
	if data.Name then
		NameToRank[string.lower(data.Name)] = data.Rank
	end
end

-- ฟังก์ชันช่วย: หาระดับจากชื่อ (case-insensitive)
local function GetRankByName(name)
	name = string.lower(name)
	return NameToRank[name] or 1  -- Default: Normal (ระดับ 1)
end

-- ฟังก์ชันช่วย: หา UserId จากชื่อ (ถ้ามี)
local function FindUserIdByName(name)
	name = string.lower(name)
	for userid, data in pairs(RankDB) do
		if data.Name and string.lower(data.Name) == name then
			return userid
		end
	end
	return nil
end

-- ส่งออก
return {
	DB = RankDB,
	GetRankByName = GetRankByName,
	FindUserIdByName = FindUserIdByName,
	NameToRank = NameToRank
}
