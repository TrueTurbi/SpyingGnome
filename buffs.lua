-- Global buff tables (shared with buffconfig.lua)
_G.SpyingGnomeFlasks = {
	["Chromatic Resistance"] = true,
	["Distilled Wisdom"] = true,
	["Flask of the Titans"] = true,
	["Flask of Overwhelming Might"] = true,
	["Flask of Supreme Power"] = true,
}

-- Mapping for buffs that check multiple names (config name -> array of actual buff names)
_G.SpyingGnomeBuffAliases = {
	["Flask of Overwhelming Might"] = {
		["Flask of Overwhelming Might"] = true,
		["Overwhelming Might"] = true,
	},
	["Flask of Supreme Power"] = {
		["Flask of Supreme Power"] = true,
		["Supreme Power"] = true,
	},
	["Elixir of Superior Defense"] = {
		["Elixir of Superior Defense"] = true,
		["Greater Armor"] = true,
	},
	["Elixir of Fortitude"] = {
		["Elixir of Fortitude"] = true,
		["Health II"] = true,
	},
	["Lung Juice Cocktail"] = {
		["Lung Juice Cocktail"] = true,
		["Spirit of Boar"] = true,
	},
	["Ground Scorpok Assay"] = {
		["Ground Scorpok Assay"] = true,
		["Strike of the Scorpok"] = true,
	},
	["R.O.I.D.S."] = {
		["R.O.I.D.S."] = true,
		["Rage of Ages"] = true,
	},
	["Cerebral Cortex Compound"] = {
		["Cerebral Cortex Compound"] = true,
		["Infallible Mind"] = true,
	},
	["Gizzard Gum"] = {
		["Gizzard Gum"] = true,
		["Spiritual Domination"] = true,
	},
}

_G.SpyingGnomeFoods = {
	["Well Fed"] = true,
	["\"Well Fed\""] = true,
	["Mana Regeneration"] = true,
	["Strength"] = true,
	["Increased Agility"] = true,
}

_G.SpyingGnomeProtections = {
	["Fire Protection"] = true,
	["Arcane Protection"] = true,
	["Shadow Protection"] = true,
	["Frost Protection"] = true,
	["Nature Protection"] = true,
	["Holy Protection"] = true,
}

-- Battle Elixirs (moved from SpyingGnomeElixirs)
_G.SpyingGnomeBattleElixirs = {
	["Elixir of the Mongoose"] = true,
	["Shadow Power"] = true,
	["Greater Firepower"] = true,
	["Elixir of the Giants"] = true,
	["Pure Arcane Power"] = true,
	["Dazzling Light"] = true,
	["Greater Arcane Elixir"] = true,
	["Elixir of Brute Force"] = true,
	["Winterfall Firewater"] = true,
	["Ground Scorpok Assay"] = true,
	["R.O.I.D.S."] = true,
}

-- Guardian Elixirs (moved from SpyingGnomeElixirs)
_G.SpyingGnomeGuardianElixirs = {
	["Greater Intellect"] = true,
	["Elixir of the Sages"] = true,
	["Elixir of Superior Defense"] = true,
	["Elixir of Fortitude"] = true,
	["Lung Juice Cocktail"] = true,
	["Cerebral Cortex Compound"] = true,
	["Gizzard Gum"] = true,
}

-- Local references for convenience
local flasks = _G.SpyingGnomeFlasks
local foods = _G.SpyingGnomeFoods
local protections = _G.SpyingGnomeProtections
local battleElixirs = _G.SpyingGnomeBattleElixirs
local guardianElixirs = _G.SpyingGnomeGuardianElixirs
local buffAliases = _G.SpyingGnomeBuffAliases or {}

