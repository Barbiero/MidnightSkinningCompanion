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

-- The lure is ground-targeted, and item use in general is only
-- permitted through a real hardware click on a secure action button
-- - calling UseItemByName from Lua, even directly from an OnClick
-- script, is ADDON_ACTION_FORBIDDEN. So the button below is a
-- SecureActionButtonTemplate with its "item" attribute pointed at
-- the current lure; Blizzard's own secure click handling takes it
-- from there; the player still places the ground target themselves,
-- same as using the item manually. SetAttribute is itself combat
-- protected, which is why this is only ever called from
-- OnPlayerAurasChanged, which already refuses to run in combat.
local function BuildOverlay()
    local f = CreateFrame("Frame", "MidnightSkinningCompanionLureOverlay", UIParent, "BackdropTemplate")
    f:SetSize(220, 70)
    f:SetPoint("TOP", 0, -120)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOP", 0, -10)
    f.label = label

    local button = CreateFrame("Button", "MidnightSkinningCompanionLureOverlayButton", f, "SecureActionButtonTemplate, UIPanelButtonTemplate")
    button:SetSize(140, 24)
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("Use Lure")
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type", "item")
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

    if not overlayFrame then
        overlayFrame = BuildOverlay()
    end
    local lure = MSC.BEAST_LURE[key]
    local count = GetLureCount(lure.itemID)
    overlayFrame.label:SetText(MSC.Names:GetBeastName(key) .. " lure: " .. count)
    overlayFrame.button:SetAttribute("item", "item:" .. lure.itemID)
    overlayFrame.button:SetEnabled(count > 0)
    overlayFrame:Show()
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
