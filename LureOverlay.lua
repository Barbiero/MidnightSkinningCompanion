local ADDON_NAME, MSC = ...

local LureOverlay = {}
MSC.LureOverlay = LureOverlay

-- ============================================================
-- Proximity overlay for using a skinning lure.
--
-- On by default (MSC.db.lureOverlayEnabled); nothing here exists
-- until Enable() actually runs, whether that's at login restoring a
-- prior session or the player flipping the Options checkbox.
--
-- Detection is event-driven, not polled: the game applies one of
-- MSC.SIXTH_SENSE_SPELL_IDS to the player when a lure can be used
-- here, so a single UNIT_AURA listener on "player" tells us when to
-- look, instead of a repeating ticker checking position every
-- second. Zone + quest completion then narrow that down to a beast;
-- a one-off distance check only runs to break a tie between beasts
-- that share a zone.
--
-- Checks are skipped while in combat and re-run once combat ends:
-- building/showing the overlay while combat lockdown is active is a
-- plausible taint source, and the debuff can easily land mid-fight.
-- ============================================================

local listenerFrame
local overlayFrame
local pendingRecheck = false

local function GetLureCount(itemID)
    if not itemID then
        return 0
    end
    local ok, count = pcall(C_Item.GetItemCount, itemID, false, false, true)
    if not ok then
        return 0
    end
    return count or 0
end

-- Public so the UI can show live lure counts without duplicating
-- this bag-scanning logic.
function LureOverlay:GetLureCount(key)
    local lure = MSC.BEAST_LURE[key]
    return GetLureCount(lure and lure.itemID)
end

local function IsQuestDone(questID)
    return questID ~= nil and C_QuestLog.IsQuestFlaggedCompleted(questID) == true
end

