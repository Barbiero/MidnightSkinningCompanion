local ADDON_NAME, MSC = ...

local Profession = {}
MSC.Profession = Profession

-- ============================================================
-- Gate for every other feature module: this addon only makes
-- sense for a character who has learned Skinning. Detection reads
-- the player's two primary profession slots (GetProfessions /
-- GetProfessionInfo) - the same stable API the profession UI
-- itself is built on - and re-checks on SKILL_LINES_CHANGED, which
-- fires whenever a profession is learned, dropped, or swapped. No
-- polling: the event only fires on an actual skill-line change, and
-- the handler itself is a couple of cheap API calls, not a scan.
-- ============================================================

local listenerFrame
local isSkinner = false
local onChange

local function GetSkillLine(profIndex)
    local ok, results = pcall(function() return { GetProfessionInfo(profIndex) } end)
    if not ok or not results then
        return nil
    end
    return results[7]
end

local function DetectSkinner()
    local prof1, prof2 = GetProfessions()
    for _, profIndex in ipairs({ prof1, prof2 }) do
        if profIndex and GetSkillLine(profIndex) == MSC.SKINNING_SKILL_LINE_ID then
            return true
        end
    end
    return false
end

function Profession:IsSkinner()
    return isSkinner
end

local function Refresh()
    local was = isSkinner
    isSkinner = DetectSkinner()
    if isSkinner ~= was and onChange then
        onChange(isSkinner)
    end
end

-- Called once from Core:OnPlayerLogin(). callback is invoked with
-- the player's current Skinning status immediately, and again any
-- time that status flips for the rest of the session.
function Profession:OnLogin(callback)
    onChange = callback
    isSkinner = DetectSkinner()

    listenerFrame = CreateFrame("Frame")
    listenerFrame:RegisterEvent("SKILL_LINES_CHANGED")
    listenerFrame:SetScript("OnEvent", Refresh)

    if onChange then
        onChange(isSkinner)
    end
end
