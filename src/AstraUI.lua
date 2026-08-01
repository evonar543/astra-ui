--!strict
-- AstraUI 1.0.2
-- A self-contained Roblox UI toolkit for LocalScripts and ModuleScripts.

local AstraUI = {}
AstraUI.Version = "1.0.2"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local DEFAULT_THEME = {
	Background = Color3.fromRGB(10, 13, 22),
	Surface = Color3.fromRGB(18, 23, 37),
	SurfaceRaised = Color3.fromRGB(26, 33, 51),
	SurfaceHover = Color3.fromRGB(34, 43, 66),
	Accent = Color3.fromRGB(96, 139, 255),
	AccentMuted = Color3.fromRGB(52, 76, 138),
	Text = Color3.fromRGB(241, 245, 255),
	Subtext = Color3.fromRGB(151, 165, 195),
	Stroke = Color3.fromRGB(58, 69, 98),
	Danger = Color3.fromRGB(255, 100, 113),
	Success = Color3.fromRGB(91, 220, 157),
	Warning = Color3.fromRGB(255, 190, 92),
}

local function copyTable(source)
	local result = {}
	for key, value in pairs(source) do
		result[key] = value
	end
	return result
end

local function merge(base, override)
	local result = copyTable(base)
	for key, value in pairs(override or {}) do
		result[key] = value
	end
	return result
end

local function make(className, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	return instance
end

local function round(instance, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = instance })
end

local function outline(instance, color, transparency)
	return make("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = instance,
	})
end

local function tween(instance, duration, properties)
	local animation = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
	animation:Play()
	return animation
end

local function call(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local arguments = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(function()
			callback(table.unpack(arguments, 1, arguments.n))
		end)
		if not ok then
			warn("[AstraUI] callback error: " .. tostring(err))
		end
	end)
end

local function text(parent, content, size, color, properties)
	local label = make("TextLabel", merge({
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Text = content or "",
		TextColor3 = color,
		TextSize = size or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	}, properties))
	return label
end

local function bindHover(button, theme)
	button.MouseEnter:Connect(function()
		tween(button, 0.12, { BackgroundColor3 = theme.SurfaceHover })
	end)
	button.MouseLeave:Connect(function()
		tween(button, 0.12, { BackgroundColor3 = theme.SurfaceRaised })
	end)
end

local function keyName(input)
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		return input.KeyCode.Name
	end
	return input.UserInputType.Name:gsub("MouseButton", "Mouse ")
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

