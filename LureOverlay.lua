local ADDON_NAME, MSC = ...

local LureOverlay = {}
MSC.LureOverlay = LureOverlay

-- ============================================================
-- Proximity overlay for using a skinning lure.
--
-- Nothing here exists until the player ticks the "Lure Overlay"
-- checkbox in the UI - MSC.db.lureOverlayEnabled defaults to false.
--
-- Detection is event-driven, not polled: the game applies
-- MSC.SIXTH_SENSE_SPELL_ID to the player when a lure can be used
-- here, so a single UNIT_AURA listener on "player" tells us when to
-- look, instead of a repeating ticker checking position every
-- second. Zone + quest completion then narrow that down to a beast;
-- a one-off distance check only runs to break a tie between beasts
-- that share a zone.
-- ============================================================

local listenerFrame
local overlayFrame
local currentKey

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

-- Called only from the overlay button's OnClick, i.e. always as a
-- direct player action - never queued or triggered by addon logic
-- on its own, so this carries no taint risk.
local function UseLure(key)
    local lure = MSC.BEAST_LURE[key]
    if not lure then
        return
    end
    if GetLureCount(lure.itemID) <= 0 then
        MSC:Print("No " .. MSC.Names:GetBeastName(key) .. " lure in your bags.")
        return
    end
    local ok, err = pcall(UseItemByName, lure.itemID)
    if not ok then
        MSC:Print("Could not use lure: " .. tostring(err))
    end
end

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

    local button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    button:SetSize(140, 24)
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("Use Lure")
    button:SetScript("OnClick", function()
        if currentKey then
            UseLure(currentKey)
        end
    end)
    f.button = button

    f:Hide()
    return f
end

local function HasSixthSense()
    return C_UnitAuras.GetPlayerAuraBySpellID(MSC.SIXTH_SENSE_SPELL_ID) ~= nil
end

local function OnPlayerAurasChanged()
    local key = HasSixthSense() and FindTargetKey() or nil
    if not key then
        currentKey = nil
        if overlayFrame then
            overlayFrame:Hide()
        end
        return
    end

    if not overlayFrame then
        overlayFrame = BuildOverlay()
    end
    currentKey = key
    local count = GetLureCount(MSC.BEAST_LURE[key].itemID)
    overlayFrame.label:SetText(MSC.Names:GetBeastName(key) .. " lure: " .. count)
    overlayFrame.button:SetEnabled(count > 0)
    overlayFrame:Show()
end

-- Called from Core:OnPlayerLogin(). Restores the player's own prior
-- choice; does not turn the overlay on for someone who never asked.
function LureOverlay:OnLogin()
    if MSC.db.lureOverlayEnabled then
        self:Enable()
    end
end

function LureOverlay:Enable()
    if listenerFrame then
        return
    end
    listenerFrame = CreateFrame("Frame")
    listenerFrame:RegisterUnitEvent("UNIT_AURA", "player")
    listenerFrame:SetScript("OnEvent", OnPlayerAurasChanged)
    MSC.db.lureOverlayEnabled = true
    -- Covers the case where the player enables this while already
    -- standing in range with the debuff up.
    OnPlayerAurasChanged()
end

function LureOverlay:Disable()
    if listenerFrame then
        listenerFrame:UnregisterAllEvents()
        listenerFrame:SetScript("OnEvent", nil)
        listenerFrame = nil
    end
    if overlayFrame then
        overlayFrame:Hide()
    end
    currentKey = nil
    MSC.db.lureOverlayEnabled = false
end

function LureOverlay:IsEnabled()
    return listenerFrame ~= nil
end
