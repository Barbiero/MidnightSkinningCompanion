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

local function AddDropdown(variable, name, tooltip, default, options, getValue, setValue)
    local setting = Settings.RegisterProxySetting(category, variable, Settings.VarType.Number, name, default, getValue, setValue)
    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        for _, opt in ipairs(options) do
            container:Add(opt.value, opt.text)
        end
        return container:GetData()
    end
    Settings.CreateDropdown(category, setting, GetOptions, tooltip)
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

AddCheckbox(
    "MSC_MINIMAP_ICON_SHOWN",
    "Show Minimap Button",
    "Show a minimap button that opens the companion window (same as the slash command).",
    false,
    function() return not MSC.db.minimapIcon.hide end,
    function(value)
        MSC.db.minimapIcon.hide = not value
        MSC:UpdateMinimapIcon()
    end
)

AddCheckbox(
    "MSC_ADDON_COMPARTMENT_SHOWN",
    "Show Addon Compartment Button",
    "Show an entry in the Addon Compartment (minimap dropdown) that opens the companion window.",
    true,
    function() return MSC.db.showAddonCompartmentButton end,
    function(value)
        MSC.db.showAddonCompartmentButton = value
        MSC:SetAddonCompartmentShown(value)
    end
)

AddDropdown(
    "MSC_UI_SCALE",
    "Interface Size",
    "Scales the companion window and lure popup.",
    1.0,
    { { value = 0.8, text = "80%" }, { value = 1.0, text = "100%" }, { value = 1.25, text = "125%" } },
    function() return MSC.db.uiScale end,
    function(value)
        MSC.db.uiScale = value
        if MSC.UI then
            MSC.UI:ApplyScale()
        end
        if MSC.LureOverlay then
            MSC.LureOverlay:ApplyScale()
        end
    end
)

Settings.RegisterAddOnCategory(category)

function Options:Open()
    Settings.OpenToCategory(category:GetID())
end