function AstraUI:CreateWindow(options)
	options = options or {}
	local theme = merge(DEFAULT_THEME, options.Theme)
	local playerGui = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	local name = options.Name or "AstraUI"

	local gui = make("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = options.DisplayOrder or 100,
		Parent = playerGui,
	})

	local windowSize = options.Size or UDim2.fromOffset(760, 500)
	local frame = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = windowSize,
		Parent = gui,
	})
	round(frame, 12)
	outline(frame, theme.Stroke, 0.25)

	local top = make("Frame", {
		Name = "Topbar",
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 72),
		Parent = frame,
	})
	round(top, 12)
	local topFix = make("Frame", {
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
		Parent = top,
	})

	local brand = make("Frame", {
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 18),
		Size = UDim2.fromOffset(36, 36),
		Parent = top,
	})
	round(brand, 10)
	text(brand, string.sub(options.Mark or "A", 1, 1):upper(), 17, theme.Text, {
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	text(top, options.Title or "Astra Window", 18, theme.Text, {
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(68, 14),
		Size = UDim2.new(1, -260, 0, 24),
	})
	text(top, options.Subtitle or "Focused tools, clear controls.", 12, theme.Subtext, {
		Position = UDim2.fromOffset(68, 37),
		Size = UDim2.new(1, -260, 0, 18),
	})

	local searchBox = make("TextBox", {
		Name = "Search",
		BackgroundColor3 = theme.SurfaceRaised,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = theme.Subtext,
		PlaceholderText = "Search controls...",
		Text = "",
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(1, -202, 0, 20),
		Size = UDim2.fromOffset(158, 32),
		Parent = top,
	})
	searchBox.ZIndex = 3
	round(searchBox, 8)
	make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = searchBox })

	local close = make("TextButton", {
		BackgroundColor3 = theme.SurfaceRaised,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = theme.Subtext,
		TextSize = 22,
		Position = UDim2.new(1, -36, 0, 20),
		Size = UDim2.fromOffset(22, 32),
		Parent = top,
	})
	close.ZIndex = 3
	round(close, 7)

	local accentRail = make("Frame", {
		Name = "AccentRail",
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, -88, 1, 0),
		Size = UDim2.fromOffset(176, 2),
		Visible = false,
		ZIndex = 3,
		Parent = top,
	})
	round(accentRail, 2)
	make("UIGradient", {
		Color = ColorSequence.new(theme.AccentMuted, theme.Accent),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.28, 0.15),
			NumberSequenceKeypoint.new(0.72, 0.15),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = accentRail,
	})

	-- The title strip is the only draggable area. Keeping it separate from the
	-- search and close controls prevents normal clicks from capturing the cursor.
	local dragHandle = make("TextButton", {
		Name = "DragHandle",
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Modal = false,
		Text = "",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -218, 1, 0),
		ZIndex = 2,
		Parent = top,
	})
	local dragGrip = make("Frame", {
		Name = "DragGrip",
		Active = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -244, 0, 24),
		Size = UDim2.fromOffset(18, 24),
		ZIndex = 3,
		Parent = top,
	})
	for index = 0, 2 do
		local line = make("Frame", {
			BackgroundColor3 = theme.Subtext,
			BackgroundTransparency = 0.28,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(4, 4 + index * 6),
			Size = UDim2.fromOffset(10, 2),
			ZIndex = 3,
			Parent = dragGrip,
		})
		round(line, 1)
	end

	local sidebar = make("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 72),
		Size = UDim2.new(0, 174, 1, -72),
		Parent = frame,
	})
	local sidebarLayout = make("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})
	make("UIPadding", {
		PaddingTop = UDim.new(0, 15),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = sidebar,
	})

	local pages = make("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(174, 72),
		Size = UDim2.new(1, -174, 1, -72),
		ClipsDescendants = true,
		Parent = frame,
	})

	local notifications = make("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(320, 260),
		Parent = gui,
	})
	local notificationLayout = make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = notifications,
	})

	local self = setmetatable({
		Theme = theme,
		Gui = gui,
		Frame = frame,
		Pages = pages,
		Sidebar = sidebar,
		Tabs = {},
		Controls = {},
		Connections = {},
		Visible = true,
		Closed = false,
		ActiveTab = nil,
		ToggleKey = options.ToggleKeybind or Enum.KeyCode.RightControl,
		MinSize = options.MinSize or Vector2.new(520, 340),
		MaxSize = options.MaxSize or Vector2.new(1100, 760),
		Notifications = notifications,
		AccentRail = accentRail,
		VisualEffects = false,
		EffectToken = 0,
		EffectTween = nil,
	}, Window)

	local function track(connection)
		table.insert(self.Connections, connection)
		return connection
	end

	local dragStart, frameStart, dragInput
	local dragging = false
	local function updateDrag(input)
		local delta = input.Position - dragStart
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		local size = frame.AbsoluteSize
		local nextX = math.clamp(frameStart.X.Offset + delta.X, -size.X / 2 + 70, viewport.X - size.X / 2 - 70)
		local nextY = math.clamp(frameStart.Y.Offset + delta.Y, -size.Y / 2 + 25, viewport.Y - size.Y / 2 - 25)
		frame.Position = UDim2.new(frameStart.X.Scale, nextX, frameStart.Y.Scale, nextY)
	end
	local function stopDragging()
		dragging = false
		dragInput = nil
		dragStart = nil
	end
	track(dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			frameStart = frame.Position
			dragging = true
		end
	end))
	track(dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput and dragStart and (input.Position - dragStart).Magnitude >= 3 then updateDrag(input) end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then stopDragging() end
	end))

	local grip = make("TextButton", {
		Name = "ResizeGrip",
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "⋰",
		TextColor3 = theme.Subtext,
		TextSize = 18,
		Position = UDim2.new(1, -4, 1, -4),
		Size = UDim2.fromOffset(24, 24),
		Parent = frame,
	})
	local resizeStart, initialSize, resizeInput
	local resizing = false
	track(grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizeStart, initialSize = input.Position, frame.AbsoluteSize
			resizing = true
		end
	end))
	track(grip.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then resizeInput = input end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if resizing and input == resizeInput and resizeStart then
			local delta = input.Position - resizeStart
			local width = math.clamp(initialSize.X + delta.X, self.MinSize.X, self.MaxSize.X)
			local height = math.clamp(initialSize.Y + delta.Y, self.MinSize.Y, self.MaxSize.Y)
			frame.Size = UDim2.fromOffset(width, height)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
			resizeInput = nil
			resizeStart = nil
		end
	end))

	track(close.MouseButton1Click:Connect(function() self:SetVisible(false) end))
	track(UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == self.ToggleKey then self:ToggleVisible() end
	end))
	track(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchBox.Text)
		for _, control in ipairs(self.Controls) do
			control.Container.Visible = query == "" or string.find(string.lower(control.SearchText), query, 1, true) ~= nil
		end
	end))

	return self
