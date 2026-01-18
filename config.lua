local addon = _G.SpyingGnome

-- Create main config frame
local configFrame = CreateFrame("Frame", "SpyingGnomeConfigFrame", UIParent)
configFrame:SetWidth(320)
configFrame:SetHeight(500)
configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
configFrame:SetMovable(true)
configFrame:EnableMouse(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
configFrame:Hide()

-- Create backdrop
configFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
configFrame:SetBackdropColor(0, 0, 0, 1)

-- Title bar
local titleBar = CreateFrame("Frame", nil, configFrame)
titleBar:SetHeight(24)
titleBar:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", 0, 0)
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
titleText:SetText("SpyingGnome Configuration")

-- Close button
local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeButton:SetScale(0.8)
closeButton:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -3, -3)
closeButton:SetScript("OnClick", function() configFrame:Hide() end)

-- Scroll frame for content
local scrollFrame = CreateFrame("ScrollFrame", "SpyingGnomeScrollFrame", configFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 15, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -30, 15)

local contentFrame = CreateFrame("Frame", "SpyingGnomeContentFrame", scrollFrame)
contentFrame:SetWidth(260)
contentFrame:SetHeight(1)
scrollFrame:SetScrollChild(contentFrame)

local function checkFunc(key, setting) 
	if addon and addon.db then
		addon.db[key] = setting == "1" and true or false 
	end
	-- If protection checkbox was toggled, no visual updates needed
	-- The OnClick hook handles preventing clicks when disabled
end

local function newCheckbox(label, key, small, parent)
	parent = parent or contentFrame
	local check = CreateFrame("CheckButton", "SpyingGnomeCheck" .. key, parent, small and "InterfaceOptionsSmallCheckButtonTemplate" or "InterfaceOptionsCheckButtonTemplate")
	
	-- Set checked state
	if addon and addon.db and addon.db[key] ~= nil then
	check:SetChecked(addon.db[key])
	else
		check:SetChecked(false)
	end
	
	check.key = key
	check.setFunc = function(setting) checkFunc(check.key, setting) end
	
	-- Get and configure text
	local text = _G[check:GetName() .. "Text"]
	if text then
		text:SetText(label)
		if not small then
			text:SetWidth(220)
			text:SetJustifyH("LEFT")
			text:SetJustifyV("TOP")
			text:SetNonSpaceWrap(true)
		else
			text:SetWidth(200)
			text:SetJustifyH("LEFT")
			text:SetJustifyV("TOP")
			text:SetNonSpaceWrap(true)
		end
	end
	
	-- For "Print to raid chat after a ready check", make it dependent on "Enable Status Report Printing in Raid Chat"
	-- This will be set up after both checkboxes are created
	
	check:Show()
	return check
end

-- Store UI elements to avoid recreating
local uiElements = {}

-- Build UI (only once)
local function buildUI()
	-- Refresh addon reference
	addon = _G.SpyingGnome
	
	-- Only build if not already built
	if uiElements.title then
		-- Just update checked states
		for key, check in pairs(uiElements) do
			if type(check) == "table" and check.GetChecked and addon and addon.db then
				if addon.db[key] ~= nil then
					check:SetChecked(addon.db[key])
				end
	end
