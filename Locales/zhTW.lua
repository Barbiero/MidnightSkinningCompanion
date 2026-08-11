local ADDON_NAME, MSC = ...

MSC.Locale:Register("zhTW", {
    OPTIONS_TOOLTIP = "選項",
    AVAILABLE_BEASTS = "可尋獵的野獸",
    SKINNING_LURES = "剝皮誘餌",
    AUCTIONATOR_BUTTON = "Auctionator 購物清單",
    AUCTIONATOR_TOOLTIP = "為你尚未擁有的每種誘餌所需的材料建立 Auctionator 購物清單。",
    MSG_AH_LIST_FAILED = "無法建立 Auctionator 購物清單。",
    MSG_AH_LIST_EMPTY = "沒有缺少的誘餌 - 無需購買。",
    MSG_AH_LIST_CREATED = "已建立 Auctionator 購物清單，包含 %d 種材料。",
    NO_QUESTS_CONFIGURED = "尚未設定野獸擊殺。",
    WAYPOINT_BUTTON = "路標",
    NO_BEASTS_CONFIGURED = "尚未設定剝皮野獸。",
    CRAFT_BUTTON = "製作",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "材料不足",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "尚未學會配方",
    MSG_REQUIRES_SKINNING = "此外掛需要剝皮專業。",

    OPT_LURE_OVERLAY_NAME = "誘餌浮層",
    OPT_LURE_OVERLAY_TOOLTIP = "當遊戲在附近賦予你六感時，顯示一個用於使用野獸誘餌的彈出視窗。",
    OPT_MINIMAP_NAME = "顯示小地圖按鈕",
    OPT_MINIMAP_TOOLTIP = "顯示一個可開啟夥伴視窗的小地圖按鈕（與斜線指令效果相同）。",
    OPT_COMPARTMENT_NAME = "顯示外掛面板按鈕",
    OPT_COMPARTMENT_TOOLTIP = "在外掛面板（小地圖下拉選單）中顯示一個可開啟夥伴視窗的項目。",
    OPT_UI_SCALE_NAME = "介面大小",
    OPT_UI_SCALE_TOOLTIP = "縮放夥伴視窗和誘餌彈出視窗。",

    EDIT_MODE_TITLE = "剝皮夥伴誘餌",
    EDIT_MODE_SUBTITLE = "拖曳以移動 - 按右鍵以重設",
    MSG_CANT_SHOW_COMBAT = "戰鬥中無法顯示誘餌浮層。",
    MSG_UNKNOWN_BEAST = "未知野獸：%s",
    DEBUG_LABEL = "除錯",

    MSG_CLOSE_PROFESSION_WINDOW = "製作誘餌前請先關閉已開啟的專業視窗。",
    MSG_COULD_NOT_OPEN_RECIPE = "無法開啟配方：%s",
    MSG_CANNOT_CRAFT_NOW = "目前無法製作此誘餌",
    MSG_COULD_NOT_CRAFT = "無法製作：%s",
    ITEM_FALLBACK = "物品 #%d",

    NOTE_GRAND_BEAST = "巨型野獸 - 需要更強力的誘餌配方。",

    BEAST_NAMES = {
        gloomclaw = "幽暗裂爪",
        silverscale = "銀鱗",
        lumenfin = "流明之鰭",
        umbrafang = "影牙",
        netherscythe = "虛空之鐮",
    },
})
