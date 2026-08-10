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
-- opt-in.
-- ============================================================
local DEFAULTS = {
    lureOverlayEnabled = true,
    minimapIcon = { hide = false },
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
    -- but not this icon, since the Addon Compartment has no supported
    -- way to remove an entry once registered.
    if MSC.Profession:IsSkinner() then
        MSC:RegisterAddonCompartment()
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
-- ============================================================
SLASH_MIDNIGHTSKINNINGCOMPANION1 = "/mscompanion"
SLASH_MIDNIGHTSKINNINGCOMPANION2 = "/skinningcompanion"
SlashCmdList["MIDNIGHTSKINNINGCOMPANION"] = function(msg)
    if MSC.UI then
        MSC.UI:Toggle()
    end
end

local function OnAddonCompartmentClick()
    if MSC.UI then
        MSC.UI:Toggle()
    end
end

-- Registers the Addon Compartment icon by hand instead of through
-- the TOC's AddonCompartmentFunc, which would register unconditionally
-- for every player at load - before MSC.Profession even knows whether
-- they're a skinner. Only called once, from OnPlayerLogin, and only
-- for a skinner.
function MSC:RegisterAddonCompartment()
    if not AddonCompartmentFrame then
        return
    end
    AddonCompartmentFrame:RegisterAddon({
        text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title") or ADDON_NAME,
        icon = C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture"),
        notCheckable = true,
        func = OnAddonCompartmentClick,
    })
end

function MSC:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MidnightSkinningCompanion|r: " .. tostring(msg))
end
