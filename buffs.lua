local flasks = {
	["Flask of Endless Rage"] = true,
	["Flask of Pure Mojo"] = true,
	["Flask of Stoneblood"] = true,
	["Flask of the Frost Wyrm"] = true,
	["Lesser Flask of Toughness"] = true,
	["Lesser Flask of Resistance"] = true,
	["Flask of Arcane Fortification"] = true,
	["Chromatic Resistance"] = true,
	["Distilled Wisdom"] = true,
	["Flask of Fortification"] = true,
	["Flask of Mighty Restoration"] = true,
	["Flask of Relentless Assault"] = true,
	["Flask of Shadow Fortification"] = true,
	["Supreme Power"] = true,
	["Flask of Pure Death"] = true,
	["Flask of the Titans"] = true,
	["Supreme Power of Shattrath"] = true,
	["Fortification of Shattrath"] = true,
	["Mighty Restoration of Shattrath"] = true,
	["Relentless Assault of Shattrath"] = true,
	["Pure Death of Shattrath"] = true,
	["Blinding Light of Shattrath"] = true,
	["Unstable Flask of the Bandit"] = true,
	["Unstable Flask of the Beast"] = true,
	["Unstable Flask of the Elder"] = true,
	["Unstable Flask of the Sorcerer"] = true,
	["Unstable Flask of the Soldier"] = true,
	["Unstable Flask of the Physician"] = true,
	["Overwhelming Might"] = true,
	["Flask of Overwhelming Might"] = true,
	["Flask of Supreme Power"] = true,
	["Flask of the North"] = true,
}

local foods = {
	["Well Fed"] = true,
	["\"Well Fed\""] = true,
}

local protections = {
	["Fire Protection"] = true,
	["Arcane Protection"] = true,
	["Shadow Protection"] = true,
	["Frost Protection"] = true,
	["Nature Protection"] = true,
	["Holy Protection"] = true,
}

local texture = nil

-- Class color table
local classColors = {
	["WARRIOR"] = "|cffC69B6D",
	["PALADIN"] = "|cffF48CBA",
	["HUNTER"] = "|cffAAD372",
	["ROGUE"] = "|cffFFF468",
	["PRIEST"] = "|cffFFFFFF",
	["SHAMAN"] = "|cff0070DD",
	["MAGE"] = "|cff3FC7EB", 
	["WARLOCK"] = "|cff8788EE",
	["DRUID"] = "|cffFF7C0A",
}

-- Cache for player name to class mapping (built during inspectRaid)
local playerClassCache = {}

-- Function to get colored name for a player
local function getColoredName(playerName)
	if not playerName then return "|cffcccccc" .. tostring(playerName) .. "|r" end
	
	-- Get class from cache
	local class = playerClassCache[playerName]
	
	-- If not in cache, try to look it up
	if not class then
		-- Try raid roster
		for i = 1, GetNumRaidMembers() do
			local name, rank, subgroup, level, classFileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if name == playerName then
				class = classFileName
				playerClassCache[playerName] = class
				break
			end
		end
		
		-- If not found in raid, try party
		if not class then
			for i = 1, GetNumPartyMembers() do
				local unit = "party" .. i
				local name = UnitName(unit)
				if name == playerName then
					class = select(2, UnitClass(unit))
					playerClassCache[playerName] = class
					break
				end
			end
		end
		
		-- If still not found, try player
		if not class then
			if UnitName("player") == playerName then
				class = select(2, UnitClass("player"))
				playerClassCache[playerName] = class
			end
		end
	end
	
	-- Apply color if class exists in our table
	-- Convert class to uppercase for lookup (API returns "Warlock", table has "WARLOCK")
	local classUpper = class and string.upper(class) or nil
	if classUpper and classColors[classUpper] then
		return classColors[classUpper] .. playerName .. "|r"
	else
		-- Default gray color
		return "|cffcccccc" .. playerName .. "|r"
	end
end

-- Helper function to check if player is Raid Leader or Raid Officer
local function isRaidLeaderOrOfficer()
	return IsRaidLeader() or UnitIsRaidOfficer("player")
end

local f = CreateFrame("Frame")

function f:ADDON_LOADED(msg)
	if msg:lower() ~= "spyinggnome" then return end
	_G.SpyingGnomeDB = _G.SpyingGnomeDB or {}
	self.db = _G.SpyingGnomeDB
	for k, v in pairs({
		enableSpyingGnome = true,
		statusPrintInRaidChat = true,
		statusPrintAtReady = true,
		checkFlasks = true,
		checkFood = true,
		checkProtection = false,
		checkFire = false,
		checkArcane = false,
		checkShadow = false,
		checkFrost = false,
		checkNature = false,
		checkHoly = false,
	}) do
		if type(self.db[k]) == "nil" then
			self.db[k] = v
		end
	end

	local t = UIParent:CreateTexture("SpyingGnomeSalute", "OVERLAY")
	t:SetTexture("Interface\\AddOns\\SpyingGnome\\spyinggnome")
	t:SetHeight(256)
	t:SetWidth(256)
	t:SetPoint("CENTER", UIParent)
	t:SetAlpha(0)
	t:Hide()
	texture = t
	
	self:UnregisterEvent("ADDON_LOADED")
