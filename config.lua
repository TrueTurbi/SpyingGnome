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
	
	-- For protection checkboxes, add click handler to prevent toggling when parent is disabled
	local protectionKeys = {"checkFire", "checkArcane", "checkShadow", "checkFrost", "checkNature", "checkHoly"}
	local isProtectionKey = false
	for _, protKey in ipairs(protectionKeys) do
		if key == protKey then
			isProtectionKey = true
			break
		end
	end
	
	if isProtectionKey then
		-- Hook OnClick to prevent toggling if parent is disabled
		local originalOnClick = check:GetScript("OnClick")
		check:SetScript("OnClick", function(self, button, down)
			-- Check if protection checking is enabled
			if not (addon and addon.db and addon.db.checkProtection) then
				-- Parent is disabled, prevent toggle by reverting state
				self:SetChecked(not self:GetChecked())
				return
			end
			-- Parent is enabled, allow normal click behavior
			if originalOnClick then
				originalOnClick(self, button, down)
			end
		end)
	end
	
	-- For "Print a status report after a ready check", make it dependent on "Enable Status Report Printing in Raid Chat"
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
		return
	end
	
	local title = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT", 0, -5)
	title:SetText("SpyingGnome")
	uiElements.title = title

	local subtitle = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	subtitle:SetWidth(240)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetText("Gnomes will overrule the world. Thank you for using the addon!")
	uiElements.subtitle = subtitle

	local statusPrintInRaidChat = newCheckbox("Enable Status Report Printing in Raid Chat", "statusPrintInRaidChat", false, contentFrame)
	statusPrintInRaidChat:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
	uiElements.statusPrintInRaidChat = statusPrintInRaidChat

	local statusPrint = newCheckbox("Print a status report after a ready check", "statusPrintAtReady", true, contentFrame)
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

	local party = newCheckbox("Party with the gnome", "partyWithTheGnome", false, contentFrame)
	party:SetPoint("TOPLEFT", statusPrint, "BOTTOMLEFT", -10, -3)
	uiElements.partyWithTheGnome = party

	local checkFlasks = newCheckbox("Check for missing flasks", "checkFlasks", false, contentFrame)
	checkFlasks:SetPoint("TOPLEFT", party, "BOTTOMLEFT", 0, -4)
	uiElements.checkFlasks = checkFlasks

	local checkFood = newCheckbox("Check for missing food buff", "checkFood", false, contentFrame)
	checkFood:SetPoint("TOPLEFT", checkFlasks, "BOTTOMLEFT", 0, -4)
	uiElements.checkFood = checkFood

	local checkProtection = newCheckbox("Check for missing protection buffs", "checkProtection", false, contentFrame)
	checkProtection:SetPoint("TOPLEFT", checkFood, "BOTTOMLEFT", 0, -4)
	uiElements.checkProtection = checkProtection

	local checkFire = newCheckbox("Fire Protection", "checkFire", true, contentFrame)
	checkFire:SetPoint("TOPLEFT", checkProtection, "BOTTOMLEFT", 10, -1)
	uiElements.checkFire = checkFire

	local checkArcane = newCheckbox("Arcane Protection", "checkArcane", true, contentFrame)
	checkArcane:SetPoint("TOPLEFT", checkFire, "BOTTOMLEFT", 0, -1)
	uiElements.checkArcane = checkArcane

	local checkShadow = newCheckbox("Shadow Protection", "checkShadow", true, contentFrame)
	checkShadow:SetPoint("TOPLEFT", checkArcane, "BOTTOMLEFT", 0, -1)
	uiElements.checkShadow = checkShadow

	local checkFrost = newCheckbox("Frost Protection", "checkFrost", true, contentFrame)
	checkFrost:SetPoint("TOPLEFT", checkShadow, "BOTTOMLEFT", 0, -1)
	uiElements.checkFrost = checkFrost

	local checkNature = newCheckbox("Nature Protection", "checkNature", true, contentFrame)
	checkNature:SetPoint("TOPLEFT", checkFrost, "BOTTOMLEFT", 0, -1)
	uiElements.checkNature = checkNature

	local checkHoly = newCheckbox("Holy Protection", "checkHoly", true, contentFrame)
	checkHoly:SetPoint("TOPLEFT", checkNature, "BOTTOMLEFT", 0, -1)
	uiElements.checkHoly = checkHoly

	-- Add handler to parent checkbox to uncheck all protection checkboxes when parent is unchecked
	local originalProtectionOnClick = checkProtection:GetScript("OnClick")
	checkProtection:SetScript("OnClick", function(self, button, down)
		-- Call original handler first
		if originalProtectionOnClick then
			originalProtectionOnClick(self, button, down)
		end
		-- If parent is now unchecked, uncheck all protection checkboxes
		if not self:GetChecked() then
			local protectionBoxes = {
				{box = checkFire, key = "checkFire"},
				{box = checkArcane, key = "checkArcane"},
				{box = checkShadow, key = "checkShadow"},
				{box = checkFrost, key = "checkFrost"},
				{box = checkNature, key = "checkNature"},
				{box = checkHoly, key = "checkHoly"}
			}
			for _, item in ipairs(protectionBoxes) do
				if item.box and addon and addon.db then
					item.box:SetChecked(false)
					addon.db[item.key] = false
				end
			end
		end
	end)


	-- Manual check button
	local checkButton = CreateFrame("Button", "SpyingGnomeCheckButton", contentFrame, "UIPanelButtonTemplate")
	checkButton:SetWidth(180)
	checkButton:SetHeight(22)
	checkButton:SetText("Check Flasks, Food & Protection")
	checkButton:SetPoint("TOPLEFT", checkHoly, "BOTTOMLEFT", -10, -6)
	checkButton:SetScript("OnClick", function()
		if addon and addon.ManualCheck then
			local hasIssues = addon:ManualCheck()
			if not hasIssues then
				print("SpyingGnome: All raid members have flasks, food, and protection buffs!")
			end
		else
			print("SpyingGnome: Addon not loaded yet. Please wait a moment and try again.")
		end
	end)
	uiElements.checkButton = checkButton

	local hint = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	hint:SetPoint("TOPLEFT", checkButton, "BOTTOMLEFT", 0, -4)
	hint:SetWidth(240)
	hint:SetJustifyH("CENTER")
	hint:SetJustifyV("TOP")
	hint:SetNonSpaceWrap(true)
	hint:SetText("|cff44ff44Use the button above to manually check for missing flasks, food, and protection buffs.|r")
	hint:Show()
	uiElements.hint = hint
	
	-- Update content frame height
	contentFrame:SetHeight(math.abs(hint:GetBottom() - title:GetTop()) + 20)
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
