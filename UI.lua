local ADDON_NAME, MSC = ...

local UI = {}
MSC.UI = UI

-- Built on first Toggle(). Nothing here exists until the player
-- actually opens the addon.
local frame

local ROW_HEIGHT = 20
local ROW_BUTTON_WIDTH = 70

local function BuildFrame()
    local f = CreateFrame("Frame", "MidnightSkinningCompanionFrame", UIParent, "BackdropTemplate")
    f:SetSize(380, 460)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
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

    -- Hidden quest section -------------------------------------------------
    local questHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    questHeader:SetPoint("TOPLEFT", 20, -44)
    questHeader:SetText("Hidden Quests")

    local trackToggle = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    trackToggle:SetPoint("LEFT", questHeader, "RIGHT", 8, 0)
    local toggleLabel = _G[trackToggle:GetName() .. "Text"]
    if toggleLabel then
        toggleLabel:SetText("Track")
    end
    trackToggle:SetChecked(MSC.db.trackingEnabled)
    trackToggle:SetScript("OnClick", function(btn)
        if btn:GetChecked() then
            MSC.Quests:StartTracking()
        else
            MSC.Quests:StopTracking()
        end
    end)
    f.trackToggle = trackToggle

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

    -- Lure overlay section ---------------------------------------------------
    local overlayHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    overlayHeader:SetPoint("TOPLEFT", craftList, "BOTTOMLEFT", 0, -12)
    overlayHeader:SetText("Lure Overlay")

    local overlayToggle = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    overlayToggle:SetPoint("LEFT", overlayHeader, "RIGHT", 8, 0)
    local overlayToggleLabel = _G[overlayToggle:GetName() .. "Text"]
    if overlayToggleLabel then
        overlayToggleLabel:SetText("Show when near a beast")
    end
    overlayToggle:SetChecked(MSC.db.lureOverlayEnabled)
    overlayToggle:SetScript("OnClick", function(btn)
        if btn:GetChecked() then
            MSC.LureOverlay:Enable()
        else
            MSC.LureOverlay:Disable()
        end
    end)
    f.overlayToggle = overlayToggle

    -- Auction house section (stub, greyed out) -----------------------------
    local ahButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    ahButton:SetSize(200, 24)
    ahButton:SetPoint("BOTTOM", 0, 16)
    ahButton:SetText("Fetch Materials from AH")
    ahButton:SetEnabled(false)
    ahButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Coming soon", 1, 1, 1)
        GameTooltip:AddLine("Auction house material fetching is not implemented yet.", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    ahButton:SetScript("OnLeave", GameTooltip_Hide)
    f.ahButton = ahButton

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
        local color = entry.completed and "|cff33ff33" or "|cffffffff"
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
        local row = AcquireRow(frame.craftRows, frame.craftList, 1)
        row.label:SetText("|cff888888No skinning beasts configured yet.|r")
        HideRowsFrom(frame.craftRows, 2)
        return
    end
    for i, status in ipairs(statuses) do
        local row = AcquireRow(frame.craftRows, frame.craftList, i)
        local name = MSC.Names:GetBeastName(status.key)
        local label
        if status.haveAll then
            label = "|cff33ff33" .. name .. " lure - ready|r"
        else
            label = "|cffff5555" .. name .. " lure - missing " .. #status.missing .. " reagent(s)|r"
        end
        row.label:SetText(label)
        row.button:SetText("Craft")
        row.button:SetScript("OnClick", function()
            MSC.Crafting:OpenRecipe(status.key)
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
