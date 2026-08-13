local ADDON_NAME, MSC = ...

if not MSC.Locale:ShouldLoad("frFR") then return end

MSC.Locale:Register("frFR", function() return {
    OPTIONS_TOOLTIP = "Options",
    AVAILABLE_BEASTS = "Bêtes disponibles",
    SKINNING_LURES = "Appâts de dépeçage",
    AUCTIONATOR_BUTTON = "Liste d'achats Auctionator",
    AUCTIONATOR_TOOLTIP = "Crée une liste d'achats Auctionator pour les composants de chaque appât que vous ne possédez pas encore.",
    MSG_AH_LIST_FAILED = "Impossible de créer la liste d'achats Auctionator.",
    MSG_AH_LIST_EMPTY = "Aucun appât manquant - rien à acheter.",
    MSG_AH_LIST_CREATED = "Liste d'achats Auctionator créée avec %d composant(s).",
    NO_QUESTS_CONFIGURED = "Aucune mise à mort de bête configurée pour le moment.",
    WAYPOINT_BUTTON = "Point de repère",
    NO_BEASTS_CONFIGURED = "Aucune bête de dépeçage configurée pour le moment.",
    CRAFT_BUTTON = "Créer",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "Matériaux manquants",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "Recette pas encore apprise",
    MSG_REQUIRES_SKINNING = "Cet addon nécessite le métier Dépeçage.",

    OPT_LURE_OVERLAY_NAME = "Superposition d'appât",
    OPT_LURE_OVERLAY_TOOLTIP = "Affiche une fenêtre pour utiliser l'appât d'une bête lorsque le jeu vous accorde Sixième Sens à proximité.",
    OPT_MINIMAP_NAME = "Afficher le bouton de minicarte",
    OPT_MINIMAP_TOOLTIP = "Affiche un bouton sur la minicarte qui ouvre la fenêtre du compagnon (comme la commande slash).",
    OPT_COMPARTMENT_NAME = "Afficher le bouton du compartiment d'addons",
    OPT_COMPARTMENT_TOOLTIP = "Affiche une entrée dans le compartiment d'addons (menu de la minicarte) qui ouvre la fenêtre du compagnon.",
    OPT_UI_SCALE_NAME = "Taille de l'interface",
    OPT_UI_SCALE_TOOLTIP = "Redimensionne la fenêtre du compagnon et la fenêtre d'appât.",

    EDIT_MODE_TITLE = "Appât du compagnon de dépeçage",
    EDIT_MODE_SUBTITLE = "Glisser pour déplacer - clic droit pour réinitialiser",
    MSG_CANT_SHOW_COMBAT = "Impossible d'afficher la superposition d'appât en combat.",
    MSG_UNKNOWN_BEAST = "Bête inconnue : %s",
    DEBUG_LABEL = "débogage",

    MSG_CLOSE_PROFESSION_WINDOW = "Fermez la fenêtre de métier ouverte avant de fabriquer un appât.",
    MSG_COULD_NOT_OPEN_RECIPE = "Impossible d'ouvrir la recette : %s",
    MSG_CANNOT_CRAFT_NOW = "Impossible de fabriquer cet appât pour le moment",
    MSG_COULD_NOT_CRAFT = "Fabrication impossible : %s",
    ITEM_FALLBACK = "Objet #%d",

    NOTE_GRAND_BEAST = "Bête majeure - nécessite la recette d'appât la plus puissante.",

    BEAST_NAMES = {
        gloomclaw = "Griffe-sinistre",
        silverscale = "Ecaille-d'argent",
        lumenfin = "Lumaileron",
        umbrafang = "Ombrecroc",
        netherscythe = "Faux-du-Néant",
    },
} end)
