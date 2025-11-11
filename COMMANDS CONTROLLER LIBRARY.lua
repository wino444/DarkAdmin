--// 3. COMMANDS CONTROLLER LIBRARY.lua v7 (VIP ปลดล็อกเต็มรูปแบบ + ทุกคนรับได้!)

local DA = getgenv().DarkAdmin
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function printDebug(...) if DA.DADebug then print("[CONTROLLER DEBUG]", ...) end end

print("CONTROLLER LIBRARY v7 โหลดแล้ว – VIP ปลดล็อกเต็มรูปแบบ!")

local ControlledCommands = {}

-- เพิ่มคำสั่งควบคุม
local function AddControlledCommand(name, callback, minRank)
	name = name:lower()
	ControlledCommands[name] = { func = callback, rank = minRank or 1 }
	printDebug("เพิ่มคำสั่งควบคุม:", name)
end

-- === ฟังแชทของทุกคนด้วย plr.Chatted:Connect ===
local function SetupGlobalChatListener()
	if getgenv().GlobalChatListener then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		plr.Chatted:Connect(function(msg)
			if not msg or msg:sub(1,1) ~= "!" then return end

			local lowerMsg = string.lower(msg)
			local cmdName, args = string.match(lowerMsg, "^!([^%s]+)%s*(.*)$")
			if not cmdName then return end

			local cmd = ControlledCommands[cmdName]
			if not cmd then return end

			local senderRank = DA.SafeGetPlayerRank(plr)  -- ใช้ SafeGetPlayerRank (รวม Owner + TempVIP)
			if senderRank < cmd.rank then
				printDebug(plr.Name.." พยายามใช้ "..cmdName.." แต่ Rank ไม่ถึง")
				return
			end

			printDebug(plr.Name.." ใช้ !"..cmdName.." → รันฝั่งเรา")
			spawn(function()
				cmd.func(plr, args, LocalPlayer)
			end)
		end)
	end

	Players.PlayerAdded:Connect(function(plr)
		plr.Chatted:Connect(function(msg)
			if not msg or msg:sub(1,1) ~= "!" then return end

			local lowerMsg = string.lower(msg)
			local cmdName, args = string.match(lowerMsg, "^!([^%s]+)%s*(.*)$")
			if not cmdName then return end

			local cmd = ControlledCommands[cmdName]
			if not cmd then return end

			local senderRank = DA.SafeGetPlayerRank(plr)
			if senderRank < cmd.rank then
				printDebug(plr.Name.." พยายามใช้ "..cmdName.." แต่ Rank ไม่ถึง")
				return
			end

			printDebug(plr.Name.." ใช้ !"..cmdName.." → รันฝั่งเรา")
			spawn(function()
				cmd.func(plr, args, LocalPlayer)
			end)
		end)
	end)

	getgenv().GlobalChatListener = true
end

-- === ระบบ TempVIP 2 แบบ (อัปเดตทุก 10 วิ) ===
local function CheckTempVIPExpiry()
	for uid, value in pairs(DA.TempVIP) do
		if type(value) == "number" then
			if os.time() >= value then
				DA.TempVIP[uid] = nil
				local plr = Players:GetPlayerByUserId(uid)
				if plr and plr == LocalPlayer then
					DA.Notify("DarkAdmin", "TempVIP ของคุณหมดอายุแล้ว ⏰", 4)
				end
				printDebug("TempVIP หมดอายุสำหรับ UserId: "..uid)
			end
		end
	end
end

spawn(function()
	while true do
		task.wait(10)
		if DA.CoreLoaded then CheckTempVIPExpiry() end
	end
end)

-- !givevip ชื่อเต็ม [วินาที] → ทุกคนรับได้! (ไม่ต้องอยู่ใน RankDB)
AddControlledCommand("givevip", function(sender, args, receiver)
	local targetName, timeStr = args:match("^(%S+)%s*(%d*)$")
	if not targetName then 
		DA.Notify("DarkAdmin","ใช้: !givevip <ชื่อ> [วินาที]",3); return 
	end
	if receiver.Name:lower() ~= targetName:lower() then return end

	-- อนุญาตให้ Owner และ VIP ให้ได้
	local senderRank = DA.SafeGetPlayerRank(sender)
	if senderRank < DA.Ranks.VIP then
		DA.Notify("DarkAdmin","ต้องเป็น VIP+ หรือ Owner!",3); return
	end

	local expiryTime
	if timeStr and tonumber(timeStr) and tonumber(timeStr) > 0 then
		expiryTime = os.time() + tonumber(timeStr)
		DA.TempVIP[receiver.UserId] = expiryTime
		local mins = math.floor(tonumber(timeStr)/60)
		local secs = tonumber(timeStr) % 60
		DA.Notify("DarkAdmin", 
			"ได้รับ VIP ชั่วคราวจาก "..sender.DisplayName.."! ⏳\nหมดอายุใน "..
			(mins > 0 and mins.." นาที " or "")..
			(secs > 0 and secs.." วินาที" or ""), 
			6
		)
	else
		DA.TempVIP[receiver.UserId] = true
		DA.Notify("DarkAdmin","ได้รับ VIP ชั่วคราวจาก "..sender.DisplayName.."! ✅\n(หายตอนออกเกม)", 5)
	end

	printDebug(receiver.Name.." ได้รับ TempVIP จาก "..sender.Name..(expiryTime and " (หมดอายุ)" or ""))
end, DA.Ranks.VIP)

-- !removevip
AddControlledCommand("removevip", function(sender, args, receiver)
	local targetName = args:match("^%S+")
	if not targetName or receiver.Name:lower() ~= targetName:lower() then return end

	if DA.TempVIP[receiver.UserId] then
		DA.TempVIP[receiver.UserId] = nil
		DA.Notify("DarkAdmin","VIP ชั่วคราวถูกถอนโดย "..sender.DisplayName.." ❌",4)
	end
end, DA.Ranks.VIP)

-- !clearvip
AddControlledCommand("clearvip", function(sender, _, receiver)
	if DA.SafeGetPlayerRank(sender) < DA.Ranks.Owner then return end
	DA.TempVIP = {}
	DA.Notify("DarkAdmin","ล้าง TempVIP ทั้งหมดโดย "..sender.DisplayName.." 🧹",4)
end, DA.Ranks.Owner)

SetupGlobalChatListener()

printDebug("CONTROLLER v7 โหลดสำเร็จ – VIP ปลดล็อกเต็มรูปแบบ!")
