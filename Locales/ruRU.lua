local ADDON_NAME, MSC = ...

MSC.Locale:Register("ruRU", {
    OPTIONS_TOOLTIP = "Настройки",
    AVAILABLE_BEASTS = "Доступные звери",
    SKINNING_LURES = "Приманки для снятия шкур",
    AUCTIONATOR_BUTTON = "Список покупок Auctionator",
    AUCTIONATOR_TOOLTIP = "Создает список покупок Auctionator для реагентов каждой приманки, которой у вас еще нет.",
    MSG_AH_LIST_FAILED = "Не удалось создать список покупок Auctionator.",
    MSG_AH_LIST_EMPTY = "Нет недостающих приманок - покупать нечего.",
    MSG_AH_LIST_CREATED = "Список покупок Auctionator создан: %d реагент(ов).",
    NO_QUESTS_CONFIGURED = "Скрытые задания пока не настроены.",
    WAYPOINT_BUTTON = "Маршрут",
    NO_BEASTS_CONFIGURED = "Звери для снятия шкур пока не настроены.",
    CRAFT_BUTTON = "Создать",
    MSG_REQUIRES_SKINNING = "Для этого аддона требуется профессия Снятие шкур.",

    OPT_LURE_OVERLAY_NAME = "Оверлей приманки",
    OPT_LURE_OVERLAY_TOOLTIP = "Показывает всплывающее окно для использования приманки зверя, когда игра дает вам Шестое чувство поблизости.",
    OPT_MINIMAP_NAME = "Показать кнопку на миникарте",
    OPT_MINIMAP_TOOLTIP = "Показывает кнопку на миникарте, открывающую окно спутника (аналог слэш-команды).",
    OPT_COMPARTMENT_NAME = "Показать кнопку в отсеке аддонов",
    OPT_COMPARTMENT_TOOLTIP = "Показывает пункт в отсеке аддонов (меню миникарты), открывающий окно спутника.",
    OPT_UI_SCALE_NAME = "Размер интерфейса",
    OPT_UI_SCALE_TOOLTIP = "Масштабирует окно спутника и всплывающее окно приманки.",

    EDIT_MODE_TITLE = "Приманка спутника по снятию шкур",
    EDIT_MODE_SUBTITLE = "Перетащите для перемещения - правый клик для сброса",
    MSG_CANT_SHOW_COMBAT = "Невозможно показать оверлей приманки в бою.",
    MSG_UNKNOWN_BEAST = "Неизвестный зверь: %s",
    DEBUG_LABEL = "отладка",

    MSG_CLOSE_PROFESSION_WINDOW = "Закройте открытое окно профессии перед созданием приманки.",
    MSG_COULD_NOT_OPEN_RECIPE = "Не удалось открыть рецепт: %s",
    MSG_CANNOT_CRAFT_NOW = "Невозможно создать эту приманку прямо сейчас",
    MSG_COULD_NOT_CRAFT = "Не удалось создать: %s",
    ITEM_FALLBACK = "Предмет #%d",

    NOTE_GRAND_BEAST = "Большой зверь - требует более сильный рецепт приманки.",

    BEAST_NAMES = {
        gloomclaw = "Мрачный Коготь",
        silverscale = "Сереброчешуй",
        lumenfin = "Светлоплав",
        umbrafang = "Мракоклык",
        netherscythe = "Коса Пустоты",
    },
})
