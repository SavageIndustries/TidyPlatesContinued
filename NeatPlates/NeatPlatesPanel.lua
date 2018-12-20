---------------------------------------------------------------------------------------------------------------------
-- Neat Plates Interface Panel
---------------------------------------------------------------------------------------------------------------------

local addonName, NeatPlatesInternal = ...
NeatPlatesPanel = {}
NeatPlatesHubMenus = NeatPlatesHubMenus or {}

local SetTheme = NeatPlatesInternal.SetTheme	-- Use the protected version

local version = GetAddOnMetadata("NeatPlates", "version")
local versionString = "|cFF666666"..version

local NeatPlatesInterfacePanel = PanelHelpers:CreatePanelFrame( "NeatPlatesInterfacePanel", "Neat Plates", nil )
InterfaceOptions_AddCategory(NeatPlatesInterfacePanel);

local CallIn = NeatPlatesUtility.CallIn
local copytable = NeatPlatesUtility.copyTable
local PanelHelpers = NeatPlatesUtility.PanelHelpers
local RGBToHex = NeatPlatesUtility.RGBToHex

local NO_AUTOMATION = "No Automation"
local DURING_COMBAT = "Show during Combat, Hide when Combat ends"
local OUT_OF_COMBAT = "Hide when Combat starts, Show when Combat ends"

local font = "Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf"
local yellow, blue, red, orange = "|cffffff00", "|cFF3782D1", "|cFFFF1100", "|cFFFF6906"

local function SetCastBars(enable)
	if enable then NeatPlates:EnableCastBars()
		else NeatPlates:DisableCastBars()
	end
end


-------------------------------------------------------------------------------------
--  Default Options
-------------------------------------------------------------------------------------

local FirstTryTheme = "Neon"
local DefaultProfile = "Default"

local ActiveProfile = "None"

NeatPlatesOptions = {

	ActiveTheme = nil,

	FirstSpecProfile = DefaultProfile,
	SecondSpecProfile = DefaultProfile,
	ThirdSpecProfile = DefaultProfile,
	FourthSpecProfile = DefaultProfile,

	FriendlyAutomation = NO_AUTOMATION,
	EnemyAutomation = NO_AUTOMATION,
	DisableCastBars = false,
	ForceBlizzardFont = false,
	HealthFrequent = true,

	NameplateClickableHeight = 1,
	NameplateClickableWidth = 1,
	WelcomeShown = false,
}

local NeatPlatesOptionsDefaults = copytable(NeatPlatesOptions)
local NeatPlatesThemeNames = {}

local AutomationDropdownItems = {
					{ text = NO_AUTOMATION, value = NO_AUTOMATION } ,
					{ text = DURING_COMBAT, value = DURING_COMBAT } ,
					{ text = OUT_OF_COMBAT, value = OUT_OF_COMBAT } ,
					}

local HubProfileList = {}


local function GetProfile()
	return ActiveProfile
end

NeatPlates.GetProfile = GetProfile


