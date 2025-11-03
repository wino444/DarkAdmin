local RankDB = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/DarkAdmin/main/RANK_DATA.lua"))()

-- สร้าง NameToRank (ค้นหาเร็วสุด!)
local NameToRank = {}
for _, data in ipairs(RankDB) do
	if data.Name then
		NameToRank[string.lower(data.Name)] = data.Rank
	end
end

-- ฟังก์ชัน: หาระดับจากชื่อ
local function GetRankByName(name)
	name = string.lower(name)
	return NameToRank[name] or 1  -- ไม่มีใน DB → Normal
end

-- ฟังก์ชัน: หา UserId (ไม่มีแล้ว)
local function FindUserIdByName()
	return nil
end

-- ส่งออก
return {
	DB = RankDB,
	GetRankByName = GetRankByName,
	FindUserIdByName = FindUserIdByName,
	NameToRank = NameToRank
}
