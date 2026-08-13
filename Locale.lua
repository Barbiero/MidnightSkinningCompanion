local ADDON_NAME, MSC = ...

-- Minimal string localization. MSC.L falls back client-locale ->
-- enUS -> the key itself, so a missing translation degrades to
-- English instead of erroring.
--
-- Register() only invokes the builder for the client's own locale
-- (plus enUS, the fallback) - the other ~10 locale files' tables are
-- never built, even though the .toc loads and parses every file.

local Locale = {}
MSC.Locale = Locale

local registry = {}

function Locale:ShouldLoad(localeCode)
    return localeCode == GetLocale() or localeCode == "enUS"
end

function Locale:Register(localeCode, buildStrings)
    registry[localeCode] = buildStrings()
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
