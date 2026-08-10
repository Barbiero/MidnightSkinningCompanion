local ADDON_NAME, MSC = ...

local Waypoint = {}
MSC.Waypoint = Waypoint

-- Sets/clears the player's world map waypoint (the native pin, not
-- a third-party routing addon) for a beast's location.

function Waypoint:Set(key)
    local loc = MSC.BEAST_LOCATION[key]
    if not loc then
        return
    end
    if not (C_Map and C_Map.SetUserWaypoint) then
        -- Should never happen on a supported client - not localized.
        MSC:Print("Waypoint API not available on this client.")
        return
    end
    local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x / 100, loc.y / 100)
    C_Map.SetUserWaypoint(point)
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
end

function Waypoint:Clear()
    if C_Map and C_Map.ClearUserWaypoint then
        C_Map.ClearUserWaypoint()
    end
end
