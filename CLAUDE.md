# MidnightSkinningCompanion

A World of Warcraft: Midnight addon that tracks the beast-skinning
hidden quest line, simplifies crafting the associated skinning
lures, and (later) helps source their reagents. These are working
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
  characters that can get mangled by packaging tools.
- Match the style of the surrounding code, especially for UI widget
  construction.
- Keep modules isolated: a feature module should not reach into
  another feature's internal state, and disabling/removing one
  feature must not break another. Cross-module calls should go
  through each module's public functions only.
- Don't hardcode player-facing strings for anything the client can
  give you localized (zone names, item names, etc.) - fetch them
  through the relevant API instead. Only keep a locale table for
  strings with no such API (e.g. creature names).

## Structure

- `Core.lua` - namespace setup, saved variables, slash command. Load
  first.
- `Constants.lua` - pure data tables. No logic, no side effects.
- `Names.lua` - display-name resolution (zone/item names from client
  APIs, beast names from a small locale table). No other module
  keeps its own copy of a display string.
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