end
		
		-- Update button state based on master switch
		if uiElements.checkButton and uiElements.enableSpyingGnome then
			if uiElements.enableSpyingGnome:GetChecked() then
				uiElements.checkButton:SetAlpha(1.0)
			else
				uiElements.checkButton:SetAlpha(0.5)
			end
		end
		
		return
	end
	
	local title = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT", 0, -5)
	title:SetText("SpyingGnome v1.3.2")
	uiElements.title = title

	local subtitle = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	subtitle:SetWidth(240)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetText("Gnomes will overrule the world. Thank you for using the addon!")
	uiElements.subtitle = subtitle

	-- Configuration button (moved to top and centered)
	local configButton = CreateFrame("Button", "SpyingGnomeConfigButton", contentFrame, "UIPanelButtonTemplate")
	configButton:SetWidth(180)
	configButton:SetHeight(22)
	configButton:SetText("Configuration")
	-- Center horizontally on contentFrame, position vertically below subtitle
	configButton:SetPoint("TOP", contentFrame, "TOP", 0, -60)
	configButton:SetScript("OnClick", function()
		if _G.SpyingGnomeToggleBuffConfig then
			_G.SpyingGnomeToggleBuffConfig()
		else
			print("SpyingGnome: Buff configuration not loaded yet. Please wait a moment and try again.")
		end
	end)
	uiElements.configButton = configButton

	local enableSpyingGnome = newCheckbox("Enable SpyingGnome", "enableSpyingGnome", false, contentFrame)
	enableSpyingGnome:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -40)
	uiElements.enableSpyingGnome = enableSpyingGnome

	local statusPrintInRaidChat = newCheckbox("Enable Status Report Printing in Raid Chat", "statusPrintInRaidChat", false, contentFrame)
	statusPrintInRaidChat:SetPoint("TOPLEFT", enableSpyingGnome, "BOTTOMLEFT", 0, -4)
	uiElements.statusPrintInRaidChat = statusPrintInRaidChat

	local statusPrint = newCheckbox("Print to raid chat after a ready check", "statusPrintAtReady", true, contentFrame)
	statusPrint:SetPoint("TOPLEFT", statusPrintInRaidChat, "BOTTOMLEFT", 10, -1)
	uiElements.statusPrintAtReady = statusPrint
	
	-- Add handler to dependent checkbox to prevent toggling when parent is disabled
	local originalStatusPrintOnClick = statusPrint:GetScript("OnClick")
	statusPrint:SetScript("OnClick", function(self, button, down)
		-- Check if parent checkbox is checked (check the actual checkbox state)
		if not statusPrintInRaidChat:GetChecked() then
			-- Parent is disabled, prevent toggle by reverting state
			self:SetChecked(not self:GetChecked())
			return
		end
		-- Parent is enabled, allow normal click behavior
		if originalStatusPrintOnClick then
			originalStatusPrintOnClick(self, button, down)
		end
	end)
	
	-- Add handler to parent checkbox to uncheck dependent checkbox when parent is unchecked
	local originalParentOnClick = statusPrintInRaidChat:GetScript("OnClick")
	statusPrintInRaidChat:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalParentOnClick then
			originalParentOnClick(self, button, down)
		end
		-- If parent is now unchecked, uncheck the dependent checkbox
		if not self:GetChecked() then
			if statusPrint and addon and addon.db then
				statusPrint:SetChecked(false)
				addon.db.statusPrintAtReady = false
			end
		end
	end)

	-- Main checkboxes for what to check
	local checkFlasks = newCheckbox("Check for missing Flasks", "checkFlasks", false, contentFrame)
	checkFlasks:SetPoint("TOPLEFT", statusPrint, "BOTTOMLEFT", -10, -4)
	uiElements.checkFlasks = checkFlasks

	local checkElixirs = newCheckbox("Check for missing Battle Elixirs", "checkElixirs", false, contentFrame)
	checkElixirs:SetPoint("TOPLEFT", checkFlasks, "BOTTOMLEFT", 0, -4)
	uiElements.checkElixirs = checkElixirs
	
	local checkGuardianElixirs = newCheckbox("Check for missing Guardian Elixirs", "checkGuardianElixirs", false, contentFrame)
	checkGuardianElixirs:SetPoint("TOPLEFT", checkElixirs, "BOTTOMLEFT", 0, -4)
	uiElements.checkGuardianElixirs = checkGuardianElixirs

	local checkFood = newCheckbox("Check for missing Food buff", "checkFood", false, contentFrame)
	checkFood:SetPoint("TOPLEFT", checkGuardianElixirs, "BOTTOMLEFT", 0, -4)
	uiElements.checkFood = checkFood

	local checkProtection = newCheckbox("Check for missing Protection buffs", "checkProtection", false, contentFrame)
	checkProtection:SetPoint("TOPLEFT", checkFood, "BOTTOMLEFT", 0, -4)
	uiElements.checkProtection = checkProtection

	-- Mutual exclusivity between Flasks and Elixirs:
	-- If Flasks is checked, automatically uncheck both Battle and Guardian Elixirs
	-- If either Elixir checkbox is checked, automatically uncheck Flasks
	
	-- Handler for Flasks checkbox
	local originalFlasksOnClick = checkFlasks:GetScript("OnClick")
	checkFlasks:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalFlasksOnClick then
			originalFlasksOnClick(self, button, down)
		end
		if self:GetChecked() then
			-- Flasks enabled: disable both Elixir checks
			if checkElixirs and addon and addon.db then
				checkElixirs:SetChecked(false)
				addon.db.checkElixirs = false
			end
			if checkGuardianElixirs and addon and addon.db then
				checkGuardianElixirs:SetChecked(false)
				addon.db.checkGuardianElixirs = false
			end
		end
	end)

	-- Handler for Battle Elixirs checkbox
	local originalElixirsOnClick = checkElixirs:GetScript("OnClick")
	checkElixirs:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalElixirsOnClick then
			originalElixirsOnClick(self, button, down)
		end
		-- If Battle Elixirs is now checked, uncheck Flasks
		if self:GetChecked() then
			if checkFlasks and addon and addon.db then
				checkFlasks:SetChecked(false)
				addon.db.checkFlasks = false
			end
		end
	end)
	
	-- Handler for Guardian Elixirs checkbox
	local originalGuardianOnClick = checkGuardianElixirs:GetScript("OnClick")
	checkGuardianElixirs:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalGuardianOnClick then
			originalGuardianOnClick(self, button, down)
		end
		-- If Guardian Elixirs is now checked, uncheck Flasks
		if self:GetChecked() then
			if checkFlasks and addon and addon.db then
				checkFlasks:SetChecked(false)
				addon.db.checkFlasks = false
			end
		end
	end)
	
	-- Helper function to make a checkbox dependent on enableSpyingGnome
	local function makeDependentOnMaster(checkbox)
		if not checkbox then return end
		local originalOnClick = checkbox:GetScript("OnClick")
		checkbox:SetScript("OnClick", function(self, button, down)
			-- Check if master switch is enabled
			if not (enableSpyingGnome and enableSpyingGnome:GetChecked()) then
				-- Master is disabled, prevent toggle by reverting state
				self:SetChecked(not self:GetChecked())
				return
			end
			-- Master is enabled, allow normal click behavior
			if originalOnClick then
				originalOnClick(self, button, down)
			end
		end)
	end

	-- Make all checkboxes dependent on enableSpyingGnome (except enableSpyingGnome itself)
	makeDependentOnMaster(statusPrintInRaidChat)
	makeDependentOnMaster(statusPrint)
	makeDependentOnMaster(checkFlasks)
	makeDependentOnMaster(checkElixirs)
	makeDependentOnMaster(checkGuardianElixirs)
	makeDependentOnMaster(checkFood)
	makeDependentOnMaster(checkProtection)

	-- Manual check button (created early so we can reference it in master switch handler)
	local checkButton = CreateFrame("Button", "SpyingGnomeCheckButton", contentFrame, "UIPanelButtonTemplate")
	checkButton:SetWidth(180)
	checkButton:SetHeight(22)
	checkButton:SetText("Perform check")
	-- Position below checkProtection, centered horizontally on contentFrame
	checkButton:SetPoint("TOPLEFT", checkProtection, "BOTTOMLEFT", 40, -25)
	checkButton:Show()
	uiElements.checkButton = checkButton

	-- Add handler to master checkbox to uncheck all dependent checkboxes when unchecked
	local originalMasterOnClick = enableSpyingGnome:GetScript("OnClick")
	enableSpyingGnome:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalMasterOnClick then
			originalMasterOnClick(self, button, down)
		end
		-- Update button visual state
		if checkButton then
			if self:GetChecked() then
				checkButton:SetAlpha(1.0)
			else
				checkButton:SetAlpha(0.5)
			end
		end
		-- If master is now unchecked, uncheck all dependent checkboxes
		if not self:GetChecked() then
			local dependentBoxes = {
				{box = statusPrintInRaidChat, key = "statusPrintInRaidChat"},
				{box = statusPrint, key = "statusPrintAtReady"},
				{box = checkFlasks, key = "checkFlasks"},
				{box = checkElixirs, key = "checkElixirs"},
				{box = checkGuardianElixirs, key = "checkGuardianElixirs"},
				{box = checkFood, key = "checkFood"},
				{box = checkProtection, key = "checkProtection"}
			}
			for _, item in ipairs(dependentBoxes) do
				if item.box and addon and addon.db then
					item.box:SetChecked(false)
					addon.db[item.key] = false
				end
			end
		end
	end)
	-- Set initial button state
	if enableSpyingGnome:GetChecked() then
		checkButton:SetAlpha(1.0)
	else
		checkButton:SetAlpha(0.5)
	end

	checkButton:SetScript("OnClick", function()
		-- Check if SpyingGnome is enabled
		if not (addon and addon.db and addon.db.enableSpyingGnome) then
			return
		end
		
		-- Only operate in raid groups (addon is raid-only)
		if GetNumRaidMembers() == 0 then
			print("SpyingGnome: You are not in a raid party.")
			return
		end
		
		if addon and addon.ManualCheck then
			-- Check if all checks are disabled
			local allChecksDisabled =
				not addon.db.checkFlasks and
				not addon.db.checkElixirs and
				not addon.db.checkGuardianElixirs and
				not addon.db.checkFood and
				not addon.db.checkProtection
			
			if allChecksDisabled then
				print("[SG]: You have not selected any checks. Check your configuration.")
				return
			end
			
			local hasIssues = addon:ManualCheck()
			if not hasIssues then
				-- Verify that enabled checks actually have items selected in Configuration
				local hasValidChecks = true
				
				-- Flasks
				if addon.db.checkFlasks then
					local hasEnabledFlasks = false
					if addon.db.enabledFlasks and _G.SpyingGnomeFlasks then
						for flaskName, _ in pairs(_G.SpyingGnomeFlasks) do
							if addon.db.enabledFlasks[flaskName] ~= false then
								hasEnabledFlasks = true
								break
							end
						end
					end
					if not hasEnabledFlasks then
						hasValidChecks = false
					end
				end
				
				-- Battle Elixirs
				if addon.db.checkElixirs then
					local hasEnabledBattleElixirs = false
					if addon.db.enabledElixirs and _G.SpyingGnomeBattleElixirs then
						for elixirName, _ in pairs(_G.SpyingGnomeBattleElixirs) do
							if addon.db.enabledElixirs[elixirName] ~= false then
								hasEnabledBattleElixirs = true
								break
							end
						end
					end
					if not hasEnabledBattleElixirs then
						hasValidChecks = false
					end
				end
				
				-- Guardian Elixirs
				if addon.db.checkGuardianElixirs then
					local hasEnabledGuardianElixirs = false
					if addon.db.enabledGuardianElixirs and _G.SpyingGnomeGuardianElixirs then
						for elixirName, _ in pairs(_G.SpyingGnomeGuardianElixirs) do
							if addon.db.enabledGuardianElixirs[elixirName] ~= false then
								hasEnabledGuardianElixirs = true
								break
							end
						end
					end
					if not hasEnabledGuardianElixirs then
						hasValidChecks = false
					end
				end
				
				-- Protections
				if addon.db.checkProtection then
					local hasEnabledProtections = false
					if addon.db.enabledProtections and _G.SpyingGnomeProtections then
						for protName, _ in pairs(_G.SpyingGnomeProtections) do
							if addon.db.enabledProtections[protName] == true then
								hasEnabledProtections = true
								break
							end
						end
					end
					if not hasEnabledProtections then
						hasValidChecks = false
					end
				end
				
				if hasValidChecks then
					print("SpyingGnome: All raiders meet the configured consumable criteria.")
				end
			end
		else
			print("SpyingGnome: Addon not loaded yet. Please wait a moment and try again.")
		end
	end)
	uiElements.checkButton = checkButton

	local hint = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	hint:SetPoint("TOP", checkButton, "BOTTOM", 0, -4)
	hint:Show()
	hint:SetWidth(240)
	hint:SetJustifyH("CENTER")
	hint:SetJustifyV("TOP")
	hint:SetNonSpaceWrap(true)
	hint:SetText("|cff44ff44Use the button above to manually check for missing flasks, battle elixirs, guardian elixirs, food, and protection buffs.|r")
	hint:Show()
	uiElements.hint = hint

	local configHint = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	configHint:SetPoint("TOP", hint, "BOTTOM", 0, -4)
	configHint:SetWidth(240)
	configHint:SetJustifyH("CENTER")
	configHint:SetJustifyV("TOP")
	configHint:SetNonSpaceWrap(true)
	configHint:SetText("|cff44ff44Use the Configuration button at the top to change the consumables the addon checks.|r")
	configHint:Show()
	uiElements.configHint = configHint
	
	-- Update content frame height to include all content (from title top to configHint bottom)
	local titleTop = title:GetTop()
	local configHintBottom = configHint:GetBottom()
	-- GetBottom returns negative values, so we need to account for that
	-- Add extra padding to ensure the green text is fully visible
	local contentHeight = titleTop - configHintBottom + 110
	contentFrame:SetHeight(contentHeight)
	
	-- Resize configFrame to match content
	local titleBarHeight = 24
	local scrollFrameTopPadding = 10
	local scrollFrameBottomPadding = 15
	local contentHeight = contentFrame:GetHeight()
	local totalHeight = titleBarHeight + scrollFrameTopPadding + contentHeight + scrollFrameBottomPadding
	configFrame:SetHeight(totalHeight)
end

-- Show/hide function
local function toggleConfig()
	if configFrame:IsShown() then
		configFrame:Hide()
	else
		buildUI()
		configFrame:Show()
	end
end

-- Chat command handler
SLASH_SPYINGGNOME1 = "/spyinggnome"
SLASH_SPYINGGNOME2 = "/sg"
SlashCmdList["SPYINGGNOME"] = function(msg)
	toggleConfig()
end

-- Build UI when frame is shown
configFrame:SetScript("OnShow", function()
	buildUI()
end)
