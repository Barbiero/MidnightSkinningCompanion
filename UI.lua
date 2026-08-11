local ADDON_NAME, MSC = ...

local UI = {}
MSC.UI = UI

-- Built on first Toggle(). Nothing here exists until the player
-- actually opens the addon.
local frame

local ROW_HEIGHT = 25
local ROW_BUTTON_WIDTH = 87.5

local CRAFT_ROW_HEIGHT = 30
local CRAFT_ICON_SIZE = 25
local REAGENT_ICON_SIZE = 20
-- Headroom over the current max of 2 reagents/beast (Constants.lua).
local MAX_REAGENT_ICONS = 4

local FONT_SCALE = 1.25

local function GrowFont(fontString)
    local file, size, flags = fontString:GetFont()
    if file then
        fontString:SetFont(file, size * FONT_SCALE, flags)
    end
end

local function BuildFrame()
    local f = CreateFrame("Frame", "MidnightSkinningCompanionFrame", UIParent, "BackdropTemplate")
    f:SetSize(525, 575)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetScale(MSC.db.uiScale or 1.0)
    f:SetMovable(true)
    f:EnableMouse(true)
    tinsert(UISpecialFrames, f:GetName())
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 40, edgeSize = 40,
        insets = { left = 13.75, right = 15, top = 15, bottom = 13.75 },
    })

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText(C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title") or ADDON_NAME)
    GrowFont(title)
    f.title = title

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() f:Hide() end)

    local optionsButton = CreateFrame("Button", nil, f)
    optionsButton:SetSize(25, 25)
    optionsButton:SetPoint("RIGHT", close, "LEFT", -2.5, 0)
    optionsButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    optionsButton:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
    optionsButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
    optionsButton:SetScript("OnClick", function()
        MSC.Options:Open()
    end)
    optionsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(MSC.L.OPTIONS_TOOLTIP)
        GameTooltip:Show()
    end)
    optionsButton:SetScript("OnLeave", GameTooltip_Hide)

    -- Hidden quest section -------------------------------------------------
    local questHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    questHeader:SetPoint("TOPLEFT", 25, -55)
    questHeader:SetText(MSC.L.AVAILABLE_BEASTS)
    GrowFont(questHeader)

    local questList = CreateFrame("Frame", nil, f)
    questList:SetPoint("TOPLEFT", 25, -82.5)
    questList:SetPoint("RIGHT", -25, 0)
    questList:SetHeight(200)
    f.questList = questList
    f.questRows = {}

    -- Lure crafting section -------------------------------------------------
    local craftHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    craftHeader:SetPoint("TOPLEFT", questList, "BOTTOMLEFT", 0, -15)
    craftHeader:SetText(MSC.L.SKINNING_LURES)
    GrowFont(craftHeader)
    f.craftHeader = craftHeader

    local craftList = CreateFrame("Frame", nil, f)
    craftList:SetPoint("TOPLEFT", craftHeader, "BOTTOMLEFT", 0, -7.5)
    craftList:SetPoint("RIGHT", -25, 0)
    craftList:SetHeight(200)
    f.craftList = craftList
    f.craftRows = {}

    -- Auctionator integration: only ever shown if Auctionator itself
    -- is loaded, since MSC never fetches AH data on its own.
    if MSC.AuctionHouse:IsAuctionatorLoaded() then
        local ahButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        ahButton:SetSize(250, 30)
        ahButton:SetPoint("TOPLEFT", craftList, "BOTTOMLEFT", 0, -25)
        ahButton:SetText(MSC.L.AUCTIONATOR_BUTTON)
        ahButton:SetScript("OnClick", function()
            local ok, count = MSC.AuctionHouse:CreateShoppingList()
            if not ok then
                MSC:Print(MSC.L.MSG_AH_LIST_FAILED)
            elseif count == 0 then
                MSC:Print(MSC.L.MSG_AH_LIST_EMPTY)
            else
                MSC:Print(string.format(MSC.L.MSG_AH_LIST_CREATED, count))
            end
        end)
        ahButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(MSC.L.AUCTIONATOR_BUTTON, 1, 1, 1)
            GameTooltip:AddLine(MSC.L.AUCTIONATOR_TOOLTIP, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        ahButton:SetScript("OnLeave", GameTooltip_Hide)
        f.ahButton = ahButton
    end

    -- Reagent/lure status depends on bag contents, which can change
    -- from mail, fishing, trades, vendors, etc. - not just crafting.
    -- BAG_UPDATE_DELAYED coalesces all of that into one event per
    -- batch of changes, so this stays event-driven rather than
    -- polling. Registered only while the window is shown, so a
    -- closed window costs nothing.
    f:SetScript("OnEvent", function(_, event)
        if event == "BAG_UPDATE_DELAYED" then
            UI:RefreshCraftTab()
        end
    end)
    f:SetScript("OnShow", function(self)
        self:RegisterEvent("BAG_UPDATE_DELAYED")
    end)
    f:SetScript("OnHide", function(self)
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
    end)

    f:Hide()
    return f
end

-- Row pool helper shared by the quest and craft lists: each row is
-- a label plus an optional action button on the right.
local function AcquireRow(pool, parent, index)
    local row = pool[index]
    if not row then
        row = CreateFrame("Frame", nil, parent)
        row:SetHeight(ROW_HEIGHT)
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.label:SetPoint("LEFT", 0, 0)
        row.label:SetPoint("RIGHT", row, "RIGHT", -(ROW_BUTTON_WIDTH + 7.5), 0)
        row.label:SetJustifyH("LEFT")
        GrowFont(row.label)
        row.button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.button:SetSize(ROW_BUTTON_WIDTH, ROW_HEIGHT - 2.5)
        row.button:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        pool[index] = row
    end
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    row.button:Hide()
    row:Show()
    return row
end

local function HideRowsFrom(pool, fromIndex)
    for i = fromIndex, #pool do
        pool[i]:Hide()
    end
end

-- A single "bag slot" style widget: item icon with a count badge in
-- the corner, and an item tooltip on hover. Used for both the lure
-- itself and its reagents so "do we have it" and "how many" collapse
-- into one glance instead of separate text.
local function CreateIconWithCount(parent, size)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetSize(size, size)
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon.count = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2.5, -1.25)
    GrowFont(icon.count)
    icon:EnableMouse(true)
    icon:SetScript("OnEnter", function(self)
        if not self.itemID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemID)
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", GameTooltip_Hide)
    return icon
