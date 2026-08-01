# AstraUI

AstraUI is a standalone, dependency-free Roblox UI library for polished LocalScript and ModuleScript interfaces. It provides draggable/resizable windows, tabs, sections, search, notifications, widgets, and JSON config helpers in one source file.

This library is designed for interfaces you own or are authorized to run. The included RBA example is UI-only: it creates a local ScreenGui and does not call remotes or automate gameplay.

## Features

- Rounded, dark interface with themed accents and notifications
- Bounded dragging and resize grip, so the window stays usable on screen
- Optional clean header/window glow controlled by `window:SetVisualEffects(boolean)`
- Divider, progress, stepper, multi-select, and color-palette widgets for richer control panels
- Tabs, section cards, built-in control search, and a Right Control visibility hotkey
- Button, toggle, slider, dropdown, textbox, keybind, label, paragraph, and stat widgets
- Safe callback isolation: a broken callback is warned instead of breaking the UI
- ModuleScript-friendly source plus local RBA demo and raw-source loader option

## Roblox Studio

1. Put `src/AstraUI.lua` into `ReplicatedStorage` as a ModuleScript called `AstraUI`.
2. Copy `examples/studio-demo.client.lua` into a LocalScript in `StarterPlayerScripts`.
3. Play-test. Press **Right Control** to hide or restore the window.

```lua
local AstraUI = require(game.ReplicatedStorage.AstraUI)

local window = AstraUI:CreateWindow({
	Title = "My tools",
	Subtitle = "A clear local interface",
	ToggleKeybind = Enum.KeyCode.RightControl,
})

local tab = window:CreateTab({ Title = "Main", Icon = "◆" })
local section = tab:CreateSection({ Title = "Settings" })
section:AddToggle({ Title = "Enabled", Callback = function(value) print(value) end })
```

## RBA / raw loader

For an authorized local-script workflow, you can load the published source directly:

```lua
local AstraUI = assert(loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/evonar543/astra-ui/30077f7/src/AstraUI.lua"
)))()
```

Or run `examples/rba-demo.lua`; it loads the GitHub raw source by default. If your executor has an allowed local script directory, set `getgenv().ASTRA_UI_LOCAL_PATH` to that file before running the demo.

## API

See [docs/API.md](docs/API.md). `Window:Destroy()` disconnects all window-level listeners and removes the UI.

## License

MIT. See [LICENSE](LICENSE).