local texture = nil
local texture2 = nil
local currentTexture = nil

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
		checkElixirs = false,
		checkGuardianElixirs = false,
		checkFood = true,
		checkProtection = false,
	}) do
		if type(self.db[k]) == "nil" then
			self.db[k] = v
		end
	end
	
	-- Initialize enabled buffs tables (will be populated by buffconfig.lua, but initialize as empty tables here)
	if not self.db.enabledFlasks then
		self.db.enabledFlasks = {}
	end
	if not self.db.enabledElixirs then
		self.db.enabledElixirs = {}
	end
	if not self.db.enabledGuardianElixirs then
		self.db.enabledGuardianElixirs = {}
	end
	if not self.db.enabledProtections then
		self.db.enabledProtections = {}
	end

	local t = UIParent:CreateTexture("SpyingGnomeSalute", "OVERLAY")
	t:SetTexture("Interface\\AddOns\\SpyingGnome\\spyinggnome")
	t:SetHeight(256)
	t:SetWidth(256)
	t:SetPoint("CENTER", UIParent)
	t:SetAlpha(0)
	t:Hide()
	texture = t
	
	local t2 = UIParent:CreateTexture("SpyingGnomeSalute2", "OVERLAY")
	t2:SetTexture("Interface\\AddOns\\SpyingGnome\\spyinggnome3")
	t2:SetHeight(256)
	t2:SetWidth(256)
	t2:SetPoint("CENTER", UIParent)
	t2:SetAlpha(0)
	t2:Hide()
	texture2 = t2
	
	-- Start with first texture
	currentTexture = texture
	
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
local nobattleElixir, noguardianElixir = {}, {}
local nofire, noarcane, noshadow, nofrost, nonature, noholy = {}, {}, {}, {}, {}, {}
local function inspectUnit(unit)
	local flask, food, battleElixir, guardianElixir = nil, nil, nil, nil
	local fire, arcane, shadow, frost, nature, holy = nil, nil, nil, nil, nil, nil
	for j = 1, 40 do
		local name = UnitBuff(unit, j)
		if not name then break end
		if foods[name] then food = true end
		-- Check if flask is enabled in database (default to true if not set)
		-- First check direct match
		if flasks[name] and (not f.db.enabledFlasks or f.db.enabledFlasks[name] ~= false) then 
			flask = true 
		end
		-- Then check aliases (e.g., "Flask of Overwhelming Might" also matches "Overwhelming Might")
		-- This allows checking for EITHER name when the config name is enabled
		if not flask then
			for configName, aliasTable in pairs(buffAliases) do
				-- Check if the current buff name is in the alias table for this config name
				if aliasTable[name] then
					-- Check if the config name is in the flasks table and enabled
					if flasks[configName] and (not f.db.enabledFlasks or f.db.enabledFlasks[configName] ~= false) then
						flask = true
						break
					end
				end
			end
		end
		-- Check if battle elixir is enabled in database (default to true if not set)
		if not battleElixir then
			if battleElixirs[name] and (not f.db.enabledElixirs or f.db.enabledElixirs[name] ~= false) then
				battleElixir = true
			end
		end
		-- Check battle elixir aliases
		if not battleElixir then
			for configName, aliasTable in pairs(buffAliases) do
				if aliasTable[name] and battleElixirs[configName] and (not f.db.enabledElixirs or f.db.enabledElixirs[configName] ~= false) then
					battleElixir = true
					break
				end
			end
		end
		-- Check if guardian elixir is enabled in database (default to true if not set)
		if not guardianElixir then
			if guardianElixirs[name] and (not f.db.enabledGuardianElixirs or f.db.enabledGuardianElixirs[name] ~= false) then
				guardianElixir = true
			end
		end
		-- Check guardian elixir aliases
		if not guardianElixir then
			for configName, aliasTable in pairs(buffAliases) do
				if aliasTable[name] and guardianElixirs[configName] and (not f.db.enabledGuardianElixirs or f.db.enabledGuardianElixirs[configName] ~= false) then
					guardianElixir = true
					break
				end
			end
		end
		-- Check if protection is enabled in database (default to false if not set)
		if protections[name] and f.db.enabledProtections and f.db.enabledProtections[name] == true then
			if name == "Fire Protection" then fire = true
			elseif name == "Arcane Protection" then arcane = true
			elseif name == "Shadow Protection" then shadow = true
			elseif name == "Frost Protection" then frost = true
			elseif name == "Nature Protection" then nature = true
			elseif name == "Holy Protection" then holy = true
			end
		end
		if food and flask and battleElixir and guardianElixir and fire and arcane and shadow and frost and nature and holy then break end
	end
	return flask, food, battleElixir, guardianElixir, fire, arcane, shadow, frost, nature, holy
