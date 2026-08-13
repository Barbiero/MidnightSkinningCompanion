local ADDON_NAME, MSC = ...

if not MSC.Locale:ShouldLoad("zhCN") then return end

MSC.Locale:Register("zhCN", function() return {
    OPTIONS_TOOLTIP = "选项",
    AVAILABLE_BEASTS = "可寻猎的野兽",
    SKINNING_LURES = "剥皮诱饵",
    AUCTIONATOR_BUTTON = "Auctionator 购物清单",
    AUCTIONATOR_TOOLTIP = "为你尚未拥有的每种诱饵所需的材料创建 Auctionator 购物清单。",
    MSG_AH_LIST_FAILED = "无法创建 Auctionator 购物清单。",
    MSG_AH_LIST_EMPTY = "没有缺少的诱饵 - 无需购买。",
    MSG_AH_LIST_CREATED = "已创建 Auctionator 购物清单，包含 %d 种材料。",
    NO_QUESTS_CONFIGURED = "尚未配置野兽击杀。",
    WAYPOINT_BUTTON = "路标",
    NO_BEASTS_CONFIGURED = "尚未配置剥皮野兽。",
    CRAFT_BUTTON = "制造",
    CRAFT_TOOLTIP_MISSING_MATERIALS = "材料不足",
    CRAFT_TOOLTIP_RECIPE_NOT_LEARNED = "尚未学会配方",
    MSG_REQUIRES_SKINNING = "此插件需要剥皮专业。",

    OPT_LURE_OVERLAY_NAME = "诱饵浮层",
    OPT_LURE_OVERLAY_TOOLTIP = "当游戏在附近赋予你六感时，显示一个用于使用野兽诱饵的弹窗。",
    OPT_MINIMAP_NAME = "显示小地图按钮",
    OPT_MINIMAP_TOOLTIP = "显示一个可打开伙伴窗口的小地图按钮（与斜杠命令效果相同）。",
    OPT_COMPARTMENT_NAME = "显示插件面板按钮",
    OPT_COMPARTMENT_TOOLTIP = "在插件面板（小地图下拉菜单）中显示一个可打开伙伴窗口的条目。",
    OPT_UI_SCALE_NAME = "界面大小",
    OPT_UI_SCALE_TOOLTIP = "缩放伙伴窗口和诱饵弹窗。",

    EDIT_MODE_TITLE = "剥皮伙伴诱饵",
    EDIT_MODE_SUBTITLE = "拖动以移动 - 右键单击以重置",
    MSG_CANT_SHOW_COMBAT = "战斗中无法显示诱饵浮层。",
    MSG_UNKNOWN_BEAST = "未知野兽：%s",
    DEBUG_LABEL = "调试",

    MSG_CLOSE_PROFESSION_WINDOW = "制作诱饵前请先关闭已打开的专业窗口。",
    MSG_COULD_NOT_OPEN_RECIPE = "无法打开配方：%s",
    MSG_CANNOT_CRAFT_NOW = "目前无法制作此诱饵",
    MSG_COULD_NOT_CRAFT = "无法制作：%s",
    ITEM_FALLBACK = "物品 #%d",

    NOTE_GRAND_BEAST = "巨型野兽 - 需要更强力的诱饵配方。",

    BEAST_NAMES = {
        gloomclaw = "幽灵之爪",
        silverscale = "银鳞",
        lumenfin = "流明之鳍",
        umbrafang = "幽齿",
        netherscythe = "虚空飞镰",
    },
} end)
