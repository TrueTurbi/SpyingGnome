local addon = _G.SpyingGnome

-- Use buff tables from buffs.lua (loaded first)
local flasks = _G.SpyingGnomeFlasks or {}
local battleElixirs = _G.SpyingGnomeBattleElixirs or {}
local guardianElixirs = _G.SpyingGnomeGuardianElixirs or {}
local protections = _G.SpyingGnomeProtections or {}

-- Item ID mapping for tooltips (buffName -> itemID)
-- These are the item IDs for flasks and elixirs in WoW 3.3.5
local itemIDs = {
	-- Flasks
	["Chromatic Resistance"] = 13513, -- Flask of Chromatic Resistance
	["Distilled Wisdom"] = 13511, -- Flask of Distilled Wisdom
	["Flask of Overwhelming Might"] = 60423, -- Flask of Overwhelming Might
	["Flask of Supreme Power"] = 13512, -- Flask of Supreme Power
	["Flask of the Titans"] = 13510, -- Flask of the Titans
	-- Battle Elixirs
	["Dazzling Light"] = 62069, -- Elixir of Dazzling Light
	["Greater Firepower"] = 21546, -- Elixir of Greater Firepower
	["Greater Intellect"] = 9179, -- Elixir of Greater Intellect
	["Pure Arcane Power"] = 62072, -- Elixir of Pure Arcane Power
	["Shadow Power"] = 9264, -- Elixir of Shadow Power
	["Elixir of the Giants"] = 9206, -- Elixir of Giants
	["Elixir of the Mongoose"] = 13452, -- Elixir of the Mongoose
	["Elixir of the Sages"] = 13447, -- Elixir of the Sages
	["Greater Arcane Elixir"] = 13454, -- Greater Arcane Elixir
	["Elixir of Brute Force"] = 13453, -- Elixir of Brute Force
	["Winterfall Firewater"] = 12820, -- Winterfall Firewater
	["Ground Scorpok Assay"] = 8412, -- Ground Scorpok Assay (Strike of the Scorpok buff)
	["R.O.I.D.S."] = 8410, -- R.O.I.D.S. (Rage of Ages buff)
	-- Guardian Elixirs
	["Elixir of Superior Defense"] = 13445, -- Elixir of Superior Defense (Greater Armor buff)
	["Elixir of Fortitude"] = 3825, -- Elixir of Fortitude (Health II buff)
	["Lung Juice Cocktail"] = 8411, -- Lung Juice Cocktail (Spirit of Boar buff)
	["Cerebral Cortex Compound"] = 8423, -- Cerebral Cortex Compound (Infallible Mind buff)
	["Gizzard Gum"] = 8424, -- Gizzard Gum (Spiritual Domination buff)
	-- Protections
	["Arcane Protection"] = 13461, -- Greater Arcane Protection Potion
	["Fire Protection"] = 13457, -- Greater Fire Protection Potion
	["Frost Protection"] = 13456, -- Greater Frost Protection Potion
	["Holy Protection"] = 13460, -- Greater Holy Protection Potion
	["Nature Protection"] = 13458, -- Greater Nature Protection Potion
	["Shadow Protection"] = 13459, -- Greater Shadow Protection Potion
}