end

-- Craft rows need more than a label + button: a lure icon/count,
-- reagent icons/counts, and an optional price, all on one line.
local function AcquireCraftRow(pool, parent, index)
    local row = pool[index]
    if not row then
        row = CreateFrame("Frame", nil, parent)
        row:SetHeight(CRAFT_ROW_HEIGHT)

        row.lureIcon = CreateIconWithCount(row, CRAFT_ICON_SIZE)
        row.lureIcon:SetPoint("LEFT", row, "LEFT", 0, 0)

        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", row.lureIcon, "RIGHT", 5, 0)
        row.name:SetWidth(77.5)
        row.name:SetWordWrap(false)
        row.name:SetJustifyH("LEFT")
        GrowFont(row.name)

        row.reagentIcons = {}
        for i = 1, MAX_REAGENT_ICONS do
            local reagentIcon = CreateIconWithCount(row, REAGENT_ICON_SIZE)
            if i == 1 then
                reagentIcon:SetPoint("LEFT", row.name, "RIGHT", 5, 0)
            else
                reagentIcon:SetPoint("LEFT", row.reagentIcons[i - 1], "RIGHT", 20, 0)
            end
            row.reagentIcons[i] = reagentIcon
        end

        row.button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.button:SetSize(ROW_BUTTON_WIDTH, CRAFT_ROW_HEIGHT - 2.5)
        row.button:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.button:SetMotionScriptsWhileDisabled(true)
        row.button:SetScript("OnEnter", function(self)
            if not self.disabledTooltip then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.disabledTooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        row.button:SetScript("OnLeave", GameTooltip_Hide)

        row.price = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        row.price:SetPoint("LEFT", row.reagentIcons[MAX_REAGENT_ICONS], "RIGHT", 7.5, 0)
        row.price:SetPoint("RIGHT", row.button, "LEFT", -5, 0)
        row.price:SetJustifyH("LEFT")
        row.price:SetWordWrap(false)
        GrowFont(row.price)

        pool[index] = row
    end
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * CRAFT_ROW_HEIGHT)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    row.lureIcon:Hide()
    for _, reagentIcon in ipairs(row.reagentIcons) do
        reagentIcon:Hide()
    end
    row.name:SetText("")
    row.price:SetText("")
    row.button:Hide()
    row.button.disabledTooltip = nil
    row:Show()
    return row
end