end

function Window:SetVisible(isVisible)
	if self.Closed then return end
	self.Visible = isVisible
	if isVisible then
		self.Gui.Enabled = true
		self.Frame.Position = UDim2.new(self.Frame.Position.X.Scale, self.Frame.Position.X.Offset, self.Frame.Position.Y.Scale, self.Frame.Position.Y.Offset + 8)
		tween(self.Frame, 0.16, { Position = UDim2.new(self.Frame.Position.X.Scale, self.Frame.Position.X.Offset, self.Frame.Position.Y.Scale, self.Frame.Position.Y.Offset - 8) })
	else
		self.Gui.Enabled = false
	end
end

function Window:SetVisualEffects(enabled)
	if self.Closed then return end
	self.VisualEffects = enabled == true
	self.EffectToken = self.EffectToken + 1
	if self.EffectTween then
		self.EffectTween:Cancel()
		self.EffectTween = nil
	end
	if not self.VisualEffects then
		self.AccentRail.Visible = false
		return
	end

	local token = self.EffectToken
	self.AccentRail.Visible = true
	task.spawn(function()
		while not self.Closed and self.VisualEffects and token == self.EffectToken do
			self.AccentRail.Position = UDim2.new(0, -88, 1, 0)
			local animation = tween(self.AccentRail, 1.9, { Position = UDim2.new(1, 88, 1, 0) })
			self.EffectTween = animation
			animation.Completed:Wait()
		end
	end)
end

function Window:ToggleVisible()
	self:SetVisible(not self.Visible)
end

function Window:SetToggleKey(keyCode)
	self.ToggleKey = keyCode
end

