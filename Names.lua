local ADDON_NAME, MSC = ...

local Names = {}
MSC.Names = Names

-- No client API exposes an arbitrary NPC's localized name (unlike
-- items or zones), so these are hand-maintained per CLAUDE.md's
-- carve-out for creature names. They live in each Locales/<code>.lua
-- file's BEAST_NAMES table (sourced from Wowhead's per-locale NPC
-- pages, e.g. https://de.wowhead.com/npc=245688) alongside every
-- other player-facing string, rather than in a separate table here -
-- MSC.L's client-locale -> enUS -> key fallback applies to them too.
function Names:GetBeastName(key)
    local names = MSC.L.BEAST_NAMES
    return (names and names[key]) or key
end

-- Ordinary UI text (not a proper noun), so it comes from MSC.L like
-- everything else in Locales/ rather than living in BEAST_NAMES.
function Names:GetBeastNote(key)
    if key == "netherscythe" then
        return MSC.L.NOTE_GRAND_BEAST
    end
    return nil
end

function Names:GetZoneName(mapID)
    if not mapID then
        return nil
    end
    local info = C_Map.GetMapInfo(mapID)
    return info and info.name or nil
end

function Names:GetItemName(itemID)
    if not itemID then
        return nil
    end
    local name = C_Item.GetItemNameByID(itemID)
    if not name then
        C_Item.RequestLoadItemDataByID(itemID)
    end
    return name
end
