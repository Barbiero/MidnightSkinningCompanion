local ADDON_NAME, MSC = ...
MSC.ADDON_NAME = ADDON_NAME

-- ============================================================
-- Client detection.
--
-- The addon targets both 12.0.7 and 12.1.0 from a single code
-- path (the underlying APIs used here do not differ between the
-- two), but MSC.IS_121 is exposed up front so any future patch-only
-- branch has a place to hang without touching the shared code.
-- Never "fix up" logic inside a 12.0-only branch once one exists;
-- treat it as frozen and delete it when 12.1 becomes the floor.
-- ============================================================
local _, _, _, tocVersion = GetBuildInfo()
MSC.IS_121 = tocVersion >= 120100

-- ============================================================
-- Saved variables / defaults.
--
-- lureOverlayEnabled defaults to true: it's the addon's other core
-- feature, and off is an opt-out (Options > Lure Overlay), not an
-- opt-in. uiScale is a straight multiplier on top of the addon's own
-- built-in layout, which is already sized 25% larger than the
-- addon's original geometry - see Options.lua's Interface Size
-- dropdown.
-- ============================================================
local DEFAULTS = {
    lureOverlayEnabled = true,
    minimapIcon = { hide = true },
    showAddonCompartmentButton = true,
    uiScale = 1.0,
}

local function CopyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            CopyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

MSC.db = nil

-- ============================================================
-- Root event frame. This is the ONLY frame created at load time.
-- Everything else (the main window, per-feature listeners) is
-- built lazily so a player who never opens the addon, or never
-- opts into tracking, pays nothing: no extra frames, no extra
-- event registrations, no OnUpdate.
-- ============================================================
local rootFrame = CreateFrame("Frame")
rootFrame:RegisterEvent("ADDON_LOADED")
rootFrame:RegisterEvent("PLAYER_LOGIN")

rootFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded == ADDON_NAME then
            MidnightSkinningCompanionDB = MidnightSkinningCompanionDB or {}
            MSC.db = CopyDefaults(MidnightSkinningCompanionDB, DEFAULTS)
            rootFrame:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        MSC:OnPlayerLogin()
    end
end)

function MSC:OnPlayerLogin()
    MSC.Profession:OnLogin(function(isSkinner)
        MSC:SetFeaturesEnabled(isSkinner)
    end)
    -- Snapshot at login only - a player who learns Skinning mid-
    -- session gets the rest of the addon live (see SetFeaturesEnabled)
    -- but not these icons.
    if MSC.Profession:IsSkinner() then
        MSC:SetAddonCompartmentShown(MSC.db.showAddonCompartmentButton)
        MSC:UpdateMinimapIcon()
    end
end

-- The addon is inert for a non-skinner and live for a skinner - this
-- is the only place that decision gets made. Fires once at login and
-- again any time MSC.Profession detects the player's Skinning status
-- has flipped (e.g. they just learned it). LureOverlay restores the
-- player's own prior choice (defaults to on, but Options > Lure
-- Overlay can turn it off) rather than being forced on - each
-- module's startup is independent, so one must never turn the other
-- on or off as a side effect.
function MSC:SetFeaturesEnabled(enabled)
    if MSC.featuresEnabled == enabled then
        return
    end
    MSC.featuresEnabled = enabled

    if enabled then
        if MSC.Quests then
            MSC.Quests:Enable()
        end
        if MSC.LureOverlay then
            MSC.LureOverlay:OnProfessionGained()
        end
    else
        if MSC.Quests then
            MSC.Quests:Disable()
        end
        if MSC.LureOverlay then
            MSC.LureOverlay:OnProfessionLost()
        end
        if MSC.UI then
            MSC.UI:Close()
        end
    end
end

-- ============================================================
-- Slash command - the only entry point that builds the UI.
-- "lure [beast|off]" is a debug hatch that forces the lure overlay to
-- show, bypassing Sixth Sense/zone/quest checks.
-- ============================================================
SLASH_MIDNIGHTSKINNINGCOMPANION1 = "/mscompanion"
SLASH_MIDNIGHTSKINNINGCOMPANION2 = "/skinningcompanion"
SlashCmdList["MIDNIGHTSKINNINGCOMPANION"] = function(msg)
    local command, arg = msg:lower():match("^(%S*)%s*(%S*)$")
    if command == "lure" and MSC.LureOverlay then
        if arg == "off" then
            MSC.LureOverlay:DebugHide()
        else
            MSC.LureOverlay:DebugShow(arg ~= "" and arg or nil)
        end
        return
    end
    if MSC.UI then
        MSC.UI:Toggle()
    end
end

local function OnAddonCompartmentClick()
    if MSC.UI then
        MSC.UI:Toggle()
    end
end

-- AddonCompartmentFrame has no supported unregister call, but
-- registeredAddons is a plain (non-secure) Lua table - adding/removing
-- our own entry from it, then calling UpdateDisplay(), is the same
-- technique LibDBCompartment uses for a real show/hide toggle.
local compartmentButtonInfo

function MSC:SetAddonCompartmentShown(shown)
    if not AddonCompartmentFrame then
        return
    end
    compartmentButtonInfo = compartmentButtonInfo or {
        text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title") or ADDON_NAME,
        icon = C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture"),
        notCheckable = true,
        func = OnAddonCompartmentClick,
    }
    local index = tIndexOf(AddonCompartmentFrame.registeredAddons, compartmentButtonInfo)
    if shown and not index then
        AddonCompartmentFrame:RegisterAddon(compartmentButtonInfo)
    elseif not shown and index then
        table.remove(AddonCompartmentFrame.registeredAddons, index)
        AddonCompartmentFrame:UpdateDisplay()
    end
end

local ldbObject

local function GetOrCreateLDB()
    if ldbObject then
        return ldbObject
    end
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then
        return nil
    end
    ldbObject = LDB:NewDataObject(ADDON_NAME, {
        type = "launcher",
        text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title") or ADDON_NAME,
        icon = C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture"),
        OnClick = function()
            if MSC.UI then
                MSC.UI:Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title") or ADDON_NAME)
        end,
    })
    return ldbObject
end

function MSC:UpdateMinimapIcon()
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    local ldb = GetOrCreateLDB()
    if not LibDBIcon or not ldb then
        return
    end
    if not LibDBIcon:IsRegistered(ADDON_NAME) then
        LibDBIcon:Register(ADDON_NAME, ldb, MSC.db.minimapIcon)
    end
    if MSC.db.minimapIcon.hide then
        LibDBIcon:Hide(ADDON_NAME)
    else
        LibDBIcon:Show(ADDON_NAME)
    end
end

function MSC:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MidnightSkinningCompanion|r: " .. tostring(msg))
end