local function GetCandidateKeys(mapID)
    local candidates = {}
    for _, key in ipairs(MSC.BEASTS) do
        if MSC.BEAST_LOCATION[key].mapID == mapID and not IsQuestDone(MSC.BEAST_QUEST[key]) then
            candidates[#candidates + 1] = key
        end
    end
    return candidates
end

-- Only called to break a tie between multiple candidates in the same
-- zone (e.g. Umbrafang and Netherscythe both in Voidstorm). A single
-- position read, not a repeating check.
local function NearestCandidate(candidates, mapID)
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        return candidates[1]
    end
    local px, py = pos:GetXY()
    local nearest, nearestDistSq
    for _, key in ipairs(candidates) do
        local loc = MSC.BEAST_LOCATION[key]
        local dx = px - (loc.x / 100)
        local dy = py - (loc.y / 100)
        local distSq = dx * dx + dy * dy
        if not nearestDistSq or distSq < nearestDistSq then
            nearest, nearestDistSq = key, distSq
        end
    end
    return nearest
end

local function FindTargetKey()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return nil
    end
    local candidates = GetCandidateKeys(mapID)
    if #candidates == 0 then
        return nil
    elseif #candidates == 1 then
        return candidates[1]
    end
    return NearestCandidate(candidates, mapID)
end

local FONT_SCALE = 1.25

local function GrowFont(fontString)
    local file, size, flags = fontString:GetFont()
    if file then
        fontString:SetFont(file, size * FONT_SCALE, flags)
    end
end

-- Reposition support (see LureOverlay:EnterEditMode below). Stored as
-- a single point/x/y relative to UIParent - the same anchor family
-- the overlay is always built with - so applying a saved position is
-- just a SetPoint, no coordinate conversion.
local function ApplyPosition(f)
    f:ClearAllPoints()
    local pos = MSC.db.lureOverlayPoint
    if pos then
        f:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    else
        f:SetPoint("TOP", 0, -150)
    end
end

local function SavePosition(f)
    local point, _, _, x, y = f:GetPoint(1)
    if not point then
        return
    end
    MSC.db.lureOverlayPoint = { point = point, x = x, y = y }
end

-- Item use requires a real hardware click on a SecureActionButtonTemplate
-- with its "item" attribute set - calling UseItemByName from Lua is
-- ADDON_ACTION_FORBIDDEN. SetAttribute is itself combat protected,
-- hence the InCombatLockdown guards around every caller.
-- No backdrop/dialog box: this is meant to read as a floating action
-- button, the same way ExtraActionBarFrame has no background panel of
-- its own - just the button and its ornate art.
local function BuildOverlay()
    local f = CreateFrame("Frame", "MidnightSkinningCompanionLureOverlay", UIParent)
    f:SetSize(320, 200)
    ApplyPosition(f)
    f:SetFrameStrata("HIGH")
    f:SetScale(MSC.db.uiScale or 1.0)
    f:SetMovable(true)
    f:SetClampedToScreen(true)

    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOP", 0, 0)
    GrowFont(label)
    f.label = label

    local button = CreateFrame("Button", "MidnightSkinningCompanionLureOverlayButton", f, "SecureActionButtonTemplate")
    button:SetSize(65, 65)
    button:SetPoint("TOP", f, "TOP", 0, -40)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type", "item")
    button:RegisterEvent("GLOBAL_MOUSE_UP")
    button:SetScript("OnEvent", function(self)
        self:SetButtonState("NORMAL")
    end)

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetPoint("TOPLEFT", 0, -1)
    button.icon:SetPoint("BOTTOMRIGHT", 0, -1)

    -- Same ornate frame art ExtraActionButton1 itself uses, sized and
    -- centered the same way, rather than a hand-drawn border.
    local style = button:CreateTexture(nil, "OVERLAY")
    style:SetSize(320, 160)
    style:SetPoint("CENTER", -2.5, 0)
    style:SetTexture("Interface\\ExtraButton\\ChampionLight")
    button.style = style

    button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    local pushed = button:GetPushedTexture()
    pushed:SetPoint("TOPLEFT", 0, -1)
    pushed:SetPoint("BOTTOMRIGHT", 0, -1)

    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    local highlight = button:GetHighlightTexture()
    highlight:SetPoint("TOPLEFT", 0, -1)
    highlight:SetPoint("BOTTOMRIGHT", 0, -1)

    button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.count:SetJustifyH("RIGHT")
    button.count:SetPoint("BOTTOMRIGHT", button.icon, -4, 4)
    GrowFont(button.count)
    f.button = button

    f:Hide()
    return f
end

local function HasSixthSense()
    for _, spellID in ipairs(MSC.SIXTH_SENSE_SPELL_IDS) do
        if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
            return true
        end
    end
    return false
end

-- Shared by OnPlayerAurasChanged and DebugShow; both already guarantee
-- combat isn't active before calling this.
local function ShowOverlayFor(key, labelSuffix)
    if not overlayFrame then
        overlayFrame = BuildOverlay()
    end
    local lure = MSC.BEAST_LURE[key]
    local count = GetLureCount(lure.itemID)
    overlayFrame.label:SetText(MSC.Names:GetBeastName(key) .. (labelSuffix or ""))
    overlayFrame.button.icon:SetTexture(MSC.BEAST_ICON[key])
    overlayFrame.button.count:SetText(count)
    overlayFrame.button:SetAttribute("item", "item:" .. lure.itemID)
    overlayFrame.button:SetEnabled(count > 0)
    overlayFrame:Show()
end

local function OnPlayerAurasChanged()
    if InCombatLockdown() then
        pendingRecheck = true
        return
    end

    local key = HasSixthSense() and FindTargetKey() or nil
    if not key then
        if overlayFrame then
            overlayFrame:Hide()
        end
        return
    end

    ShowOverlayFor(key)
end

-- Repositioning via Blizzard's Edit Mode - approach and colors
-- derived from Plumber (Modules/Shared/SharedEditMode.lua and
-- Art/Frame/EditModeHighlighted.blp / EditModeSelected.blp).

local EDIT_MODE_COLOR_HIGHLIGHT = { border = { 41 / 255, 190 / 255, 1, 1 }, bg = { 151 / 255, 223 / 255, 1, 0.8 } }
local EDIT_MODE_COLOR_SELECTED = { border = { 1, 210 / 255, 0, 1 }, bg = { 1, 245 / 255, 107 / 255, 0.8 } }

local EDIT_MODE_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local function SetEditModeSelectionState(sel, selected)
    local colors = selected and EDIT_MODE_COLOR_SELECTED or EDIT_MODE_COLOR_HIGHLIGHT
    sel:SetBackdropColor(unpack(colors.bg))
    sel:SetBackdropBorderColor(unpack(colors.border))
    sel.subtitle:SetShown(not selected)
end

local function OnEditModeSelectionMouseDown(self, button)
    if button == "LeftButton" then
        SetEditModeSelectionState(self, true)
        if EditModeManagerFrame and EditModeManagerFrame.ClearSelectedSystem then
            EditModeManagerFrame:ClearSelectedSystem()
        end
    end
end

local function OnEditModeSelectionMouseUp(self, button)
    if button == "RightButton" then
        LureOverlay:ResetPosition()
    end
end

local function OnEditModeSelectionDragStart(self)
    self:GetParent():StartMoving()
end

local function OnEditModeSelectionDragStop(self)
    local f = self:GetParent()
    f:StopMovingOrSizing()
    SavePosition(f)
end

-- Deselects (back to the highlighted/blue state) on any click that
-- doesn't land on this frame - the same technique Plumber uses for
-- its own Edit Mode selections.
local function OnEditModeSelectionEvent(self, event)
    if event == "GLOBAL_MOUSE_DOWN" then
        local foci = GetMouseFoci()
        if not (foci and foci[1] == self) then
            SetEditModeSelectionState(self, false)
        end
    end
end

local function OnEditModeSelectionShow(self)
    self:RegisterEvent("GLOBAL_MOUSE_DOWN")
end

local function OnEditModeSelectionHide(self)
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
end

local function BuildEditModeSelection(f)
    local sel = CreateFrame("Frame", nil, f, "BackdropTemplate")
    sel:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    sel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 40)
    sel:SetFrameStrata(f:GetFrameStrata())
    sel:SetToplevel(true)
    sel:SetFrameLevel(999)
    sel:EnableMouse(true)
    sel:RegisterForDrag("LeftButton")
    sel:SetBackdrop(EDIT_MODE_BACKDROP)
    sel:Hide()

    local title = sel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", sel, "CENTER", 0, 6)
    title:SetJustifyH("CENTER")
    title:SetText(MSC.L.EDIT_MODE_TITLE)
    sel.title = title

    local subtitle = sel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)
    subtitle:SetJustifyH("CENTER")
    subtitle:SetText(MSC.L.EDIT_MODE_SUBTITLE)
    sel.subtitle = subtitle

    SetEditModeSelectionState(sel, false)

    sel:SetScript("OnMouseDown", OnEditModeSelectionMouseDown)
    sel:SetScript("OnMouseUp", OnEditModeSelectionMouseUp)
    sel:SetScript("OnDragStart", OnEditModeSelectionDragStart)
    sel:SetScript("OnDragStop", OnEditModeSelectionDragStop)
    sel:SetScript("OnEvent", OnEditModeSelectionEvent)
    sel:SetScript("OnShow", OnEditModeSelectionShow)
    sel:SetScript("OnHide", OnEditModeSelectionHide)

    f.editModeSelection = sel
    return sel
