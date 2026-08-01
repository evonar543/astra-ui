# AstraUI API

```lua
local AstraUI = require(game.ReplicatedStorage.AstraUI)
local window = AstraUI:CreateWindow(options)
```

## Window

`CreateWindow` accepts `Title`, `Subtitle`, `Mark`, `Size`, `Position`, `Theme`, `Parent`, `ToggleKeybind`, `MinSize`, and `MaxSize`.

- `window:CreateTab({ Title, Icon })`
- `window:SelectTab(tab)`
- `window:Notify({ Title, Content, Color, Duration })`
- `window:SetVisible(boolean)` / `window:ToggleVisible()`
- `window:SetVisualEffects(boolean)` controls the animated header accent rail
- `window:SetToggleKey(Enum.KeyCode)`
- `window:Destroy()`

## Tabs and sections

```lua
local section = window:CreateTab({ Title = "Main" }):CreateSection({
	Title = "Settings",
	Description = "Optional supporting text",
})
```

## Widgets

Each widget returns an object with a `Container` and its appropriate state methods.

- `section:AddLabel({ Text, Color, TextSize, Height })` → `:Set(value)`
- `section:AddParagraph({ Title, Content, Height })`
- `section:AddButton({ Title, Description, Callback })` → `:Press()`, `:SetText(value)`
- `section:AddToggle({ Title, Description, Default, Callback })` → `:Set(boolean, silent)`
- `section:AddSlider({ Title, Min, Max, Default, Increment, Callback })` → `:Set(number, silent)`
- `section:AddTextbox({ Title, Placeholder, Default, OnFocusLost, Callback })` → `:Get()`, `:Set(value)`
- `section:AddDropdown({ Title, Options, Default, Callback })` → `:Set(value, silent)`
- `section:AddKeybind({ Title, Default, Callback })` → `:Set(Enum.KeyCode)`
- `section:AddStat({ Title, Value, Color })` → `:Set(value)`

## Config helpers

`AstraUI:SerializeConfig(table)` returns JSON or `nil`; `AstraUI:DeserializeConfig(json)` returns a table or `nil`.