-- Display name mapping with colors (buffName -> colored display text)
local displayNames = {
	-- Flasks
	["Chromatic Resistance"] = "Flask of Chromatic Resistance |cffff69b4(+25 All Resistance)|r",
	["Distilled Wisdom"] = "Flask of Distilled Wisdom |cff0070dd(+65 Intellect)|r",
	["Flask of Overwhelming Might"] = "Flask of Overwhelming Might |cffff8080(+90 Attack Power)|r",
	["Flask of Supreme Power"] = "Flask of Supreme Power |cff00ffff(+70 Spell Damage)|r",
	["Flask of the Titans"] = "Flask of the Titans |cff00ff00(+700 HP)|r",
	-- Battle Elixirs
	["Dazzling Light"] = "Elixir of Dazzling Light |cffffff00(+40 Holy Damage)|r",
	["Greater Firepower"] = "Elixir of Greater Firepower |cffff8080(+40 Fire Damage)|r",
	["Greater Intellect"] = "Elixir of Greater Intellect |cff0070dd(+25 Intellect)|r",
	["Pure Arcane Power"] = "Elixir of Pure Arcane Power |cff00ffff(+40 Arcane Damage)|r",
	["Shadow Power"] = "Elixir of Shadow Power |cffc000c0(+40 Shadow Damage)|r",
	["Elixir of the Giants"] = "Elixir of Giants |cffff8080(+25 Strength)|r",
	["Elixir of the Mongoose"] = "Elixir of the Mongoose |cff90ee90(+25 Agility, +2% Crit)|r",
	["Elixir of the Sages"] = "Elixir of the Sages |cff0070dd(+18 Intellect, +18 Spirit)|r",
	["Greater Arcane Elixir"] = "Greater Arcane Elixir |cff00ffff(+35 Spell Damage)|r",
	["Elixir of Brute Force"] = "Elixir of Brute Force |cffff8080(+18 Strength, +18 Stamina)|r",
	["Winterfall Firewater"] = "Winterfall Firewater |cffff8080(+35 Attack Power, +Size)|r",
	["Ground Scorpok Assay"] = "Ground Scorpok Assay |cff00ff00(+25 Agility)|r",
	["R.O.I.D.S."] = "R.O.I.D.S. |cffff8080(+25 Strength)|r",
	
	-- Guardian Elixirs
	["Elixir of Superior Defense"] = "Elixir of Superior Defense |cffb0b0b0(+450 Armor)|r",
	["Elixir of Fortitude"] = "Elixir of Fortitude |cff00ff00(+120 HP)|r",
	["Lung Juice Cocktail"] = "Lung Juice Cocktail |cff00ff00(+25 Stamina)|r",
	["Cerebral Cortex Compound"] = "Cerebral Cortex Compound |cff0070dd(+25 Intellect)|r",
	["Gizzard Gum"] = "Gizzard Gum |cff0070dd(+25 Spirit)|r",
}

-- Create main buff config frame
local buffConfigFrame = CreateFrame("Frame", "SpyingGnomeBuffConfigFrame", UIParent)
buffConfigFrame:SetWidth(400)
buffConfigFrame:SetHeight(550)
buffConfigFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
buffConfigFrame:SetMovable(true)
buffConfigFrame:EnableMouse(true)
buffConfigFrame:RegisterForDrag("LeftButton")
buffConfigFrame:SetScript("OnDragStart", buffConfigFrame.StartMoving)
buffConfigFrame:SetScript("OnDragStop", buffConfigFrame.StopMovingOrSizing)
buffConfigFrame:Hide()

-- Create backdrop
buffConfigFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
buffConfigFrame:SetBackdropColor(0, 0, 0, 1)

-- Title bar
local titleBar = CreateFrame("Frame", nil, buffConfigFrame)
titleBar:SetHeight(24)
titleBar:SetPoint("TOPLEFT", buffConfigFrame, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", buffConfigFrame, "TOPRIGHT", 0, 0)
titleBar:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header",
	edgeFile = nil,
	tile = true,
	tileSize = 256,
	edgeSize = 0,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
titleBar:SetBackdropColor(1, 1, 1, 1)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 2)
titleText:SetText("SpyingGnome Buff Configuration")

-- Close button
local closeButton = CreateFrame("Button", nil, buffConfigFrame, "UIPanelCloseButton")
closeButton:SetScale(0.8)
closeButton:SetPoint("TOPRIGHT", buffConfigFrame, "TOPRIGHT", -3, -3)
closeButton:SetScript("OnClick", function() buffConfigFrame:Hide() end)

