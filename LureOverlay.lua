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
    f:SetPoint("TOP", 0, -150)
    f:SetFrameStrata("HIGH")
    f:SetScale(MSC.db.uiScale or 1.0)

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
    -- Covers the case where listening starts while already standing
    -- in range with the debuff up.
    OnPlayerAurasChanged()
end

local function StopListening()
    if listenerFrame then
        listenerFrame:UnregisterAllEvents()
        listenerFrame:SetScript("OnEvent", nil)
        listenerFrame = nil
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
        MSC:Print("Can't show the lure overlay in combat.")
        return
    end
    key = key or MSC.BEASTS[1]
    if not MSC.BEAST_LURE[key] then
        MSC:Print("Unknown beast: " .. tostring(key))
        return
    end
    ShowOverlayFor(key, " |cffff8800(debug)|r")
end

function LureOverlay:DebugHide()
    if overlayFrame then
        overlayFrame:Hide()
    end
end