function NeatPlatesPanel.AddProfile(self, profileName )
	if profileName then
		HubProfileList[#HubProfileList+1] = { text = profileName, value = profileName, }
	end
end

function NeatPlatesPanel.RemoveProfile(self, profileName )
	table.foreach(HubProfileList, function(i, profile)
		if profile.value == profileName then HubProfileList[i] = nil end
	end)
end

local function SetNameplateVisibility(cvar, mode, combat)
	if mode == DURING_COMBAT then
		if combat then
			SetCVar(cvar, 1)
		else
			SetCVar(cvar, 0)
		end
	elseif mode == OUT_OF_COMBAT then
		if combat then
			SetCVar(cvar, 0)
		else
			SetCVar(cvar, 1)
		end
	end
end

local function GetClickableArea()
	return NeatPlatesOptions.NameplateClickableWidth or 1, NeatPlatesOptions.NameplateClickableHeight or 1
end

--local function SetClickableArea(width, height)
--	if width then NeatPlatesOptions.NameplateClickableWidth = width end
--	if height then NeatPlatesOptions.NameplateClickableHeight = height end
--end

--[[
function NeatPlates:ReloadTheme()
	SetTheme(NeatPlatesInternal.activeThemeName)
	NeatPlatesOptions.ActiveTheme = NeatPlatesInternal.activeThemeName
	NeatPlates:ForceUpdate()
end
--]]

NeatPlatesPanel.GetClickableArea = GetClickableArea

-------------------------------------------------------------------------------------
-- Panel
-------------------------------------------------------------------------------------
local ThemeDropdownMenuItems = {}

local function ApplyAutomationSettings()
	SetCastBars(not NeatPlatesOptions.DisableCastBars)
	NeatPlates.OverrideFonts( NeatPlatesOptions.ForceBlizzardFont)
	NeatPlates:SetHealthUpdateMethod(NeatPlatesOptions.HealthFrequent)

	if NeatPlatesOptions._EnableMiniButton then
		NeatPlatesUtility:CreateMinimapButton()
		NeatPlatesUtility:ShowMinimapButton()
	end

	NeatPlates:ForceUpdate()
end

--local function Role2Profile(spec)
--	local s = GetSpecializationInfo(spec)
--	if s ~= nil then	
--		local role = GetSpecializationRole(spec)
--		if role == "DAMAGER" then return "Damage" end
--		if role == "TANK" then return "Tank" end
--		if role == "HEALER" then return "Healer" end
--	end
--	return "Damage"
--end

local function VerifyPanelSettings()
	for k, v in pairs(NeatPlatesOptionsDefaults) do
		if NeatPlatesOptions[k] == nil then
			NeatPlatesOptions[k] = NeatPlatesOptionsDefaults[k]
		end
	end
end

local function ApplyPanelSettings()
	-- Theme
	SetTheme(NeatPlatesOptions.ActiveTheme or NeatPlatesUtility.GetCacheSet("SavedTemplate")["Theme"] or FirstTryTheme)

	-- This is here in case the theme couldn't be loaded, and the core falls back to defaults
	--NeatPlatesOptions.ActiveTheme = NeatPlatesInternal.activeThemeName
	--local theme = NeatPlatesThemeList[NeatPlatesInternal.activeThemeName]

	-- Load Hub Profile
	ActiveProfile = DefaultProfile

	local currentSpec = GetSpecialization()

	if currentSpec == 4 then
		ActiveProfile = NeatPlatesOptions.FourthSpecProfile
	elseif currentSpec == 3 then
		ActiveProfile = NeatPlatesOptions.ThirdSpecProfile
	elseif currentSpec == 2 then
		ActiveProfile = NeatPlatesOptions.SecondSpecProfile
	else
		ActiveProfile = NeatPlatesOptions.FirstSpecProfile
	end


	local theme = NeatPlates:GetTheme()

	if theme and theme.OnChangeProfile then theme:OnChangeProfile(ActiveProfile) end

	-- Store it for external usage
	--NeatPlatesOptions.ActiveProfile = ActiveProfile
	-- ** Use NeatPlates:GetProfile()

	-- Reset Widgets
	NeatPlates:ResetWidgets()
	NeatPlates:ForceUpdate()
end

local function GetPanelValues(panel)
	NeatPlatesOptions.ActiveTheme = panel.ActiveThemeDropdown:GetValue()

	NeatPlatesOptions.FriendlyAutomation = panel.AutoShowFriendly:GetValue()
	NeatPlatesOptions.EnemyAutomation = panel.AutoShowEnemy:GetValue()
	NeatPlatesOptions.DisableCastBars = panel.DisableCastBars:GetChecked()
	NeatPlatesOptions.ForceBlizzardFont = panel.ForceBlizzardFont:GetChecked()
	NeatPlatesOptions.HealthFrequent = panel.HealthFrequent:GetChecked()
	NeatPlatesOptions.NameplateClickableWidth = panel.NameplateClickableWidth:GetValue()
	NeatPlatesOptions.NameplateClickableHeight = panel.NameplateClickableHeight:GetValue()
	NeatPlatesOptions.PrimaryProfile = panel.FirstSpecDropdown:GetValue()

	NeatPlatesOptions.FirstSpecProfile = panel.FirstSpecDropdown:GetValue()
	NeatPlatesOptions.SecondSpecProfile = panel.SecondSpecDropdown:GetValue()
	NeatPlatesOptions.ThirdSpecProfile = panel.ThirdSpecDropdown:GetValue()
	NeatPlatesOptions.FourthSpecProfile = panel.FourthSpecDropdown:GetValue()
end


local function SetPanelValues(panel)
	panel.ActiveThemeDropdown:SetValue(NeatPlatesOptions.ActiveTheme)

	panel.FirstSpecDropdown:SetValue(NeatPlatesOptions.FirstSpecProfile)
	panel.SecondSpecDropdown:SetValue(NeatPlatesOptions.SecondSpecProfile)
	panel.ThirdSpecDropdown:SetValue(NeatPlatesOptions.ThirdSpecProfile)
	panel.FourthSpecDropdown:SetValue(NeatPlatesOptions.FourthSpecProfile)

	panel.DisableCastBars:SetChecked(NeatPlatesOptions.DisableCastBars)
	panel.ForceBlizzardFont:SetChecked(NeatPlatesOptions.ForceBlizzardFont)
	panel.HealthFrequent:SetChecked(NeatPlatesOptions.HealthFrequent)
	panel.NameplateClickableWidth:SetValue(NeatPlatesOptions.NameplateClickableWidth)
	panel.NameplateClickableHeight:SetValue(NeatPlatesOptions.NameplateClickableHeight)
	panel.AutoShowFriendly:SetValue(NeatPlatesOptions.FriendlyAutomation)
	panel.AutoShowEnemy:SetValue(NeatPlatesOptions.EnemyAutomation)
	
	-- CVars
	panel.NameplateTargetClamp:SetChecked((function() if GetCVar("nameplateTargetRadialPosition") == "1" then return true else return false end end)())
	panel.NameplateStacking:SetChecked((function() if GetCVar("nameplateMotion") == "1" then return true else return false end end)())
	panel.NameplateMaxDistance:SetValue(GetCVar("nameplateMaxDistance"))
	panel.NameplateOverlapH:SetValue(GetCVar("nameplateOverlapH"))
	panel.NameplateOverlapV:SetValue(GetCVar("nameplateOverlapV"))
end



local function OnValueChange(self)
	local panel = self:GetParent()
	GetPanelValues(panel)
	ApplyPanelSettings()
end


local function OnOkay(panel)
	panel = panel.MainFrame
	GetPanelValues(panel)
	ApplyPanelSettings()
	ApplyAutomationSettings()
end


-- Loads values from the saved vars, and preps for display of the panel
local function OnRefresh(panel)
	panel = panel.MainFrame
	if not panel then return end

	SetPanelValues(panel)

	------------------------
	-- Spec Notes
	------------------------
	local currentSpec = GetSpecialization()

	------------------------
	-- First Spec Details
	------------------------
	local id, name = GetSpecializationInfo(1)

	if name then
		if currentSpec == 1 then name = name.." (Active)" end
		panel.FirstSpecLabel:SetText(name)
	end
	------------------------
	-- Second Spec Details
	------------------------
	local id, name = GetSpecializationInfo(2)

	if name then
		if currentSpec == 2 then name = name.." (Active)" end
		panel.SecondSpecLabel:SetText(name)
	end
	------------------------
	-- Third Spec Details
	------------------------
	local id, name = GetSpecializationInfo(3)

	if name then
		if currentSpec == 3 then name = name.." (Active)" end
		panel.ThirdSpecLabel:SetText(name)
		panel.ThirdSpecLabel:Show()
		panel.ThirdSpecDropdown:Show()
	end
	------------------------
	-- Fourth Spec Details
	------------------------
	local id, name = GetSpecializationInfo(4)

	if name then
		if currentSpec == 4 then name = name.." (Active)" end
		panel.FourthSpecLabel:SetText(name)
		panel.FourthSpecLabel:Show()
		panel.FourthSpecDropdown:Show()
	end

end





local function CreateMenuTables()
	-- Convert the Theme List into a Menu List
	local themecount = 1

	ThemeDropdownMenuItems = {{text = "           ",},}

	if type(NeatPlatesThemeList) == "table" then
		for themename, themepointer in pairs(NeatPlatesThemeList) do
			NeatPlatesThemeNames[themecount] = themename
			--NeatPlatesThemeIndexes[themename] = themecount
			themecount = themecount + 1
		end
		-- Theme Choices
		for index, name in pairs(NeatPlatesThemeNames) do ThemeDropdownMenuItems[index] = {text = name, value = name } end
	end
	sort(ThemeDropdownMenuItems, function (a,b)
	  return (a.text < b.text)
    end)

end

local function OnMouseWheelScrollFrame(frame, value, name)
	local scrollbar = _G[frame:GetName() .. "ScrollBar"];
	local currentPosition = scrollbar:GetValue()
	local increment = 50

	-- Spin Up
	if ( value > 0 ) then scrollbar:SetValue(currentPosition - increment);
	-- Spin Down
	else scrollbar:SetValue(currentPosition + increment); end
end

local function BuildInterfacePanel(panel)
	local _panel = panel
	panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	panel:SetBackdropColor(0.06, 0.06, 0.06, .7)

	panel.Label:SetFont("Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf", 26)
	panel.Label:SetPoint("TOPLEFT", panel, "TOPLEFT", 16+6, -16-4)
	panel.Label:SetTextColor(255/255, 105/255, 6/255)

	panel.Version = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panel.Version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -16-4)
	panel.Version:SetHeight(15)
	panel.Version:SetWidth(350)
	panel.Version:SetJustifyH("RIGHT")
	panel.Version:SetJustifyV("TOP")
	panel.Version:SetText(versionString)
	panel.Version:SetFont("Interface\\Addons\\NeatPlates\\Media\\DefaultFont.ttf", 18)

	panel.DividerLine = panel:CreateTexture(nil, 'ARTWORK')
	panel.DividerLine:SetTexture("Interface\\Addons\\NeatPlatesHub\\shared\\ThinBlackLine")
	panel.DividerLine:SetSize( 500, 12)
	panel.DividerLine:SetPoint("TOPLEFT", panel.Label, "BOTTOMLEFT", -6, -12)

	-- Main Scrolled Frame
	------------------------------
	panel.MainFrame = CreateFrame("Frame")
	panel.MainFrame:SetWidth(412)
	panel.MainFrame:SetHeight(100) 		-- If the items inside the frame overflow, it automatically adjusts the height.

	-- Scrollable Panel Window
	------------------------------
	panel.ScrollFrame = CreateFrame("ScrollFrame","NeatPlates_Scrollframe", panel, "UIPanelScrollFrameTemplate")
	panel.ScrollFrame:SetPoint("LEFT", 16 )
	panel.ScrollFrame:SetPoint("TOP", panel.DividerLine, "BOTTOM", 0, -8 )
	panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 16 )
	panel.ScrollFrame:SetScrollChild(panel.MainFrame)
	panel.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

	-- Scroll Frame Border
	------------------------------
	panel.ScrollFrameBorder = CreateFrame("Frame", "NeatPlatesScrollFrameBorder", panel.ScrollFrame )
	panel.ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	panel.ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	panel.ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												--tile = true, tileSize = 16,
												edgeSize = 16,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	panel.ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	panel.ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 0)

	panel = panel.MainFrame
	----------------------------------------------
	-- Theme
	----------------------------------------------
	panel.ThemeCategoryTitle = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ThemeCategoryTitle:SetFont(font, 22)
	panel.ThemeCategoryTitle:SetText("Theme")
	panel.ThemeCategoryTitle:SetPoint("TOPLEFT", 20, -10)
	panel.ThemeCategoryTitle:SetTextColor(255/255, 105/255, 6/255)

	-- Dropdown
	panel.ActiveThemeDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesChooserDropdown", panel, ThemeDropdownMenuItems, NeatPlatesDefaultThemeName, nil, true)
	panel.ActiveThemeDropdown:SetPoint("TOPLEFT", panel.ThemeCategoryTitle, "BOTTOMLEFT", -20, -4)

	----------------------------------------------
	-- Profiles
	----------------------------------------------
	panel.ProfileLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ProfileLabel:SetFont(font, 22)
	panel.ProfileLabel:SetText("Profile")
	panel.ProfileLabel:SetPoint("TOPLEFT", panel.ActiveThemeDropdown, "BOTTOMLEFT", 20, -20)
	panel.ProfileLabel:SetTextColor(255/255, 105/255, 6/255)

	---------------
	-- Column 1
	---------------
	-- Spec 1
	panel.FirstSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.FirstSpecLabel:SetPoint("TOPLEFT", panel.ProfileLabel,"BOTTOMLEFT", 0, -4)
	panel.FirstSpecLabel:SetWidth(170)
	panel.FirstSpecLabel:SetJustifyH("LEFT")
	panel.FirstSpecLabel:SetText("First Spec")

	panel.FirstSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesFirstSpecDropdown", panel, HubProfileList, DefaultProfile, nil, true)
	panel.FirstSpecDropdown:SetPoint("TOPLEFT", panel.FirstSpecLabel, "BOTTOMLEFT", -20, -2)

	-- Spec 3
	panel.ThirdSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.ThirdSpecLabel:SetPoint("TOPLEFT", panel.FirstSpecDropdown,"BOTTOMLEFT", 20, -8)
	panel.ThirdSpecLabel:SetWidth(170)
	panel.ThirdSpecLabel:SetJustifyH("LEFT")
	panel.ThirdSpecLabel:SetText("Third Spec")
	panel.ThirdSpecLabel:Hide()

	panel.ThirdSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesThirdSpecDropdown", panel, HubProfileList, DefaultProfile, nil, true)
	panel.ThirdSpecDropdown:SetPoint("TOPLEFT", panel.ThirdSpecLabel, "BOTTOMLEFT", -20, -2)
	panel.ThirdSpecLabel:Hide()

	---------------
	-- Column 2
	---------------
	-- Spec 2
	panel.SecondSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.SecondSpecLabel:SetPoint("TOPLEFT", panel.FirstSpecLabel,"TOPLEFT", 150, 0)
	panel.SecondSpecLabel:SetWidth(170)
	panel.SecondSpecLabel:SetJustifyH("LEFT")
	panel.SecondSpecLabel:SetText("Second Spec")

	panel.SecondSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesSecondSpecDropdown", panel, HubProfileList, DefaultProfile, nil, true)
	panel.SecondSpecDropdown:SetPoint("TOPLEFT",panel.SecondSpecLabel, "BOTTOMLEFT", -20, -2)

	-- Spec 4
	panel.FourthSpecLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.FourthSpecLabel:SetPoint("TOPLEFT", panel.SecondSpecDropdown,"BOTTOMLEFT", 20, -8)
	panel.FourthSpecLabel:SetWidth(170)
	panel.FourthSpecLabel:SetJustifyH("LEFT")
	panel.FourthSpecLabel:SetText("Fourth Spec")
	panel.FourthSpecLabel:Hide()

	panel.FourthSpecDropdown = PanelHelpers:CreateDropdownFrame("NeatPlatesFourthSpecDropdown", panel, HubProfileList, DefaultProfile, nil, true)
	panel.FourthSpecDropdown:SetPoint("TOPLEFT",panel.FourthSpecLabel, "BOTTOMLEFT", -20, -2)
	panel.FourthSpecDropdown:Hide()


	----------------------------------------------
	-- Automation
	----------------------------------------------
	panel.AutomationLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutomationLabel:SetFont(font, 22)
	panel.AutomationLabel:SetText("Automation")
	panel.AutomationLabel:SetPoint("TOPLEFT", panel.ThirdSpecDropdown, "BOTTOMLEFT", 20, -20)
	panel.AutomationLabel:SetTextColor(255/255, 105/255, 6/255)


	---------------
	-- Column 1
	---------------
	-- Enemy Visibility
	panel.AutoShowEnemyLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutoShowEnemyLabel:SetPoint("TOPLEFT", panel.AutomationLabel,"BOTTOMLEFT", 0, -4)
	panel.AutoShowEnemyLabel:SetWidth(170)
	panel.AutoShowEnemyLabel:SetJustifyH("LEFT")
	panel.AutoShowEnemyLabel:SetText("Enemy Nameplates:")

	panel.AutoShowEnemy = PanelHelpers:CreateDropdownFrame("NeatPlatesAutoShowEnemy", panel, AutomationDropdownItems, NO_AUTOMATION, nil, true)
	panel.AutoShowEnemy:SetPoint("TOPLEFT",panel.AutoShowEnemyLabel, "BOTTOMLEFT", -20, -2)


	---------------
	-- Column 2
	---------------
	-- Friendly Visibility
	panel.AutoShowFriendlyLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.AutoShowFriendlyLabel:SetPoint("TOPLEFT", panel.AutoShowEnemyLabel,"TOPLEFT", 150, 0)
	panel.AutoShowFriendlyLabel:SetWidth(170)
	panel.AutoShowFriendlyLabel:SetJustifyH("LEFT")
	panel.AutoShowFriendlyLabel:SetText("Friendly Nameplates:")

	panel.AutoShowFriendly = PanelHelpers:CreateDropdownFrame("NeatPlatesAutoShowFriendly", panel, AutomationDropdownItems, NO_AUTOMATION, nil, true)
	panel.AutoShowFriendly:SetPoint("TOPLEFT", panel.AutoShowFriendlyLabel,"BOTTOMLEFT", -20, -2)



	----------------------------------------------
	-- Other Options
	----------------------------------------------
	-- Cast Bars
	panel.DisableCastBars = PanelHelpers:CreateCheckButton("NeatPlatesOptions_DisableCastBars", panel, "Disable Cast Bars")
	panel.DisableCastBars:SetPoint("TOPLEFT", panel.AutoShowEnemy, "TOPLEFT", 16, -50)
	panel.DisableCastBars:SetScript("OnClick", function(self) SetCastBars(not self:GetChecked()) end)

	-- ForceBlizzardFont
	panel.ForceBlizzardFont = PanelHelpers:CreateCheckButton("NeatPlatesOptions_ForceBlizzardFont", panel, "Force Multi-Lingual Font (Requires /reload)")
	panel.ForceBlizzardFont:SetPoint("TOPLEFT", panel.DisableCastBars, "TOPLEFT", 0, -25)
	panel.ForceBlizzardFont:SetScript("OnClick", function(self) NeatPlates.OverrideFonts( self:GetChecked()) end)

	-- Frequent Health Updates
	panel.HealthFrequent = PanelHelpers:CreateCheckButton("NeatPlatesOptions_HealthFrequent", panel, "Use Frequent Health Updates")
	panel.HealthFrequent:SetPoint("TOPLEFT", panel.ForceBlizzardFont, "TOPLEFT", 0, -25)
	panel.HealthFrequent:SetScript("OnClick", function(self) NeatPlates:SetHealthUpdateMethod(self:GetChecked()) end)

	-- Nameplate Behaviour
	panel.CVarsLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.CVarsLabel:SetFont(font, 22)
	panel.CVarsLabel:SetText("CVars")
	panel.CVarsLabel:SetPoint("TOPLEFT", panel.HealthFrequent, "BOTTOMLEFT", 0, -20)
	panel.CVarsLabel:SetTextColor(255/255, 105/255, 6/255)

	panel.NameplateTargetClamp = PanelHelpers:CreateCheckButton("NeatPlatesOptions_NameplateTargetClamp", panel, "Always keep Target Nameplate on Screen")
	panel.NameplateTargetClamp:SetPoint("TOPLEFT", panel.CVarsLabel, "TOPLEFT", 0, -25)
	panel.NameplateTargetClamp:SetScript("OnClick", function(self) if self:GetChecked() then SetCVar("nameplateTargetRadialPosition", 1) else SetCVar("nameplateTargetRadialPosition", 0) end end)

	panel.NameplateStacking = PanelHelpers:CreateCheckButton("NeatPlatesOptions_NameplateStacking", panel, "Stacking Nameplates")
	panel.NameplateStacking:SetPoint("TOPLEFT", panel.NameplateTargetClamp, "TOPLEFT", 0, -25)
	panel.NameplateStacking:SetScript("OnClick", function(self) if self:GetChecked() then SetCVar("nameplateMotion", 1) else SetCVar("nameplateMotion", 0) end end)

	panel.NameplateMaxDistance = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateMaxDistance", panel, "Nameplate Max Distance", 60, 10, 100, 1, "ACTUAL", 250)
	panel.NameplateMaxDistance:SetPoint("TOPLEFT", panel.NameplateStacking, "TOPLEFT", 10, -45)
	panel.NameplateMaxDistance:SetScript("OnMouseUp", function(self) SetCVar("nameplateMaxDistance", self.ceil(self:GetValue())) end)

	panel.NameplateOverlapH = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateOverlapH", panel, "Nameplate Horizontal Overlap", 0, 0, 10, .1, "ACTUAL", 170)
	panel.NameplateOverlapH:SetPoint("TOPLEFT", panel.NameplateMaxDistance, "TOPLEFT", 0, -45)
	panel.NameplateOverlapH:SetScript("OnMouseUp", function(self) SetCVar("nameplateOverlapH", self.ceil(self:GetValue())) end)

	panel.NameplateOverlapV = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateOverlapV", panel, "Nameplate Vertical Overlap", 0, 0, 10, .1, "ACTUAL", 170)
	panel.NameplateOverlapV:SetPoint("TOPLEFT", panel.NameplateMaxDistance, "TOPLEFT", 200, -45)
	panel.NameplateOverlapV:SetScript("OnMouseUp", function(self) SetCVar("nameplateOverlapV", self.ceil(self:GetValue())) end)

	panel.NameplateClickableWidth = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateClickableWidth", panel, "Clickable Width of Nameplates", 1, .1, 2, .01, nil, 170)
	panel.NameplateClickableWidth:SetPoint("TOPLEFT", panel.NameplateOverlapH, "TOPLEFT", 0, -45)
	--panel.NameplateClickableWidth:SetScript("OnMouseUp", function(self) print(self.ceil(self:GetValue())) end)

	panel.NameplateClickableHeight = PanelHelpers:CreateSliderFrame("NeatPlatesOptions_NameplateClickableHeight", panel, "Clickable Height of Nameplates", 1, .1, 2, .01, nil, 170)
	panel.NameplateClickableHeight:SetPoint("TOPLEFT", panel.NameplateOverlapH, "TOPLEFT", 200, -45)
	--panel.NameplateClickableHeight:SetScript("OnMouseUp", function(self) print("clickableheight", self.ceil(self:GetValue())) end)

	-- Blizz Button
	local BlizzOptionsButton = CreateFrame("Button", "NeatPlatesOptions_BlizzOptionsButton", panel, "NeatPlatesPanelButtonTemplate")
	BlizzOptionsButton:SetPoint("TOPLEFT", panel.NameplateClickableWidth, "TOPLEFT", -10, -70)
	BlizzOptionsButton:SetWidth(260)
	BlizzOptionsButton:SetText("Nameplate Motion & Visibility")

	-- Reset
	local ResetButton = CreateFrame("Button", "NeatPlatesOptions_ResetButton", panel, "NeatPlatesPanelButtonTemplate")
	ResetButton:SetPoint("TOPLEFT", BlizzOptionsButton, "BOTTOMLEFT", 0, -10)
	ResetButton:SetWidth(155)
	ResetButton:SetText("Reset Configuration")

	-- Profile settings
	local ProfileEditLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	ProfileEditLabel:SetPoint("TOPLEFT", ResetButton, "BOTTOMLEFT", 5, -50)
	ProfileEditLabel:SetWidth(170)
	ProfileEditLabel:SetJustifyH("LEFT")
	ProfileEditLabel:SetText("Profile Name")

	local ProfileEditBox = CreateFrame("EditBox", "NeatPlatesOptions_ProfileEditBox", panel, "InputBoxTemplate")
	ProfileEditBox:SetWidth(150)
	ProfileEditBox:SetHeight(25)
	ProfileEditBox:SetPoint("TOP", ProfileEditLabel, "BOTTOM", -8, 0)
	ProfileEditBox:SetAutoFocus(false)
	ProfileEditBox:SetFont("media\\DefaultFont.TTF", 11, "NONE")
	ProfileEditBox:SetFrameStrata("DIALOG")

	-- Profile Color picker
	local ProfileColorBox = PanelHelpers:CreateColorBox("ProfileColor", panel, "", nil, 0, .5, 1, 1)
	ProfileColorBox:SetPoint("LEFT", ProfileEditBox, "RIGHT")

	-- Add Profile
	local AddProfileButton = CreateFrame("Button", "NeatPlatesOptions_AddProfileButton", panel, "NeatPlatesPanelButtonTemplate")
	AddProfileButton:SetPoint("TOPLEFT", ProfileEditBox, "BOTTOMLEFT", -5, 0)
	AddProfileButton:SetWidth(155)
	AddProfileButton:SetText("Add Profile")
	AddProfileButton:SetScript("OnClick", function(self) NeatPlatesUtility.OpenInterfacePanel(NeatPlatesHubMenus.CreateProfile(ProfileEditBox:GetText(), RGBToColorCode(ProfileColorBox:GetBackdropColor()))); ProfileEditBox:SetText("") end)



	-- Update Functions
	_panel.okay = OnOkay
	_panel.refresh = OnRefresh
	panel.ActiveThemeDropdown.OnValueChanged = OnValueChange

	panel.FirstSpecDropdown.OnValueChanged = OnValueChange
	panel.SecondSpecDropdown.OnValueChanged = OnValueChange
	panel.ThirdSpecDropdown.OnValueChanged = OnValueChange
	panel.FourthSpecDropdown.OnValueChanged = OnValueChange



	-- Blizzard Nameplate Options Button
	BlizzOptionsButton:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"])
	end)

	-- Reset Button
	ResetButton:SetScript("OnClick", function()
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("threatWarning", 3)		-- Required for threat/aggro detection


		if IsShiftKeyDown() then
			NeatPlatesOptions = wipe(NeatPlatesOptions)
			for i, v in pairs(NeatPlatesOptionsDefaults) do NeatPlatesOptions[i] = v end
			SetCVar("nameplateShowFriends", 0)
			ReloadUI()
		else
			NeatPlatesOptions = wipe(NeatPlatesOptions)
			for i, v in pairs(NeatPlatesOptionsDefaults) do NeatPlatesOptions[i] = v end
			OnRefresh(_panel)
			ApplyPanelSettings()
			print(yellow.."Resetting "..orange.."Neat Plates"..yellow.." Theme Selection to Default")
			print(yellow.."Holding down "..blue.."Shift"..yellow.." while clicking "..red.."Reset Configuration"..yellow.." will clear your saved settings, AND reload the user interface.")
		end

	end)
