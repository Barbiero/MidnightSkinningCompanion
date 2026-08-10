local ADDON_NAME, MSC = ...

local UI = {}
MSC.UI = UI

-- Built on first Toggle(). Nothing here exists until the player
-- actually opens the addon.
local frame

local ROW_HEIGHT = 20
local ROW_BUTTON_WIDTH = 70

local CRAFT_ROW_HEIGHT = 24
local CRAFT_ICON_SIZE = 20
local REAGENT_ICON_SIZE = 16
-- Headroom over the current max of 2 reagents/beast (Constants.lua).
local MAX_REAGENT_ICONS = 4

local function BuildFrame()
    local f = CreateFrame("Frame", "MidnightSkinningCompanionFrame", UIParent, "BackdropTemplate")
    f:SetSize(420, 460)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    -- Registering the frame's global name here makes Escape close it,
    -- same as the X button, without us handling the key ourselves.
    tinsert(UISpecialFrames, "MidnightSkinningCompanionFrame")
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Midnight Skinning Companion")
    f.title = title

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)

    local optionsButton = CreateFrame("Button", nil, f)
    optionsButton:SetSize(20, 20)
    optionsButton:SetPoint("RIGHT", close, "LEFT", -2, 0)
    optionsButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    optionsButton:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
    optionsButton:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
    optionsButton:SetScript("OnClick", function()
        MSC.Options:Open()
    end)
    optionsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Options")
        GameTooltip:Show()
    end)
    optionsButton:SetScript("OnLeave", GameTooltip_Hide)

    -- Hidden quest section -------------------------------------------------
    local questHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    questHeader:SetPoint("TOPLEFT", 20, -44)
    questHeader:SetText("Available Beasts")

    local questList = CreateFrame("Frame", nil, f)
    questList:SetPoint("TOPLEFT", 20, -66)
    questList:SetPoint("RIGHT", -20, 0)
    questList:SetHeight(160)
    f.questList = questList
    f.questRows = {}

    -- Lure crafting section -------------------------------------------------
    local craftHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    craftHeader:SetPoint("TOPLEFT", questList, "BOTTOMLEFT", 0, -12)
    craftHeader:SetText("Skinning Lures")
    f.craftHeader = craftHeader

    local craftList = CreateFrame("Frame", nil, f)
    craftList:SetPoint("TOPLEFT", craftHeader, "BOTTOMLEFT", 0, -6)
    craftList:SetPoint("RIGHT", -20, 0)
    craftList:SetHeight(160)
    f.craftList = craftList
    f.craftRows = {}

    -- Auctionator integration: only ever shown if Auctionator itself
    -- is loaded, since MSC never fetches AH data on its own.
    if MSC.AuctionHouse:IsAuctionatorLoaded() then
        local ahButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        ahButton:SetSize(200, 24)
        ahButton:SetPoint("TOPLEFT", craftList, "BOTTOMLEFT", 0, -20)
        ahButton:SetText("Auctionator Shopping List")
        ahButton:SetScript("OnClick", function()
            local ok, count = MSC.AuctionHouse:CreateShoppingList()
            if not ok then
                MSC:Print("Could not create Auctionator shopping list.")
            elseif count == 0 then
                MSC:Print("No missing lures - nothing to shop for.")
            else
                MSC:Print("Auctionator shopping list created with " .. count .. " reagent(s).")
            end
        end)
        ahButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Auctionator Shopping List", 1, 1, 1)
            GameTooltip:AddLine("Creates an Auctionator shopping list for the reagents of every lure you don't have yet.", nil, nil, nil, true)
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
        row.label:SetPoint("RIGHT", row, "RIGHT", -(ROW_BUTTON_WIDTH + 6), 0)
        row.label:SetJustifyH("LEFT")
        row.button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.button:SetSize(ROW_BUTTON_WIDTH, ROW_HEIGHT - 2)
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
    icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -1)
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
        row.name:SetPoint("LEFT", row.lureIcon, "RIGHT", 4, 0)
        row.name:SetWidth(62)
        row.name:SetWordWrap(false)
        row.name:SetJustifyH("LEFT")

        row.reagentIcons = {}
        for i = 1, MAX_REAGENT_ICONS do
            local reagentIcon = CreateIconWithCount(row, REAGENT_ICON_SIZE)
            if i == 1 then
                reagentIcon:SetPoint("LEFT", row.name, "RIGHT", 4, 0)
            else
                reagentIcon:SetPoint("LEFT", row.reagentIcons[i - 1], "RIGHT", 16, 0)
            end
            row.reagentIcons[i] = reagentIcon
        end

        row.button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.button:SetSize(ROW_BUTTON_WIDTH, CRAFT_ROW_HEIGHT - 2)
        row.button:SetPoint("RIGHT", row, "RIGHT", 0, 0)

        row.price = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        row.price:SetPoint("LEFT", row.reagentIcons[MAX_REAGENT_ICONS], "RIGHT", 6, 0)
        row.price:SetPoint("RIGHT", row.button, "LEFT", -4, 0)
        row.price:SetJustifyH("LEFT")
        row.price:SetWordWrap(false)

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
        row.label:SetText("|cff888888No hidden quests configured yet.|r")
        HideRowsFrom(frame.questRows, 2)
        return
    end
    for i, entry in ipairs(progress) do
        local row = AcquireRow(frame.questRows, frame.questList, i)
        local color = entry.completed and "|cffff5555" or "|cff33ff33"
        local name = MSC.Names:GetBeastName(entry.key)
        local zone = MSC.Names:GetZoneName(MSC.BEAST_LOCATION[entry.key].mapID) or "?"
        row.label:SetText(color .. name .. " (" .. zone .. ")|r")
        row.button:SetText("Waypoint")
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
        row.name:SetText("|cff888888No skinning beasts configured yet.|r")
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

        row.button:SetText("Craft")
        -- Greyed out exactly when the profession window's own Create
        -- button would be: missing reagents.
        row.button:SetEnabled(status.haveAll)
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

function UI:IsShown()
    return frame ~= nil and frame:IsShown()
end
