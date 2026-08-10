local ADDON_NAME, MSC = ...

local Crafting = {}
MSC.Crafting = Crafting

-- Bag + bank count for a reagent. Wrapped in pcall: a bad itemID in
-- Constants.lua must never surface as a Lua error to the player.
local function GetOwnedCount(itemID)
    if not itemID then
        return 0
    end
    local ok, count = pcall(C_Item.GetItemCount, itemID, false, false, true)
    if not ok then
        return 0
    end
    return count or 0
end

function Crafting:GetReagentStatus(key)
    local status = {
        key = key,
        missing = {},
        haveAll = true,
    }
    for _, reagent in ipairs(MSC.BEAST_REAGENTS[key] or {}) do
        local have = GetOwnedCount(reagent.itemID)
        if have < reagent.required then
            status.haveAll = false
            status.missing[#status.missing + 1] = {
                itemID = reagent.itemID,
                name = MSC.Names:GetItemName(reagent.itemID) or ("Item #" .. reagent.itemID),
                need = reagent.required - have,
            }
        end
    end
    return status
end

function Crafting:GetAllReagentStatus()
    local out = {}
    for _, key in ipairs(MSC.BEASTS) do
        out[#out + 1] = self:GetReagentStatus(key)
    end
    return out
end

-- Opens the profession window on the given recipe so the player
-- crafts it themselves. The addon never crafts on the player's
-- behalf: calling craft-triggering API from addon code is exactly
-- the kind of thing that risks taint and "action blocked" errors,
-- and it takes away a choice (exact reagent, quality, etc.) that
-- should stay with the player.
function Crafting:OpenRecipe(key)
    local lure = MSC.BEAST_LURE[key]
    if not lure then
        return
    end
    if not (C_TradeSkillUI and C_TradeSkillUI.OpenRecipe) then
        MSC:Print("Profession UI API not available on this client.")
        return
    end
    local ok, err = pcall(C_TradeSkillUI.OpenRecipe, lure.craftSpellID)
    if not ok then
        MSC:Print("Could not open recipe: " .. tostring(err))
    end
end
