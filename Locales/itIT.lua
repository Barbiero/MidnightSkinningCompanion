local ADDON_NAME, MSC = ...

MSC.Locale:Register("itIT", {
    OPTIONS_TOOLTIP = "Opzioni",
    AVAILABLE_BEASTS = "Bestie disponibili",
    SKINNING_LURES = "Esche da scuoiatura",
    AUCTIONATOR_BUTTON = "Lista della spesa Auctionator",
    AUCTIONATOR_TOOLTIP = "Crea una lista della spesa Auctionator per i reagenti di ogni esca che non possiedi ancora.",
    MSG_AH_LIST_FAILED = "Impossibile creare la lista della spesa Auctionator.",
    MSG_AH_LIST_EMPTY = "Nessuna esca mancante - niente da comprare.",
    MSG_AH_LIST_CREATED = "Lista della spesa Auctionator creata con %d reagente/i.",
    NO_QUESTS_CONFIGURED = "Nessuna missione nascosta configurata ancora.",
    WAYPOINT_BUTTON = "Punto di passaggio",
    NO_BEASTS_CONFIGURED = "Nessuna bestia da scuoiatura configurata ancora.",
    CRAFT_BUTTON = "Crea",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Materiali mancanti",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Ricetta non ancora appresa",
    MSG_REQUIRES_SKINNING = "Questo addon richiede la professione Scuoiatura.",

    OPT_LURE_OVERLAY_NAME = "Sovrapposizione esca",
    OPT_LURE_OVERLAY_TOOLTIP = "Mostra un popup per usare l'esca di una bestia quando il gioco ti concede Sesto Senso nelle vicinanze.",
    OPT_MINIMAP_NAME = "Mostra pulsante minimappa",
    OPT_MINIMAP_TOOLTIP = "Mostra un pulsante sulla minimappa che apre la finestra del compagno (come il comando slash).",
    OPT_COMPARTMENT_NAME = "Mostra pulsante nello scomparto addon",
    OPT_COMPARTMENT_TOOLTIP = "Mostra una voce nello scomparto addon (menu della minimappa) che apre la finestra del compagno.",
    OPT_UI_SCALE_NAME = "Dimensione interfaccia",
    OPT_UI_SCALE_TOOLTIP = "Ridimensiona la finestra del compagno e il popup dell'esca.",

    EDIT_MODE_TITLE = "Esca del Compagno di Scuoiatura",
    EDIT_MODE_SUBTITLE = "Trascina per spostare - clic destro per ripristinare",
    MSG_CANT_SHOW_COMBAT = "Impossibile mostrare la sovrapposizione dell'esca in combattimento.",
    MSG_UNKNOWN_BEAST = "Bestia sconosciuta: %s",
    DEBUG_LABEL = "debug",

    MSG_CLOSE_PROFESSION_WINDOW = "Chiudi la finestra della professione aperta prima di creare un'esca.",
    MSG_COULD_NOT_OPEN_RECIPE = "Impossibile aprire la ricetta: %s",
    MSG_CANNOT_CRAFT_NOW = "Impossibile creare questa esca in questo momento",
    MSG_COULD_NOT_CRAFT = "Impossibile creare: %s",
    ITEM_FALLBACK = "Oggetto #%d",

    NOTE_GRAND_BEAST = "Bestia maestosa - richiede la ricetta dell'esca più potente.",

    BEAST_NAMES = {
        gloomclaw = "Cupartiglio",
        silverscale = "Scagliargento",
        lumenfin = "Lumipinna",
        umbrafang = "Zannombra",
        netherscythe = "Falcefatua",
    },
})
