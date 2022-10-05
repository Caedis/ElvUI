local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')



--Cache global variables
local _G = _G
--Lua functions
local format = string.format
local pairs = pairs
local IsShiftKeyDown = IsShiftKeyDown
local tinsert, twipe = tinsert, wipe
--WoW API / Variables
local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter
local C_EquipmentSet_GetEquipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs
local C_EquipmentSet_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local C_EquipmentSet_UseEquipmentSet = C_EquipmentSet.UseEquipmentSet


local setCache = {}
local activeSetIndex
local setMenu = {}

local displayString = ''
local function OnEnter(self)
	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(L["Equipment Sets"])

	DT.tooltip:AddLine(' ')

	for _,set in pairs(setCache) do
		DT.tooltip:AddLine(format('|T%s:14:14:0:0:64:64:4:60:4:60|t |cFF%s%s|r', set.IconFileID, set.IsEquipped and '00ff00' or 'ff0000', set.Name))
	end

	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Equipment Set"])
	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Open Equipment Manager"])

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if InCombatLockdown() then return end

	if button == 'LeftButton' then
		if IsShiftKeyDown() then
			ToggleCharacter('PaperDollFrame')

			if E.Retail then
				if PaperDollSidebarTab3 then -- just in case something happens to this tab
					PaperDollSidebarTab3:Click()
				end
			elseif E.Wrath and GearManagerToggleButton:IsVisible() then
				GearManagerToggleButton:Click()
			end

			return
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(setMenu, DT.EasyMenu, nil, nil, nil, 'MENU')

	end

end


local function OnEvent(self)
	twipe(setCache)
	twipe(setMenu)
	tinsert(setMenu, { text = L["Equipment Sets"], isTitle = true, notCheckable = true })


	local sets = C_EquipmentSet_GetEquipmentSetIDs()

	activeSetIndex = -1
	for i,setID in pairs(sets) do
		local name, iconFileID, _, isEquipped = C_EquipmentSet_GetEquipmentSetInfo(setID)

		tinsert(setMenu,
			{
				text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', iconFileID, name),
				checked = isEquipped,
				func = function() C_EquipmentSet_UseEquipmentSet(setID) end
			}
		)

		tinsert(setCache,
			{
				SetID = setID,
				Name = name,
				IconFileID = iconFileID,
				IsEquipped = isEquipped
			}
		)

		if isEquipped then
			activeSetIndex = i
		end
	end


	if activeSetIndex == -1 then
		self.text:SetText(L["No Set Equipped"])
	else
		local set = setCache[activeSetIndex]
		self.text:SetText(format(L["Set: %s |T%s:16:16:0:0:64:64:4:60:4:60|t"], set.Name, set.IconFileID))
	end

end


local events = {
	'EQUIPMENT_SETS_CHANGED',
	'PLAYER_EQUIPMENT_CHANGED',
	'EQUIPMENT_SWAP_FINISHED'
}


DT:RegisterDatatext('EquipmentManager', nil, events, OnEvent, nil, OnClick, OnEnter, nil, EQUIPMENT_MANAGER)