function Window:Notify(options)
	options = options or {}
	local color = options.Color or self.Theme.Accent
	local toast = make("Frame", {
		BackgroundColor3 = self.Theme.SurfaceRaised,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		LayoutOrder = os.clock() * 1000,
		Size = UDim2.new(1, 0, 0, 66),
		Parent = self.Notifications,
	})
	round(toast, 9)
	outline(toast, self.Theme.Stroke, 0.15)
	local line = make("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.fromOffset(4, 38), Position = UDim2.fromOffset(10, 14), Parent = toast })
	round(line, 2)
	text(toast, options.Title or "AstraUI", 13, self.Theme.Text, { Font = Enum.Font.GothamBold, Position = UDim2.fromOffset(25, 10), Size = UDim2.new(1, -38, 0, 20) })
	text(toast, options.Content or "", 11, self.Theme.Subtext, { TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(25, 30), Size = UDim2.new(1, -38, 0, 28) })
	task.delay(options.Duration or 4, function()
		if toast.Parent then
			tween(toast, 0.18, { BackgroundTransparency = 1 })
			task.wait(0.2)
			toast:Destroy()
		end
	end)
	return toast
end

function Window:Destroy()
	if self.Closed then return end
	self.Closed = true
	if self.EffectTween then self.EffectTween:Cancel() end
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	self.Gui:Destroy()
end

function Window:CreateTab(options)
	options = options or {}
	local tab = setmetatable({ Window = self, Sections = {}, Button = nil, Page = nil }, Tab)
	local label = options.Title or "Tab"
	local button = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = self.Theme.Surface,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = (options.Icon and options.Icon .. "  " or "") .. label,
		TextColor3 = self.Theme.Subtext,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 37),
		Parent = self.Sidebar,
	})
	round(button, 8)
	make("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = button })
	local page = make("ScrollingFrame", {
		Name = label .. "Page",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = self.Theme.AccentMuted,
		ScrollBarThickness = 4,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.Pages,
	})
	make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
	make("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 17), PaddingRight = UDim.new(0, 17), Parent = page })
	tab.Button, tab.Page = button, page
	self.Tabs[label] = tab
	button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
	if not self.ActiveTab then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab == tab then return end
	for _, candidate in pairs(self.Tabs) do
		candidate.Page.Visible = false
		candidate.Button.BackgroundColor3 = self.Theme.Surface
		candidate.Button.TextColor3 = self.Theme.Subtext
	end
	self.ActiveTab = tab
	tab.Page.Visible = true
	tab.Button.BackgroundColor3 = self.Theme.SurfaceRaised
	tab.Button.TextColor3 = self.Theme.Text
end

function Tab:CreateSection(options)
	options = options or {}
	local window, theme = self.Window, self.Window.Theme
	local card = make("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self.Page,
	})
	round(card, 10)
	outline(card, theme.Stroke, 0.38)
	make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	make("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 13), PaddingRight = UDim.new(0, 13), Parent = card })
	text(card, options.Title or "Section", 13, theme.Text, { Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 18) })
	if options.Description then text(card, options.Description, 11, theme.Subtext, { TextWrapped = true, Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Top }) end
	local section = setmetatable({ Window = window, Theme = theme, Container = card }, Section)
	table.insert(self.Sections, section)
	return section
end

function Section:_row(height, searchText)
	local row = make("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height or 38), Parent = self.Container })
	table.insert(self.Window.Controls, { Container = row, SearchText = searchText or "" })
	return row
end

function Section:AddLabel(options)
	options = options or {}
	local row = self:_row(options.Height or 31, options.Text or "")
	local label = text(row, options.Text or "Label", options.TextSize or 12, options.Color or self.Theme.Subtext, { TextWrapped = true, Size = UDim2.fromScale(1, 1), TextYAlignment = Enum.TextYAlignment.Center })
	return { Set = function(_, value) label.Text = tostring(value) end, Container = row }
end

function Section:AddParagraph(options)
	options = options or {}
	local row = self:_row(options.Height or 58, (options.Title or "") .. " " .. (options.Content or ""))
	text(row, options.Title or "Info", 12, self.Theme.Text, { Font = Enum.Font.GothamBold, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 18) })
	text(row, options.Content or "", 11, self.Theme.Subtext, { TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(0, 21), Size = UDim2.new(1, 0, 1, -21) })
	return { Container = row }
end

function Section:AddButton(options)
	options = options or {}
	local row = self:_row(39, (options.Title or "Button") .. " " .. (options.Description or ""))
	local button = make("TextButton", {
		AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium, Text = options.Title or "Button", TextColor3 = self.Theme.Text, TextSize = 12,
		Size = UDim2.fromScale(1, 1), Parent = row,
	})
	round(button, 8); bindHover(button, self.Theme)
	button.MouseButton1Click:Connect(function() call(options.Callback) end)
	return { Container = row, Press = function() call(options.Callback) end, SetText = function(_, value) button.Text = tostring(value) end }
end

function Section:AddToggle(options)
	options = options or {}
	local value = options.Default == true
	local row = self:_row(40, (options.Title or "Toggle") .. " " .. (options.Description or ""))
	text(row, options.Title or "Toggle", 12, self.Theme.Text, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -70, 0, 20) })
	if options.Description then text(row, options.Description, 10, self.Theme.Subtext, { Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, -70, 0, 17) }) end
	local switch = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = value and self.Theme.Accent or self.Theme.SurfaceRaised, BorderSizePixel = 0, Text = "", Position = UDim2.new(1, -48, 0.5, -11), Size = UDim2.fromOffset(42, 22), Parent = row })
	round(switch, 11)
	local dot = make("Frame", { BackgroundColor3 = self.Theme.Text, BorderSizePixel = 0, Position = value and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(16, 16), Parent = switch })
	round(dot, 8)
	local api = { Container = row, Value = value }
	function api:Set(nextValue, silent)
		value, self.Value = nextValue == true, nextValue == true
		tween(switch, 0.12, { BackgroundColor3 = value and self.Theme.Accent or self.Theme.SurfaceRaised })
		tween(dot, 0.12, { Position = value and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3) })
		if not silent then call(options.Callback, value) end
	end
	switch.MouseButton1Click:Connect(function() api:Set(not value) end)
	return api
