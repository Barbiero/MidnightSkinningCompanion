local ADDON_NAME, MSC = ...

-- ============================================================
-- Minimal string localization.
--
-- Locales/<code>.lua each call MSC.Locale:Register(code, { KEY =
-- "..." }); this file only owns the registry and the public MSC.L
-- table. Lookup falls back from the client's locale to enUS to the
-- key itself, so a locale file that's missing a key (or hasn't been
-- written yet) degrades to English instead of a blank string or a
-- Lua error. No separate "apply" step is needed - MSC.L resolves
-- lazily on each access, so load order between Locale.lua's
-- registration and any locale file's Register() call only has to
-- happen before the string is actually displayed, not before the
-- files are parsed.
-- ============================================================

local Locale = {}
MSC.Locale = Locale

local registry = {}

function Locale:Register(localeCode, strings)
    registry[localeCode] = strings
end

MSC.L = setmetatable({}, {
    __index = function(_, key)
        local strings = registry[GetLocale()]
        local value = strings and strings[key]
        if value == nil then
            local enUS = registry.enUS
            value = enUS and enUS[key]
        end
        return value or key
    end,
})
