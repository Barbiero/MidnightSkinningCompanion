local ADDON_NAME, MSC = ...

-- Multiple ranks/variants exist per location; treat any as "in range".
MSC.SIXTH_SENSE_SPELL_IDS = { 1239058, 1239120, 1239121, 1239122, 1239151 }

-- Crafting. Fixed, well-known skill line ID, unchanged across
-- expansions - used to detect whether the profession window (if
-- already open) is showing Skinning or some other profession.
MSC.SKINNING_SKILL_LINE_ID = 393

MSC.BEASTS = { "gloomclaw", "silverscale", "lumenfin", "umbrafang", "netherscythe" }

-- Waypoint, LureOverlay
MSC.BEAST_LOCATION = {
    gloomclaw    = { mapID = 2395, x = 41.95, y = 80.05, npcID = 245688 },
    silverscale  = { mapID = 2437, x = 47.69, y = 53.25, npcID = 245699 },
    lumenfin     = { mapID = 2413, x = 66.28, y = 47.91, npcID = 245690 },
    umbrafang    = { mapID = 2405, x = 54.60, y = 65.80, npcID = 247096 },
    netherscythe = { mapID = 2405, x = 43.25, y = 82.75, npcID = 247101 },
}

-- Quests, LureOverlay
MSC.BEAST_QUEST = {
    gloomclaw = 88545,
    silverscale = 88526,
    lumenfin = 88531,
    umbrafang = 88532,
    netherscythe = 88524,
}

-- Crafting, LureOverlay
MSC.BEAST_LURE = {
    gloomclaw    = { craftSpellID = 1225943, itemID = 238652 },
    silverscale  = { craftSpellID = 1225944, itemID = 238653 },
    lumenfin     = { craftSpellID = 1225945, itemID = 238654 },
    umbrafang    = { craftSpellID = 1225946, itemID = 238655 },
    netherscythe = { craftSpellID = 1225948, itemID = 238656, craftingDataID = 2510 },
}

-- Crafting, AuctionHouse only
MSC.BEAST_REAGENTS = {
    gloomclaw    = { { itemID = 238371, required = 8 }, { itemID = 238366, required = 8 } },
    silverscale  = { { itemID = 238382, required = 8 } },
    lumenfin     = { { itemID = 238375, required = 8 }, { itemID = 238374, required = 8 } },
    umbrafang    = { { itemID = 238373, required = 4 } },
    netherscythe = { { itemID = 238380, required = 4 } },
}

MSC.BEAST_ICON = {
    gloomclaw = "Interface\\Icons\\Ability_Hunter_Pet_Cat",
    silverscale = "Interface\\Icons\\Ability_Hunter_Pet_Turtle",
    lumenfin = "Interface\\Icons\\INV_SporeBat3Mount_Purple",
    umbrafang = "Interface\\Icons\\INV_StalkerMount_Orange",
    netherscythe = "Interface\\Icons\\INV_Achievement_RaidNerubian_FlyingNerubianEvolved",
}