end
local function inspectRaid()
	-- Safety check - ensure f.db exists
	if not f or not f.db then return end
	
	-- Clear and rebuild class cache
	wipe(playerClassCache)
	wipe(nofood); wipe(noflask)
	wipe(nobattleElixir); wipe(noguardianElixir)
	wipe(nofire); wipe(noarcane); wipe(noshadow); wipe(nofrost); wipe(nonature); wipe(noholy)
	
	for i = 1, GetNumRaidMembers() do
		local name, rank, subgroup, level, classFileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if name then
			-- Cache the class for this player (store as-is, we'll uppercase on lookup)
			playerClassCache[name] = classFileName
			
			-- Use unit ID (raid1, raid2, etc.) instead of name for UnitBuff
			local unitID = "raid" .. i
			local flask, food, battleElixir, guardianElixir, fire, arcane, shadow, frost, nature, holy = inspectUnit(unitID)
			-- Only check for food if checkFood is enabled
			if f.db.checkFood and not food then 
				nofood[#nofood+1] = name 
			end
			-- Only check for flask if checkFlasks is enabled
			if f.db.checkFlasks and not flask then
				noflask[#noflask+1] = name
			end
			-- Check for Battle Elixirs separately if checkElixirs is enabled
			if f.db.checkElixirs and not battleElixir then
				nobattleElixir[#nobattleElixir+1] = name
			end
			-- Check for Guardian Elixirs separately if checkGuardianElixirs is enabled
			if f.db.checkGuardianElixirs and not guardianElixir then
				noguardianElixir[#noguardianElixir+1] = name
			end
			-- Check for protection buffs if checkProtection is enabled
			if f.db.checkProtection then
				if f.db.enabledProtections and f.db.enabledProtections["Arcane Protection"] and not arcane then
					noarcane[#noarcane+1] = name
				end
				if f.db.enabledProtections and f.db.enabledProtections["Fire Protection"] and not fire then
					nofire[#nofire+1] = name
				end
				if f.db.enabledProtections and f.db.enabledProtections["Frost Protection"] and not frost then
					nofrost[#nofrost+1] = name
				end
				if f.db.enabledProtections and f.db.enabledProtections["Holy Protection"] and not holy then
					noholy[#noholy+1] = name
				end
				if f.db.enabledProtections and f.db.enabledProtections["Nature Protection"] and not nature then
					nonature[#nonature+1] = name
				end
				if f.db.enabledProtections and f.db.enabledProtections["Shadow Protection"] and not shadow then
					noshadow[#noshadow+1] = name
				end
			end
			-- Add to recheck if any check is missing (and their check is enabled)
			local hasMissingProtection = false
			if f.db.checkProtection and f.db.enabledProtections then
				hasMissingProtection = ((f.db.enabledProtections["Fire Protection"] and not fire) or 
				                        (f.db.enabledProtections["Arcane Protection"] and not arcane) or 
				                        (f.db.enabledProtections["Shadow Protection"] and not shadow) or 
				                        (f.db.enabledProtections["Frost Protection"] and not frost) or 
				                        (f.db.enabledProtections["Nature Protection"] and not nature) or 
				                        (f.db.enabledProtections["Holy Protection"] and not holy))
			end
			if (f.db.checkFood and not food) or (f.db.checkFlasks and not flask) or (f.db.checkElixirs and not battleElixir) or (f.db.checkGuardianElixirs and not guardianElixir) or hasMissingProtection then 
				recheck[#recheck+1] = name 
			end
		end
	end
end

local function printStatusReport()
	-- Check if SpyingGnome is enabled (master switch)
	if not f.db.enableSpyingGnome then return end
	
	-- Check if checkboxes are enabled but no items are selected in Configuration
	-- These configuration warnings should always print, regardless of raid chat settings
	if f.db.checkFlasks then
		local hasEnabledFlasks = false
		if f.db.enabledFlasks then
			for flaskName, _ in pairs(flasks) do
				if f.db.enabledFlasks[flaskName] ~= false then
					hasEnabledFlasks = true
					break
				end
			end
		end
		if not hasEnabledFlasks then
			print("[SG]: You have not selected any flasks to check for.")
		end
	end
	
	if f.db.checkElixirs then
		local hasEnabledBattleElixirs = false
		if f.db.enabledElixirs then
			for elixirName, _ in pairs(battleElixirs) do
				if f.db.enabledElixirs[elixirName] ~= false then
					hasEnabledBattleElixirs = true
					break
				end
			end
		end
		if not hasEnabledBattleElixirs then
			print("[SG]: You have not selected any battle elixirs to check for.")
		end
	end
	
	if f.db.checkGuardianElixirs then
		local hasEnabledGuardianElixirs = false
		if f.db.enabledGuardianElixirs then
			for elixirName, _ in pairs(guardianElixirs) do
				if f.db.enabledGuardianElixirs[elixirName] ~= false then
					hasEnabledGuardianElixirs = true
					break
				end
			end
		end
		if not hasEnabledGuardianElixirs then
			print("[SG]: You have not selected any guardian elixirs to check for.")
		end
	end
	
	if f.db.checkProtection then
		local hasEnabledProtections = false
		if f.db.enabledProtections then
			for protName, _ in pairs(protections) do
				if f.db.enabledProtections[protName] == true then
					hasEnabledProtections = true
					break
				end
			end
		end
		if not hasEnabledProtections then
			print("[SG]: You have not selected any protection buffs to check for.")
		end
	end
	
	-- Don't print debug messages if raid chat printing is enabled AND player is raid leader/officer
	-- If raid chat printing is enabled but player is NOT raid leader/officer, print to debug instead
	if f.db.statusPrintInRaidChat and isRaidLeaderOrOfficer() then return end
	
	-- Print status reports to console with colored names
	-- Order: Flask, Battle Elixir, Guardian Elixir, Food, Protection
	-- Only print if the respective check is enabled AND items are selected in Configuration
	if f.db.checkFlasks and #noflask > 0 then
		local hasEnabledFlasks = false
		if f.db.enabledFlasks then
			for flaskName, _ in pairs(flasks) do
				if f.db.enabledFlasks[flaskName] ~= false then
					hasEnabledFlasks = true
					break
				end
			end
		end
		if hasEnabledFlasks then
			local coloredFlaskList = {}
			for i, player in next, noflask do
				coloredFlaskList[#coloredFlaskList+1] = getColoredName(player)
			end
			print("[SG] Missing flask: " .. table.concat(coloredFlaskList, ", ") .. ".")
		end
	end
	
	if f.db.checkElixirs and #nobattleElixir > 0 then
		local hasEnabledBattleElixirs = false
		if f.db.enabledElixirs then
			for elixirName, _ in pairs(battleElixirs) do
				if f.db.enabledElixirs[elixirName] ~= false then
					hasEnabledBattleElixirs = true
					break
				end
			end
		end
		if hasEnabledBattleElixirs then
			local coloredBattleElixirList = {}
			for i, player in next, nobattleElixir do
				coloredBattleElixirList[#coloredBattleElixirList+1] = getColoredName(player)
			end
			print("[SG] Missing Battle Elixir: " .. table.concat(coloredBattleElixirList, ", ") .. ".")
		end
	end
	
	if f.db.checkGuardianElixirs and #noguardianElixir > 0 then
		local hasEnabledGuardianElixirs = false
		if f.db.enabledGuardianElixirs then
			for elixirName, _ in pairs(guardianElixirs) do
				if f.db.enabledGuardianElixirs[elixirName] ~= false then
					hasEnabledGuardianElixirs = true
					break
				end
			end
		end
		if hasEnabledGuardianElixirs then
			local coloredGuardianElixirList = {}
			for i, player in next, noguardianElixir do
				coloredGuardianElixirList[#coloredGuardianElixirList+1] = getColoredName(player)
			end
			print("[SG] Missing Guardian Elixir: " .. table.concat(coloredGuardianElixirList, ", ") .. ".")
		end
	end
	
	if f.db.checkFood and #nofood > 0 then
		local coloredFoodList = {}
		for i, player in next, nofood do
			coloredFoodList[#coloredFoodList+1] = getColoredName(player)
		end
		print("[SG] Missing food buff: " .. table.concat(coloredFoodList, ", ") .. ".")
	end
	if f.db.checkProtection and f.db.enabledProtections then
		local hasEnabledProtections = false
		if f.db.enabledProtections then
			for protName, _ in pairs(protections) do
				if f.db.enabledProtections[protName] == true then
					hasEnabledProtections = true
					break
				end
			end
		end
		if hasEnabledProtections then
			if f.db.enabledProtections["Arcane Protection"] and #noarcane > 0 then
				local coloredList = {}
				for i, player in next, noarcane do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Arcane Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
			if f.db.enabledProtections["Fire Protection"] and #nofire > 0 then
				local coloredList = {}
				for i, player in next, nofire do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Fire Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
			if f.db.enabledProtections["Frost Protection"] and #nofrost > 0 then
				local coloredList = {}
				for i, player in next, nofrost do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Frost Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
			if f.db.enabledProtections["Holy Protection"] and #noholy > 0 then
				local coloredList = {}
				for i, player in next, noholy do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Holy Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
			if f.db.enabledProtections["Nature Protection"] and #nonature > 0 then
				local coloredList = {}
				for i, player in next, nonature do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Nature Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
			if f.db.enabledProtections["Shadow Protection"] and #noshadow > 0 then
				local coloredList = {}
				for i, player in next, noshadow do
					coloredList[#coloredList+1] = getColoredName(player)
				end
				print("[SG] Missing Shadow Protection: " .. table.concat(coloredList, ", ") .. ".")
			end
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
	-- Order: Flask, Battle Elixir, Guardian Elixir, Food, Protection
	-- Only send if items are selected in Configuration
	if f.db.checkFlasks and #noflask > 0 then
		local hasEnabledFlasks = false
		if f.db.enabledFlasks then
			for flaskName, _ in pairs(flasks) do
				if f.db.enabledFlasks[flaskName] ~= false then
					hasEnabledFlasks = true
					break
				end
			end
		end
		if hasEnabledFlasks then
			sendRaidReport(noflask, "Missing flask", false)
		end
	end
	if f.db.checkElixirs and #nobattleElixir > 0 then
		local hasEnabledBattleElixirs = false
		if f.db.enabledElixirs then
			for elixirName, _ in pairs(battleElixirs) do
				if f.db.enabledElixirs[elixirName] ~= false then
					hasEnabledBattleElixirs = true
					break
				end
			end
		end
		if hasEnabledBattleElixirs then
			sendRaidReport(nobattleElixir, "Missing Battle Elixir", false)
		end
	end
	if f.db.checkGuardianElixirs and #noguardianElixir > 0 then
		local hasEnabledGuardianElixirs = false
		if f.db.enabledGuardianElixirs then
			for elixirName, _ in pairs(guardianElixirs) do
				if f.db.enabledGuardianElixirs[elixirName] ~= false then
					hasEnabledGuardianElixirs = true
					break
				end
			end
		end
		if hasEnabledGuardianElixirs then
			sendRaidReport(noguardianElixir, "Missing Guardian Elixir", false)
		end
	end
	if f.db.checkFood and #nofood > 0 then
		sendRaidReport(nofood, "Missing food buff", false)
	end
	if f.db.checkProtection and f.db.enabledProtections then
		if f.db.enabledProtections["Arcane Protection"] and #noarcane > 0 then
			sendRaidReport(noarcane, "Missing Arcane Protection", false)
		end
		if f.db.enabledProtections["Fire Protection"] and #nofire > 0 then
			sendRaidReport(nofire, "Missing Fire Protection", false)
		end
		if f.db.enabledProtections["Frost Protection"] and #nofrost > 0 then
			sendRaidReport(nofrost, "Missing Frost Protection", false)
		end
		if f.db.enabledProtections["Holy Protection"] and #noholy > 0 then
			sendRaidReport(noholy, "Missing Holy Protection", false)
		end
		if f.db.enabledProtections["Nature Protection"] and #nonature > 0 then
			sendRaidReport(nonature, "Missing Nature Protection", false)
		end
		if f.db.enabledProtections["Shadow Protection"] and #noshadow > 0 then
			sendRaidReport(noshadow, "Missing Shadow Protection", false)
		end
	end
end

function f:READY_CHECK_FINISHED()
	self:Hide()
	self:UnregisterEvent("READY_CHECK_FINISHED")	-- Because these can get spammed when you leave raid/group (and because we can call this function due to timeout)

	-- Always do status report inspection and print to console (debug)
	wipe(nofood); wipe(noflask)
	wipe(nobattleElixir); wipe(noguardianElixir)
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
			local flask, food, battleElixir, guardianElixir, fire, arcane, shadow, frost, nature, holy = inspectUnit(unitID)
			-- Only check for food if checkFood is enabled
			-- Store plain names, printStatusReport will color them
			if self.db.checkFood and not food then 
				nofood[#nofood+1] = player 
			end
			-- Only check for flask if checkFlasks is enabled
			if self.db.checkFlasks and not flask then
				noflask[#noflask+1] = player
			end
			-- Check for Battle Elixirs separately if checkElixirs is enabled
			if self.db.checkElixirs and not battleElixir then
				nobattleElixir[#nobattleElixir+1] = player
			end
			-- Check for Guardian Elixirs separately if checkGuardianElixirs is enabled
			if self.db.checkGuardianElixirs and not guardianElixir then
				noguardianElixir[#noguardianElixir+1] = player
			end
			-- Check for protection buffs if checkProtection is enabled
			if self.db.checkProtection and self.db.enabledProtections then
				if self.db.enabledProtections["Arcane Protection"] and not arcane then
					noarcane[#noarcane+1] = player
				end
				if self.db.enabledProtections["Fire Protection"] and not fire then
					nofire[#nofire+1] = player
				end
				if self.db.enabledProtections["Frost Protection"] and not frost then
					nofrost[#nofrost+1] = player
				end
				if self.db.enabledProtections["Holy Protection"] and not holy then
					noholy[#noholy+1] = player
				end
				if self.db.enabledProtections["Nature Protection"] and not nature then
					nonature[#nonature+1] = player
				end
				if self.db.enabledProtections["Shadow Protection"] and not shadow then
					noshadow[#noshadow+1] = player
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
f:SetScript("OnHide", function() 
	UIFrameFlashStop(texture)
	UIFrameFlashStop(texture2)
end)
f:SetScript("OnUpdate", function(self, elapsed)

	if GetTime()>rcTimeout then
		self:READY_CHECK_FINISHED()
	end

	if total <= 0 and self.db.enableSpyingGnome then
		local rx = math.random(128, WorldFrame:GetWidth() - 128)
		local ry = math.random(128, WorldFrame:GetHeight() - 128)
		-- Position both textures at the same location
		texture:SetPoint("CENTER", UIParent, "TOPLEFT", rx, -ry)
		texture2:SetPoint("CENTER", UIParent, "TOPLEFT", rx, -ry)
		-- Alternate between the two textures
		if currentTexture == texture then
			currentTexture = texture2
		else
			currentTexture = texture
		end
		-- Flash the current texture
		UIFrameFlash(currentTexture, 0.5, 0.5, 1.6, false, 0.2, 0.4)
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
	wipe(nobattleElixir); wipe(noguardianElixir)
	
	-- Inspect the raid
	inspectRaid()
	
	-- Only send raid chat messages if player is Raid Leader or Raid Officer
	if isRaidLeaderOrOfficer() then
		-- Send raid chat messages (only if checks are enabled)
		-- Pass false to indicate this is from a manual check (not ready check)
		-- Only send if items are selected in Configuration
		if self.db.checkFlasks and #noflask > 0 then
			local hasEnabledFlasks = false
			if self.db.enabledFlasks then
				for flaskName, _ in pairs(flasks) do
					if self.db.enabledFlasks[flaskName] ~= false then
						hasEnabledFlasks = true
						break
					end
				end
			end
			if hasEnabledFlasks then
				sendRaidReport(noflask, "Missing flask", false)
			end
		end
		if self.db.checkElixirs and #nobattleElixir > 0 then
			local hasEnabledBattleElixirs = false
			if self.db.enabledElixirs then
				for elixirName, _ in pairs(battleElixirs) do
					if self.db.enabledElixirs[elixirName] ~= false then
						hasEnabledBattleElixirs = true
						break
					end
				end
			end
			if hasEnabledBattleElixirs then
				sendRaidReport(nobattleElixir, "Missing Battle Elixir", false)
			end
		end
		if self.db.checkGuardianElixirs and #noguardianElixir > 0 then
			local hasEnabledGuardianElixirs = false
			if self.db.enabledGuardianElixirs then
				for elixirName, _ in pairs(guardianElixirs) do
					if self.db.enabledGuardianElixirs[elixirName] ~= false then
						hasEnabledGuardianElixirs = true
						break
					end
				end
			end
			if hasEnabledGuardianElixirs then
				sendRaidReport(noguardianElixir, "Missing Guardian Elixir", false)
			end
		end
		if self.db.checkFood and #nofood > 0 then
			sendRaidReport(nofood, "Missing food buff", false)
		end
		if self.db.checkProtection and self.db.enabledProtections then
			local hasEnabledProtections = false
			if self.db.enabledProtections then
				for protName, _ in pairs(protections) do
					if self.db.enabledProtections[protName] == true then
						hasEnabledProtections = true
						break
					end
				end
			end
			if hasEnabledProtections then
				if self.db.enabledProtections["Arcane Protection"] and #noarcane > 0 then
					sendRaidReport(noarcane, "Missing Arcane Protection", false)
				end
				if self.db.enabledProtections["Fire Protection"] and #nofire > 0 then
					sendRaidReport(nofire, "Missing Fire Protection", false)
				end
				if self.db.enabledProtections["Frost Protection"] and #nofrost > 0 then
					sendRaidReport(nofrost, "Missing Frost Protection", false)
				end
				if self.db.enabledProtections["Holy Protection"] and #noholy > 0 then
					sendRaidReport(noholy, "Missing Holy Protection", false)
				end
				if self.db.enabledProtections["Nature Protection"] and #nonature > 0 then
					sendRaidReport(nonature, "Missing Nature Protection", false)
				end
				if self.db.enabledProtections["Shadow Protection"] and #noshadow > 0 then
					sendRaidReport(noshadow, "Missing Shadow Protection", false)
				end
			end
		end
	end
	
	-- Always print status report to console
	printStatusReport()
	
	-- Return true if we found any issues
	local hasMissingProtection = false
	if self.db.checkProtection and self.db.enabledProtections then
		hasMissingProtection = ((self.db.enabledProtections["Fire Protection"] and #nofire > 0) or 
		                        (self.db.enabledProtections["Arcane Protection"] and #noarcane > 0) or
		                        (self.db.enabledProtections["Shadow Protection"] and #noshadow > 0) or 
		                        (self.db.enabledProtections["Frost Protection"] and #nofrost > 0) or
		                        (self.db.enabledProtections["Nature Protection"] and #nonature > 0) or 
		                        (self.db.enabledProtections["Holy Protection"] and #noholy > 0))
	end
	return (self.db.checkFlasks and #noflask > 0) or (self.db.checkElixirs and #nobattleElixir > 0) or (self.db.checkGuardianElixirs and #noguardianElixir > 0) or (self.db.checkFood and #nofood > 0) or hasMissingProtection
end

_G.SpyingGnome = f