end

function Section:AddSlider(options)
	options = options or {}
	local minimum, maximum = options.Min or 0, options.Max or 100
	local value = math.clamp(options.Default or minimum, minimum, maximum)
	local row = self:_row(54, (options.Title or "Slider") .. " " .. (options.Description or ""))
	text(row, options.Title or "Slider", 12, self.Theme.Text, { Size = UDim2.new(1, -65, 0, 19) })
	local valueLabel = text(row, tostring(value), 11, self.Theme.Accent, { Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -58, 0, 0), Size = UDim2.fromOffset(58, 19) })
	local track = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, Text = "", Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 8), Parent = row })
	round(track, 4)
	local fill = make("Frame", { BackgroundColor3 = self.Theme.Accent, BorderSizePixel = 0, Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0), Parent = track })
	round(fill, 4)
	local function setFromPosition(position, silent)
		local alpha = math.clamp((position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local stepped = math.round((minimum + (maximum - minimum) * alpha) / (options.Increment or 1)) * (options.Increment or 1)
		value = math.clamp(stepped, minimum, maximum)
		fill.Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0)
		valueLabel.Text = tostring(value)
		if not silent then call(options.Callback, value) end
	end
	local dragging = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromPosition(input.Position) end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromPosition(input.Position) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	local api = { Container = row, Value = value }
	function api:Set(nextValue, silent)
		value = math.clamp(nextValue, minimum, maximum); self.Value = value
		fill.Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0); valueLabel.Text = tostring(value)
		if not silent then call(options.Callback, value) end
	end
	return api
end

