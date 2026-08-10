local ADDON_NAME, MSC = ...

local Names = {}
MSC.Names = Names

local BEAST_NAMES = {
    enUS = {
        gloomclaw = "Gloomclaw",
        silverscale = "Silverscale",
        lumenfin = "Lumenfin",
        umbrafang = "Umbrafang",
        netherscythe = "Netherscythe",
    },
}

local BEAST_NOTES = {
    enUS = {
        netherscythe = "Grand beast - requires the stronger lure recipe.",
    },
}

local names = BEAST_NAMES[GetLocale()] or BEAST_NAMES.enUS
local notes = BEAST_NOTES[GetLocale()] or BEAST_NOTES.enUS

function Names:GetBeastName(key)
    return names[key] or key
end

function Names:GetBeastNote(key)
    return notes[key]
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
