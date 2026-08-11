local ADDON_NAME, MSC = ...

MSC.Locale:Register("deDE", {
    OPTIONS_TOOLTIP = "Optionen",
    AVAILABLE_BEASTS = "Verfügbare Bestien",
    SKINNING_LURES = "Kürschnerköder",
    AUCTIONATOR_BUTTON = "Auctionator-Einkaufsliste",
    AUCTIONATOR_TOOLTIP = "Erstellt eine Auctionator-Einkaufsliste für die Zutaten jedes Köders, den du noch nicht besitzt.",
    MSG_AH_LIST_FAILED = "Die Auctionator-Einkaufsliste konnte nicht erstellt werden.",
    MSG_AH_LIST_EMPTY = "Keine fehlenden Köder - nichts einzukaufen.",
    MSG_AH_LIST_CREATED = "Auctionator-Einkaufsliste mit %d Zutat(en) erstellt.",
    NO_QUESTS_CONFIGURED = "Noch keine versteckten Quests konfiguriert.",
    WAYPOINT_BUTTON = "Wegpunkt",
    NO_BEASTS_CONFIGURED = "Noch keine Bestien zum Häuten konfiguriert.",
    CRAFT_BUTTON = "Herstellen",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Materialien fehlen",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Rezept noch nicht erlernt",
    MSG_REQUIRES_SKINNING = "Dieses Addon erfordert den Beruf Kürschnerei.",

    OPT_LURE_OVERLAY_NAME = "Köder-Overlay",
    OPT_LURE_OVERLAY_TOOLTIP = "Zeigt ein Popup zum Einsetzen des Köders einer Bestie, sobald das Spiel dir in der Nähe Sechster Sinn gewährt.",
    OPT_MINIMAP_NAME = "Minikarten-Symbol anzeigen",
    OPT_MINIMAP_TOOLTIP = "Zeigt ein Minikarten-Symbol, das das Begleiterfenster öffnet (wie der Slash-Befehl).",
    OPT_COMPARTMENT_NAME = "Addon-Fach-Eintrag anzeigen",
    OPT_COMPARTMENT_TOOLTIP = "Zeigt einen Eintrag im Addon-Fach (Minikarten-Dropdown), der das Begleiterfenster öffnet.",
    OPT_UI_SCALE_NAME = "Oberflächengröße",
    OPT_UI_SCALE_TOOLTIP = "Skaliert das Begleiterfenster und das Köder-Popup.",

    EDIT_MODE_TITLE = "Köder des Kürschner-Begleiters",
    EDIT_MODE_SUBTITLE = "Ziehen zum Verschieben - Rechtsklick zum Zurücksetzen",
    MSG_CANT_SHOW_COMBAT = "Das Köder-Overlay kann im Kampf nicht angezeigt werden.",
    MSG_UNKNOWN_BEAST = "Unbekannte Bestie: %s",
    DEBUG_LABEL = "Debug",

    MSG_CLOSE_PROFESSION_WINDOW = "Schließe das geöffnete Berufsfenster, bevor du einen Köder herstellst.",
    MSG_COULD_NOT_OPEN_RECIPE = "Rezept konnte nicht geöffnet werden: %s",
    MSG_CANNOT_CRAFT_NOW = "Dieser Köder kann gerade nicht hergestellt werden",
    MSG_COULD_NOT_CRAFT = "Herstellung fehlgeschlagen: %s",
    ITEM_FALLBACK = "Gegenstand #%d",

    NOTE_GRAND_BEAST = "Großbestie - erfordert das stärkere Köder-Rezept.",

    BEAST_NAMES = {
        gloomclaw = "Düsterklaue",
        silverscale = "Silberschuppe",
        lumenfin = "Lumenflosse",
        umbrafang = "Umbralfangzahn",
        netherscythe = "Nethersense",
    },
})
