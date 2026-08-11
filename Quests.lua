local ADDON_NAME, MSC = ...

local Quests = {}
MSC.Quests = Quests

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

-- Called from MSC:SetFeaturesEnabled() whenever the player is (or
-- becomes) a skinner. Not an opt-in feature in its own right, but
-- gated entirely on MSC.Profession - tracking Renowned Beast kills
-- that require Skinning is pointless for anyone else.
function Quests:Enable()
    if listenerFrame then
        return
    end
    listenerFrame = CreateFrame("Frame")
    listenerFrame:RegisterEvent("CRITERIA_UPDATE")
    listenerFrame:RegisterEvent("QUEST_TURNED_IN")
    listenerFrame:SetScript("OnEvent", OnTrackedEvent)
end

-- Called from MSC:SetFeaturesEnabled() if the player is not (or no
-- longer) a skinner.
function Quests:Disable()
    if not listenerFrame then
        return
    end
    listenerFrame:UnregisterAllEvents()
    listenerFrame:SetScript("OnEvent", nil)
    listenerFrame = nil
end
