local ADDON_NAME, MSC = ...

local AuctionHouse = {}
MSC.AuctionHouse = AuctionHouse

-- ============================================================
-- STUB MODULE.
--
-- Fetching missing lure reagents from the auction house is a
-- future task. This file intentionally does nothing yet: no
-- events, no frames, no AH API calls. It exists only so UI.lua has
-- a stable module to point its (disabled) button at.
--
-- When this feature is actually built:
--   1. Implement FetchMissingReagents below, driven by
--      C_AuctionHouse events (results ready, etc.), never polling.
--   2. Flip the "Fetch Materials from AH" button in UI.lua back on
--      and remove its tooltip/disabled state.
--   3. Any listener this adds must only be registered while the AH
--      frame is open, same "zero cost unless enabled" rule as the
--      rest of the addon.
-- ============================================================

function AuctionHouse:IsImplemented()
    return false
end

-- Planned shape, not implemented yet:
-- function AuctionHouse:FetchMissingReagents(missingReagentList) end