end

local function sendRaidReport(players, reportType, isReadyCheck)
	if #players == 0 then return end
	
	-- Check if SpyingGnome is enabled (master switch)
	if not f.db.enableSpyingGnome then return end
	
	-- Check if raid chat printing is enabled
	if not f.db.statusPrintInRaidChat then return end
	
	-- Only send if player is Raid Leader or Raid Officer
	if not isRaidLeaderOrOfficer() then return end
	
	-- Must be in a raid or party to send
	if GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
		return
	end
	
	-- Build list of plain player names for raid chat (no colors)
	local nameList = {}
	for i, player in next, players do
		nameList[#nameList+1] = player
	end
	
	-- Format message with plain names
	local message = "[SG] " .. reportType .. ": " .. table.concat(nameList, ", ")
	
	-- Debug: print colored version to console
	-- Truncate if too long (WoW chat limit is 255, but reference uses 230 for safety)
	if string.len(message) > 230 then
		message = string.sub(message, 1, 230)
	end
	
	-- Send to raid or party chat (use lowercase as per reference code)
	if GetNumRaidMembers() > 0 then
		SendChatMessage(message, "raid")
	elseif GetNumPartyMembers() > 0 then
		SendChatMessage(message, "party")
	end
end

local nofood, noflask, recheck = {}, {}, {}
local nofire, noarcane, noshadow, nofrost, nonature, noholy = {}, {}, {}, {}, {}, {}
local function inspectUnit(unit)
	local flask, food = nil, nil
	local fire, arcane, shadow, frost, nature, holy = nil, nil, nil, nil, nil, nil
	for j = 1, 40 do
		local name = UnitBuff(unit, j)
		if not name then break end
		if foods[name] then food = true end
		if flasks[name] then flask = true end
		if protections[name] then
			if name == "Fire Protection" then fire = true
			elseif name == "Arcane Protection" then arcane = true
			elseif name == "Shadow Protection" then shadow = true
			elseif name == "Frost Protection" then frost = true
			elseif name == "Nature Protection" then nature = true
			elseif name == "Holy Protection" then holy = true
			end
		end
		if food and flask and fire and arcane and shadow and frost and nature and holy then break end
	end
	return flask, food, fire, arcane, shadow, frost, nature, holy
end
local function inspectRaid()
	-- Safety check - ensure f.db exists
	if not f or not f.db then return end
	
	-- Clear and rebuild class cache
	wipe(playerClassCache)
	wipe(nofood); wipe(noflask)
	wipe(nofire); wipe(noarcane); wipe(noshadow); wipe(nofrost); wipe(nonature); wipe(noholy)
	
	for i = 1, GetNumRaidMembers() do
		local name, rank, subgroup, level, classFileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if name then
			-- Cache the class for this player (store as-is, we'll uppercase on lookup)
			playerClassCache[name] = classFileName
			
			-- Use unit ID (raid1, raid2, etc.) instead of name for UnitBuff
			local unitID = "raid" .. i
			local flask, food, fire, arcane, shadow, frost, nature, holy = inspectUnit(unitID)
			-- Only check for food if checkFood is enabled
			if f.db.checkFood and not food then 
				nofood[#nofood+1] = name 
			end
			-- Only check for flask if checkFlasks is enabled
			if f.db.checkFlasks and not flask then 
				noflask[#noflask+1] = name 
			end
			-- Check for protection buffs if checkProtection is enabled
			if f.db.checkProtection then
				if f.db.checkFire and not fire then
					nofire[#nofire+1] = name
				end
				if f.db.checkArcane and not arcane then
					noarcane[#noarcane+1] = name
				end
				if f.db.checkShadow and not shadow then
					noshadow[#noshadow+1] = name
				end
				if f.db.checkFrost and not frost then
					nofrost[#nofrost+1] = name
				end
				if f.db.checkNature and not nature then
					nonature[#nonature+1] = name
				end
				if f.db.checkHoly and not holy then
					noholy[#noholy+1] = name
				end
			end
			-- Add to recheck if any check is missing (and their check is enabled)
			if (f.db.checkFood and not food) or (f.db.checkFlasks and not flask) or 
			   (f.db.checkProtection and ((f.db.checkFire and not fire) or (f.db.checkArcane and not arcane) or 
			    (f.db.checkShadow and not shadow) or (f.db.checkFrost and not frost) or 
			    (f.db.checkNature and not nature) or (f.db.checkHoly and not holy))) then 
				recheck[#recheck+1] = name 
			end
		end
	end
end

local function printStatusReport()
	-- Check if SpyingGnome is enabled (master switch)
	if not f.db.enableSpyingGnome then return end
	
	-- Print status reports to console with colored names
	-- Only print if the respective check is enabled
	if f.db.checkFood and #nofood > 0 then
		local coloredFoodList = {}
		for i, player in next, nofood do
			coloredFoodList[#coloredFoodList+1] = getColoredName(player)
		end
		print("Missing food: " .. table.concat(coloredFoodList, ", ") .. ".")
	end
	if f.db.checkFlasks and #noflask > 0 then
		local coloredFlaskList = {}
		for i, player in next, noflask do
			coloredFlaskList[#coloredFlaskList+1] = getColoredName(player)
		end
		print("Missing flask: " .. table.concat(coloredFlaskList, ", ") .. ".")
	end
	if f.db.checkProtection then
		if f.db.checkFire and #nofire > 0 then
			local coloredList = {}
			for i, player in next, nofire do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Fire Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
		if f.db.checkArcane and #noarcane > 0 then
			local coloredList = {}
			for i, player in next, noarcane do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Arcane Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
		if f.db.checkShadow and #noshadow > 0 then
			local coloredList = {}
			for i, player in next, noshadow do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Shadow Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
		if f.db.checkFrost and #nofrost > 0 then
			local coloredList = {}
			for i, player in next, nofrost do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Frost Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
		if f.db.checkNature and #nonature > 0 then
			local coloredList = {}
			for i, player in next, nonature do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Nature Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
		if f.db.checkHoly and #noholy > 0 then
			local coloredList = {}
			for i, player in next, noholy do
				coloredList[#coloredList+1] = getColoredName(player)
			end
			print("Missing Holy Protection: " .. table.concat(coloredList, ", ") .. ".")
		end
	end
end

-- Function to send status reports to raid chat
-- Only sends if "Print a status report after a ready check" is checked
local function sendStatusReportToRaidChat()
	-- Only send if "Print a status report after a ready check" is checked
	if not f.db.statusPrintAtReady then
		return
	end
	
	-- Send reports for each category (sendRaidReport will check statusPrintInRaidChat)
	if f.db.checkFlasks and #noflask > 0 then
		sendRaidReport(noflask, "Missing Flask", false)
	end
	if f.db.checkFood and #nofood > 0 then
		sendRaidReport(nofood, "Missing Food", false)
	end
	if f.db.checkProtection then
		if f.db.checkFire and #nofire > 0 then
			sendRaidReport(nofire, "Missing Fire Protection", false)
		end
		if f.db.checkArcane and #noarcane > 0 then
			sendRaidReport(noarcane, "Missing Arcane Protection", false)
		end
		if f.db.checkShadow and #noshadow > 0 then
			sendRaidReport(noshadow, "Missing Shadow Protection", false)
		end
		if f.db.checkFrost and #nofrost > 0 then
			sendRaidReport(nofrost, "Missing Frost Protection", false)
		end
		if f.db.checkNature and #nonature > 0 then
			sendRaidReport(nonature, "Missing Nature Protection", false)
		end
		if f.db.checkHoly and #noholy > 0 then
			sendRaidReport(noholy, "Missing Holy Protection", false)
		end
	end
end

function f:READY_CHECK_FINISHED()
	self:Hide()
	self:UnregisterEvent("READY_CHECK_FINISHED")	-- Because these can get spammed when you leave raid/group (and because we can call this function due to timeout)

	-- Always do status report inspection and print to console (debug)
	wipe(nofood); wipe(noflask)
	wipe(nofire); wipe(noarcane); wipe(noshadow); wipe(nofrost); wipe(nonature); wipe(noholy)
	
	for i, player in next, recheck do
		-- Convert player name to unit ID by searching raid roster
		local unitID = nil
		for j = 1, GetNumRaidMembers() do
			local name = GetRaidRosterInfo(j)
			if name == player then
				unitID = "raid" .. j
				break
			end
		end
		
		-- Only inspect if we found a valid unit ID
		if unitID then
			local flask, food, fire, arcane, shadow, frost, nature, holy = inspectUnit(unitID)
			-- Only check for food if checkFood is enabled
			-- Store plain names, printStatusReport will color them
			if self.db.checkFood and not food then 
				nofood[#nofood+1] = player 
			end
			-- Only check for flask if checkFlasks is enabled
			if self.db.checkFlasks and not flask then 
				noflask[#noflask+1] = player 
			end
			-- Check for protection buffs if checkProtection is enabled
			if self.db.checkProtection then
				if self.db.checkFire and not fire then
					nofire[#nofire+1] = player
				end
				if self.db.checkArcane and not arcane then
					noarcane[#noarcane+1] = player
				end
				if self.db.checkShadow and not shadow then
					noshadow[#noshadow+1] = player
				end
				if self.db.checkFrost and not frost then
					nofrost[#nofrost+1] = player
				end
				if self.db.checkNature and not nature then
					nonature[#nonature+1] = player
				end
				if self.db.checkHoly and not holy then
					noholy[#noholy+1] = player
				end
			end
		end
	end
	
	wipe(recheck)
	
	-- Always print to console (debug) - regardless of checkbox states
	printStatusReport()
	
	-- Only send to raid chat if "Enable Status Report Printing in Raid Chat" is checked
	sendStatusReportToRaidChat()
end

local rcTimeout = 0

function f:READY_CHECK(sender,timeout)

	-- Track timeout locally because officers sometimes don't get the _FINISHED like they should. Yay.
	rcTimeout = GetTime() + tonumber(timeout) + 1  -- +1 because half the time we get given "29" instead of "30". blizzard strikes again.
	
	self:Show()

	self:RegisterEvent("READY_CHECK_FINISHED")

	wipe(nofood); wipe(noflask); wipe(recheck)
	inspectRaid()

	-- Don't send messages here - wait for READY_CHECK_FINISHED
	-- Messages will be sent in READY_CHECK_FINISHED if "Print a status report after a ready check" is checked

end

local total = 0
f:Hide()
f:SetScript("OnHide", function() UIFrameFlashStop(texture) end)
f:SetScript("OnUpdate", function(self, elapsed)

	if GetTime()>rcTimeout then
		self:READY_CHECK_FINISHED()
	end

	if total <= 0 and self.db.enableSpyingGnome then
		local rx = math.random(128, WorldFrame:GetWidth() - 128)
		local ry = math.random(128, WorldFrame:GetHeight() - 128)
		texture:SetPoint("CENTER", UIParent, "TOPLEFT", rx, -ry)
		UIFrameFlash(texture, 0.5, 0.5, 1.6, false, 0.2, 0.4)
		total = 1.7
	end
	total = total - elapsed
end)
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("ADDON_LOADED")

-- Removed filter for flaskTell/foodTell since those settings no longer exist

-- Manual check function that can be called from UI button
function f:ManualCheck()
	-- Clear previous results
	wipe(nofood); wipe(noflask); wipe(recheck)
	
	-- Inspect the raid
	inspectRaid()
	
	-- Only send raid chat messages if player is Raid Leader or Raid Officer
	if isRaidLeaderOrOfficer() then
		-- Send raid chat messages (only if checks are enabled)
		-- Pass false to indicate this is from a manual check (not ready check)
		if self.db.checkFlasks and #noflask > 0 then
			sendRaidReport(noflask, "Missing Flask", false)
		end
		if self.db.checkFood and #nofood > 0 then
			sendRaidReport(nofood, "Missing Food", false)
		end
		if self.db.checkProtection then
			if self.db.checkFire and #nofire > 0 then
				sendRaidReport(nofire, "Missing Fire Protection", false)
			end
			if self.db.checkArcane and #noarcane > 0 then
				sendRaidReport(noarcane, "Missing Arcane Protection", false)
			end
			if self.db.checkShadow and #noshadow > 0 then
				sendRaidReport(noshadow, "Missing Shadow Protection", false)
			end
			if self.db.checkFrost and #nofrost > 0 then
				sendRaidReport(nofrost, "Missing Frost Protection", false)
			end
			if self.db.checkNature and #nonature > 0 then
				sendRaidReport(nonature, "Missing Nature Protection", false)
			end
			if self.db.checkHoly and #noholy > 0 then
				sendRaidReport(noholy, "Missing Holy Protection", false)
			end
		end
	end
	
	-- Always print status report to console
	printStatusReport()
	
	-- Return true if we found any issues
	return (self.db.checkFlasks and #noflask > 0) or (self.db.checkFood and #nofood > 0) or
	       (self.db.checkProtection and ((self.db.checkFire and #nofire > 0) or (self.db.checkArcane and #noarcane > 0) or
	        (self.db.checkShadow and #noshadow > 0) or (self.db.checkFrost and #nofrost > 0) or
	        (self.db.checkNature and #nonature > 0) or (self.db.checkHoly and #noholy > 0)))
end

_G.SpyingGnome = f

