local ADDON_NAME, MSC = ...

local AuctionHouse = {}
MSC.AuctionHouse = AuctionHouse

-- Auctionator integration only. We never touch C_AuctionHouse or the
-- AHDB ourselves beyond reading Auctionator's already-scanned price
-- cache - fetching live AH data stays Auctionator's job.
local SHOPPING_LIST_NAME = "MSC: Skinning Lures"

function AuctionHouse:IsAuctionatorLoaded()
    return C_AddOns.IsAddOnLoaded("Auctionator") == true
end

-- Beast keys whose crafted lure the player does not currently own.
-- Goes through Crafting's public status rather than counting bags
-- itself, so the two modules never disagree on what "owned" means.
function AuctionHouse:GetMissingLureKeys()
    local missing = {}
    for _, key in ipairs(MSC.BEASTS) do
        if MSC.Crafting:GetReagentStatus(key).lureCount == 0 then
            missing[#missing + 1] = key
        end
    end
    return missing
end

-- Reagent shortfall (required - owned), aggregated across every
-- missing lure and keyed by itemID so a reagent shared by two
-- recipes is only asked for once.
function AuctionHouse:GetMissingLureReagentMap()
    local map = {}
    for _, key in ipairs(self:GetMissingLureKeys()) do
        local status = MSC.Crafting:GetReagentStatus(key)
        for _, reagent in ipairs(status.missing) do
            local entry = map[reagent.itemID]
            if not entry then
                entry = { itemID = reagent.itemID, name = reagent.name, need = 0 }
                map[reagent.itemID] = entry
            end
            entry.need = entry.need + reagent.need
        end
    end
    return map
end

-- Creates (or replaces) an Auctionator shopping list with one search
-- term per reagent still needed for the player's missing lures.
-- Returns true and the number of items added, or false if Auctionator
-- isn't loaded.
function AuctionHouse:CreateShoppingList()
    if not self:IsAuctionatorLoaded() then
        return false
    end

    local searchStrings = {}
    for _, entry in pairs(self:GetMissingLureReagentMap()) do
        local ok, searchString = pcall(Auctionator.API.v1.ConvertToSearchString, ADDON_NAME, {
            searchString = entry.name,
            isExact = true,
            quantity = entry.need,
        })
        if ok and searchString then
            searchStrings[#searchStrings + 1] = searchString
        end
    end

    local ok = pcall(Auctionator.API.v1.CreateShoppingList, ADDON_NAME, SHOPPING_LIST_NAME, searchStrings)
    if not ok then
        return false
    end
    return true, #searchStrings
end

-- Sum of Auctionator's latest AHDB price for a lure's reagents, or
-- nil if Auctionator isn't loaded or has no price for any one of
-- them - a partial total would be misleading, so we show nothing
-- instead. Purely an "extra" display, never required to use the addon.
function AuctionHouse:GetLurePrice(key)
    if not self:IsAuctionatorLoaded() then
        return nil
    end
    local total = 0
    for _, reagent in ipairs(MSC.BEAST_REAGENTS[key] or {}) do
        local ok, price = pcall(Auctionator.API.v1.GetAuctionPriceByItemID, ADDON_NAME, reagent.itemID)
        if not ok or not price or price <= 0 then
            return nil
        end
        total = total + price * reagent.required
    end
    return total
end
