local ADDON_NAME, MSC = ...

local AuctionHouse = {}
MSC.AuctionHouse = AuctionHouse

-- We never touch C_AuctionHouse or any addon's AHDB ourselves beyond
-- reading an already-scanned price cache through its public API -
-- fetching live AH data stays that addon's job.
local SHOPPING_LIST_NAME = "MSC: " .. MSC.L.SKINNING_LURES

-- Single-item price lookup sources, in priority order when more than
-- one is loaded. Each getPrice returns a copper amount or nil (no
-- price known for that item). This mirrors the addon list CraftSim
-- supports for the same purpose.
local PRICE_SOURCES = {
    {
        addonName = "TradeSkillMaster",
        getPrice = function(itemID)
            if not TSM_API then
                return nil
            end
            local ok, price = pcall(TSM_API.GetCustomPriceValue, "dbmarket", "i:" .. itemID)
            if not ok or not price or price <= 0 then
                return nil
            end
            return price
        end,
    },
    {
        addonName = "Auctionator",
        getPrice = function(itemID)
            local ok, price = pcall(Auctionator.API.v1.GetAuctionPriceByItemID, ADDON_NAME, itemID)
            if not ok or not price or price <= 0 then
                return nil
            end
            return price
        end,
    },
    {
        addonName = "RECrystallize",
        getPrice = function(itemID)
            if not RECrystallize_PriceCheckItemID then
                return nil
            end
            local ok, price = pcall(RECrystallize_PriceCheckItemID, itemID)
            if not ok or not price or price <= 0 then
                return nil
            end
            return price
        end,
    },
    {
        addonName = "OribosExchange",
        getPrice = function(itemID)
            if not OEMarketInfo then
                return nil
            end
            local result = {}
            local ok = pcall(OEMarketInfo, itemID, result)
            if not ok then
                return nil
            end
            local price = result.market
            if not price or price <= 0 then
                price = result.region
            end
            if not price or price <= 0 then
                return nil
            end
            return price
        end,
    },
}

function AuctionHouse:IsAuctionatorLoaded()
    return C_AddOns.IsAddOnLoaded("Auctionator") == true
end

-- The first loaded price-source addon in PRICE_SOURCES priority
-- order, or nil if none of them are loaded. Not cached: addons can
-- load after MSC does (e.g. on-demand loaded), so each caller asks
-- fresh rather than risking a stale "none loaded" answer.
function AuctionHouse:GetActivePriceSource()
    for _, source in ipairs(PRICE_SOURCES) do
        if C_AddOns.IsAddOnLoaded(source.addonName) then
            return source
        end
    end
    return nil
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

-- Sum of the active price source's latest price for a lure's
-- reagents, or nil if no supported price-source addon is loaded or
-- one has no price for any one of them - a partial total would be
-- misleading, so we show nothing instead. Purely an "extra" display,
-- never required to use the addon.
function AuctionHouse:GetLurePrice(key)
    local source = self:GetActivePriceSource()
    if not source then
        return nil
    end
    local total = 0
    for _, reagent in ipairs(MSC.BEAST_REAGENTS[key] or {}) do
        local price = source.getPrice(reagent.itemID)
        if not price then
            return nil
        end
        total = total + price * reagent.required
    end
    return total
end