end

-------------------------------------------------------------------------------------
-- Auto-Loader
-------------------------------------------------------------------------------------
local panelevents = {}

function panelevents:ACTIVE_TALENT_GROUP_CHANGED(self)
	--print("Panel:Talent Group Changed")
	ApplyPanelSettings()
	--OnRefresh(NeatPlatesInterfacePanel)
end

function panelevents:PLAYER_ENTERING_WORLD()
	--print("Panel:Player Entering World")
	-- Tihs may happen every time a loading screen is shown
	local fallBackTheme

	-- Locate a fallback theme
	if NeatPlatesThemeList[FirstTryTheme] then
		fallBackTheme = FirstTryTheme
	else
		for i,v in pairs(NeatPlatesThemeList) do fallBackTheme = i break; end
	end

	-- Check to make sure the selected themes exist; if not, replace with fallback
	if not NeatPlatesThemeList[NeatPlatesOptions.ActiveTheme] then
		NeatPlatesOptions.ActiveTheme = fallBackTheme end

	VerifyPanelSettings()
	ApplyPanelSettings()
	ApplyAutomationSettings()
end

function panelevents:PLAYER_REGEN_ENABLED()
	SetNameplateVisibility("nameplateShowEnemies", NeatPlatesOptions.EnemyAutomation, false)
	SetNameplateVisibility("nameplateShowFriends", NeatPlatesOptions.FriendlyAutomation, false)