function UI:RefreshQuestTab()
    if not frame then
        return
    end
    local progress = MSC.Quests:GetProgress()
    if #progress == 0 then
        local row = AcquireRow(frame.questRows, frame.questList, 1)
        row.label:SetText("|cff888888" .. MSC.L.NO_QUESTS_CONFIGURED .. "|r")
        HideRowsFrom(frame.questRows, 2)
        return
    end
    for i, entry in ipairs(progress) do
        local row = AcquireRow(frame.questRows, frame.questList, i)
        local color = entry.completed and "|cffff5555" or "|cff33ff33"
        local name = MSC.Names:GetBeastName(entry.key)
        local zone = MSC.Names:GetZoneName(MSC.BEAST_LOCATION[entry.key].mapID) or "?"
        row.label:SetText(color .. name .. " (" .. zone .. ")|r")
        row.button:SetText(MSC.L.WAYPOINT_BUTTON)
        row.button:SetScript("OnClick", function()
            MSC.Waypoint:Set(entry.key)
        end)
        row.button:Show()
    end
    HideRowsFrom(frame.questRows, #progress + 1)
end

function UI:RefreshCraftTab()
    if not frame then
        return
    end
    local statuses = MSC.Crafting:GetAllReagentStatus()
    if #statuses == 0 then
        local row = AcquireCraftRow(frame.craftRows, frame.craftList, 1)
        row.name:SetWidth(0)
        row.name:SetText("|cff888888" .. MSC.L.NO_BEASTS_CONFIGURED .. "|r")
        HideRowsFrom(frame.craftRows, 2)
        return
    end
    for i, status in ipairs(statuses) do
        local row = AcquireCraftRow(frame.craftRows, frame.craftList, i)
        local name = MSC.Names:GetBeastName(status.key)

        -- Lure icon + owned count: "do we have it" and "how many"
        -- collapsed into one glance.
        if status.lureItemID then
            row.lureIcon.itemID = status.lureItemID
            row.lureIcon.texture:SetTexture(C_Item.GetItemIconByID(status.lureItemID))
            row.lureIcon.count:SetText(tostring(status.lureCount))
            if status.lureCount > 0 then
                row.lureIcon.count:SetTextColor(0.4, 1, 0.4)
            else
                row.lureIcon.count:SetTextColor(1, 0.3, 0.3)
            end
            row.lureIcon:Show()
        end

        row.name:SetText(status.haveAll and ("|cff33ff33" .. name .. "|r") or ("|cffff5555" .. name .. "|r"))

        -- Missing reagents as icon + shortfall count, freed up by the
        -- lure icon no longer needing a "missing N reagent(s)" sentence.
        for idx, reagentIcon in ipairs(row.reagentIcons) do
            local missing = status.missing[idx]
            if missing then
                reagentIcon.itemID = missing.itemID
                reagentIcon.texture:SetTexture(C_Item.GetItemIconByID(missing.itemID))
                reagentIcon.count:SetText(tostring(missing.need))
                reagentIcon.count:SetTextColor(1, 0.3, 0.3)
                reagentIcon:Show()
            end
        end

        -- Extra-only: Auctionator's AHDB price for the reagents, when
        -- Auctionator is loaded and has data for all of them.
        local price = MSC.AuctionHouse:GetLurePrice(status.key)
        row.price:SetText(price and GetCoinTextureString(price) or "")

        row.button:SetText(MSC.L.CRAFT_BUTTON)
        -- Greyed out exactly when the profession window's own Create
        -- button would be: missing reagents or recipe not learned yet.
        row.button:SetEnabled(status.canCraft)
        if status.canCraft then
            row.button.disabledTooltip = nil
        elseif status.recipeKnown == false then
            row.button.disabledTooltip = MSC.L.CRAFT_TOOLTIP_RECIPE_NOT_LEARNED
        else
            row.button.disabledTooltip = MSC.L.CRAFT_TOOLTIP_MISSING_MATERIALS
        end
        row.button:SetScript("OnClick", function()
            MSC.Crafting:CraftLure(status.key)
        end)
        row.button:Show()
    end
    HideRowsFrom(frame.craftRows, #statuses + 1)
end

function UI:Refresh()
    self:RefreshQuestTab()
    self:RefreshCraftTab()
end

function UI:Toggle()
    if not MSC.Profession:IsSkinner() then
        MSC:Print(MSC.L.MSG_REQUIRES_SKINNING)
        self:Close()
        return
    end
    if not frame then
        frame = BuildFrame()
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        self:Refresh()
    end
end

-- Called from MSC:SetFeaturesEnabled() if the player is not (or no
-- longer) a skinner, so the window doesn't linger open showing dead
-- data (e.g. after a profession swap mid-session).
function UI:Close()
    if frame and frame:IsShown() then
        frame:Hide()
    end
end

function UI:IsShown()
    return frame ~= nil and frame:IsShown()
end

function UI:ApplyScale()
    if frame then
        frame:SetScale(MSC.db.uiScale or 1.0)
    end
end