end

-- Placeholder content shown while forced onscreen for repositioning;
-- there may be no real beast in range to show. Disabling the button
-- also keeps a stray click from trying to use whatever item it last
-- held.
local function ShowEditModePreview(f)
    f.label:SetText(MSC.L.EDIT_MODE_TITLE)
    f.button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    f.button.count:SetText("")
    f.button:SetEnabled(false)
    f:Show()
end

-- Called from the EditMode.Enter callback, only registered while the
-- overlay feature itself is enabled (see StartListening) - repositioning
-- something that's off has nothing to show.
function LureOverlay:EnterEditMode()
    if InCombatLockdown() then
        return
    end
    if not overlayFrame then
        overlayFrame = BuildOverlay()
    end
    if not overlayFrame.editModeSelection then
        BuildEditModeSelection(overlayFrame)
    end
    ShowEditModePreview(overlayFrame)
    SetEditModeSelectionState(overlayFrame.editModeSelection, false)
    overlayFrame.editModeSelection:Show()
end

function LureOverlay:ExitEditMode()
    if not overlayFrame or not overlayFrame.editModeSelection then
        return
    end
    overlayFrame.editModeSelection:Hide()
    -- Recompute the real state instead of just hiding - covers the
    -- (rare) case where the player actually has a lure available
    -- while Edit Mode happens to be open.
    OnPlayerAurasChanged()
