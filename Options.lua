local ADDON_NAME, MSC = ...

local Options = {}
MSC.Options = Options

-- Configuration lives in the Settings API (Escape > Options > AddOns
-- > Midnight Skinning Companion), not in a custom frame - a single
-- shared panel avoids the slash-command collisions and duplicate
-- popups that come with every addon rolling its own options window.

local category

local function AddCheckbox(variable, name, tooltip, default, getValue, setValue)
    local setting = Settings.RegisterProxySetting(category, variable, Settings.VarType.Boolean, name, default, getValue, setValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

category = Settings.RegisterVerticalLayoutCategory("Midnight Skinning Companion")

AddCheckbox(
    "MSC_LURE_OVERLAY_ENABLED",
    "Lure Overlay",
    "Show a popup to use a beast's lure when the game grants you Sixth Sense nearby.",
    true,
    function() return MSC.db.lureOverlayEnabled end,
    function(value)
        if value then
            MSC.LureOverlay:Enable()
        else
            MSC.LureOverlay:Disable()
        end
    end
)

Settings.RegisterAddOnCategory(category)

function Options:Open()
    Settings.OpenToCategory(category:GetID())
end
