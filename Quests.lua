local ADDON_NAME, MSC = ...

local Quests = {}
MSC.Quests = Quests

-- Only created once the player opts in via StartTracking(). This
-- keeps CRITERIA_UPDATE / QUEST_TURNED_IN off the event queue for
-- everyone who never uses the feature.
local listenerFrame

local function IsQuestDone(questID)
    return questID ~= nil and C_QuestLog.IsQuestFlaggedCompleted(questID) == true
end

function Quests:GetProgress()
    local out = {}
    for _, key in ipairs(MSC.BEASTS) do
        out[#out + 1] = {
            key = key,
            completed = IsQuestDone(MSC.BEAST_QUEST[key]),
        }
    end
    return out
end

local function OnTrackedEvent()
    -- Cheap: this only re-reads a handful of quest flags, and only
    -- if the window is actually open to see them.
    if MSC.UI and MSC.UI:IsShown() then
        MSC.UI:RefreshQuestTab()
    end
end

-- Called from Core:OnPlayerLogin(). Restores the player's own prior
-- choice; does not turn tracking on for someone who never asked for it.
function Quests:OnLogin()
    if MSC.db.trackingEnabled then
        self:StartTracking()
    end
end

function Quests:StartTracking()
    if listenerFrame then
        return
    end
    listenerFrame = CreateFrame("Frame")
    listenerFrame:RegisterEvent("CRITERIA_UPDATE")
    listenerFrame:RegisterEvent("QUEST_TURNED_IN")
    listenerFrame:SetScript("OnEvent", OnTrackedEvent)
    MSC.db.trackingEnabled = true
end

function Quests:StopTracking()
    if listenerFrame then
        listenerFrame:UnregisterAllEvents()
        listenerFrame:SetScript("OnEvent", nil)
        listenerFrame = nil
    end
    MSC.db.trackingEnabled = false
end

function Quests:IsTracking()
    return listenerFrame ~= nil
end