end

function LureOverlay:ResetPosition()
    MSC.db.lureOverlayPoint = nil
    if overlayFrame then
        ApplyPosition(overlayFrame)
    end
end

local function OnEditModeEnter()
    LureOverlay:EnterEditMode()
end

local function OnEditModeExit()
    LureOverlay:ExitEditMode()
end

local function OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        if pendingRecheck then
            pendingRecheck = false
            OnPlayerAurasChanged()
        end
    else
        OnPlayerAurasChanged()
    end
end

-- Mechanism only - never touches MSC.db.lureOverlayEnabled. That
-- keeps the player's own preference intact regardless of how many
-- times MSC.Profession starts/stops this around a Skinning gain or
-- loss; only the user-facing Enable()/Disable() below persist it.
local function StartListening()
    if listenerFrame then
        return
    end
    listenerFrame = CreateFrame("Frame")
    listenerFrame:RegisterUnitEvent("UNIT_AURA", "player")
    listenerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    listenerFrame:SetScript("OnEvent", OnEvent)
    EventRegistry:RegisterCallback("EditMode.Enter", OnEditModeEnter, LureOverlay)
    EventRegistry:RegisterCallback("EditMode.Exit", OnEditModeExit, LureOverlay)
    -- Covers the case where listening starts while already standing
    -- in range with the debuff up.
    OnPlayerAurasChanged()
    -- Covers the case where the feature is turned on (e.g. from
    -- Options) while Edit Mode already happens to be open.
    if EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive() then
        LureOverlay:EnterEditMode()
    end
end

local function StopListening()
    if listenerFrame then
        listenerFrame:UnregisterAllEvents()
        listenerFrame:SetScript("OnEvent", nil)
        listenerFrame = nil
    end
    EventRegistry:UnregisterCallback("EditMode.Enter", LureOverlay)
    EventRegistry:UnregisterCallback("EditMode.Exit", LureOverlay)
    if overlayFrame and overlayFrame.editModeSelection then
        overlayFrame.editModeSelection:Hide()
    end
    if overlayFrame then
        overlayFrame:Hide()
    end
    pendingRecheck = false
end

-- Called from MSC:SetFeaturesEnabled() when the player is (or
-- becomes) a skinner. Restores the player's own prior choice; does
-- not turn the overlay on for someone who never asked.
function LureOverlay:OnProfessionGained()
    if MSC.db.lureOverlayEnabled then
        StartListening()
    end
end

-- Called from MSC:SetFeaturesEnabled() when the player is not (or no
-- longer) a skinner. Leaves the saved preference alone so regaining
-- Skinning later restores exactly what the player had before.
function LureOverlay:OnProfessionLost()
    StopListening()
end

-- User-facing toggle (Options > Lure Overlay). Persists the choice
-- even if the player isn't currently a skinner, so it takes effect
-- immediately if they later learn Skinning.
function LureOverlay:Enable()
    MSC.db.lureOverlayEnabled = true
    if MSC.Profession:IsSkinner() then
        StartListening()
    end
end

function LureOverlay:Disable()
    MSC.db.lureOverlayEnabled = false
    StopListening()
end

function LureOverlay:IsEnabled()
    return listenerFrame ~= nil
end

function LureOverlay:ApplyScale()
    if overlayFrame then
        overlayFrame:SetScale(MSC.db.uiScale or 1.0)
    end
end

-- Debug-only: wired up from "/mscompanion lure" in Core.lua.
function LureOverlay:DebugShow(key)
    if InCombatLockdown() then
        MSC:Print(MSC.L.MSG_CANT_SHOW_COMBAT)
        return
    end
    key = key or MSC.BEASTS[1]
    if not MSC.BEAST_LURE[key] then
        MSC:Print(string.format(MSC.L.MSG_UNKNOWN_BEAST, tostring(key)))
        return
    end
    ShowOverlayFor(key, " |cffff8800(" .. MSC.L.DEBUG_LABEL .. ")|r")
end

function LureOverlay:DebugHide()
    if overlayFrame then
        overlayFrame:Hide()
    end
end
