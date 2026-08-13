local ADDON_NAME, MSC = ...

if not MSC.Locale:ShouldLoad("ptBR") then return end

MSC.Locale:Register("ptBR", function() return {
    OPTIONS_TOOLTIP = "Opções",
    AVAILABLE_BEASTS = "Bestas disponíveis",
    SKINNING_LURES = "Iscas de esfolamento",
    AUCTIONATOR_BUTTON = "Lista de compras do Auctionator",
    AUCTIONATOR_TOOLTIP = "Cria uma lista de compras do Auctionator com os reagentes de cada isca que você ainda não possui.",
    MSG_AH_LIST_FAILED = "Não foi possível criar a lista de compras do Auctionator.",
    MSG_AH_LIST_EMPTY = "Nenhuma isca faltando - nada para comprar.",
    MSG_AH_LIST_CREATED = "Lista de compras do Auctionator criada com %d reagente(s).",
    NO_QUESTS_CONFIGURED = "Nenhuma morte de besta configurada ainda.",
    WAYPOINT_BUTTON = "Ponto de rota",
    NO_BEASTS_CONFIGURED = "Nenhuma besta de esfolamento configurada ainda.",
    CRAFT_BUTTON = "Criar",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Faltam materiais",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Receita ainda não aprendida",
    MSG_REQUIRES_SKINNING = "Este addon requer a profissão de Esfolamento.",

    OPT_LURE_OVERLAY_NAME = "Sobreposição de isca",
    OPT_LURE_OVERLAY_TOOLTIP = "Mostra um popup para usar a isca de uma besta quando o jogo concede Sexto Sentido nas proximidades.",
    OPT_MINIMAP_NAME = "Mostrar botão no minimapa",
    OPT_MINIMAP_TOOLTIP = "Mostra um botão no minimapa que abre a janela do companheiro (igual ao comando de barra).",
    OPT_COMPARTMENT_NAME = "Mostrar botão no compartimento de addons",
    OPT_COMPARTMENT_TOOLTIP = "Mostra uma entrada no compartimento de addons (menu do minimapa) que abre a janela do companheiro.",
    OPT_UI_SCALE_NAME = "Tamanho da interface",
    OPT_UI_SCALE_TOOLTIP = "Redimensiona a janela do companheiro e o popup da isca.",

    EDIT_MODE_TITLE = "Isca do Companheiro de Esfolamento",
    EDIT_MODE_SUBTITLE = "Arraste para mover - clique com o botão direito para redefinir",
    MSG_CANT_SHOW_COMBAT = "Não é possível mostrar a sobreposição de isca em combate.",
    MSG_UNKNOWN_BEAST = "Besta desconhecida: %s",
    DEBUG_LABEL = "depuração",

    MSG_CLOSE_PROFESSION_WINDOW = "Feche a janela de profissão aberta antes de confeccionar uma isca.",
    MSG_COULD_NOT_OPEN_RECIPE = "Não foi possível abrir a receita: %s",
    MSG_CANNOT_CRAFT_NOW = "Não é possível confeccionar esta isca agora",
    MSG_COULD_NOT_CRAFT = "Não foi possível confeccionar: %s",
    ITEM_FALLBACK = "Item #%d",

    NOTE_GRAND_BEAST = "Besta grandiosa - requer a receita de isca mais forte.",

    BEAST_NAMES = {
        gloomclaw = "Garrúgubre",
        silverscale = "Escamaprata",
        lumenfin = "Barbatúmen",
        umbrafang = "Presassombra",
        netherscythe = "Foicetérea",
    },
} end)
