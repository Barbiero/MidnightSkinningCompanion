# MidnightSkinningCompanion

A World of Warcraft: Midnight addon that tracks Renowned Beast
skinning kills, simplifies crafting the associated skinning lures,
and (later) helps source their reagents. These are working
guidelines for anyone (human or Claude) contributing to this addon,
adapted from EllesmereUI's CONTRIBUTING.md and trimmed to what's
generally applicable rather than EllesmereUI-specific.

## Acceptance criteria for any change

1. **Zero cost when disabled.** A feature nobody turned on must not
   register events, create frames, run timers, or allocate anything
   per frame. Build UI and listeners lazily, on first use / opt-in,
   not at load time.
2. **No default behavior changes.** New settings default to OFF.
   Only a genuine bug fix may change behavior without the player
   opting in.
3. **Low cost when enabled.** Prefer event-driven code over polling.
   Avoid wall-clock timers and table allocation in hot paths
   (`OnUpdate`, frequently-fired events).
4. **Zero taint risk.** Never call into protected/combat-sensitive
   APIs from addon code, and never touch protected Blizzard frames.
   Wrap calls whose behavior depends on data we don't fully control
   (item/spell/quest IDs) in `pcall` so a bad entry degrades
   gracefully instead of throwing.
   Exception: `Crafting:CraftLure` may call `C_TradeSkillUI.CraftRecipe`
   directly, but only synchronously from the Craft button's own
   OnClick (a real hardware event, which `CraftRecipe` requires
   anyway) and only when `GetReagentStatus` already reports every
   reagent present. This is a single, player-initiated craft - not
   queuing, batching, or auto-confirming crafts unattended.
5. **Works across the client versions we target.** Branch on client
   version only where APIs actually differ; keep one code path
   otherwise. Once a version-specific branch exists, don't "fix up"
   the old branch - treat it as frozen.

## Code style

- Lua 5.1 syntax only - no `goto` or labeled blocks.
- ASCII only in source files - no em dashes, curly quotes, or other
  characters that can get mangled by packaging tools. Exception:
  `Locales/*.lua` and the `## Notes-<locale>:` lines in the .toc,
  where the whole point is genuine non-English text (accents,
  Cyrillic, Hangul, Han characters) - those files are UTF-8 by
  necessity. The rule still applies to every other file, including
  the English strings in `Locales/enUS.lua`.
- Match the style of the surrounding code, especially for UI widget
  construction.
- Keep modules isolated: a feature module should not reach into
  another feature's internal state, and disabling/removing one
  feature must not break another. Cross-module calls should go
  through each module's public functions only.
- Don't hardcode player-facing strings for anything the client can
  give you localized (zone names, item names, etc.) - fetch them
  through the relevant API instead. Everything else player-facing
  (UI labels, tooltips, chat messages, and beast names, which have no
  client API) goes through `MSC.L` (see `Locale.lua`), keyed by a
  short UPPER_SNAKE_CASE name; add the key to every file in
  `Locales/`, not just `enUS.lua` - a missing key falls back to
  English rather than erroring, but a translation that never gets
  added stays English forever by accident. `MSC.L` values don't have
  to be strings - `BEAST_NAMES` is a nested table of beast key ->
  name for exactly this reason.
- Error strings for conditions that should never occur on a supported
  client (an API missing entirely, e.g. `MSG_PROFESSION_API_UNAVAILABLE`-
  style messages) stay plain hardcoded English in the module that
  raises them, not in `MSC.L` - translating text nobody is expected to
  ever see just adds upkeep for no player benefit.

## Structure

- `Core.lua` - namespace setup, saved variables, slash command. Load
  first.
- `Constants.lua` - pure data tables. No logic, no side effects.
- `Locale.lua` - owns the `MSC.L` string table and its registration
  function; loads before `Locales/*.lua` and before every module that
  reads a player-facing string. `MSC.L` falls back client-locale ->
  enUS -> the key itself, so a missing translation degrades to
  English instead of erroring.
- `Locales/*.lua` - one file per supported client locale (enUS,
  deDE, esES, esMX, frFR, itIT, ptBR, ruRU, koKR, zhCN, zhTW), each
  calling `MSC.Locale:Register(localeCode, { KEY = "..." })`, including
  a `BEAST_NAMES` sub-table. Add new keys to every file, not just
  `enUS.lua`.
- `Names.lua` - display-name resolution (zone/item names from client
  APIs, beast names from `MSC.L.BEAST_NAMES`). No other module keeps
  its own copy of a display string.
- `Profession.lua` - detects whether the player has learned Skinning.
  `Core.lua` subscribes to changes and drives every feature module's
  Enable/Disable from them; a module may also call
  `MSC.Profession:IsSkinner()` directly for a one-off, user-initiated
  check (e.g. before opening the UI), but must never register its
  own listener for it - that stays centralized in `Profession.lua`.
- Feature modules (`Quests.lua`, `Crafting.lua`, `Waypoint.lua`,
  `LureOverlay.lua`, `AuctionHouse.lua`, ...) - one concern each,
  each exposing a small public API on its own table (`MSC.<Module>`).
- `Options.lua` - all player-facing configuration, registered through
  the Settings API (`Settings.RegisterAddOnCategory`), not a custom
  frame. Toggling a feature on/off always goes through this panel.
- `UI.lua` - the only module allowed to build visible frames tied to
  more than one feature module; it reads from and calls into feature
  modules but never contains feature logic itself. It shows data, it
  doesn't configure anything - that's Options.lua's job.
