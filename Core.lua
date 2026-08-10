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
    -- Quests always tracks. LureOverlay restores the player's own
    -- prior choice (defaults to on, but Options > Lure Overlay can
    -- turn it off) - each module's startup is independent, so one
    -- must never turn the other on or off as a side effect.
    if MSC.Quests and MSC.Quests.OnLogin then
        MSC.Quests:OnLogin()
    end
    if MSC.LureOverlay and MSC.LureOverlay.OnLogin then
        MSC.LureOverlay:OnLogin()
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

-- Referenced by name from the TOC's AddonCompartmentFunc - must stay
-- global. Same action as the slash command.
function MSC_OnAddonCompartmentClick()
    if MSC.UI then
        MSC.UI:Toggle()
    end
end

function MSC:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MidnightSkinningCompanion|r: " .. tostring(msg))
end