end

function panelevents:PLAYER_REGEN_DISABLED()
	SetNameplateVisibility("nameplateShowEnemies", NeatPlatesOptions.EnemyAutomation, true)
	SetNameplateVisibility("nameplateShowFriends", NeatPlatesOptions.FriendlyAutomation, true)
end

function panelevents:PLAYER_LOGIN()
	-- This happens only once a session

	-- Setup the interface panels
	CreateMenuTables()				-- Look at the theme table and get names
	BuildInterfacePanel(NeatPlatesInterfacePanel)

	-- First time setup
	if not NeatPlatesOptions.WelcomeShown then
		SetCVar("nameplateShowAll", 1)		--


		SetCVar("nameplateShowEnemies", 1)
		SetCVar("threatWarning", 3)		-- Required for threat/aggro detection
		NeatPlatesOptions.WelcomeShown = true
		
		--NeatPlatesOptions.FirstSpecProfile = Role2Profile(1)
		--NeatPlatesOptions.SecondSpecProfile = Role2Profile(2)
		--NeatPlatesOptions.ThirdSpecProfile = Role2Profile(3)
		--NeatPlatesOptions.FourthSpecProfile = Role2Profile(4)
		NeatPlatesOptions.FirstSpecProfile = "Default"
		NeatPlatesOptions.SecondSpecProfile = "Default"
		NeatPlatesOptions.ThirdSpecProfile = "Default"
		NeatPlatesOptions.FourthSpecProfile = "Default"
	end
end

NeatPlatesInterfacePanel:SetScript("OnEvent", function(self, event, ...) panelevents[event](self, ...) end)
for eventname in pairs(panelevents) do NeatPlatesInterfacePanel:RegisterEvent(eventname) end

-------------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------------

NeatPlatesSlashCommands = {}

function slash_NeatPlates(arg)
	if type(NeatPlatesSlashCommands[arg]) == 'function' then
		NeatPlatesSlashCommands[arg]()
		NeatPlates:ForceUpdate()
	else
		NeatPlatesUtility.OpenInterfacePanel(NeatPlatesInterfacePanel)
	end
end

SLASH_NeatPlates1 = '/NeatPlates'
SLASH_NeatPlates2 = '/np'
SlashCmdList['NeatPlates'] = slash_NeatPlates;


