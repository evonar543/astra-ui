-- RBA local UI-only demo. It creates a ScreenGui and does not call remotes, alter gameplay, or inspect game content.
local environment = (getgenv and getgenv()) or _G

if environment.__ASTRA_UI_RBA_DEMO and environment.__ASTRA_UI_RBA_DEMO.stop then
	environment.__ASTRA_UI_RBA_DEMO.stop()
end

-- Pin the library revision for this demo so executor-level HTTP caches cannot
-- silently substitute an older copy of the UI library.
local remoteUrl = "https://raw.githubusercontent.com/evonar543/astra-ui/307aec7/src/AstraUI.lua"
local source
local localSourceExists = false

-- Default to the published file: several executors hard-fail when asked about
-- a path outside their own allow-list. A developer may opt into a local copy
-- explicitly by setting getgenv().ASTRA_UI_LOCAL_PATH to an allowed path.
local localPath = environment.ASTRA_UI_LOCAL_PATH
if type(localPath) == "string" and type(readfile) == "function" and type(isfile) == "function" then
	local checked, exists = pcall(function() return isfile(localPath) end)
	localSourceExists = checked and exists == true
end

if localSourceExists then
	local readOk, localSource = pcall(readfile, localPath)
	if readOk then source = localSource end
end
if not source then source = game:HttpGet(remoteUrl) end

local factory, loadError = loadstring(source)
assert(factory, "AstraUI could not be loaded: " .. tostring(loadError))
local AstraUI = factory()

local window = AstraUI:CreateWindow({
	Name = "AstraUI_RBA_Demo",
	Title = "AstraUI",
	Subtitle = "Local RBA compatibility check",
	Mark = "A",
	ToggleKeybind = Enum.KeyCode.RightControl,
})

local dashboard = window:CreateTab({ Title = "Dashboard", Icon = "◆" })
local status = dashboard:CreateSection({ Title = "RBA demo status", Description = "This is a local interface demonstration only." })
status:AddStat({ Title = "Library", Value = "v" .. AstraUI.Version, Color = window.Theme.Success })
status:AddStat({ Title = "Loader", Value = source and "Connected" or "Unavailable", Color = window.Theme.Accent })
status:AddParagraph({ Title = "Safe scope", Content = "No RemoteEvents, RemoteFunctions, game automation, targeting, or gameplay actions are used." })

local controls = window:CreateTab({ Title = "Controls", Icon = "◈" })
local section = controls:CreateSection({ Title = "Widget smoke test", Description = "All callbacks stay within the local GUI." })
section:AddToggle({ Title = "Visual effects", Description = "Shows or hides the animated header accent.", Callback = function(value)
	window:SetVisualEffects(value)
	window:Notify({ Title = "Visual effects", Content = value and "Header accent enabled" or "Header accent disabled" })
end })
section:AddSlider({ Title = "Accent strength", Min = 0, Max = 100, Default = 72, Increment = 1 })
section:AddDropdown({ Title = "Layout", Options = { "Compact", "Balanced", "Expanded" }, Default = "Balanced" })
section:AddTextbox({ Title = "Local note", Placeholder = "Nothing is sent anywhere..." })
section:AddKeybind({ Title = "Notify hotkey", Default = Enum.KeyCode.N, Callback = function() window:Notify({ Title = "AstraUI", Content = "Keybind works." }) end })

environment.__ASTRA_UI_RBA_DEMO = {
	window = window,
	health = function()
		return { running = window.Gui.Parent ~= nil, visible = window.Visible, version = AstraUI.Version, scope = "ui-only" }
	end,
	stop = function()
		window:Destroy()
		environment.__ASTRA_UI_RBA_DEMO = nil
	end,
}

window:Notify({ Title = "AstraUI loaded", Content = "RBA local UI demo is ready. Right Control toggles it.", Color = window.Theme.Success })
