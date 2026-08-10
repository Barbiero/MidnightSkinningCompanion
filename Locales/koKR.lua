local ADDON_NAME, MSC = ...

MSC.Locale:Register("koKR", {
    OPTIONS_TOOLTIP = "옵션",
    AVAILABLE_BEASTS = "사냥 가능한 야수",
    SKINNING_LURES = "무두질 유인제",
    AUCTIONATOR_BUTTON = "Auctionator 구매 목록",
    AUCTIONATOR_TOOLTIP = "아직 보유하지 않은 모든 유인제의 재료로 Auctionator 구매 목록을 생성합니다.",
    MSG_AH_LIST_FAILED = "Auctionator 구매 목록을 생성할 수 없습니다.",
    MSG_AH_LIST_EMPTY = "부족한 유인제가 없습니다 - 구매할 항목이 없습니다.",
    MSG_AH_LIST_CREATED = "재료 %d개로 Auctionator 구매 목록을 생성했습니다.",
    NO_QUESTS_CONFIGURED = "아직 설정된 숨겨진 퀘스트가 없습니다.",
    WAYPOINT_BUTTON = "경로 표시",
    NO_BEASTS_CONFIGURED = "아직 설정된 무두질 야수가 없습니다.",
    CRAFT_BUTTON = "제작",
    MSG_REQUIRES_SKINNING = "이 애드온은 무두질 전문 기술이 필요합니다.",

    OPT_LURE_OVERLAY_NAME = "유인제 오버레이",
    OPT_LURE_OVERLAY_TOOLTIP = "근처에서 육감을 얻었을 때 야수의 유인제를 사용할 수 있는 팝업을 표시합니다.",
    OPT_MINIMAP_NAME = "미니맵 버튼 표시",
    OPT_MINIMAP_TOOLTIP = "동반자 창을 여는 미니맵 버튼을 표시합니다 (슬래시 명령어와 동일).",
    OPT_COMPARTMENT_NAME = "애드온 모음 버튼 표시",
    OPT_COMPARTMENT_TOOLTIP = "동반자 창을 여는 항목을 애드온 모음(미니맵 드롭다운)에 표시합니다.",
    OPT_UI_SCALE_NAME = "인터페이스 크기",
    OPT_UI_SCALE_TOOLTIP = "동반자 창과 유인제 팝업의 크기를 조절합니다.",

    EDIT_MODE_TITLE = "무두질 동반자 유인제",
    EDIT_MODE_SUBTITLE = "드래그하여 이동 - 우클릭하여 초기화",
    MSG_CANT_SHOW_COMBAT = "전투 중에는 유인제 오버레이를 표시할 수 없습니다.",
    MSG_UNKNOWN_BEAST = "알 수 없는 야수: %s",
    DEBUG_LABEL = "디버그",

    MSG_CLOSE_PROFESSION_WINDOW = "유인제를 제작하기 전에 열려 있는 전문 기술 창을 닫으세요.",
    MSG_COULD_NOT_OPEN_RECIPE = "제조법을 열 수 없습니다: %s",
    MSG_CANNOT_CRAFT_NOW = "지금은 이 유인제를 제작할 수 없습니다",
    MSG_COULD_NOT_CRAFT = "제작할 수 없습니다: %s",
    ITEM_FALLBACK = "아이템 #%d",

    NOTE_GRAND_BEAST = "강대한 야수 - 더 강력한 유인제 제조법이 필요합니다.",

    BEAST_NAMES = {
        gloomclaw = "암울발톱",
        silverscale = "은비늘",
        lumenfin = "광명지느러미",
        umbrafang = "암영송곳니",
        netherscythe = "황천낫",
    },
})