function Section:AddTextbox(options)
	options = options or {}
	local row = self:_row(59, (options.Title or "Textbox") .. " " .. (options.Placeholder or ""))
	text(row, options.Title or "Textbox", 12, self.Theme.Text, { Size = UDim2.new(1, 0, 0, 18) })
	local box = make("TextBox", { BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, ClearTextOnFocus = false, Font = Enum.Font.Gotham, PlaceholderColor3 = self.Theme.Subtext, PlaceholderText = options.Placeholder or "Enter text...", Text = options.Default or "", TextColor3 = self.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 28), Parent = row })
	round(box, 7); make("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), Parent = box })
	box.FocusLost:Connect(function(enterPressed) if enterPressed or options.OnFocusLost then call(options.Callback, box.Text, enterPressed) end end)
	return { Container = row, Get = function() return box.Text end, Set = function(_, value) box.Text = tostring(value) end }
end

function Section:AddDropdown(options)
	options = options or {}
	local choices = options.Options or {}
	local selected = options.Default or choices[1]
	local row = self:_row(66, (options.Title or "Dropdown") .. " " .. table.concat(choices, " "))
	text(row, options.Title or "Dropdown", 12, self.Theme.Text, { Size = UDim2.new(1, 0, 0, 18) })
	local button = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, Font = Enum.Font.Gotham, Text = tostring(selected or "Select...") .. "   ▾", TextColor3 = self.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 29), Parent = row })
	round(button, 7); make("UIPadding", { PaddingLeft = UDim.new(0, 9), Parent = button })
	local menu = make("Frame", { BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(0, 55), Size = UDim2.new(1, 0, 0, 0), Visible = false, ZIndex = 8, Parent = row })
	round(menu, 7); outline(menu, self.Theme.Stroke, 0.2)
	make("UIListLayout", { Padding = UDim.new(0, 2), Parent = menu }); make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = menu })
	local open = false
	local api = { Container = row, Value = selected }
	local function choose(choice, silent)
		selected, api.Value = choice, choice; button.Text = tostring(choice) .. "   ▾"; open = false; menu.Visible = false; row.Size = UDim2.new(1, 0, 0, 66)
		if not silent then call(options.Callback, choice) end
	end
	for _, choice in ipairs(choices) do
		local option = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = self.Theme.Surface, BorderSizePixel = 0, Font = Enum.Font.Gotham, Text = tostring(choice), TextColor3 = self.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 25), ZIndex = 9, Parent = menu })
		round(option, 5); make("UIPadding", { PaddingLeft = UDim.new(0, 7), Parent = option }); bindHover(option, self.Theme); option.MouseButton1Click:Connect(function() choose(choice) end)
	end
	button.MouseButton1Click:Connect(function()
		open = not open; menu.Visible = open; row.Size = UDim2.new(1, 0, 0, open and (66 + #choices * 27 + 8) or 66); menu.Size = UDim2.new(1, 0, 0, #choices * 27 + 8)
	end)
	function api:Set(value, silent) choose(value, silent) end
	return api
end

function Section:AddKeybind(options)
	options = options or {}
	local value = options.Default or Enum.KeyCode.Unknown
	local waiting = false
	local row = self:_row(39, (options.Title or "Keybind") .. " " .. (options.Description or ""))
	text(row, options.Title or "Keybind", 12, self.Theme.Text, { Size = UDim2.new(1, -110, 0, 20) })
	local button = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, Text = keyName({ KeyCode = value, UserInputType = Enum.UserInputType.Keyboard }), TextColor3 = self.Theme.Accent, TextSize = 10, Position = UDim2.new(1, -103, 0.5, -13), Size = UDim2.fromOffset(97, 26), Parent = row })
	round(button, 7)
	local api = { Container = row, Value = value }
	button.MouseButton1Click:Connect(function() waiting = true; button.Text = "Press a key..." end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if waiting then
			waiting = false; value, api.Value = input.KeyCode, input.KeyCode; button.Text = keyName(input); call(options.Callback, value); return
		end
		if not processed and input.KeyCode == value then call(options.Callback, value) end
	end)
	function api:Set(nextValue) value, self.Value = nextValue, nextValue; button.Text = nextValue.Name end
	return api
end

function Section:AddStat(options)
	options = options or {}
	local row = self:_row(50, (options.Title or "Stat") .. " " .. tostring(options.Value or ""))
	local card = make("Frame", { BackgroundColor3 = self.Theme.SurfaceRaised, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = row })
	round(card, 8)
	text(card, options.Title or "Stat", 11, self.Theme.Subtext, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 15) })
	local value = text(card, tostring(options.Value or "0"), 17, options.Color or self.Theme.Text, { Font = Enum.Font.GothamBold, Position = UDim2.fromOffset(10, 21), Size = UDim2.new(1, -20, 0, 23) })
	return { Container = row, Set = function(_, nextValue) value.Text = tostring(nextValue) end }
end

function AstraUI:SerializeConfig(values)
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, values)
	return ok and encoded or nil
end

function AstraUI:DeserializeConfig(encoded)
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, encoded)
	return ok and decoded or nil
end

return AstraUI
