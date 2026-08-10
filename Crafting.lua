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
    local lure = MSC.BEAST_LURE[key]
    local status = {
        key = key,
        missing = {},
        haveAll = true,
        lureItemID = lure and lure.itemID,
        lureCount = lure and GetOwnedCount(lure.itemID) or 0,
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

-- Crafts a lure directly, as if the player had clicked Create in the
-- profession window themselves. Only ever called from the Craft
-- button's own OnClick (a real hardware event, which CraftRecipe
-- requires) and only when every reagent is already present - this is
-- one player-initiated craft, not queuing or auto-confirming crafts
-- unattended. See CLAUDE.md's taint-risk exception for CraftLure.
--
-- CraftRecipe (and most of C_TradeSkillUI) only works once a trade
-- skill session is active, and the only documented way to establish
-- one is opening the profession UI - crafting has no secure
-- attribute like item use's "item" type (see LureOverlay), so there
-- is no headless equivalent. If the window is already open to
-- Skinning, we craft in place and leave it exactly as the player left
-- it. Otherwise we open it, craft, and immediately hide it again
-- within this same click handler, before the game renders a frame,
-- so the window should never actually be seen on screen. If a
-- different profession is open, switching it out from under the
-- player would be disruptive and can't happen synchronously anyway
-- (CraftRecipe requires the same hardware event that opened it), so
-- we ask them to close it instead of silently doing nothing.
function Crafting:CraftLure(key)
    local lure = MSC.BEAST_LURE[key]
    if not lure then
        return
    end
    if not self:GetReagentStatus(key).haveAll then
        return
    end
    if not (C_TradeSkillUI and C_TradeSkillUI.OpenRecipe and C_TradeSkillUI.CraftRecipe) then
        MSC:Print("Profession UI API not available on this client.")
        return
    end

    local wasShown = ProfessionsFrame and ProfessionsFrame:IsShown()
    if wasShown and C_TradeSkillUI.GetTradeSkillLine then
        local okLine, skillLineID = pcall(C_TradeSkillUI.GetTradeSkillLine)
        if okLine and skillLineID and skillLineID ~= MSC.SKINNING_SKILL_LINE_ID then
            MSC:Print("Close the open profession window before crafting a lure.")
            return
        end
    end

    local okOpen, errOpen = pcall(C_TradeSkillUI.OpenRecipe, lure.craftSpellID)
    if not okOpen then
        MSC:Print("Could not open recipe: " .. tostring(errOpen))
        return
    end

    -- Belt-and-suspenders on top of our own reagent count above:
    -- GetRecipeInfo's "craftable" field also accounts for tools and
    -- skill requirements we don't track ourselves.
    local okInfo, recipeInfo = pcall(C_TradeSkillUI.GetRecipeInfo, lure.craftSpellID)
    if okInfo and recipeInfo and recipeInfo.craftable == false then
        MSC:Print("Cannot craft this lure right now" ..
            (recipeInfo.disabledReason and (": " .. recipeInfo.disabledReason) or "."))
        if ProfessionsFrame and not wasShown then
            ProfessionsFrame:Hide()
        end
        return
    end

    local okCraft, errCraft = pcall(C_TradeSkillUI.CraftRecipe, lure.craftSpellID, 1)
    if not okCraft then
        MSC:Print("Could not craft: " .. tostring(errCraft))
    end

    if ProfessionsFrame and not wasShown then
        ProfessionsFrame:Hide()
    end
end
