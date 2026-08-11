local ADDON_NAME, MSC = ...

MSC.Locale:Register("esMX", {
    OPTIONS_TOOLTIP = "Opciones",
    AVAILABLE_BEASTS = "Bestias disponibles",
    SKINNING_LURES = "Señuelos de desuello",
    AUCTIONATOR_BUTTON = "Lista de compras de Auctionator",
    AUCTIONATOR_TOOLTIP = "Crea una lista de compras de Auctionator con los materiales de cada señuelo que todavía no tienes.",
    MSG_AH_LIST_FAILED = "No se pudo crear la lista de compras de Auctionator.",
    MSG_AH_LIST_EMPTY = "No faltan señuelos - no hay nada que comprar.",
    MSG_AH_LIST_CREATED = "Lista de compras de Auctionator creada con %d material(es).",
    NO_QUESTS_CONFIGURED = "Todavía no hay misiones ocultas configuradas.",
    WAYPOINT_BUTTON = "Ruta",
    NO_BEASTS_CONFIGURED = "Todavía no hay bestias de desuello configuradas.",
    CRAFT_BUTTON = "Elaborar",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Faltan materiales",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Receta aún no aprendida",
    MSG_REQUIRES_SKINNING = "Este addon requiere la profesión de Desuello.",

    OPT_LURE_OVERLAY_NAME = "Superposición de señuelo",
    OPT_LURE_OVERLAY_TOOLTIP = "Muestra una ventana emergente para usar el señuelo de una bestia cuando el juego te otorga Sexto Sentido cerca.",
    OPT_MINIMAP_NAME = "Mostrar botón de minimapa",
    OPT_MINIMAP_TOOLTIP = "Muestra un botón en el minimapa que abre la ventana del acompañante (igual que el comando de barra diagonal).",
    OPT_COMPARTMENT_NAME = "Mostrar botón en el compartimento de addons",
    OPT_COMPARTMENT_TOOLTIP = "Muestra una entrada en el compartimento de addons (menú del minimapa) que abre la ventana del acompañante.",
    OPT_UI_SCALE_NAME = "Tamaño de interfaz",
    OPT_UI_SCALE_TOOLTIP = "Escala la ventana del acompañante y la ventana emergente del señuelo.",

    EDIT_MODE_TITLE = "Señuelo del Acompañante de Desuello",
    EDIT_MODE_SUBTITLE = "Arrastra para mover - clic derecho para restablecer",
    MSG_CANT_SHOW_COMBAT = "No se puede mostrar la superposición de señuelo en combate.",
    MSG_UNKNOWN_BEAST = "Bestia desconocida: %s",
    DEBUG_LABEL = "depuración",

    MSG_CLOSE_PROFESSION_WINDOW = "Cierra la ventana de profesión abierta antes de elaborar un señuelo.",
    MSG_COULD_NOT_OPEN_RECIPE = "No se pudo abrir la receta: %s",
    MSG_CANNOT_CRAFT_NOW = "No se puede elaborar este señuelo en este momento",
    MSG_COULD_NOT_CRAFT = "No se pudo elaborar: %s",
    ITEM_FALLBACK = "Objeto #%d",

    NOTE_GRAND_BEAST = "Bestia mayor - requiere la receta de señuelo más fuerte.",

    BEAST_NAMES = {
        gloomclaw = "Zarpenumbra",
        silverscale = "Escama de plata",
        lumenfin = "Lumialeta",
        umbrafang = "Umbracolmillo",
        netherscythe = "Guadaña abisal",
    },
})
