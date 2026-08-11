local ADDON_NAME, MSC = ...

-- Base locale. Every key MSC.L is ever asked for must exist here -
-- every other locale file falls back to this one for anything it
-- doesn't (yet) translate.
MSC.Locale:Register("enUS", {
    OPTIONS_TOOLTIP = "Options",
    AVAILABLE_BEASTS = "Available Beasts",
    SKINNING_LURES = "Skinning Lures",
    AUCTIONATOR_BUTTON = "Auctionator Shopping List",
    AUCTIONATOR_TOOLTIP = "Creates an Auctionator shopping list for the reagents of every lure you don't have yet.",
    MSG_AH_LIST_FAILED = "Could not create Auctionator shopping list.",
    MSG_AH_LIST_EMPTY = "No missing lures - nothing to shop for.",
    MSG_AH_LIST_CREATED = "Auctionator shopping list created with %d reagent(s).",
    NO_QUESTS_CONFIGURED = "No beast kills configured yet.",
    WAYPOINT_BUTTON = "Waypoint",
    NO_BEASTS_CONFIGURED = "No skinning beasts configured yet.",
    CRAFT_BUTTON = "Craft",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Missing materials",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Recipe not learned yet",
    MSG_REQUIRES_SKINNING = "This addon requires the Skinning profession.",

    OPT_LURE_OVERLAY_NAME = "Lure Overlay",
    OPT_LURE_OVERLAY_TOOLTIP = "Show a popup to use a beast's lure when the game grants you Sixth Sense nearby.",
    OPT_MINIMAP_NAME = "Show Minimap Button",
    OPT_MINIMAP_TOOLTIP = "Show a minimap button that opens the companion window (same as the slash command).",
    OPT_COMPARTMENT_NAME = "Show Addon Compartment Button",
    OPT_COMPARTMENT_TOOLTIP = "Show an entry in the Addon Compartment (minimap dropdown) that opens the companion window.",
    OPT_UI_SCALE_NAME = "Interface Size",
    OPT_UI_SCALE_TOOLTIP = "Scales the companion window and lure popup.",

    EDIT_MODE_TITLE = "Skinning Companion Lure",
    EDIT_MODE_SUBTITLE = "Drag to move - right-click to reset",
    MSG_CANT_SHOW_COMBAT = "Can't show the lure overlay in combat.",
    MSG_UNKNOWN_BEAST = "Unknown beast: %s",
    DEBUG_LABEL = "debug",

    MSG_CLOSE_PROFESSION_WINDOW = "Close the open profession window before crafting a lure.",
    MSG_COULD_NOT_OPEN_RECIPE = "Could not open recipe: %s",
    MSG_CANNOT_CRAFT_NOW = "Cannot craft this lure right now",
    MSG_COULD_NOT_CRAFT = "Could not craft: %s",
    ITEM_FALLBACK = "Item #%d",

    NOTE_GRAND_BEAST = "Grand beast - requires the stronger lure recipe.",

    -- No client API exposes an arbitrary NPC's localized name - see
    -- Names.lua. Sourced from Wowhead's per-locale NPC pages:
    -- gloomclaw=245688, silverscale=245699, lumenfin=245690,
    -- umbrafang=247096, netherscythe=247101.
    BEAST_NAMES = {
        gloomclaw = "Gloomclaw",
        silverscale = "Silverscale",
        lumenfin = "Lumenfin",
        umbrafang = "Umbrafang",
        netherscythe = "Netherscythe",
    },
})