-- Scroll frame for content
local scrollFrame = CreateFrame("ScrollFrame", "SpyingGnomeBuffScrollFrame", buffConfigFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 15, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", buffConfigFrame, "BOTTOMRIGHT", -30, 15)

local contentFrame = CreateFrame("Frame", "SpyingGnomeBuffContentFrame", scrollFrame)
contentFrame:SetWidth(350)
scrollFrame:SetScrollChild(contentFrame)

-- Initialize enabled buffs in database
local function initializeEnabledBuffs()
	if not addon or not addon.db then return end
	
	-- Initialize enabledFlasks
	if not addon.db.enabledFlasks then
		addon.db.enabledFlasks = {}
	end
	-- Set all flasks to enabled by default if not set
	for flaskName, _ in pairs(flasks) do
		if addon.db.enabledFlasks[flaskName] == nil then
			addon.db.enabledFlasks[flaskName] = true
		end
	end
	
	-- Initialize enabledElixirs (Battle Elixirs)
	if not addon.db.enabledElixirs then
		addon.db.enabledElixirs = {}
	end
	-- Set all battle elixirs to enabled by default if not set
	for elixirName, _ in pairs(battleElixirs) do
		if addon.db.enabledElixirs[elixirName] == nil then
			addon.db.enabledElixirs[elixirName] = true
		end
	end
	
	-- Initialize enabledGuardianElixirs
	if not addon.db.enabledGuardianElixirs then
		addon.db.enabledGuardianElixirs = {}
	end
	-- Set all guardian elixirs to enabled by default if not set
	for elixirName, _ in pairs(guardianElixirs) do
		if addon.db.enabledGuardianElixirs[elixirName] == nil then
			addon.db.enabledGuardianElixirs[elixirName] = true
		end
	end
	
	-- Initialize enabledProtections
	if not addon.db.enabledProtections then
		addon.db.enabledProtections = {}
	end
	-- Set all protections to disabled by default if not set
	for protName, _ in pairs(protections) do
		if addon.db.enabledProtections[protName] == nil then
			addon.db.enabledProtections[protName] = false
		end
	end
end

-- Store UI elements
local uiElements = {}

-- Function to create a checkbox for a buff
local function createBuffCheckbox(buffName, category, parent, yOffset)
	local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	check:SetWidth(20)
	check:SetHeight(20)
	check:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
	
	local label = check:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("LEFT", check, "RIGHT", 5, 0)
	-- Use display name with colors if available, otherwise use original name
	local displayText = displayNames[buffName] or buffName
	label:SetText(displayText)
	label:SetJustifyH("LEFT")
	
	-- Set initial checked state - read from database after initialization
	local dbKey = "enabled" .. category
	-- Ensure database tables exist and are initialized
	if addon and addon.db then
		if not addon.db[dbKey] then
			addon.db[dbKey] = {}
		end
		-- Read the value from database (should be set by initializeEnabledBuffs or from saved data)
		local savedValue = addon.db[dbKey][buffName]
		local finalState
		if savedValue ~= nil then
			-- Value exists in database, use it (explicitly convert to boolean)
			finalState = (savedValue == true)
			check:SetChecked(finalState)
		else
			-- Value doesn't exist, use default (protections false, flasks/elixirs true)
			finalState = (category ~= "Protections")
			check:SetChecked(finalState)
			-- Initialize in database
			addon.db[dbKey][buffName] = finalState
		end
		-- Store the initial state on the checkbox object
		check.currentState = finalState
	else
		-- Default: protections false, flasks/elixirs true
		check:SetChecked(category ~= "Protections")
	end
	
	-- Store reference to buffName and category for debugging
	check.buffName = buffName
	check.category = category
	
	-- Store the current state on the checkbox object so we can track changes
	check.currentState = check:GetChecked() or false
	
	-- Add tooltip support for flasks and elixirs
	local itemID = itemIDs[buffName]
	if itemID then
		-- Function to show tooltip
		local function showTooltip(self)
			if GameTooltip then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink("item:" .. itemID)
				GameTooltip:Show()
			end
		end
		
		-- Function to hide tooltip
		local function hideTooltip(self)
			if GameTooltip then
				GameTooltip:Hide()
			end
		end
		
		-- Add tooltip to checkbox
		check:SetScript("OnEnter", showTooltip)
		check:SetScript("OnLeave", hideTooltip)
		
		-- Create a transparent frame over the label for tooltip support
		-- (FontString doesn't support EnableMouse in WoW 3.3.5)
		local tooltipFrame = CreateFrame("Frame", nil, check:GetParent())
		tooltipFrame:SetPoint("LEFT", label, "LEFT", 0, 0)
		tooltipFrame:SetPoint("RIGHT", label, "RIGHT", 0, 0)
		tooltipFrame:SetPoint("TOP", label, "TOP", 0, 0)
		tooltipFrame:SetPoint("BOTTOM", label, "BOTTOM", 0, 0)
		tooltipFrame:EnableMouse(true)
		tooltipFrame:SetScript("OnEnter", showTooltip)
		tooltipFrame:SetScript("OnLeave", hideTooltip)
	end
	
	-- OnClick handler - use stored values from the checkbox
	check:SetScript("OnClick", function(self)
		-- Refresh addon reference
		addon = _G.SpyingGnome
		if addon and addon.db then
			-- Use stored category and buffName from the checkbox
			local checkCategory = self.category or category
			local checkBuffName = self.buffName or buffName
			local dbKey = "enabled" .. checkCategory
			if not addon.db[dbKey] then
				addon.db[dbKey] = {}
			end
			-- In WoW, OnClick fires BEFORE the state changes, so the new state is the opposite
			-- Use the stored current state and invert it
			local newState = not (self.currentState or false)
			-- Update our stored state
			self.currentState = newState
			-- Save the new checked state (explicitly as boolean)
			addon.db[dbKey][checkBuffName] = newState
		end
	end)
	
	check:Show()
	return check
end

-- Build UI
local function buildBuffConfigUI()
	-- Refresh addon reference
	addon = _G.SpyingGnome
	if not addon or not addon.db then
		print("SpyingGnome: Addon not loaded yet. Please wait a moment and try again.")
		return
	end
	
	-- Initialize enabled buffs (only sets defaults for nil values, preserves existing saved values)
	initializeEnabledBuffs()
	
	-- Clear existing UI elements
	for _, element in pairs(uiElements) do
		if element and element.Hide then
			element:Hide()
		end
	end
	wipe(uiElements)
	
	local yOffset = -10
	local spacing = -20
	
	-- Flasks section
	local flasksHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	flasksHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
	flasksHeader:SetText("Flasks")
	flasksHeader:SetTextColor(1, 1, 0.5, 1)
	uiElements.flasksHeader = flasksHeader
	yOffset = yOffset + spacing
	
	-- Sort flask names for display
	local flaskNames = {}
	for name, _ in pairs(flasks) do
		table.insert(flaskNames, name)
	end
	table.sort(flaskNames)
	
	for i, flaskName in ipairs(flaskNames) do
		local check = createBuffCheckbox(flaskName, "Flasks", contentFrame, yOffset)
		uiElements["flask_" .. flaskName] = check
		yOffset = yOffset + spacing
	end
	
	-- Battle Elixirs section
	yOffset = yOffset + spacing -- Add some space between sections
	local battleElixirsHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	battleElixirsHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
	battleElixirsHeader:SetText("Battle Elixirs")
	battleElixirsHeader:SetTextColor(1, 1, 0.5, 1)
	uiElements.battleElixirsHeader = battleElixirsHeader
	yOffset = yOffset + spacing
	
	-- Sort battle elixir names for display
	local battleElixirNames = {}
	local bottomElixirs = {"Ground Scorpok Assay", "R.O.I.D.S."}
	local bottomElixirsSet = {}
	for _, name in ipairs(bottomElixirs) do
		bottomElixirsSet[name] = true
	end
	
	-- Add all elixirs except the bottom ones, then sort
	for name, _ in pairs(battleElixirs) do
		if not bottomElixirsSet[name] then
			table.insert(battleElixirNames, name)
		end
	end
	table.sort(battleElixirNames)
	
	-- Add bottom elixirs at the end
	for _, name in ipairs(bottomElixirs) do
		if battleElixirs[name] then
			table.insert(battleElixirNames, name)
		end
	end
	
	for i, elixirName in ipairs(battleElixirNames) do
		local check = createBuffCheckbox(elixirName, "Elixirs", contentFrame, yOffset)
		uiElements["battleElixir_" .. elixirName] = check
		yOffset = yOffset + spacing
	end
	
	-- Guardian Elixirs section
	yOffset = yOffset + spacing -- Add some space between sections
	local guardianElixirsHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	guardianElixirsHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
	guardianElixirsHeader:SetText("Guardian Elixirs")
	guardianElixirsHeader:SetTextColor(1, 1, 0.5, 1)
	uiElements.guardianElixirsHeader = guardianElixirsHeader
	yOffset = yOffset + spacing
	
	-- Sort guardian elixir names for display
	local guardianElixirNames = {}
	local bottomGuardianElixirs = {"Cerebral Cortex Compound", "Gizzard Gum"}
	local bottomGuardianElixirsSet = {}
	for _, name in ipairs(bottomGuardianElixirs) do
		bottomGuardianElixirsSet[name] = true
	end
	
	for name, _ in pairs(guardianElixirs) do
		if not bottomGuardianElixirsSet[name] then
			table.insert(guardianElixirNames, name)
		end
	end
	table.sort(guardianElixirNames)
	
	-- Add bottom guardian elixirs at the end
	for _, name in ipairs(bottomGuardianElixirs) do
		if guardianElixirs[name] then
			table.insert(guardianElixirNames, name)
		end
	end
	
	for i, elixirName in ipairs(guardianElixirNames) do
		local check = createBuffCheckbox(elixirName, "GuardianElixirs", contentFrame, yOffset)
		uiElements["guardianElixir_" .. elixirName] = check
		yOffset = yOffset + spacing
	end
	
	-- Protections section
	yOffset = yOffset + spacing -- Add some space between sections
	local protectionsHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	protectionsHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
	protectionsHeader:SetText("Protections")
	protectionsHeader:SetTextColor(1, 1, 0.5, 1)
	uiElements.protectionsHeader = protectionsHeader
	yOffset = yOffset + spacing
	
	-- Sort protection names for display
	local protNames = {}
	for name, _ in pairs(protections) do
		table.insert(protNames, name)
	end
	table.sort(protNames)
	
	for i, protName in ipairs(protNames) do
		local check = createBuffCheckbox(protName, "Protections", contentFrame, yOffset)
		uiElements["prot_" .. protName] = check
		yOffset = yOffset + spacing
	end
	
	-- Set content frame height based on content
	contentFrame:SetHeight(math.abs(yOffset) + 20)
end

-- Toggle function
local function toggleBuffConfig()
	-- Refresh addon reference
	addon = _G.SpyingGnome
	if not addon or not addon.db then
		print("SpyingGnome: Addon not loaded yet. Please wait a moment and try again.")
		return
	end
	
	if buffConfigFrame:IsVisible() then
		buffConfigFrame:Hide()
	else
		buildBuffConfigUI()
		buffConfigFrame:Show()
	end
end

-- Expose toggle function globally
_G.SpyingGnomeToggleBuffConfig = toggleBuffConfig

-- Show UI when frame is shown
buffConfigFrame:SetScript("OnShow", function()
	buildBuffConfigUI()
end)
