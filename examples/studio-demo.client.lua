-- Place AstraUI.lua in ReplicatedStorage as a ModuleScript, then put this LocalScript in StarterPlayerScripts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AstraUI = require(ReplicatedStorage:WaitForChild("AstraUI"))

local window = AstraUI:CreateWindow({
	Title = "AstraUI Studio Demo",
	Subtitle = "ModuleScript integration example",
	Mark = "A",
	ToggleKeybind = Enum.KeyCode.RightControl,
})

local dashboard = window:CreateTab({ Title = "Dashboard", Icon = "◆" })
local overview = dashboard:CreateSection({ Title = "Project overview", Description = "These controls only affect this local demo." })
overview:AddStat({ Title = "Session status", Value = "Ready", Color = window.Theme.Success })
overview:AddParagraph({ Title = "Hotkey", Content = "Press Right Control to hide or reopen the window." })

local controls = window:CreateTab({ Title = "Controls", Icon = "◈" })
local options = controls:CreateSection({ Title = "Interactive controls" })
options:AddToggle({ Title = "Demo toggle", Description = "Runs a local callback.", Callback = function(enabled) window:Notify({ Title = "Toggle", Content = "Demo toggle: " .. tostring(enabled) }) end })
options:AddSlider({ Title = "Intensity", Min = 0, Max = 100, Default = 50, Increment = 5 })
options:AddDropdown({ Title = "Profile", Options = { "Balanced", "Performance", "Quality" }, Default = "Balanced" })
options:AddTextbox({ Title = "Note", Placeholder = "Type a local note...", Callback = function(value) print("AstraUI note:", value) end })

window:Notify({ Title = "AstraUI loaded", Content = "The Studio example is ready.", Color = window.Theme.Success })
