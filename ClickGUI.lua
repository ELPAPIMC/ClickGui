local __Node = {}
__Node.__index = function(node, key)
local child = rawget(node, "_children")[key]
if child == nil then
error("[ClickGUI bundle] '" .. tostring(key) .. "' not found in '" .. rawget(node, "_name") .. "'", 2)
end
return child
end
local function __newNode(name, parent)
local node = setmetatable({ _name = name, _parent = parent, _children = {} }, __Node)
if parent then
rawget(parent, "_children")[name] = node
end
return node
end
local __root = __newNode("ClickGUI", nil)
local __functions = {}
local __cache = {}
local __loading = {}
local function __require(node)
local cached = __cache[node]
if cached ~= nil then
return cached[1]
end
local fn = __functions[node]
if not fn then
error("[ClickGUI bundle] attempt to require a non-module", 2)
end
if __loading[node] then
error("[ClickGUI bundle] circular require", 2)
end
__loading[node] = true
local result = fn(node, __require)
__loading[node] = nil
__cache[node] = { result }
return result
end
__Node.__index = (function(inner)
return function(node, key)
if key == "Parent" then
return rawget(node, "_parent")
elseif key == "Name" then
return rawget(node, "_name")
end
return inner(node, key)
end
end)(__Node.__index)
local __n_init = __root
local __n_Components = __newNode("Components", __root)
local __n_Components_Base = __newNode("Base", __n_Components)
local __n_Components_Button = __newNode("Button", __n_Components)
local __n_Components_ColorPicker = __newNode("ColorPicker", __n_Components)
local __n_Components_Dropdown = __newNode("Dropdown", __n_Components)
local __n_Components_Graphic = __newNode("Graphic", __n_Components)
local __n_Components_ImageButton = __newNode("ImageButton", __n_Components)
local __n_Components_InputNumber = __newNode("InputNumber", __n_Components)
local __n_Components_Keybind = __newNode("Keybind", __n_Components)
local __n_Components_KeybindList = __newNode("KeybindList", __n_Components)
local __n_Components_Label = __newNode("Label", __n_Components)
local __n_Components_ProgressBar = __newNode("ProgressBar", __n_Components)
local __n_Components_RangeSlider = __newNode("RangeSlider", __n_Components)
local __n_Components_Section = __newNode("Section", __n_Components)
local __n_Components_Slider = __newNode("Slider", __n_Components)
local __n_Components_Textbox = __newNode("Textbox", __n_Components)
local __n_Components_Toggle = __newNode("Toggle", __n_Components)
local __n_Components_UIShadow = __newNode("UIShadow", __n_Components)
local __n_Core = __newNode("Core", __root)
local __n_Core_AnimationManager = __newNode("AnimationManager", __n_Core)
local __n_Core_Category = __newNode("Category", __n_Core)
local __n_Core_Config = __newNode("Config", __n_Core)
local __n_Core_Fonts = __newNode("Fonts", __n_Core)
local __n_Core_HUD = __newNode("HUD", __n_Core)
local __n_Core_InputManager = __newNode("InputManager", __n_Core)
local __n_Core_Loader = __newNode("Loader", __n_Core)
local __n_Core_Module = __newNode("Module", __n_Core)
local __n_Core_Notifications = __newNode("Notifications", __n_Core)
local __n_Core_Settings = __newNode("Settings", __n_Core)
local __n_Core_Styles = __newNode("Styles", __n_Core)
local __n_Core_TargetHUD = __newNode("TargetHUD", __n_Core)
local __n_Core_ThemeManager = __newNode("ThemeManager", __n_Core)
local __n_Core_Tooltip = __newNode("Tooltip", __n_Core)
local __n_Core_Visual = __newNode("Visual", __n_Core)
local __n_Core_Watermark = __newNode("Watermark", __n_Core)
local __n_Core_Window = __newNode("Window", __n_Core)
local __n_Types = __newNode("Types", __root)
local __n_Utilities = __newNode("Utilities", __root)
local __n_Utilities_Create = __newNode("Create", __n_Utilities)
local __n_Utilities_Draggable = __newNode("Draggable", __n_Utilities)
local __n_Utilities_Maid = __newNode("Maid", __n_Utilities)
local __n_Utilities_Resizer = __newNode("Resizer", __n_Utilities)
local __n_Utilities_Signal = __newNode("Signal", __n_Utilities)
local __n_Utilities_Tween = __newNode("Tween", __n_Utilities)
__functions[__n_Components_Base] = function(script, require)
local Utilities = script.Parent.Parent.Utilities
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local Signal = require(Utilities.Signal)
local AnimationManager = require(script.Parent.Parent.Core.AnimationManager)
local InputManager = require(script.Parent.Parent.Core.InputManager)
local Visual = require(script.Parent.Parent.Core.Visual)
local Base = {}
Base.__index = Base
function Base.new(ctx, parent: Instance, name: string, height: number)
assert(type(name) == "string", "[ClickGUI] component options need a `Name` string")
local self = setmetatable({}, Base)
self.Name = name
self.Value = nil
self.Module = nil
self.Changed = Signal.new()
self._ctx = ctx
self._theme = ctx.Theme
self._maid = Maid.new()
self._callback = nil
self._flag = nil
self._destroyed = false
self.Frame = Create("Frame", {
Name = name,
Size = UDim2.new(1, 0, 0, height),
BackgroundTransparency = 1,
Parent = parent,
})
return self
end
function Base:_emit(...)
self.Changed:Fire(...)
if self._callback then
local ok, err = pcall(self._callback, ...)
if not ok then
warn(`[ClickGUI] Callback error in "{self.Name}": {err}`)
end
end
end
function Base:_onTheme(fn)
self._maid:Give(self._theme.Changed:Connect(fn))
end
function Base:_bind(instance, property, key)
self._theme:Bind(instance, property, key)
end
function Base:_label(props)
props.Font = self._theme:Get("Font")
props.TextColor3 = self._theme:Get("Text")
local label = Create("TextLabel", props)
self._theme:Bind(label, "TextColor3", "Text")
self._theme:Bind(label, "Font", "Font")
return label
end
function Base:_play(instance, goal, animated, preset)
AnimationManager.Play(instance, animated and (preset or "Fast") or "Instant", goal)
end
function Base:_lockScroll(locked: boolean)
local scroller = self.Frame:FindFirstAncestorOfClass("ScrollingFrame")
if scroller then
scroller.ScrollingEnabled = not locked
end
end
function Base:SetVisible(visible: boolean)
self.Frame.Visible = visible
end
function Base:_initKeybind(options)
if not self._keyAction then
return
end
local theme = self._theme
self._hasKeyAction = true
self._bindable = options.Bindable ~= false
local chip = Create("TextLabel", {
Name = "KeyChip",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(self._chipCenter and 0.5 or 1, -(self._chipOffset or 4), 0.5, 0),
Size = UDim2.fromOffset(0, 14),
AutomaticSize = Enum.AutomaticSize.X,
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = "",
TextSize = 10,
TextColor3 = theme:Get("Accent"),
Visible = false,
ZIndex = 8,
Parent = self.Frame,
})
Create.corner(chip, 4)
Create.padding(chip, 0, 5, 0, 5)
theme:Bind(chip, "BackgroundColor3", "Element")
theme:Bind(chip, "TextColor3", "Accent")
self._chip = chip
self._bindKey = nil
self._keyBinding = self._ctx.Input:BindKey(nil, function()
self:_runKeyAction()
end)
self._maid:Give(self._keyBinding)
if options.Keybind then
self:SetKeybind(options.Keybind, true)
end
self._defaultBind = self._bindKey
if self._bindable then
local function hook(gui)
self._maid:Give(gui.MouseButton2Click:Connect(function()
self:_beginBind()
end))
end
for _, descendant in self.Frame:GetDescendants() do
if descendant:IsA("GuiButton") then
hook(descendant)
end
end
end
end
function Base:_runKeyAction()
if self._enabledState == false or not self._keyAction then
return
end
local ok, err = pcall(self._keyAction, self)
if not ok then
warn(`[ClickGUI] Keybind action error in "{self.Name}": {err}`)
end
end
function Base:SetKeybind(key, silent)
if not self._hasKeyAction then
warn(`[ClickGUI] "{self.Name}" does not support keybinds`)
return
end
if type(key) == "string" then
local ok, item = pcall(function()
return Enum.KeyCode[key]
end)
key = ok and item or nil
end
if key == Enum.KeyCode.Unknown then
key = nil
end
self._bindKey = key
self._keyBinding:SetKey(key)
self._chip.Text = InputManager.KeyName(key)
self._chip.Visible = key ~= nil
if not silent then
self.Changed:Fire(self.Value, key)
end
end
function Base:GetKeybind()
return self._bindKey
end
function Base:_beginBind()
if not self._hasKeyAction then
return
end
self._chip.Text = "..."
self._chip.Visible = true
self._ctx.Input:Capture(function(key, cancelled)
if self._destroyed then
return
end
if cancelled then
self:SetKeybind(self._bindKey, true)
else
self:SetKeybind(key)
end
end)
end
function Base:SetTooltip(text)
self._maid:Remove("tooltip")
local window = self._ctx.Window
if text == nil or not window or not window.Tooltip then
return
end
local detach = {}
table.insert(detach, window.Tooltip:Attach(self.Frame, text))
for _, descendant in self.Frame:GetDescendants() do
if descendant:IsA("GuiButton") or descendant:IsA("TextBox") then
table.insert(detach, window.Tooltip:Attach(descendant, text))
end
end
self._maid:GiveNamed("tooltip", function()
for _, fn in detach do
fn()
end
end)
end
function Base:SetEnabled(enabled: boolean)
self._enabledState = not not enabled
if not self._blocker then
self._blocker = Create("TextButton", {
Name = "Disabled",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = self._theme:Get("Module"),
BackgroundTransparency = 0.35,
ZIndex = 20,
Visible = false,
Parent = self.Frame,
})
self._theme:Bind(self._blocker, "BackgroundColor3", "Module")
end
self._blocker.Visible = not self._enabledState
end
function Base:IsEnabled(): boolean
return self._enabledState ~= false
end
function Base:Get()
return self.Value
end
function Base:Set(_value, _silent)
end
function Base:Serialize()
return self.Value
end
function Base:Deserialize(value)
self:Set(value)
end
function Base:Destroy()
if self._destroyed then
return
end
self._destroyed = true
local module = self.Module
if module then
if self._flag and module.Window.Flags[self._flag] == self then
module.Window.Flags[self._flag] = nil
end
module:_removeComponent(self)
end
self._maid:Clean()
self.Changed:Destroy()
self.Frame:Destroy()
end
return Base
end
__functions[__n_Components_Button] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Button = setmetatable({}, { __index = Base })
Button.__index = Button
function Button.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 26), Button)
local theme = self._theme
self._callback = options.Callback
self._hovered = false
self._button = Create("TextButton", {
Name = "Button",
Size = UDim2.fromScale(1, 1),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = options.Text or options.Name,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Parent = self.Frame,
})
Create.corner(self._button, 6)
theme:Bind(self._button, "TextColor3", "Text")
theme:Bind(self._button, "Font", "Font")
self._maid:Give(self._button.MouseEnter:Connect(function()
self._hovered = true
self:_render(true)
end))
self._maid:Give(self._button.MouseLeave:Connect(function()
self._hovered = false
self:_render(true)
end))
self._maid:Give(self._button.MouseButton1Click:Connect(function()
self:_press()
self:_emit()
end))
self:_onTheme(function()
self:_render(true)
end)
return self
end
Button.NoPersist = true
Button._chipOffset = 8
Button._keyAction = function(self)
self:_press()
self:_emit()
end
function Button:_render(animated)
local theme = self._theme
self:_play(
self._button,
{ BackgroundColor3 = self._hovered and theme:Get("ElementHover") or theme:Get("Element") },
animated
)
end
function Button:_press()
local theme = self._theme
self._button.BackgroundColor3 = theme:Get("Accent")
self:_play(
self._button,
{ BackgroundColor3 = self._hovered and theme:Get("ElementHover") or theme:Get("Element") },
true,
"Normal"
)
end
function Button:SetText(text)
self._button.Text = text
end
function Button:Fire()
self:_emit()
end
return Button
end
__functions[__n_Components_ColorPicker] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local ColorPicker = setmetatable({}, { __index = Base })
ColorPicker.__index = ColorPicker
local HEADER_HEIGHT = 24
local SV_HEIGHT = 90
local HUE_HEIGHT = 12
local HEX_HEIGHT = 22
local PICKER_HEIGHT = 6 + SV_HEIGHT + 8 + HUE_HEIGHT + 8 + HEX_HEIGHT + 4
local HUE_SEQUENCE = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
})
local function toHex(color: Color3): string
return string.format(
"#%02X%02X%02X",
math.round(color.R * 255),
math.round(color.G * 255),
math.round(color.B * 255)
)
end
function ColorPicker.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, HEADER_HEIGHT), ColorPicker)
local theme = self._theme
self._callback = options.Callback
self._open = false
self._drag = nil
self.Frame.ClipsDescendants = true
local startColor = options.Default or theme:Get("Accent")
self._h, self._s, self._v = startColor:ToHSV()
self.Value = startColor
local header =
Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, HEADER_HEIGHT), Parent = self.Frame })
self:_label({
Name = "Label",
Position = UDim2.fromOffset(2, 0),
Size = UDim2.new(1, -44, 1, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = header,
})
self._swatch = Create("Frame", {
Name = "Swatch",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -2, 0.5, 0),
Size = UDim2.fromOffset(30, 14),
BackgroundColor3 = self.Value,
Parent = header,
})
Create.corner(self._swatch, 4)
local swatchStroke = Create.stroke(self._swatch, theme:Get("Stroke"), 1)
theme:Bind(swatchStroke, "Color", "Stroke")
self._body = Create("Frame", {
Name = "Body",
Position = UDim2.fromOffset(0, HEADER_HEIGHT),
Size = UDim2.new(1, 0, 0, PICKER_HEIGHT),
BackgroundTransparency = 1,
Parent = self.Frame,
})
self._sv = Create("Frame", {
Name = "SV",
Position = UDim2.fromOffset(2, 6),
Size = UDim2.new(1, -4, 0, SV_HEIGHT),
BackgroundColor3 = Color3.fromHSV(self._h, 1, 1),
ClipsDescendants = true,
Parent = self._body,
})
Create.corner(self._sv, 5)
local white = Create(
"Frame",
{ Name = "White", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = self._sv }
)
Create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
local black = Create(
"Frame",
{ Name = "Black", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = self._sv }
)
Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
self._cursor = Create("Frame", {
Name = "Cursor",
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(10, 10),
BackgroundTransparency = 1,
ZIndex = 3,
Parent = self._sv,
})
Create.pill(self._cursor)
Create.stroke(self._cursor, Color3.new(1, 1, 1), 2)
local svHit = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = self._sv })
self._hue = Create("Frame", {
Name = "Hue",
Position = UDim2.fromOffset(2, 6 + SV_HEIGHT + 8),
Size = UDim2.new(1, -4, 0, HUE_HEIGHT),
BackgroundColor3 = Color3.new(1, 1, 1),
Parent = self._body,
})
Create.pill(self._hue)
Create("UIGradient", { Color = HUE_SEQUENCE, Parent = self._hue })
self._hueKnob = Create("Frame", {
Name = "Knob",
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(6, HUE_HEIGHT + 4),
BackgroundColor3 = Color3.new(1, 1, 1),
ZIndex = 3,
Parent = self._hue,
})
Create.corner(self._hueKnob, 3)
Create.stroke(self._hueKnob, Color3.new(0, 0, 0), 1, 0.5)
local hueHit = Create("TextButton", {
Name = "Hit",
Size = UDim2.new(1, 0, 1, 8),
Position = UDim2.fromOffset(0, -4),
ZIndex = 4,
Parent = self._hue,
})
local hexBackground = Create("Frame", {
Name = "HexBackground",
Position = UDim2.fromOffset(2, 6 + SV_HEIGHT + 8 + HUE_HEIGHT + 8),
Size = UDim2.new(1, -4, 0, HEX_HEIGHT),
BackgroundColor3 = theme:Get("Element"),
Parent = self._body,
})
Create.corner(hexBackground, 5)
theme:Bind(hexBackground, "BackgroundColor3", "Element")
self._hex = Create("TextBox", {
Name = "Hex",
Size = UDim2.fromScale(1, 1),
Text = toHex(self.Value),
PlaceholderText = "#RRGGBB",
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Active = true,
Parent = hexBackground,
})
theme:Bind(self._hex, "TextColor3", "Text")
self._maid:Give(header.MouseButton1Click:Connect(function()
self:SetOpen(not self._open)
end))
local function begin(kind)
return function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
self._drag = kind
self:_lockScroll(true)
self:_fromPosition(input.Position)
end
end
end
self._maid:Give(svHit.InputBegan:Connect(begin("sv")))
self._maid:Give(hueHit.InputBegan:Connect(begin("hue")))
self._maid:Give(UserInputService.InputChanged:Connect(function(input)
if
self._drag
and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
)
then
self:_fromPosition(input.Position)
end
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input)
if
self._drag
and (
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
)
then
self._drag = nil
self:_lockScroll(false)
end
end))
self._maid:Give(self._hex.FocusLost:Connect(function()
local ok, color = pcall(Color3.fromHex, self._hex.Text)
if ok and typeof(color) == "Color3" then
self:Set(color)
end
self._hex.Text = toHex(self.Value)
end))
self:_render(false)
return self
end
function ColorPicker:_fromPosition(position)
if self._drag == "sv" then
local size = self._sv.AbsoluteSize
if size.X <= 0 or size.Y <= 0 then
return
end
local origin = self._sv.AbsolutePosition
self._s = math.clamp((position.X - origin.X) / size.X, 0, 1)
self._v = 1 - math.clamp((position.Y - origin.Y) / size.Y, 0, 1)
elseif self._drag == "hue" then
local width = self._hue.AbsoluteSize.X
if width <= 0 then
return
end
self._h = math.clamp((position.X - self._hue.AbsolutePosition.X) / width, 0, 1)
else
return
end
self:_commit()
end
function ColorPicker:_commit()
local color = Color3.fromHSV(self._h, self._s, self._v)
self.Value = color
self:_render(false)
self:_emit(color)
end
function ColorPicker:_render(animated)
self._swatch.BackgroundColor3 = self.Value
self._sv.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
self._cursor.Position = UDim2.fromScale(self._s, 1 - self._v)
self._hueKnob.Position = UDim2.fromScale(self._h, 0.5)
if not self._hex:IsFocused() then
self._hex.Text = toHex(self.Value)
end
end
function ColorPicker:SetOpen(open)
open = not not open
if open == self._open then
return
end
self._open = open
local height = HEADER_HEIGHT + (open and PICKER_HEIGHT or 0)
self:_play(self.Frame, { Size = UDim2.new(1, 0, 0, height) }, true, "Expand")
end
function ColorPicker:Set(color, silent)
if typeof(color) ~= "Color3" then
return
end
if color == self.Value then
return
end
self._h, self._s, self._v = color:ToHSV()
self.Value = color
self:_render(false)
if not silent then
self:_emit(color)
end
end
function ColorPicker:Serialize()
return { self.Value.R, self.Value.G, self.Value.B }
end
function ColorPicker:Deserialize(value)
if type(value) == "table" and #value == 3 then
self:Set(Color3.new(value[1], value[2], value[3]))
end
end
return ColorPicker
end
__functions[__n_Components_Dropdown] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Maid = require(script.Parent.Parent.Utilities.Maid)
local Dropdown = setmetatable({}, { __index = Base })
Dropdown.__index = Dropdown
local HEADER_HEIGHT = 26
local OPTION_HEIGHT = 22
local MAX_VISIBLE = 7
local SEARCH_HEIGHT = 26
function Dropdown.new(ctx, parent, options, _module)
assert(type(options.Options) == "table", "[ClickGUI] Dropdown needs an `Options` table")
local self = setmetatable(Base.new(ctx, parent, options.Name, HEADER_HEIGHT), Dropdown)
local theme = self._theme
self._callback = options.Callback
self._multi = options.Multi == true
self._searchable = options.Searchable == true
self._options = table.clone(options.Options)
self._open = false
self._visibleCount = #self._options
self._optionMaid = Maid.new()
self._maid:Give(self._optionMaid)
self._buttons = {}
self.Frame.ClipsDescendants = true
self._header = Create("TextButton", {
Name = "Header",
Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.corner(self._header, 6)
theme:Bind(self._header, "BackgroundColor3", "Element")
self:_label({
Name = "Label",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(0.5, -8, 1, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self._header,
})
self._valueLabel = Create("TextLabel", {
Name = "Value",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -22, 0, 0),
Size = UDim2.new(0.5, -24, 1, 0),
TextXAlignment = Enum.TextXAlignment.Right,
TextTruncate = Enum.TextTruncate.AtEnd,
TextColor3 = theme:Get("Accent"),
Font = theme:Get("Font"),
Parent = self._header,
})
theme:Bind(self._valueLabel, "TextColor3", "Accent")
self._arrow = Create("TextLabel", {
Name = "Arrow",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -6, 0.5, 0),
Size = UDim2.fromOffset(12, 12),
Text = "›",
TextSize = 16,
TextColor3 = theme:Get("TextDim"),
Parent = self._header,
})
theme:Bind(self._arrow, "TextColor3", "TextDim")
if self._searchable then
local box = Create("Frame", {
Name = "SearchBox",
Position = UDim2.fromOffset(0, HEADER_HEIGHT + 2),
Size = UDim2.new(1, 0, 0, SEARCH_HEIGHT - 4),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.corner(box, 5)
theme:Bind(box, "BackgroundColor3", "Element")
self._search = Create("TextBox", {
Name = "Search",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(1, -16, 1, 0),
PlaceholderText = "Search...",
PlaceholderColor3 = theme:Get("TextDim"),
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
TextXAlignment = Enum.TextXAlignment.Left,
Active = true,
Parent = box,
})
theme:Bind(self._search, "TextColor3", "Text")
theme:Bind(self._search, "PlaceholderColor3", "TextDim")
self._maid:Give(self._search:GetPropertyChangedSignal("Text"):Connect(function()
self:_filter(self._search.Text)
end))
end
self._list = Create("ScrollingFrame", {
Name = "Options",
Position = UDim2.fromOffset(0, self:_listTop()),
Size = UDim2.new(1, 0, 0, 0),
ScrollBarThickness = 2,
ClipsDescendants = true,
Parent = self.Frame,
})
Create.list(self._list, 0)
self._maid:Give(self._header.MouseButton1Click:Connect(function()
self:SetOpen(not self._open)
end))
self:_onTheme(function()
self:_refreshOptions(true)
end)
self.Value = self._multi and {} or self._options[1]
if options.Default ~= nil then
self:Set(options.Default, true)
end
self:_buildOptions()
self:_renderValue()
return self
end
Dropdown._chipCenter = true
Dropdown._chipOffset = 4
Dropdown._keyAction = function(self)
if self._multi or #self._options == 0 then
return
end
local index = table.find(self._options, self.Value) or 0
self:Set(self._options[index % #self._options + 1])
end
function Dropdown:_listTop()
return HEADER_HEIGHT + 2 + (self._searchable and SEARCH_HEIGHT or 0)
end
function Dropdown:_listHeight()
return math.min(self._visibleCount, MAX_VISIBLE) * OPTION_HEIGHT
end
function Dropdown:_isSelected(option)
if self._multi then
return table.find(self.Value, option) ~= nil
end
return self.Value == option
end
function Dropdown:_filter(query)
query = string.lower(query or "")
local count = 0
for option, parts in self._buttons do
local visible = query == "" or string.find(string.lower(option), query, 1, true) ~= nil
parts.Button.Visible = visible
if visible then
count += 1
end
end
self._visibleCount = count
if self._open then
self:_applyHeight(false)
end
end
function Dropdown:_buildOptions()
self._optionMaid:Clean()
for _, parts in self._buttons do
parts.Button:Destroy()
end
self._buttons = {}
for index, option in self._options do
local button = Create("TextButton", {
Name = "Option_" .. option,
Size = UDim2.new(1, 0, 0, OPTION_HEIGHT),
LayoutOrder = index,
Parent = self._list,
})
local label = Create("TextLabel", {
Name = "Label",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(1, -30, 1, 0),
Text = option,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Font = self._theme:Get("Font"),
Parent = button,
})
local dot = Create("Frame", {
Name = "Dot",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.fromOffset(8, 8),
Parent = button,
})
if self._multi then
Create.corner(dot, 2)
else
Create.pill(dot)
end
local stroke = Create.stroke(dot, self._theme:Get("Stroke"), 1)
self._buttons[option] = { Button = button, Label = label, Dot = dot, Stroke = stroke }
self._optionMaid:Give(button.MouseButton1Click:Connect(function()
self:_pick(option)
end))
self._optionMaid:Give(button.MouseEnter:Connect(function()
label.TextColor3 = self._theme:Get("Text")
end))
self._optionMaid:Give(button.MouseLeave:Connect(function()
self:_refreshOptions(false)
end))
end
self._visibleCount = #self._options
self:_refreshOptions(false)
if self._search then
self:_filter(self._search.Text)
end
if self._open then
self:_applyHeight(false)
end
end
function Dropdown:_refreshOptions(animated)
local theme = self._theme
for option, parts in self._buttons do
local selected = self:_isSelected(option)
parts.Label.TextColor3 = selected and theme:Get("Text") or theme:Get("TextDim")
parts.Dot.BackgroundColor3 = selected and theme:Get("Accent") or theme:Get("Element")
parts.Stroke.Color = selected and theme:Get("Accent") or theme:Get("Stroke")
end
end
function Dropdown:_renderValue()
if self._multi then
self._valueLabel.Text = #self.Value > 0 and table.concat(self.Value, ", ") or "None"
else
self._valueLabel.Text = tostring(self.Value or "None")
end
end
function Dropdown:_applyHeight(animated)
local listHeight = self._open and self:_listHeight() or 0
local extra = self._searchable and SEARCH_HEIGHT or 0
local total = HEADER_HEIGHT + (self._open and (extra + listHeight + 4) or 0)
self:_play(self.Frame, { Size = UDim2.new(1, 0, 0, total) }, animated, "Expand")
self:_play(self._list, { Size = UDim2.new(1, 0, 0, listHeight) }, animated, "Expand")
self:_play(self._arrow, { Rotation = self._open and 90 or 0 }, animated, "Expand")
end
function Dropdown:SetOpen(open)
open = not not open
if open == self._open then
return
end
self._open = open
self:_applyHeight(true)
end
function Dropdown:_pick(option)
if self._multi then
local selected = table.clone(self.Value)
local index = table.find(selected, option)
if index then
table.remove(selected, index)
else
table.insert(selected, option)
end
self:Set(selected)
else
self:Set(option)
self:SetOpen(false)
end
end
function Dropdown:Set(value, silent)
if self._multi then
if type(value) == "string" then
value = { value }
end
if type(value) ~= "table" then
return
end
local filtered = {}
for _, option in self._options do
if table.find(value, option) then
table.insert(filtered, option)
end
end
self.Value = filtered
else
if type(value) == "table" then
value = value[1]
end
if table.find(self._options, value) == nil or value == self.Value then
return
end
self.Value = value
end
self:_refreshOptions(true)
self:_renderValue()
if not silent then
self:_emit(self._multi and table.clone(self.Value) or self.Value)
end
end
function Dropdown:SetOptions(newOptions)
self._options = table.clone(newOptions)
if self._multi then
local filtered = {}
for _, option in self._options do
if table.find(self.Value, option) then
table.insert(filtered, option)
end
end
self.Value = filtered
elseif table.find(self._options, self.Value) == nil then
self.Value = self._options[1]
end
self:_buildOptions()
self:_renderValue()
end
function Dropdown:Get()
if self._multi then
return table.clone(self.Value)
end
return self.Value
end
return Dropdown
end
__functions[__n_Components_Graphic] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Base = require(script.Parent.Base)
local ColorPicker = require(script.Parent.ColorPicker)
local Create = require(script.Parent.Parent.Utilities.Create)
local AnimationManager = require(script.Parent.Parent.Core.AnimationManager)
local Graphic = setmetatable({}, { __index = Base })
Graphic.__index = Graphic
local HEADER_HEIGHT = 24
local BODY_HEIGHT = 150
local BAR_Y = 6
local BAR_HEIGHT = 84
local STRIP_Y = BAR_Y + BAR_HEIGHT + 2
local STRIP_HEIGHT = 24
local CURVE_Y = 6
local CURVE_HEIGHT = 112
local INFO_Y = 124
local INFO_HEIGHT = 22
local PICKER_ROW_HEIGHT = 24
local PLOT_INSET = 8
local MAX_KEYPOINTS = 20
local GAP = 0.004
local MERGE = GAP / 2
local COLUMNS = 96
local MINI_COLUMNS = 12
local WHITE = Color3.new(1, 1, 1)
local function round(value)
return math.floor(value * 10000 + 0.5) / 10000
end
local function normalize(points, maxPoints)
table.sort(points, function(a, b)
return a.T < b.T
end)
local out = {}
for _, point in points do
point.T = math.clamp(point.T, 0, 1)
local last = out[#out]
if not last or point.T - last.T >= MERGE then
table.insert(out, point)
end
end
if #out == 0 then
return out
end
local head = out[1]
if head.T < MERGE then
head.T = 0
else
table.insert(out, 1, { T = 0, C = head.C, V = head.V })
end
local tail = out[#out]
if 1 - tail.T < MERGE then
tail.T = 1
else
table.insert(out, { T = 1, C = tail.C, V = tail.V })
end
while #out > maxPoints do
table.remove(out, (#out - 1))
end
return out
end
local function sampleColor(points, t)
local count = #points
if t <= points[1].T then
return points[1].C
end
if t >= points[count].T then
return points[count].C
end
for index = 1, count - 1 do
local a, b = points[index], points[index + 1]
if t <= b.T then
return a.C:Lerp(b.C, (t - a.T) / (b.T - a.T))
end
end
return points[count].C
end
local function computeTangents(points)
local count = #points
local tangents = table.create(count, 0)
if count < 2 then
return tangents
end
local spans, deltas = {}, {}
for index = 1, count - 1 do
local span = points[index + 1].T - points[index].T
spans[index] = span
deltas[index] = (points[index + 1].V - points[index].V) / span
end
tangents[1] = deltas[1]
tangents[count] = deltas[count - 1]
for index = 2, count - 1 do
local before, after = deltas[index - 1], deltas[index]
if before * after <= 0 then
tangents[index] = 0
else
local h0, h1 = spans[index - 1], spans[index]
tangents[index] = 3 * (h0 + h1) / ((2 * h1 + h0) / before + (h1 + 2 * h0) / after)
end
end
return tangents
end
local function evaluate(points, tangents, t, smooth)
local count = #points
if t <= points[1].T then
return points[1].V
end
if t >= points[count].T then
return points[count].V
end
local index = 1
while index < count - 1 and t > points[index + 1].T do
index += 1
end
local a, b = points[index], points[index + 1]
local span = b.T - a.T
local u = (t - a.T) / span
if not smooth then
return a.V + (b.V - a.V) * u
end
local u2 = u * u
local u3 = u2 * u
local result = (2 * u3 - 3 * u2 + 1) * a.V
+ (u3 - 2 * u2 + u) * span * tangents[index]
+ (-2 * u3 + 3 * u2) * b.V
+ (u3 - u2) * span * tangents[index + 1]
return math.clamp(result, 0, 1)
end
local function createGradientHandle(parent)
local root = Create("Frame", {
Name = "Marker",
AnchorPoint = Vector2.new(0.5, 0),
Size = UDim2.fromOffset(12, 20),
BackgroundTransparency = 1,
Parent = parent,
})
Create("Frame", {
Name = "Stem",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.fromScale(0.5, 0),
Size = UDim2.fromOffset(2, 6),
BackgroundColor3 = WHITE,
Parent = root,
})
local body = Create("Frame", {
Name = "Body",
Position = UDim2.fromOffset(0, 5),
Size = UDim2.fromOffset(12, 15),
BackgroundColor3 = WHITE,
Parent = root,
})
Create.corner(body, 3)
local stroke = Create.stroke(body, WHITE, 1)
return { Root = root, Body = body, Stroke = stroke }
end
local function createCurveHandle(parent)
local root = Create("Frame", {
Name = "Point",
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(10, 10),
BackgroundColor3 = WHITE,
ZIndex = 4,
Parent = parent,
})
Create.pill(root)
local stroke = Create.stroke(root, WHITE, 2)
return { Root = root, Stroke = stroke }
end
function Graphic.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, HEADER_HEIGHT), Graphic)
local theme = self._theme
local requested = type(options.Mode) == "string" and string.lower(options.Mode) or "gradient"
if requested ~= "gradient" and requested ~= "curve" then
warn(`[ClickGUI] Graphic "{options.Name}" has an unknown Mode "{tostring(options.Mode)}", using Gradient`)
requested = "gradient"
end
self._mode = requested == "curve" and "Curve" or "Gradient"
self._isCurve = self._mode == "Curve"
self._callback = options.Callback
self._smooth = options.Smooth ~= false
self._maxPoints =
math.clamp(math.floor(tonumber(options.MaxPoints) or (self._isCurve and 8 or MAX_KEYPOINTS)), 2, MAX_KEYPOINTS)
self._open = false
self._animating = false
self._animToken = 0
self._drag = nil
self._hovered = false
self._tangents = {}
self._columns = {}
self._mini = {}
self._grid = {}
self._handles = {}
self._buttons = {}
self.Frame.ClipsDescendants = true
local points
if options.Default ~= nil then
points = self:_prepare(self:_parse(options.Default))
if not points then
warn(`[ClickGUI] Graphic "{options.Name}" received an invalid Default for mode {self._mode}`)
end
end
if not points then
if self._isCurve then
points = { { T = 0, V = 0 }, { T = 1, V = 1 } }
else
points = { { T = 0, C = theme:Get("Accent") }, { T = 1, C = theme:Get("AccentDark") } }
end
end
self._points = points
self._selected = points[1]
local header =
Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, HEADER_HEIGHT), Parent = self.Frame })
self:_label({
Name = "Label",
Position = UDim2.fromOffset(2, 0),
Size = UDim2.new(1, -44, 1, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = header,
})
self._swatch = Create("Frame", {
Name = "Preview",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -2, 0.5, 0),
Size = UDim2.fromOffset(30, 14),
BackgroundColor3 = self._isCurve and theme:Get("Element") or WHITE,
Parent = header,
})
Create.corner(self._swatch, 4)
local swatchStroke = Create.stroke(self._swatch, theme:Get("Stroke"), 1)
theme:Bind(swatchStroke, "Color", "Stroke")
if self._isCurve then
theme:Bind(self._swatch, "BackgroundColor3", "Element")
local mini = Create("Frame", {
Name = "Mini",
Position = UDim2.fromOffset(3, 2),
Size = UDim2.new(1, -6, 1, -4),
BackgroundTransparency = 1,
ClipsDescendants = true,
Parent = self._swatch,
})
for index = 1, MINI_COLUMNS do
self._mini[index] = Create("Frame", {
Name = "Bar",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new((index - 1) / MINI_COLUMNS, 0, 1, 0),
Size = UDim2.new(1 / MINI_COLUMNS, 0, 0, 1),
BackgroundColor3 = theme:Get("Accent"),
Parent = mini,
})
end
else
self._swatchGradient = Create("UIGradient", { Parent = self._swatch })
end
self._content = Create("Frame", {
Name = "Content",
Position = UDim2.fromOffset(0, HEADER_HEIGHT),
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = self.Frame,
})
Create.list(self._content, 0)
self._body = Create("Frame", {
Name = "Body",
Size = UDim2.new(1, 0, 0, BODY_HEIGHT),
BackgroundTransparency = 1,
LayoutOrder = 1,
Parent = self._content,
})
if self._isCurve then
self:_buildCurve()
else
self:_buildGradient()
end
self:_buildInfo()
if not self._isCurve then
self._picker = ColorPicker.new(ctx, self._content, {
Name = "Point Color",
Default = self._selected.C,
Callback = function(color)
self:_onPickerChanged(color)
end,
}, nil)
self._picker.Frame.LayoutOrder = 2
self._maid:Give(function()
self._picker:Destroy()
end)
local pickerHeader = self._picker.Frame:FindFirstChild("Header")
self._pickerLabel = pickerHeader and pickerHeader:FindFirstChild("Label")
end
self._maid:Give(header.MouseButton1Click:Connect(function()
self:SetOpen(not self._open)
end))
self._maid:Give(self._hit.InputBegan:Connect(function(input)
self:_begin(input)
end))
self._maid:Give(self._hit.MouseEnter:Connect(function()
self._hovered = true
end))
self._maid:Give(self._hit.MouseLeave:Connect(function()
self._hovered = false
end))
self._maid:Give(UserInputService.InputChanged:Connect(function(input)
local drag = self._drag
if not drag then
return
end
if
input.UserInputType == Enum.UserInputType.MouseMovement
or (input.UserInputType == Enum.UserInputType.Touch and input == drag.Input)
then
self:_dragTo(input.Position)
end
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input)
local drag = self._drag
if not drag then
return
end
local sameTouch = input.UserInputType == Enum.UserInputType.Touch and input == drag.Input
local sameMouse = input.UserInputType == Enum.UserInputType.MouseButton1
and drag.Input.UserInputType == Enum.UserInputType.MouseButton1
if sameTouch or sameMouse then
self._drag = nil
self:_lockScroll(false)
if not drag.Moved and self._picker and self._open then
self._picker:SetOpen(true)
end
end
end))
self._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
if processed or not self._hovered or self._enabledState == false then
return
end
if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Backspace then
self:_remove(self._selected)
end
end))
self._maid:Give(self._content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
self:_updateHeight(self._animating)
end))
self:_onTheme(function()
self:_applyTheme()
self:_renderButtons(true)
self:_render(true)
end)
self:_applyTheme()
self:_rebuild()
self:_render()
if options.Expanded then
task.defer(function()
if not self._destroyed then
self:SetOpen(true)
end
end)
end
return self
end
function Graphic:_buildGradient()
local theme = self._theme
self._bar = Create("Frame", {
Name = "Bar",
Position = UDim2.fromOffset(PLOT_INSET, BAR_Y),
Size = UDim2.new(1, -PLOT_INSET * 2, 0, BAR_HEIGHT),
BackgroundColor3 = WHITE,
Parent = self._body,
})
Create.corner(self._bar, 5)
local stroke = Create.stroke(self._bar, theme:Get("Stroke"), 1)
theme:Bind(stroke, "Color", "Stroke")
self._barGradient = Create("UIGradient", { Parent = self._bar })
self._strip = Create("Frame", {
Name = "Markers",
Position = UDim2.fromOffset(PLOT_INSET, STRIP_Y),
Size = UDim2.new(1, -PLOT_INSET * 2, 0, STRIP_HEIGHT),
BackgroundTransparency = 1,
Parent = self._body,
})
self._area = self._bar
self._hit = Create("TextButton", {
Name = "Hit",
Position = UDim2.fromOffset(0, BAR_Y),
Size = UDim2.new(1, 0, 0, BAR_HEIGHT + 2 + STRIP_HEIGHT),
ZIndex = 6,
Parent = self._body,
})
end
function Graphic:_buildCurve()
local theme = self._theme
self._panel = Create("Frame", {
Name = "Panel",
Position = UDim2.fromOffset(2, CURVE_Y),
Size = UDim2.new(1, -4, 0, CURVE_HEIGHT),
BackgroundColor3 = theme:Get("Element"),
ClipsDescendants = true,
Parent = self._body,
})
Create.corner(self._panel, 5)
theme:Bind(self._panel, "BackgroundColor3", "Element")
self._plot = Create("Frame", {
Name = "Plot",
Position = UDim2.fromOffset(PLOT_INSET, PLOT_INSET),
Size = UDim2.new(1, -PLOT_INSET * 2, 1, -PLOT_INSET * 2),
BackgroundTransparency = 1,
Parent = self._panel,
})
for step = 0, 4 do
local alpha = step / 4
local horizontal = Create("Frame", {
Name = "GridH",
AnchorPoint = Vector2.new(0, alpha),
Position = UDim2.fromScale(0, alpha),
Size = UDim2.new(1, 0, 0, 1),
BackgroundColor3 = theme:Get("Stroke"),
BackgroundTransparency = 0.45,
Parent = self._plot,
})
theme:Bind(horizontal, "BackgroundColor3", "Stroke")
local vertical = Create("Frame", {
Name = "GridV",
AnchorPoint = Vector2.new(alpha, 0),
Position = UDim2.fromScale(alpha, 0),
Size = UDim2.new(0, 1, 1, 0),
BackgroundColor3 = theme:Get("Stroke"),
BackgroundTransparency = 0.45,
Parent = self._plot,
})
theme:Bind(vertical, "BackgroundColor3", "Stroke")
end
for index = 1, COLUMNS do
local fill = Create("Frame", {
Name = "Fill",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new((index - 1) / COLUMNS, 0, 1, 0),
Size = UDim2.new(1 / COLUMNS, 1, 0, 0),
BackgroundColor3 = theme:Get("Accent"),
BackgroundTransparency = 0.82,
ZIndex = 1,
Parent = self._plot,
})
local cap = Create("Frame", {
Name = "Line",
Position = UDim2.new((index - 1) / COLUMNS, 0, 1, -1),
Size = UDim2.new(1 / COLUMNS, 1, 0, 2),
BackgroundColor3 = theme:Get("Accent"),
ZIndex = 2,
Parent = self._plot,
})
self._columns[index] = { Fill = fill, Cap = cap }
end
self._area = self._plot
self._hit = Create("TextButton", {
Name = "Hit",
Size = UDim2.fromScale(1, 1),
ZIndex = 6,
Parent = self._panel,
})
end
function Graphic:_numberBox(parent, order, prefix, onCommit)
local theme = self._theme
local cell = Create("Frame", {
Name = prefix,
Size = UDim2.new(1 / 3, -3, 1, 0),
BackgroundColor3 = theme:Get("Element"),
LayoutOrder = order,
Parent = parent,
})
Create.corner(cell, 5)
theme:Bind(cell, "BackgroundColor3", "Element")
local stroke = Create.stroke(cell, theme:Get("Stroke"), 1, 1)
local tag = Create("TextLabel", {
Name = "Prefix",
Position = UDim2.fromOffset(7, 0),
Size = UDim2.new(0, 24, 1, 0),
Text = prefix,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
TextColor3 = theme:Get("TextDim"),
Font = theme:Get("Font"),
Parent = cell,
})
theme:Bind(tag, "TextColor3", "TextDim")
theme:Bind(tag, "Font", "Font")
local box = Create("TextBox", {
Name = "Box",
Position = UDim2.fromOffset(30, 0),
Size = UDim2.new(1, -36, 1, 0),
TextXAlignment = Enum.TextXAlignment.Right,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
ClipsDescendants = true,
Active = true,
Parent = cell,
})
theme:Bind(box, "TextColor3", "Text")
theme:Bind(box, "Font", "Font")
self._maid:Give(box.Focused:Connect(function()
AnimationManager.Play(stroke, "Fast", { Color = theme:Get("Accent"), Transparency = 0 })
end))
self._maid:Give(box.FocusLost:Connect(function()
AnimationManager.Play(stroke, "Fast", { Transparency = 1 })
local number = tonumber(string.match(box.Text, "%-?%d+%.?%d*"))
if number then
onCommit(number)
end
self:_render(true)
end))
return box
end
function Graphic:_actionButton(parent, order, text, callback)
local theme = self._theme
local button = Create("TextButton", {
Name = text,
Size = UDim2.new(1 / 3, -3, 1, 0),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = text,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
LayoutOrder = order,
Parent = parent,
})
Create.corner(button, 5)
theme:Bind(button, "TextColor3", "Text")
theme:Bind(button, "Font", "Font")
local entry = { Button = button, Hovered = false }
table.insert(self._buttons, entry)
self._maid:Give(button.MouseEnter:Connect(function()
entry.Hovered = true
self:_renderButtons(true)
end))
self._maid:Give(button.MouseLeave:Connect(function()
entry.Hovered = false
self:_renderButtons(true)
end))
self._maid:Give(button.MouseButton1Click:Connect(callback))
return button
end
function Graphic:_buildInfo()
local row = Create("Frame", {
Name = "Info",
Position = UDim2.fromOffset(2, INFO_Y),
Size = UDim2.new(1, -4, 0, INFO_HEIGHT),
BackgroundTransparency = 1,
Parent = self._body,
})
Create.list(row, 4, true)
self._timeBox = self:_numberBox(row, 1, "Pos", function(number)
self:_move(self._selected, number / 100, nil)
end)
if self._isCurve then
self._valueBox = self:_numberBox(row, 2, "Val", function(number)
self:_move(self._selected, self._selected.T, number)
end)
self._deleteButton = self:_actionButton(row, 3, "Delete", function()
self:_remove(self._selected)
end)
else
self._deleteButton = self:_actionButton(row, 2, "Delete", function()
self:_remove(self._selected)
end)
self:_actionButton(row, 3, "Reverse", function()
self:Reverse()
end)
end
end
function Graphic:_parse(value)
if self._mode == "Gradient" then
if typeof(value) == "ColorSequence" then
local points = {}
for _, keypoint in value.Keypoints do
table.insert(points, { T = keypoint.Time, C = keypoint.Value })
end
return points
elseif typeof(value) == "Color3" then
return { { T = 0, C = value }, { T = 1, C = value } }
end
else
if typeof(value) == "NumberSequence" then
local points = {}
for _, keypoint in value.Keypoints do
table.insert(points, { T = keypoint.Time, V = math.clamp(keypoint.Value, 0, 1) })
end
return points
elseif type(value) == "number" then
local flat = math.clamp(value, 0, 1)
return { { T = 0, V = flat }, { T = 1, V = flat } }
end
end
if type(value) ~= "table" then
return nil
end
if value.Mode ~= nil and value.Mode ~= self._mode then
return nil
end
local list = value.Points or value
if type(list) ~= "table" then
return nil
end
local points = {}
for _, entry in list do
if type(entry) == "table" and type(entry[1]) == "number" then
if self._mode == "Gradient" then
if type(entry[2]) == "number" and type(entry[3]) == "number" and type(entry[4]) == "number" then
table.insert(points, {
T = entry[1],
C = Color3.new(math.clamp(entry[2], 0, 1), math.clamp(entry[3], 0, 1), math.clamp(entry[4], 0, 1)),
})
end
elseif type(entry[2]) == "number" then
table.insert(points, { T = entry[1], V = math.clamp(entry[2], 0, 1) })
end
end
end
return points
end
function Graphic:_prepare(points)
if type(points) ~= "table" or #points == 0 then
return nil
end
local limit = math.max(self._maxPoints, math.min(#points, MAX_KEYPOINTS))
self._maxPoints = limit
local result = normalize(points, limit)
if #result < 2 then
return nil
end
return result
end
function Graphic:_valueAt(t)
return evaluate(self._points, self._tangents, t, self._smooth)
end
function Graphic:_colorSequence()
local keypoints = {}
for index, point in self._points do
keypoints[index] = ColorSequenceKeypoint.new(point.T, point.C)
end
return ColorSequence.new(keypoints)
end
function Graphic:_numberSequence()
local points = self._points
local samples = {}
for _, point in points do
table.insert(samples, { T = point.T, V = point.V })
end
local budget = MAX_KEYPOINTS - #points
if self._smooth and #points >= 3 and budget > 0 then
local segments = #points - 1
local accumulated, used = 0, 0
for index = 1, segments do
local a, b = points[index], points[index + 1]
accumulated += budget * (b.T - a.T)
local count = math.floor(accumulated + 0.5) - used
used += count
for step = 1, count do
local t = a.T + (b.T - a.T) * step / (count + 1)
table.insert(samples, { T = t, V = self:_valueAt(t) })
end
end
table.sort(samples, function(a, b)
return a.T < b.T
end)
end
local keypoints = {}
for index, sample in samples do
keypoints[index] = NumberSequenceKeypoint.new(sample.T, math.clamp(sample.V, 0, 1))
end
return NumberSequence.new(keypoints)
end
function Graphic:_rebuild()
if self._isCurve then
self._tangents = computeTangents(self._points)
self.Value = self:_numberSequence()
else
self.Value = self:_colorSequence()
end
end
function Graphic:_applyTheme()
if not self._isCurve then
return
end
local accent = self._theme:Get("Accent")
for _, column in self._columns do
column.Fill.BackgroundColor3 = accent
column.Cap.BackgroundColor3 = accent
end
for _, bar in self._mini do
bar.BackgroundColor3 = accent
end
end
function Graphic:_syncHandles()
local handles = self._handles
local parent = self._isCurve and self._plot or self._strip
while #handles < #self._points do
table.insert(handles, self._isCurve and createCurveHandle(parent) or createGradientHandle(parent))
end
while #handles > #self._points do
local handle = table.remove(handles)
handle.Root:Destroy()
end
end
function Graphic:_renderButtons(animated)
local theme = self._theme
for _, entry in self._buttons do
self:_play(
entry.Button,
{ BackgroundColor3 = entry.Hovered and theme:Get("ElementHover") or theme:Get("Element") },
animated
)
end
end
function Graphic:_renderInfo()
local points = self._points
local point = self._selected
local index = table.find(points, point)
local interior = index ~= nil and index > 1 and index < #points
if not self._timeBox:IsFocused() then
self._timeBox.Text = string.format("%.1f%%", point.T * 100)
end
self._timeBox.TextEditable = interior
if self._valueBox and not self._valueBox:IsFocused() then
self._valueBox.Text = string.format("%.3f", point.V)
end
self._deleteButton.TextTransparency = interior and 0.0 or 0.55
end
function Graphic:_render(skipPicker)
local theme = self._theme
local accent = theme:Get("Accent")
self:_syncHandles()
local points = self._points
if self._isCurve then
local previous = self:_valueAt(0)
for index = 1, COLUMNS do
local nextValue = self:_valueAt(index / COLUMNS)
local top = math.max(previous, nextValue)
local bottom = math.min(previous, nextValue)
local column = self._columns[index]
column.Fill.Size = UDim2.new(1 / COLUMNS, 1, (previous + nextValue) / 2, 0)
column.Cap.Position = UDim2.new((index - 1) / COLUMNS, 0, 1 - top, -1)
column.Cap.Size = UDim2.new(1 / COLUMNS, 1, top - bottom, 2)
previous = nextValue
end
for index, bar in self._mini do
bar.Size = UDim2.new(1 / MINI_COLUMNS, 0, self:_valueAt((index - 0.5) / MINI_COLUMNS), 1)
end
for index, point in points do
local handle = self._handles[index]
local selected = point == self._selected
handle.Root.Position = UDim2.fromScale(point.T, 1 - point.V)
handle.Root.BackgroundColor3 = selected and accent or WHITE
handle.Root.ZIndex = selected and 5 or 4
handle.Stroke.Color = selected and WHITE or accent
end
else
self._barGradient.Color = self.Value
self._swatchGradient.Color = self.Value
for index, point in points do
local handle = self._handles[index]
local selected = point == self._selected
handle.Root.Position = UDim2.new(point.T, 0, 0, 0)
handle.Root.ZIndex = selected and 3 or 2
handle.Body.BackgroundColor3 = point.C
handle.Stroke.Color = selected and accent or WHITE
handle.Stroke.Thickness = selected and 2 or 1
end
if self._picker then
if not skipPicker then
self._picker:Set(self._selected.C, true)
end
if self._pickerLabel then
local index = table.find(points, self._selected) or 1
self._pickerLabel.Text = string.format("Point %d  (%.0f%%)", index, self._selected.T * 100)
end
end
end
self:_renderInfo()
end
function Graphic:_commit(skipPicker)
self:_rebuild()
self:_render(skipPicker)
self:_emit(self.Value)
end
function Graphic:_onPickerChanged(color)
self._selected.C = color
self:_commit(true)
end
function Graphic:_locate(position)
local area = self._area
local size = area.AbsoluteSize
if size.X <= 0 or size.Y <= 0 then
return nil
end
local origin = area.AbsolutePosition
return math.clamp((position.X - origin.X) / size.X, 0, 1), (position.Y - origin.Y) / size.Y, size
end
function Graphic:_nearest(ax, ay, size)
local scale = math.max(self._ctx.GetScale(), 0.01)
local radius = (UserInputService.TouchEnabled and 16 or 10) * scale
local best, bestDistance = nil, nil
for _, point in self._points do
local dx = (point.T - ax) * size.X
local distance = math.abs(dx)
if self._isCurve then
local dy = ((1 - point.V) - ay) * size.Y
distance = math.sqrt(dx * dx + dy * dy)
end
if distance <= radius and (bestDistance == nil or distance < bestDistance) then
best, bestDistance = point, distance
end
end
return best
end
function Graphic:_add(t, v)
local points = self._points
if #points >= self._maxPoints then
return nil
end
local index = 1
while index < #points - 1 and points[index + 1].T <= t do
index += 1
end
local before, after = points[index], points[index + 1]
if after.T - before.T < GAP * 2 then
return nil
end
t = math.clamp(t, before.T + GAP, after.T - GAP)
local point
if self._isCurve then
point = { T = t, V = math.clamp(v or self:_valueAt(t), 0, 1) }
else
point = { T = t, C = sampleColor(points, t) }
end
table.insert(points, index + 1, point)
return point
end
function Graphic:_remove(point)
local points = self._points
local index = table.find(points, point)
if not index or index == 1 or index == #points or #points <= 2 then
return
end
table.remove(points, index)
if self._selected == point then
self._selected = points[index - 1]
end
self:_commit()
end
function Graphic:_move(point, t, v)
local points = self._points
local index = table.find(points, point)
if not index then
return
end
local changed = false
if index > 1 and index < #points then
t = math.clamp(t, points[index - 1].T + GAP, points[index + 1].T - GAP)
if t ~= point.T then
point.T = t
changed = true
end
end
if v ~= nil and self._isCurve then
v = math.clamp(v, 0, 1)
if v ~= point.V then
point.V = v
changed = true
end
end
if changed then
self:_commit(true)
end
end
function Graphic:_begin(input)
if self._enabledState == false then
return
end
local kind = input.UserInputType
if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.MouseButton2 and kind ~= Enum.UserInputType.Touch then
return
end
local ax, ay, size = self:_locate(input.Position)
if not ax then
return
end
local target = self:_nearest(ax, ay, size)
if kind == Enum.UserInputType.MouseButton2 then
if target then
self:_remove(target)
end
return
end
local offsetT, offsetV = 0, 0
if target then
offsetT = target.T - ax
if self._isCurve then
offsetV = target.V - (1 - ay)
end
self._selected = target
self:_render()
else
target = self:_add(ax, self._isCurve and (1 - ay) or nil)
if not target then
return
end
self._selected = target
self:_commit()
end
self._drag = { Point = target, Origin = input.Position, Moved = false, Input = input, OffsetT = offsetT, OffsetV = offsetV }
self:_lockScroll(true)
end
function Graphic:_dragTo(position)
local drag = self._drag
if not drag then
return
end
local scale = math.max(self._ctx.GetScale(), 0.01)
if not drag.Moved then
if (position - drag.Origin).Magnitude <= 3 * scale then
return
end
drag.Moved = true
end
local ax, ay = self:_locate(position)
if not ax then
return
end
self:_move(drag.Point, ax + drag.OffsetT, self._isCurve and ((1 - ay) + drag.OffsetV) or nil)
end
function Graphic:_updateHeight(animated)
if self._destroyed then
return
end
local height = HEADER_HEIGHT
if self._open then
local measured = self._content.AbsoluteSize.Y / math.max(self._ctx.GetScale(), 0.01)
if measured <= 0 then
measured = BODY_HEIGHT + (self._picker and PICKER_ROW_HEIGHT or 0)
end
height += measured
end
self:_play(self.Frame, { Size = UDim2.new(1, 0, 0, height) }, animated, "Expand")
end
function Graphic:SetOpen(open)
open = not not open
if open == self._open then
return
end
self._open = open
self._animating = true
self._animToken += 1
local token = self._animToken
task.delay(AnimationManager.Time(0.3), function()
if self._animToken == token then
self._animating = false
end
end)
self:_updateHeight(true)
end
function Graphic:Reverse()
if self._isCurve then
return
end
local reversed = {}
for index = #self._points, 1, -1 do
local point = self._points[index]
point.T = 1 - point.T
table.insert(reversed, point)
end
self._points = reversed
self:_commit()
end
function Graphic:Get()
return self.Value
end
function Graphic:Set(value, silent)
local points = self:_prepare(self:_parse(value))
if not points then
return
end
self._points = points
self._selected = points[1]
self:_rebuild()
self:_render()
if not silent then
self:_emit(self.Value)
end
end
function Graphic:Serialize()
local points = {}
for index, point in self._points do
if self._isCurve then
points[index] = { round(point.T), round(point.V) }
else
points[index] = { round(point.T), round(point.C.R), round(point.C.G), round(point.C.B) }
end
end
return { Mode = self._mode, Points = points }
end
function Graphic:Deserialize(value)
self:Set(value)
end
return Graphic
end
__functions[__n_Components_ImageButton] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local ImageButton = setmetatable({}, { __index = Base })
ImageButton.__index = ImageButton
function ImageButton.new(ctx, parent, options, _module)
assert(type(options.Image) == "string", "[ClickGUI] ImageButton needs an `Image` (rbxassetid://...)")
local self = setmetatable(Base.new(ctx, parent, options.Name, options.Height or 32), ImageButton)
local theme = self._theme
self._callback = options.Callback
self._image = options.Image
self._hoverImage = options.HoverImage
self._imageColor = options.ImageColor
self._hoverColor = options.HoverColor
self._hovered = false
local iconSize = options.ImageSize or 18
local hasText = options.Text ~= nil and options.Text ~= ""
self._button = Create("TextButton", {
Name = "Button",
Size = UDim2.fromScale(1, 1),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.corner(self._button, 6)
self._icon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = hasText and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
Position = hasText and UDim2.new(0, 10, 0.5, 0) or UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(iconSize, iconSize),
Image = self._image,
Parent = self._button,
})
if hasText then
local label = Create("TextLabel", {
Name = "Text",
Position = UDim2.fromOffset(iconSize + 18, 0),
Size = UDim2.new(1, -(iconSize + 24), 1, 0),
Text = options.Text,
TextXAlignment = Enum.TextXAlignment.Left,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Parent = self._button,
})
theme:Bind(label, "TextColor3", "Text")
end
self._maid:Give(self._button.MouseEnter:Connect(function()
self._hovered = true
self:_render(true)
end))
self._maid:Give(self._button.MouseLeave:Connect(function()
self._hovered = false
self:_render(true)
end))
self._maid:Give(self._button.MouseButton1Click:Connect(function()
self._button.BackgroundColor3 = theme:Get("Accent")
self:_render(true)
self:_emit()
end))
self:_onTheme(function()
self:_render(true)
end)
self:_render(false)
return self
end
ImageButton.NoPersist = true
ImageButton._chipOffset = 8
ImageButton._keyAction = function(self)
self:_emit()
end
function ImageButton:_render(animated)
local theme = self._theme
local hovered = self._hovered
self._icon.Image = (hovered and self._hoverImage) or self._image
self:_play(
self._button,
{ BackgroundColor3 = hovered and theme:Get("ElementHover") or theme:Get("Element") },
animated,
"Normal"
)
self:_play(self._icon, {
ImageColor3 = hovered and (self._hoverColor or theme:Get("Accent")) or (self._imageColor or theme:Get("Text")),
}, animated)
end
function ImageButton:SetImage(image, hoverImage)
self._image = image
self._hoverImage = hoverImage or self._hoverImage
self:_render(false)
end
function ImageButton:Fire()
self:_emit()
end
return ImageButton
end
__functions[__n_Components_InputNumber] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local InputNumber = setmetatable({}, { __index = Base })
InputNumber.__index = InputNumber
local function decimalsOf(step)
local text = string.format("%.6f", step):gsub("0+$", ""):gsub("%.$", "")
local dot = string.find(text, ".", 1, true)
return dot and (#text - dot) or 0
end
function InputNumber.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 26), InputNumber)
local theme = self._theme
self._callback = options.Callback
self._min = options.Min or -math.huge
self._max = options.Max or math.huge
self._step = (options.Increment and options.Increment > 0) and options.Increment or 1
self._decimals = math.clamp(options.Precision or decimalsOf(self._step), 0, 6)
self:_label({
Name = "Label",
Size = UDim2.new(1, -104, 1, 0),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
local group = Create("Frame", {
Name = "Group",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -2, 0.5, 0),
Size = UDim2.fromOffset(100, 22),
BackgroundTransparency = 1,
Parent = self.Frame,
})
local function makeButton(name, text, x)
local button = Create("TextButton", {
Name = name,
Position = UDim2.fromOffset(x, 0),
Size = UDim2.fromOffset(22, 22),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = text,
TextSize = 14,
TextColor3 = theme:Get("Text"),
Font = theme:Get("FontBold"),
Parent = group,
})
Create.corner(button, 5)
theme:Bind(button, "BackgroundColor3", "Element")
theme:Bind(button, "TextColor3", "Text")
return button
end
local minus = makeButton("Minus", "-", 0)
local plus = makeButton("Plus", "+", 78)
local boxBackground = Create("Frame", {
Name = "BoxBackground",
Position = UDim2.fromOffset(25, 0),
Size = UDim2.fromOffset(50, 22),
BackgroundColor3 = theme:Get("Element"),
Parent = group,
})
Create.corner(boxBackground, 5)
theme:Bind(boxBackground, "BackgroundColor3", "Element")
self._box = Create("TextBox", {
Name = "Box",
Size = UDim2.fromScale(1, 1),
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
ClipsDescendants = true,
Active = true,
Parent = boxBackground,
})
theme:Bind(self._box, "TextColor3", "Text")
self._maid:Give(minus.MouseButton1Click:Connect(function()
self:Set(self.Value - self._step)
end))
self._maid:Give(plus.MouseButton1Click:Connect(function()
self:Set(self.Value + self._step)
end))
self._maid:Give(self._box.FocusLost:Connect(function()
local number = tonumber(self._box.Text)
if number then
self:Set(number)
end
self:_render()
end))
self.Value = self:_clean(options.Default or math.max(self._min, 0))
self:_render()
return self
end
function InputNumber:_clean(value)
value = math.clamp(value, self._min, self._max)
return tonumber(string.format("%." .. self._decimals .. "f", value)) or value
end
function InputNumber:_render()
self._box.Text = string.format("%." .. self._decimals .. "f", self.Value)
end
function InputNumber:Set(value, silent)
if type(value) ~= "number" then
return
end
value = self:_clean(value)
if value == self.Value then
self:_render()
return
end
self.Value = value
self:_render()
if not silent then
self:_emit(value)
end
end
return InputNumber
end
__functions[__n_Components_Keybind] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local InputManager = require(script.Parent.Parent.Core.InputManager)
local Keybind = setmetatable({}, { __index = Base })
Keybind.__index = Keybind
function Keybind.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 24), Keybind)
local theme = self._theme
self._callback = options.Callback
self._onPressed = options.OnPressed
self._cancelCapture = nil
self.Value = options.Default
self:_label({
Name = "Label",
Size = UDim2.new(1, -66, 1, 0),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
self._button = Create("TextButton", {
Name = "Key",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -2, 0.5, 0),
Size = UDim2.fromOffset(58, 18),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
TextSize = 11,
Font = theme:Get("Font"),
Parent = self.Frame,
})
Create.corner(self._button, 4)
self._stroke = Create.stroke(self._button, theme:Get("Stroke"), 1)
self._binding = ctx.Input:BindKey(self.Value, function()
if self._onPressed then
local ok, err = pcall(self._onPressed)
if not ok then
warn(`[ClickGUI] OnPressed error in "{self.Name}": {err}`)
end
end
end)
self._maid:Give(self._binding)
self._maid:Give(self._button.MouseButton1Click:Connect(function()
if self._capturing then
ctx.Input:CancelCapture()
return
end
self:_beginCapture()
end))
self._maid:Give(function()
if self._capturing and self._cancelCapture then
self._cancelCapture()
end
end)
self:_onTheme(function()
self:_render(true)
end)
self:_render(false)
return self
end
function Keybind:_beginCapture()
self._capturing = true
self:_render(true)
self._cancelCapture = self._ctx.Input:Capture(function(key, cancelled)
self._capturing = false
self._cancelCapture = nil
if not cancelled then
self:Set(key)
end
if not self._destroyed then
self:_render(true)
end
end)
end
function Keybind:_render(animated)
local theme = self._theme
local capturing = self._capturing
self._button.Text = capturing and "..." or InputManager.KeyName(self.Value)
self:_play(self._button, {
BackgroundColor3 = theme:Get("Element"),
TextColor3 = (capturing or self.Value) and theme:Get("Accent") or theme:Get("TextDim"),
}, animated)
self:_play(self._stroke, { Color = capturing and theme:Get("Accent") or theme:Get("Stroke") }, animated)
end
function Keybind:Set(key, silent)
if type(key) == "string" then
key = Enum.KeyCode[key]
end
if key == Enum.KeyCode.Unknown then
key = nil
end
if key == self.Value then
return
end
self.Value = key
self._binding:SetKey(key)
self:_render(true)
if not silent then
self:_emit(key)
end
end
function Keybind:Serialize()
return self.Value and self.Value.Name or false
end
function Keybind:Deserialize(value)
if value == false or value == nil then
self:Set(nil)
elseif type(value) == "string" and Enum.KeyCode[value] then
self:Set(Enum.KeyCode[value])
end
end
return Keybind
end
__functions[__n_Components_KeybindList] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Maid = require(script.Parent.Parent.Utilities.Maid)
local InputManager = require(script.Parent.Parent.Core.InputManager)
local KeybindList = setmetatable({}, { __index = Base })
KeybindList.__index = KeybindList
function KeybindList.new(ctx, parent, options, _module)
options.Name = options.Name or "Keybinds"
local self = setmetatable(Base.new(ctx, parent, options.Name, options.Height or 170), KeybindList)
local theme = self._theme
self._filter = options.Filter
self._query = ""
self._rowMaid = Maid.new()
self._maid:Give(self._rowMaid)
local box = Create("Frame", {
Name = "SearchBox",
Size = UDim2.new(1, 0, 0, 22),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.corner(box, 5)
theme:Bind(box, "BackgroundColor3", "Element")
self._search = Create("TextBox", {
Name = "Search",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(1, -16, 1, 0),
PlaceholderText = "Filter keybinds...",
PlaceholderColor3 = theme:Get("TextDim"),
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
TextXAlignment = Enum.TextXAlignment.Left,
Active = true,
Parent = box,
})
theme:Bind(self._search, "TextColor3", "Text")
theme:Bind(self._search, "PlaceholderColor3", "TextDim")
self._scroll = Create("ScrollingFrame", {
Name = "Rows",
Position = UDim2.fromOffset(0, 26),
Size = UDim2.new(1, 0, 1, -26),
ScrollBarThickness = 2,
ScrollBarImageColor3 = theme:Get("Accent"),
Parent = self.Frame,
})
theme:Bind(self._scroll, "ScrollBarImageColor3", "Accent")
Create.list(self._scroll, 2)
self._maid:Give(self._search:GetPropertyChangedSignal("Text"):Connect(function()
self._query = string.lower(self._search.Text)
self:Refresh()
end))
local window = ctx.Window
self._maid:Give(window.ModulesChanged:Connect(function()
self:Refresh()
end))
self._maid:Give(window.Opened:Connect(function()
self:Refresh()
end))
task.defer(function()
if not self._destroyed then
self:Refresh()
end
end)
return self
end
KeybindList.NoPersist = true
function KeybindList:Refresh()
self._rowMaid:Clean()
for _, child in self._scroll:GetChildren() do
if child:IsA("Frame") then
child:Destroy()
end
end
local theme = self._theme
local order = 0
for _, module in self._ctx.Window.Modules do
local keybind = module.KeybindComponent
local listed = keybind ~= nil and (self._filter == nil or self._filter(module))
if listed and (self._query == "" or string.find(string.lower(module.Name), self._query, 1, true)) then
order += 1
local row = Create("Frame", {
Name = "Row_" .. module.Name,
Size = UDim2.new(1, 0, 0, 24),
BackgroundTransparency = 1,
LayoutOrder = order,
Parent = self._scroll,
})
local name = Create("TextLabel", {
Name = "Name",
Position = UDim2.fromOffset(2, 0),
Size = UDim2.new(1, -70, 1, 0),
Text = module.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Parent = row,
})
theme:Bind(name, "TextColor3", "Text")
local button = Create("TextButton", {
Name = "Key",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -4, 0.5, 0),
Size = UDim2.fromOffset(58, 18),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = InputManager.KeyName(keybind.Value),
TextSize = 11,
TextColor3 = theme:Get("Accent"),
Font = theme:Get("Font"),
Parent = row,
})
Create.corner(button, 4)
theme:Bind(button, "BackgroundColor3", "Element")
theme:Bind(button, "TextColor3", "Accent")
self._rowMaid:Give(keybind.Changed:Connect(function(key)
if button.Parent then
button.Text = InputManager.KeyName(key)
end
end))
self._rowMaid:Give(button.MouseButton1Click:Connect(function()
button.Text = "..."
self._ctx.Input:Capture(function(key, cancelled)
if not cancelled then
keybind:Set(key)
end
if button.Parent then
button.Text = InputManager.KeyName(keybind.Value)
end
end)
end))
end
end
end
return KeybindList
end
__functions[__n_Components_Label] = function(script, require)
local Base = require(script.Parent.Base)
local Label = setmetatable({}, { __index = Base })
Label.__index = Label
function Label.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name or "Label", 18), Label)
self.Frame.AutomaticSize = Enum.AutomaticSize.Y
self.Value = options.Text or ""
self._text = self:_label({
Name = "Text",
Size = UDim2.new(1, -4, 0, 0),
Position = UDim2.fromOffset(2, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Text = self.Value,
TextSize = 11,
TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
Parent = self.Frame,
})
self._theme:Bind(self._text, "TextColor3", "TextDim")
return self
end
Label.NoPersist = true
function Label:Set(text)
self.Value = tostring(text)
self._text.Text = self.Value
end
function Label:SetText(text)
self:Set(text)
end
return Label
end
__functions[__n_Components_ProgressBar] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Visual = require(script.Parent.Parent.Core.Visual)
local ProgressBar = setmetatable({}, { __index = Base })
ProgressBar.__index = ProgressBar
function ProgressBar.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 30), ProgressBar)
local theme = self._theme
self._callback = options.Callback
self._showText = options.ShowPercent ~= false
self._format = options.Format
self:_label({
Name = "Label",
Size = UDim2.new(1, -50, 0, 16),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
self._text = Create("TextLabel", {
Name = "Percent",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -2, 0, 0),
Size = UDim2.fromOffset(60, 16),
TextXAlignment = Enum.TextXAlignment.Right,
TextColor3 = theme:Get("TextDim"),
Font = theme:Get("Font"),
Visible = self._showText,
Parent = self.Frame,
})
theme:Bind(self._text, "TextColor3", "TextDim")
local track = Create("Frame", {
Name = "Track",
Position = UDim2.new(0, 2, 0, 21),
Size = UDim2.new(1, -4, 0, 6),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.pill(track)
theme:Bind(track, "BackgroundColor3", "Element")
self._fill = Create(
"Frame",
{ Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track }
)
Create.pill(self._fill)
Visual.accentGradient(theme, self._fill)
self.Value = 0
self:Set(options.Default or 0, true, false)
return self
end
ProgressBar.NoPersist = true
function ProgressBar:Set(value, silent, animated)
if type(value) ~= "number" then
return
end
value = math.clamp(value, 0, 1)
self.Value = value
self:_play(self._fill, { Size = UDim2.fromScale(value, 1) }, animated ~= false, "Normal")
if type(self._format) == "function" then
self._text.Text = tostring(self._format(value))
else
self._text.Text = string.format("%d%%", math.floor(value * 100 + 0.5))
end
if not silent then
self:_emit(value)
end
end
return ProgressBar
end
__functions[__n_Components_RangeSlider] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Visual = require(script.Parent.Parent.Core.Visual)
local AnimationManager = require(script.Parent.Parent.Core.AnimationManager)
local RangeSlider = setmetatable({}, { __index = Base })
RangeSlider.__index = RangeSlider
local function decimalsOf(step)
local text = string.format("%.6f", step):gsub("0+$", ""):gsub("%.$", "")
local dot = string.find(text, ".", 1, true)
return dot and (#text - dot) or 0
end
function RangeSlider.new(ctx, parent, options, _module)
assert(type(options.Min) == "number" and type(options.Max) == "number", "[ClickGUI] RangeSlider needs Min and Max")
local self = setmetatable(Base.new(ctx, parent, options.Name, 34), RangeSlider)
local theme = self._theme
self._callback = options.Callback
self._min = options.Min
self._max = math.max(options.Max, options.Min)
self._step = (options.Increment and options.Increment > 0) and options.Increment or 1
self._decimals = math.clamp(options.Precision or decimalsOf(self._step), 0, 6)
self._suffix = options.Suffix or ""
self._gap = options.MinGap or 0
self._active = nil
local touch = UserInputService.TouchEnabled
self:_label({
Name = "Label",
Size = UDim2.new(1, -90, 0, 16),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
self._valueLabel = Create("TextLabel", {
Name = "Value",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -2, 0, 0),
Size = UDim2.fromOffset(88, 16),
TextXAlignment = Enum.TextXAlignment.Right,
TextColor3 = theme:Get("TextDim"),
Font = theme:Get("Font"),
Parent = self.Frame,
})
theme:Bind(self._valueLabel, "TextColor3", "TextDim")
self._track = Create("Frame", {
Name = "Track",
Position = UDim2.new(0, 2, 0, 23),
Size = UDim2.new(1, -4, 0, 4),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.pill(self._track)
theme:Bind(self._track, "BackgroundColor3", "Element")
self._fill = Create("Frame", { Name = "Fill", BackgroundColor3 = Color3.new(1, 1, 1), Parent = self._track })
Create.pill(self._fill)
Visual.accentGradient(theme, self._fill)
self._knobs = {}
for index = 1, 2 do
local knob = Create("Frame", {
Name = index == 1 and "KnobMin" or "KnobMax",
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(10, 10),
BackgroundColor3 = Color3.new(1, 1, 1),
ZIndex = 2,
Parent = self._track,
})
Create.pill(knob)
self._knobs[index] = knob
end
local hit = Create("TextButton", {
Name = "Hit",
Position = UDim2.fromOffset(0, touch and 16 or 14),
Size = UDim2.new(1, 0, 0, touch and 24 or 20),
ZIndex = 3,
Parent = self.Frame,
})
self._maid:Give(hit.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
local alpha = self:_alphaAt(input.Position.X)
local value = self._min + alpha * (self._max - self._min)
self._active = math.abs(value - self.Value[1]) <= math.abs(value - self.Value[2]) and 1 or 2
if self.Value[1] == self.Value[2] then
self._active = value < self.Value[1] and 1 or 2
end
self:_lockScroll(true)
self:_move(input.Position.X)
end
end))
self._maid:Give(UserInputService.InputChanged:Connect(function(input)
if
self._active
and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
)
then
self:_move(input.Position.X)
end
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input)
if
self._active
and (
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
)
then
self._active = nil
self:_lockScroll(false)
end
end))
local default = options.Default
local low = type(default) == "table" and default[1] or options.DefaultMin or self._min
local high = type(default) == "table" and default[2] or options.DefaultMax or self._max
self.Value = { self:_snap(math.min(low, high)), self:_snap(math.max(low, high)) }
self:_render(false)
return self
end
function RangeSlider:_snap(value)
local snapped = self._min + math.floor((value - self._min) / self._step + 0.5) * self._step
snapped = math.clamp(snapped, self._min, self._max)
return tonumber(string.format("%." .. self._decimals .. "f", snapped)) or snapped
end
function RangeSlider:_alphaAt(x)
local width = self._track.AbsoluteSize.X
if width <= 0 then
return 0
end
return math.clamp((x - self._track.AbsolutePosition.X) / width, 0, 1)
end
function RangeSlider:_move(x)
local value = self._min + self:_alphaAt(x) * (self._max - self._min)
if self._active == 1 then
self:Set(math.min(value, self.Value[2] - self._gap), self.Value[2])
else
self:Set(self.Value[1], math.max(value, self.Value[1] + self._gap))
end
end
function RangeSlider:_render(animated)
local range = self._max - self._min
local a = range > 0 and (self.Value[1] - self._min) / range or 0
local b = range > 0 and (self.Value[2] - self._min) / range or 1
local preset = animated and "Fast" or "Instant"
AnimationManager.Play(self._fill, preset, { Position = UDim2.fromScale(a, 0), Size = UDim2.fromScale(b - a, 1) })
AnimationManager.Play(self._knobs[1], preset, { Position = UDim2.fromScale(a, 0.5) })
AnimationManager.Play(self._knobs[2], preset, { Position = UDim2.fromScale(b, 0.5) })
local format = "%." .. self._decimals .. "f"
self._valueLabel.Text = string.format(format, self.Value[1])
.. " - "
.. string.format(format, self.Value[2])
.. self._suffix
end
function RangeSlider:Set(low, high, silent)
if type(low) == "table" then
low, high, silent = low[1], low[2], high
end
if type(low) ~= "number" or type(high) ~= "number" then
return
end
low, high = self:_snap(math.min(low, high)), self:_snap(math.max(low, high))
if low == self.Value[1] and high == self.Value[2] then
return
end
self.Value = { low, high }
self:_render(not self._active)
if not silent then
self:_emit(low, high)
end
end
function RangeSlider:GetRange()
return self.Value[1], self.Value[2]
end
function RangeSlider:Get()
return table.clone(self.Value)
end
function RangeSlider:Serialize()
return { self.Value[1], self.Value[2] }
end
return RangeSlider
end
__functions[__n_Components_Section] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Section = setmetatable({}, { __index = Base })
Section.__index = Section
function Section.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 20), Section)
local theme = self._theme
local label = Create("TextLabel", {
Name = "Label",
Position = UDim2.fromOffset(2, 0),
Size = UDim2.new(1, -4, 1, -2),
Text = string.upper(options.Name),
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Bottom,
TextColor3 = theme:Get("Accent"),
Font = theme:Get("FontBold"),
Parent = self.Frame,
})
theme:Bind(label, "TextColor3", "Accent")
theme:Bind(label, "Font", "FontBold")
self._text = label
local line = Create("Frame", {
Name = "Line",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new(0, 0, 1, 0),
Size = UDim2.new(1, 0, 0, 1),
BackgroundColor3 = theme:Get("Stroke"),
BackgroundTransparency = 0.5,
Parent = self.Frame,
})
theme:Bind(line, "BackgroundColor3", "Stroke")
return self
end
Section.NoPersist = true
function Section:SetText(text)
self._text.Text = string.upper(text)
end
return Section
end
__functions[__n_Components_Slider] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Visual = require(script.Parent.Parent.Core.Visual)
local AnimationManager = require(script.Parent.Parent.Core.AnimationManager)
local Slider = setmetatable({}, { __index = Base })
Slider.__index = Slider
local function decimalsOf(step)
local text = string.format("%.6f", step):gsub("0+$", ""):gsub("%.$", "")
local dot = string.find(text, ".", 1, true)
return dot and (#text - dot) or 0
end
function Slider.new(ctx, parent, options, _module)
assert(type(options.Min) == "number" and type(options.Max) == "number", "[ClickGUI] Slider needs Min and Max")
local self = setmetatable(Base.new(ctx, parent, options.Name, 34), Slider)
local theme = self._theme
self._callback = options.Callback
self._min = options.Min
self._max = math.max(options.Max, options.Min)
self._step = (options.Increment and options.Increment > 0) and options.Increment or 1
self._decimals = math.clamp(options.Precision or decimalsOf(self._step), 0, 6)
self._suffix = options.Suffix or ""
self._dragging = false
self._hovered = false
local touch = UserInputService.TouchEnabled
self:_label({
Name = "Label",
Size = UDim2.new(1, -66, 0, 16),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
self._valueButton = Create("TextButton", {
Name = "Value",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -2, 0, 0),
Size = UDim2.fromOffset(64, 16),
TextXAlignment = Enum.TextXAlignment.Right,
TextColor3 = theme:Get("TextDim"),
Font = theme:Get("Font"),
Parent = self.Frame,
})
theme:Bind(self._valueButton, "TextColor3", "TextDim")
self._valueBox = Create("TextBox", {
Name = "Input",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -2, 0, 0),
Size = UDim2.fromOffset(64, 16),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Visible = false,
Active = true,
Parent = self.Frame,
})
Create.corner(self._valueBox, 4)
theme:Bind(self._valueBox, "BackgroundColor3", "Element")
theme:Bind(self._valueBox, "TextColor3", "Text")
self._track = Create("Frame", {
Name = "Track",
Position = UDim2.new(0, 2, 0, 23),
Size = UDim2.new(1, -4, 0, 4),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.pill(self._track)
theme:Bind(self._track, "BackgroundColor3", "Element")
if type(options.Marks) == "table" then
local range = self._max - self._min
for _, mark in options.Marks do
if type(mark) == "number" and mark >= self._min and mark <= self._max and range > 0 then
local tick = Create("Frame", {
Name = "Mark",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new((mark - self._min) / range, 0, 1, 3),
Size = UDim2.fromOffset(1, 4),
BackgroundColor3 = theme:Get("TextDim"),
BackgroundTransparency = 0.4,
Parent = self._track,
})
theme:Bind(tick, "BackgroundColor3", "TextDim")
end
end
end
self._fill = Create(
"Frame",
{ Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = self._track }
)
Create.pill(self._fill)
Visual.accentGradient(theme, self._fill)
self._knob = Create("Frame", {
Name = "Knob",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0, 0.5),
Size = UDim2.fromOffset(10, 10),
BackgroundColor3 = Color3.new(1, 1, 1),
ZIndex = 2,
Parent = self._track,
})
Create.pill(self._knob)
local hit = Create("TextButton", {
Name = "Hit",
Position = UDim2.fromOffset(0, touch and 16 or 14),
Size = UDim2.new(1, 0, 0, touch and 24 or 20),
ZIndex = 3,
Parent = self.Frame,
})
self._maid:Give(hit.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
self._dragging = true
self:_lockScroll(true)
self:_fromX(input.Position.X)
end
end))
self._maid:Give(hit.MouseEnter:Connect(function()
self._hovered = true
end))
self._maid:Give(hit.MouseLeave:Connect(function()
self._hovered = false
end))
self._maid:Give(UserInputService.InputChanged:Connect(function(input)
if
self._dragging
and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
)
then
self:_fromX(input.Position.X)
end
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input)
if
self._dragging
and (
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
)
then
self._dragging = false
self:_lockScroll(false)
end
end))
if options.Keyboard ~= false then
self._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
if processed or not self._hovered or self._enabledState == false then
return
end
local direction = input.KeyCode == Enum.KeyCode.Right and 1
or (input.KeyCode == Enum.KeyCode.Left and -1 or 0)
if direction ~= 0 then
local multiplier = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or 1
self:Set(self.Value + direction * self._step * multiplier)
end
end))
end
self._maid:Give(self._valueButton.MouseButton1Click:Connect(function()
self._valueBox.Text = string.format("%." .. self._decimals .. "f", self.Value)
self._valueBox.Visible = true
self._valueButton.Visible = false
self._valueBox:CaptureFocus()
end))
self._maid:Give(self._valueBox.FocusLost:Connect(function()
local number = tonumber(self._valueBox.Text)
self._valueBox.Visible = false
self._valueButton.Visible = true
if number then
self:Set(number)
end
end))
self.Value = self:_snap(options.Default or self._min)
self:_render(false)
return self
end
function Slider:_snap(value)
local snapped = self._min + math.floor((value - self._min) / self._step + 0.5) * self._step
snapped = math.clamp(snapped, self._min, self._max)
return tonumber(string.format("%." .. self._decimals .. "f", snapped)) or snapped
end
function Slider:_fromX(x)
local width = self._track.AbsoluteSize.X
if width <= 0 then
return
end
local alpha = math.clamp((x - self._track.AbsolutePosition.X) / width, 0, 1)
self:Set(self._min + alpha * (self._max - self._min))
end
function Slider:_render(animated)
local range = self._max - self._min
local alpha = range > 0 and (self.Value - self._min) / range or 0
local preset = animated and "Fast" or "Instant"
AnimationManager.Play(self._fill, preset, { Size = UDim2.fromScale(alpha, 1) })
AnimationManager.Play(self._knob, preset, { Position = UDim2.fromScale(alpha, 0.5) })
self._valueButton.Text = string.format("%." .. self._decimals .. "f", self.Value) .. self._suffix
end
function Slider:SetRange(min, max)
self._min = min
self._max = math.max(max, min)
self.Value = self:_snap(self.Value)
self:_render(false)
end
function Slider:Set(value, silent)
if type(value) ~= "number" then
return
end
value = self:_snap(value)
if value == self.Value then
return
end
self.Value = value
self:_render(not self._dragging)
if not silent then
self:_emit(value)
end
end
return Slider
end
__functions[__n_Components_Textbox] = function(script, require)
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local AnimationManager = require(script.Parent.Parent.Core.AnimationManager)
local Textbox = setmetatable({}, { __index = Base })
Textbox.__index = Textbox
function Textbox.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 46), Textbox)
local theme = self._theme
self._callback = options.Callback
self._numeric = options.Numeric == true
self.Value = options.Default and tostring(options.Default) or ""
self:_label({
Name = "Label",
Position = UDim2.fromOffset(2, 0),
Size = UDim2.new(1, -4, 0, 16),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
local background = Create("Frame", {
Name = "Input",
Position = UDim2.fromOffset(0, 20),
Size = UDim2.new(1, 0, 0, 24),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
Create.corner(background, 6)
theme:Bind(background, "BackgroundColor3", "Element")
self._stroke = Create.stroke(background, theme:Get("Stroke"), 1, 1)
self._box = Create("TextBox", {
Name = "Box",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(1, -16, 1, 0),
Text = self.Value,
PlaceholderText = options.Placeholder or "",
PlaceholderColor3 = theme:Get("TextDim"),
ClearTextOnFocus = options.ClearOnFocus == true,
TextXAlignment = Enum.TextXAlignment.Left,
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
ClipsDescendants = true,
Active = true,
Parent = background,
})
theme:Bind(self._box, "TextColor3", "Text")
theme:Bind(self._box, "PlaceholderColor3", "TextDim")
self._maid:Give(self._box.Focused:Connect(function()
AnimationManager.Play(self._stroke, "Fast", { Color = theme:Get("Accent"), Transparency = 0 })
end))
self._maid:Give(self._box.FocusLost:Connect(function(enterPressed)
AnimationManager.Play(self._stroke, "Fast", { Transparency = 1 })
self.Value = self._box.Text
self:_emit(self.Value, enterPressed)
end))
if self._numeric then
self._maid:Give(self._box:GetPropertyChangedSignal("Text"):Connect(function()
local filtered = string.gsub(self._box.Text, "[^%d%.%-]", "")
if filtered ~= self._box.Text then
self._box.Text = filtered
end
end))
end
return self
end
function Textbox:Set(text, silent)
text = tostring(text)
if self._numeric then
text = string.gsub(text, "[^%d%.%-]", "")
end
self.Value = text
self._box.Text = text
if not silent then
self:_emit(text, false)
end
end
return Textbox
end
__functions[__n_Components_Toggle] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Base = require(script.Parent.Base)
local Create = require(script.Parent.Parent.Utilities.Create)
local Toggle = setmetatable({}, { __index = Base })
Toggle.__index = Toggle
function Toggle.new(ctx, parent, options, _module)
local self = setmetatable(Base.new(ctx, parent, options.Name, 24), Toggle)
local theme = self._theme
self._callback = options.Callback
self._style = options.Style == "Checkbox" and "Checkbox" or "Switch"
self._activeColor = options.ActiveColor
self._inactiveColor = options.InactiveColor
self._hovered = false
self.Value = false
local checkbox = self._style == "Checkbox"
self._label = self:_label({
Name = "Label",
Size = UDim2.new(1, -40, 1, 0),
Position = UDim2.fromOffset(2, 0),
Text = options.Name,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Frame,
})
self._track = Create("Frame", {
Name = "Track",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -2, 0.5, 0),
Size = checkbox and UDim2.fromOffset(16, 16) or UDim2.fromOffset(30, 14),
BackgroundColor3 = theme:Get("Element"),
Parent = self.Frame,
})
if checkbox then
Create.corner(self._track, 4)
else
Create.pill(self._track)
end
self._knob = Create("Frame", {
Name = "Knob",
AnchorPoint = checkbox and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5),
Position = checkbox and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 2, 0.5, 0),
Size = checkbox and UDim2.fromOffset(8, 8) or UDim2.fromOffset(10, 10),
BackgroundColor3 = theme:Get("TextDim"),
BackgroundTransparency = checkbox and 1 or 0,
Parent = self._track,
})
if checkbox then
Create.corner(self._knob, 2)
else
Create.pill(self._knob)
end
local hit = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = self.Frame })
self._maid:Give(hit.MouseButton1Click:Connect(function()
self:Set(not self.Value)
end))
self._maid:Give(hit.MouseEnter:Connect(function()
self._hovered = true
end))
self._maid:Give(hit.MouseLeave:Connect(function()
self._hovered = false
end))
if options.Keyboard ~= false then
self._maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
if processed or not self._hovered or self._enabledState == false then
return
end
if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
self:Set(not self.Value)
end
end))
end
self:_onTheme(function()
self:_render(true)
end)
self:_render(false)
if options.Default then
self:Set(true, true)
end
return self
end
Toggle._chipOffset = 38
Toggle._keyAction = function(self)
self:Set(not self.Value)
end
function Toggle:_render(animated)
local theme = self._theme
local on = self.Value
local active = self._activeColor or theme:Get("Accent")
local inactive = self._inactiveColor or theme:Get("Element")
self:_play(self._track, { BackgroundColor3 = on and active or inactive }, animated)
if self._style == "Checkbox" then
self:_play(
self._knob,
{ BackgroundTransparency = on and 0 or 1, BackgroundColor3 = Color3.new(1, 1, 1) },
animated,
"Pop"
)
else
self:_play(self._knob, {
Position = on and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
BackgroundColor3 = on and Color3.new(1, 1, 1) or theme:Get("TextDim"),
}, animated, "Pop")
end
end
function Toggle:SetColors(active, inactive)
self._activeColor, self._inactiveColor = active, inactive
self:_render(true)
end
function Toggle:Set(value, silent)
value = not not value
if value == self.Value then
return
end
self.Value = value
self:_render(true)
if not silent then
self:_emit(value)
end
end
return Toggle
end
__functions[__n_Components_UIShadow] = function(script, require)
local UIShadow = {}
UIShadow.__index = UIShadow
UIShadow.Presets = {
Soft = { Opacity = 0.3, Spread = 4, Layers = 8, Offset = Vector2.new(0, 3) },
Medium = { Opacity = 0.45, Spread = 3, Layers = 8, Offset = Vector2.new(0, 4) },
Strong = { Opacity = 0.65, Spread = 3, Layers = 10, Offset = Vector2.new(0, 6) },
}
function UIShadow.new(options)
assert(typeof(options.Parent) == "Instance", "[ClickGUI] UIShadow needs a Parent")
local presetName = options.Preset or "Medium"
local preset = UIShadow.Presets[presetName] or UIShadow.Presets.Medium
local self = setmetatable({}, UIShadow)
self.Preset = UIShadow.Presets[presetName] and presetName or "Medium"
self.Enabled = true
self._radius = options.CornerRadius or 8
self._layers = math.clamp(math.floor(options.Layers or preset.Layers), 1, 14)
self._spread = math.clamp(options.Spread or preset.Spread, 1, 10)
self._opacity = math.clamp(options.Opacity or preset.Opacity, 0, 1)
self._offset = options.Offset or preset.Offset
self._color = options.Color or Color3.new(0, 0, 0)
self._frames = {}
local container = Instance.new("CanvasGroup")
container.Name = "UIShadow"
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ZIndex = 0
container.Active = false
self.Instance = container
self:_build()
container.Parent = options.Parent
return self
end
function UIShadow:_build()
for _, frame in self._frames do
frame:Destroy()
end
table.clear(self._frames)
local extent = self._layers * self._spread
local container = self.Instance
container.Position = UDim2.new(0.5, self._offset.X, 0.5, self._offset.Y)
container.Size = UDim2.new(1, extent * 2, 1, extent * 2)
local transparency = 1 - self._opacity / self._layers
for i = 1, self._layers do
local grow = i * self._spread
local layer = Instance.new("Frame")
layer.Name = "Layer" .. i
layer.AnchorPoint = Vector2.new(0.5, 0.5)
layer.Position = UDim2.fromScale(0.5, 0.5)
layer.Size = UDim2.new(1, -extent * 2 + grow * 2, 1, -extent * 2 + grow * 2)
layer.BackgroundColor3 = self._color
layer.BackgroundTransparency = transparency
layer.BorderSizePixel = 0
layer.Active = false
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, self._radius + grow)
corner.Parent = layer
layer.Parent = container
self._frames[i] = layer
end
end
function UIShadow:SetOpacity(value: number)
self._opacity = math.clamp(value, 0, 1)
local transparency = 1 - self._opacity / self._layers
for _, layer in self._frames do
layer.BackgroundTransparency = transparency
end
end
function UIShadow:SetColor(color: Color3)
self._color = color
for _, layer in self._frames do
layer.BackgroundColor3 = color
end
end
function UIShadow:SetOffset(offset: Vector2)
self._offset = offset
self.Instance.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
end
function UIShadow:SetSpread(spread: number)
self._spread = math.clamp(spread, 1, 10)
self:_build()
end
function UIShadow:SetLayers(count: number)
self._layers = math.clamp(math.floor(count), 1, 14)
self:_build()
end
function UIShadow:SetCornerRadius(radius: number)
if radius == self._radius then
return
end
self._radius = radius
for i, layer in self._frames do
local corner = layer:FindFirstChildOfClass("UICorner")
if corner then
corner.CornerRadius = UDim.new(0, radius + i * self._spread)
end
end
end
function UIShadow:SetPreset(name: string)
local preset = UIShadow.Presets[name]
if not preset or name == self.Preset then
return
end
self.Preset = name
self._spread, self._layers, self._offset = preset.Spread, preset.Layers, preset.Offset
self._opacity = preset.Opacity
self:_build()
end
function UIShadow:SetEnabled(enabled: boolean)
self.Enabled = enabled
self.Instance.Visible = enabled
end
function UIShadow:Destroy()
self.Instance:Destroy()
table.clear(self._frames)
end
return UIShadow
end
__functions[__n_Core_AnimationManager] = function(script, require)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Signal = require(script.Parent.Parent.Utilities.Signal)
local AnimationManager = {}
local DURATIONS: { [string]: number } = { Fast = 0.12, Normal = 0.22, Slow = 0.4 }
local STYLES: { [string]: { Style: Enum.EasingStyle, Direction: Enum.EasingDirection } } = {
Smooth = { Style = Enum.EasingStyle.Quint, Direction = Enum.EasingDirection.Out },
Snappy = { Style = Enum.EasingStyle.Quart, Direction = Enum.EasingDirection.Out },
Bouncy = { Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out },
Soft = { Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut },
Linear = { Style = Enum.EasingStyle.Linear, Direction = Enum.EasingDirection.Out },
}
AnimationManager.Presets = {
Instant = TweenInfo.new(0),
Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
Normal = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
Snappy = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
Expo = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
Pop = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
Expand = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
Close = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
} :: { [string]: TweenInfo }
AnimationManager.Config = { Enabled = true, Speed = 1, Preset = "Smooth" }
AnimationManager.Changed = Signal.new()
local DEFAULT_CONFIG = table.clone(AnimationManager.Config)
local active = setmetatable({}, { __mode = "k" }) :: { [Instance]: { [string]: Tween } }
function AnimationManager.SetConfig(config: { Enabled: boolean?, Speed: number?, Preset: string? })
assert(type(config) == "table", "[ClickGUI] SetAnimationConfig expects a table")
local current = AnimationManager.Config
if config.Enabled ~= nil then
current.Enabled = config.Enabled == true
end
if config.Speed ~= nil then
assert(type(config.Speed) == "number", "[ClickGUI] Animation Speed must be a number")
current.Speed = math.clamp(config.Speed, 0.1, 5)
end
if config.Preset ~= nil then
if STYLES[config.Preset] then
current.Preset = config.Preset
else
warn(`[ClickGUI] Unknown animation preset "{config.Preset}"`)
end
end
AnimationManager.Changed:Fire(current)
end
function AnimationManager.GetConfig()
return table.clone(AnimationManager.Config)
end
function AnimationManager.ResetConfig()
AnimationManager.SetConfig(DEFAULT_CONFIG)
end
function AnimationManager.GetPresetNames(): { string }
local names = {}
for name in STYLES do
table.insert(names, name)
end
table.sort(names)
return names
end
function AnimationManager.Time(seconds: number): number
local config = AnimationManager.Config
if not config.Enabled then
return 0
end
return seconds / config.Speed
end
local function resolve(preset: string | TweenInfo): TweenInfo?
local config = AnimationManager.Config
if typeof(preset) == "TweenInfo" then
return if preset.Time > 0 then preset else nil
end
if not config.Enabled or preset == "Instant" then
return nil
end
local info: TweenInfo
local duration = DURATIONS[preset]
if duration then
local style = STYLES[config.Preset] or STYLES.Smooth
info = TweenInfo.new(duration, style.Style, style.Direction)
else
info = AnimationManager.Presets[preset] or AnimationManager.Presets.Normal
end
if config.Speed ~= 1 then
info = TweenInfo.new(info.Time / config.Speed, info.EasingStyle, info.EasingDirection)
end
return if info.Time > 0 then info else nil
end
local function getEntry(instance: Instance): { [string]: Tween }
local entry = active[instance]
if not entry then
entry = {}
active[instance] = entry
instance.Destroying:Once(function()
AnimationManager.Stop(instance)
end)
end
return entry :: { [string]: Tween }
end
function AnimationManager.Play(instance: Instance, preset: string | TweenInfo, goal: { [string]: any }): Tween?
local info = resolve(preset)
local registry = getEntry(instance)
local last: Tween? = nil
for property, value in goal do
local running = registry[property]
if running then
registry[property] = nil
running:Cancel()
end
if not info then
pcall(function()
(instance :: any)[property] = value
end)
else
local ok, tween = pcall(Tween.play, instance, info, { [property] = value })
if ok then
local created = tween :: Tween
registry[property] = created
created.Completed:Once(function()
if registry[property] == created then
registry[property] = nil
end
end)
last = created
else
pcall(function()
(instance :: any)[property] = value
end)
end
end
end
return last
end
function AnimationManager.Stop(instance: Instance)
local entry = active[instance]
if entry then
active[instance] = nil
for _, tween in entry do
tween:Cancel()
end
end
end
function AnimationManager.BindHover(gui: GuiObject, maid: any, onEnter: () -> (), onLeave: () -> ())
maid:Give(gui.MouseEnter:Connect(onEnter))
maid:Give(gui.MouseLeave:Connect(onLeave))
end
return AnimationManager
end
__functions[__n_Core_Category] = function(script, require)
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local Create = require(Utilities.Create)
local Module = require(script.Parent.Module)
local Category = {}
Category.__index = Category
function Category.new(ctx, window, name: string, options: Types.CategoryOptions)
assert(type(name) == "string" and name ~= "", "[ClickGUI] CreateCategory needs a name")
local self = setmetatable({}, Category)
local theme = ctx.Theme
self.Name = name
self.Window = window
self.Modules = {}
self.Icon = options and options.Icon
self.IconSize = options and options.IconSize or 16
self.Group = options and options.Group
self.IconColor = options and options.IconColor
self._ctx = ctx
self._visible = true
self.Page = Create("ScrollingFrame", {
Name = "Page_" .. name,
Size = UDim2.fromScale(1, 1),
ScrollBarImageColor3 = theme:Get("Accent"),
})
theme:Bind(self.Page, "ScrollBarImageColor3", "Accent")
theme:Bind(self.Page, "ScrollBarThickness", function(t)
return t.ScrollBarThickness or 3
end)
self.List = Create("Frame", {
Name = "List",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = self.Page,
})
local wide = window.Layout == "Sidebar" and window.StyleData.Sidebar == "Brand"
if wide then
Create.padding(self.List, 6, 18, 14, 18)
else
Create.padding(self.List, 6, 6, 6, 6)
end
local listLayout = Create.list(self.List, 4)
theme:Bind(listLayout, "Padding", function(t)
return UDim.new(0, t.ModuleSpacing)
end)
return self
end
function Category:CreateModule(options: Types.ModuleOptions)
local module = Module.new(self._ctx, self, options)
table.insert(self.Modules, module)
self.Window:_registerModule(module)
return module
end
function Category:GetModule(name: string)
for _, module in self.Modules do
if module.Name == name then
return module
end
end
return nil
end
function Category:SetVisible(visible: boolean)
self._visible = visible
self.Window:_onCategoryVisibilityChanged(self)
end
function Category:Destroy()
self.Window:_removeCategory(self)
end
return Category
end
__functions[__n_Core_Config] = function(script, require)
local HttpService = game:GetService("HttpService")
local Fonts = require(script.Parent.Fonts)
local Config = {}
Config.Version = 4
Config.Storage = {}
function Config.Storage.Memory()
local store = {}
return {
Get = function(_, key)
return store[key]
end,
Set = function(_, key, value)
store[key] = value
end,
Remove = function(_, key)
store[key] = nil
end,
}
end
function Config.Storage.Attribute(instance, prefix)
local function name(key)
return string.sub((prefix or "CG_") .. string.gsub(key, "[^%w_]", "_"), 1, 100)
end
return {
Get = function(_, key)
local value = instance:GetAttribute(name(key))
return type(value) == "string" and value or nil
end,
Set = function(_, key, value)
instance:SetAttribute(name(key), value)
end,
Remove = function(_, key)
instance:SetAttribute(name(key), nil)
end,
}
end
function Config.Storage.File(folder)
local hasFs = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
if not hasFs then
warn("[ClickGUI] Storage.File needs writefile/readfile/isfile (executor); using memory storage instead")
return Config.Storage.Memory()
end
if folder and type(makefolder) == "function" and type(isfolder) == "function" then
pcall(function()
if not isfolder(folder) then
makefolder(folder)
end
end)
end
local function path(key)
local safe = string.gsub(key, "[^%w_%-%.]", "_")
return (folder and (folder .. "/") or "") .. safe .. ".json"
end
return {
Get = function(_, key)
local file = path(key)
local ok, result = pcall(function()
if isfile(file) then
return readfile(file)
end
return nil
end)
return ok and result or nil
end,
Set = function(_, key, value)
pcall(writefile, path(key), value)
end,
Remove = function(_, key)
if type(delfile) == "function" then
pcall(function()
if isfile(path(key)) then
delfile(path(key))
end
end)
end
end,
}
end
function Config.Storage.Custom(get, set, remove)
assert(type(get) == "function" and type(set) == "function", "[ClickGUI] Storage.Custom needs get and set functions")
return {
Get = function(_, key)
return get(key)
end,
Set = function(_, key, value)
set(key, value)
end,
Remove = function(_, key)
if remove then
remove(key)
end
end,
}
end
function Config.encode(data)
return HttpService:JSONEncode(data)
end
function Config.decode(text)
if type(text) ~= "string" then
return nil
end
local ok, result = pcall(function()
return HttpService:JSONDecode(text)
end)
if ok and type(result) == "table" then
return result
end
return nil
end
function Config.migrate(data)
if type(data) ~= "table" then
return nil
end
local out = table.clone(data)
local version = tonumber(out.Version) or 1
if version > Config.Version then
warn("[ClickGUI] Config was created by a newer version; loading what is understood")
end
if version < 2 then
out.Favorites = out.Favorites or {}
out.Pinned = out.Pinned or {}
end
for _, key in { "Flags", "Modules", "Favorites", "Pinned", "Auto", "Binds", "Themes" } do
if type(out[key]) ~= "table" then
out[key] = {}
end
end
if version < 3 and type(out.HUD) == "table" then
for _, hud in out.HUD do
if type(hud) == "table" then
hud.GradientFrom = nil
hud.GradientTo = nil
end
end
end
if version < 4 and type(out.Theme) == "table" then
out.Theme = table.clone(out.Theme)
for _, key in { "Font", "FontBold" } do
local value = out.Theme[key]
if type(value) == "string" then
out.Theme[key] = Fonts.Alias(value)
end
end
end
out.Legacy = version < 2
out.Version = Config.Version
return out
end
function Config.write(adapter, key, text)
if not adapter then
return false
end
local ok, err = pcall(adapter.Set, adapter, key, text)
if not ok then
warn("[ClickGUI] Storage write failed: " .. tostring(err))
return false
end
if Config.read(adapter, key) ~= text then
warn(
"[ClickGUI] Storage did not keep '"
.. tostring(key)
.. "': the write ran but reading it back gave something else. Check writefile/readfile/isfile."
)
return false
end
return true
end
function Config.read(adapter, key)
if not adapter then
return nil
end
local ok, result = pcall(adapter.Get, adapter, key)
if ok and type(result) == "string" then
return result
end
return nil
end
return Config
end
__functions[__n_Core_Fonts] = function(script, require)
local ContentProvider = game:GetService("ContentProvider")
local Fonts = {}
local ROOT = "rbxasset://fonts/families/"
local entries = {}
local order = {}
local byFamily = {}
local status = {}
local waiters = {}
local ALIASES = {
Fredoka = "FredokaOne",
["Fredoka One"] = "FredokaOne",
Fredoka_One = "FredokaOne",
["Builder Sans"] = "BuilderSans",
["Roboto Mono"] = "RobotoMono",
["Josefin Sans"] = "JosefinSans",
["Titillium Web"] = "TitilliumWeb",
}
Fonts.ProbeEnabled = true
local function enumFont(name, default)
local ok, value = pcall(function()
return (Enum.Font :: any)[name]
end)
if ok and value then
return value
end
return default
end
local function familyPath(family)
if string.find(family, "://", 1, true) then
return family
end
return ROOT .. family
end
local function register(name, spec)
local fallback = typeof(spec.Fallback) == "EnumItem" and spec.Fallback or Enum.Font.GothamMedium
local fallbackBold = typeof(spec.FallbackBold) == "EnumItem" and spec.FallbackBold
or (typeof(spec.Fallback) == "EnumItem" and spec.Fallback or Enum.Font.GothamBold)
local entry = {
Name = name,
Fallback = fallback,
FallbackBold = fallbackBold,
Family = type(spec.Family) == "string" and familyPath(spec.Family) or nil,
Weight = typeof(spec.Weight) == "EnumItem" and spec.Weight or Enum.FontWeight.Medium,
BoldWeight = typeof(spec.BoldWeight) == "EnumItem" and spec.BoldWeight or Enum.FontWeight.Bold,
Style = typeof(spec.Style) == "EnumItem" and spec.Style or Enum.FontStyle.Normal,
}
if entries[name] == nil then
table.insert(order, name)
end
local previous = entries[name]
if previous and previous.Family then
byFamily[previous.Family] = nil
end
entries[name] = entry
if entry.Family then
byFamily[entry.Family] = entry
status[entry.Family] = nil
end
return entry
end
local function face(name, family, fallback, fallbackBold, weight, boldWeight)
register(name, {
Family = family,
Fallback = fallback,
FallbackBold = fallbackBold,
Weight = weight,
BoldWeight = boldWeight,
})
end
local GOTHAM = Enum.Font.GothamMedium
local GOTHAM_BOLD = Enum.Font.GothamBold
face("Inter", "Inter.json", GOTHAM, GOTHAM_BOLD)
face("Montserrat", "Montserrat.json", GOTHAM, GOTHAM_BOLD)
face("BuilderSans", "BuilderSans.json", GOTHAM, GOTHAM_BOLD)
face("Nunito", "Nunito.json", enumFont("Nunito", GOTHAM), enumFont("Nunito", GOTHAM_BOLD))
face("Roboto", "Roboto.json", enumFont("Roboto", GOTHAM), enumFont("Roboto", GOTHAM_BOLD))
face("RobotoMono", "RobotoMono.json", enumFont("RobotoMono", Enum.Font.Code), enumFont("RobotoMono", Enum.Font.Code))
face("Oswald", "Oswald.json", enumFont("Oswald", GOTHAM), enumFont("Oswald", GOTHAM_BOLD))
face("Merriweather", "Merriweather.json", enumFont("Merriweather", GOTHAM), enumFont("Merriweather", GOTHAM_BOLD))
face("Ubuntu", "Ubuntu.json", enumFont("Ubuntu", GOTHAM), enumFont("Ubuntu", GOTHAM_BOLD))
face("JosefinSans", "JosefinSans.json", enumFont("JosefinSans", GOTHAM), enumFont("JosefinSans", GOTHAM_BOLD))
face("TitilliumWeb", "TitilliumWeb.json", enumFont("TitilliumWeb", GOTHAM), enumFont("TitilliumWeb", GOTHAM_BOLD))
face("Jura", "Jura.json", enumFont("Jura", GOTHAM), enumFont("Jura", GOTHAM_BOLD))
face("Inconsolata", "Inconsolata.json", Enum.Font.Code, Enum.Font.Code)
face(
"FredokaOne",
"FredokaOne.json",
enumFont("FredokaOne", GOTHAM_BOLD),
enumFont("FredokaOne", GOTHAM_BOLD),
Enum.FontWeight.Regular,
Enum.FontWeight.Regular
)
register("Gotham", { Fallback = Enum.Font.Gotham, FallbackBold = Enum.Font.GothamBold })
register("GothamMedium", { Fallback = Enum.Font.GothamMedium, FallbackBold = Enum.Font.GothamBold })
register("GothamSemibold", { Fallback = Enum.Font.GothamSemibold, FallbackBold = Enum.Font.GothamBold })
register("GothamBold", { Fallback = Enum.Font.GothamBold, FallbackBold = Enum.Font.GothamBlack })
register("GothamBlack", { Fallback = Enum.Font.GothamBlack, FallbackBold = Enum.Font.GothamBlack })
register("SourceSans", { Fallback = Enum.Font.SourceSans, FallbackBold = Enum.Font.SourceSansBold })
register("SourceSansSemibold", { Fallback = Enum.Font.SourceSansSemibold, FallbackBold = Enum.Font.SourceSansBold })
register("Arial", { Fallback = Enum.Font.Arial, FallbackBold = Enum.Font.ArialBold })
register("Code", { Fallback = Enum.Font.Code, FallbackBold = Enum.Font.Code })
function Fonts.Register(name: string, spec: { [string]: any })
assert(type(name) == "string" and name ~= "", "[ClickGUI] Fonts.Register needs a name")
assert(type(spec) == "table", "[ClickGUI] Fonts.Register needs a spec table")
return register(name, spec)
end
function Fonts.Alias(name: any): any
if type(name) == "string" and ALIASES[name] then
return ALIASES[name]
end
return name
end
function Fonts.Get(name: any)
if type(name) ~= "string" then
return nil
end
return entries[name] or entries[ALIASES[name] or ""]
end
function Fonts.Names(): { string }
return table.clone(order)
end
function Fonts.IsFace(value: any): boolean
return typeof(value) == "Font"
end
function Fonts.Resolve(name: any, bold: boolean?, literal: boolean?): any
local entry = Fonts.Get(name)
if not entry then
return nil
end
if entry.Family and status[entry.Family] ~= "failed" then
return Font.new(entry.Family, bold and entry.BoldWeight or entry.Weight, entry.Style)
end
if bold and not literal then
return entry.FallbackBold
end
return entry.Fallback
end
function Fonts.NameOf(value: any): string
if typeof(value) == "EnumItem" then
return value.Name
end
if typeof(value) == "Font" then
local entry = byFamily[value.Family]
return entry and entry.Name or "Custom"
end
return "GothamMedium"
end
function Fonts.ToEnum(value: any, bold: boolean?): Enum.Font
if typeof(value) == "EnumItem" then
return value :: any
end
if typeof(value) == "Font" then
local entry = byFamily[value.Family]
if entry then
if bold or value.Weight.Value >= 600 then
return entry.FallbackBold
end
return entry.Fallback
end
end
return bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
end
function Fonts.IsAuto(theme: any): boolean
local entry = Fonts.Get(Fonts.NameOf(theme.Font))
if not entry then
return false
end
return Fonts.Resolve(entry.Name, true) == theme.FontBold
end
function Fonts.Probe(value: any, callback: (boolean) -> ())
if typeof(value) ~= "Font" or not Fonts.ProbeEnabled then
callback(true)
return
end
local family = value.Family
local state = status[family]
if state == "ok" then
callback(true)
return
end
if state == "failed" then
callback(false)
return
end
local list = waiters[family]
if list then
table.insert(list, callback)
return
end
waiters[family] = { callback }
local settled = false
local function settle(ok: boolean)
if settled then
return
end
settled = true
status[family] = ok and "ok" or "failed"
local pending = waiters[family] or {}
waiters[family] = nil
if not ok then
warn(`[ClickGUI] Font "{family}" could not be loaded; using a built-in font instead`)
end
for _, fn in pending do
task.spawn(fn, ok)
end
end
task.delay(10, settle, true)
task.spawn(function()
local label = Instance.new("TextLabel")
local built = pcall(function()
label.FontFace = value
end)
local failed = not built
if built then
pcall(function()
ContentProvider:PreloadAsync({ label }, function(_, fetch)
if fetch == Enum.AssetFetchStatus.Failure then
failed = true
end
end)
end)
end
label:Destroy()
settle(not failed)
end)
end
function Fonts.Serialize(value: any): any
if typeof(value) == "EnumItem" then
return value.Name
end
if typeof(value) == "Font" then
return {
Name = Fonts.NameOf(value),
Family = value.Family,
Weight = value.Weight.Name,
Style = value.Style.Name,
}
end
return nil
end
function Fonts.Deserialize(value: any, bold: boolean?): any
if type(value) == "string" then
local resolved = Fonts.Resolve(value, bold, true)
if resolved then
return resolved
end
local ok, item = pcall(function()
return (Enum.Font :: any)[value]
end)
if ok and item then
return item
end
return nil
end
if type(value) == "table" and type(value.Family) == "string" and #value.Family > 0 and #value.Family <= 200 then
local okWeight, weight = pcall(function()
return (Enum.FontWeight :: any)[value.Weight]
end)
local okStyle, style = pcall(function()
return (Enum.FontStyle :: any)[value.Style]
end)
local okFont, font = pcall(
Font.new,
value.Family,
okWeight and weight or Enum.FontWeight.Medium,
okStyle and style or Enum.FontStyle.Normal
)
if okFont then
return font
end
end
return nil
end
return Fonts
end
__functions[__n_Core_HUD] = function(script, require)
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local Fonts = require(script.Parent.Fonts)
local Create = require(Utilities.Create)
local Draggable = require(Utilities.Draggable)
local Maid = require(Utilities.Maid)
local HUD = {}
HUD.__index = HUD
local ANCHORS = {
TopLeft = { Anchor = Vector2.new(0, 0), Pos = UDim2.fromScale(0, 0), Sx = 1, Sy = 1 },
TopRight = { Anchor = Vector2.new(1, 0), Pos = UDim2.fromScale(1, 0), Sx = -1, Sy = 1 },
BottomLeft = { Anchor = Vector2.new(0, 1), Pos = UDim2.fromScale(0, 1), Sx = 1, Sy = -1 },
BottomRight = { Anchor = Vector2.new(1, 1), Pos = UDim2.fromScale(1, 1), Sx = -1, Sy = -1 },
}
local COLOR_KEYS =
{ StaticColor = true, BorderColor = true, BackgroundColor = true, GradientFrom = true, GradientTo = true }
local function defaults(options)
return {
Position = options.Position or "TopRight",
Offset = options.Offset or Vector2.new(8, 8),
TextSize = options.TextSize or 16,
Sort = options.Sort or "Length",
Background = options.Background ~= false,
BackgroundTransparency = options.BackgroundTransparency or (options.Style == "Pill" and 0.3 or 0.45),
BackgroundColor = options.BackgroundColor or Color3.new(0, 0, 0),
AccentBar = options.AccentBar or "Right",
ColorMode = options.ColorMode or "Gradient",
StaticColor = options.StaticColor or Color3.new(1, 1, 1),
GradientFrom = options.GradientFrom,
GradientTo = options.GradientTo,
GradientSpeed = options.GradientSpeed or 0,
ShowInfo = options.ShowInfo ~= false,
Font = options.Font,
Spacing = options.Spacing or (options.Style == "Pill" and 3 or 0),
CornerRadius = options.CornerRadius or (options.Style == "Pill" and 6 or 0),
Border = options.Border == true,
BorderColor = options.BorderColor,
BorderThickness = options.BorderThickness or 1,
TextTransparency = options.TextTransparency or 0,
Animation = options.Animation or "Both",
}
end
function HUD.new(library, options: Types.HUDOptions)
options = options or {}
local self = setmetatable({}, HUD)
self.Library = library
self.Name = options.Name or "HUD"
self._theme = library.Theme
self._maid = Maid.new()
self._entries = {}
self._attached = {}
self._nextId = 0
self._editable = false
self._options = defaults(options)
assert(ANCHORS[self._options.Position], "[ClickGUI] Invalid HUD position")
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_HUD_" .. self.Name,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 50,
Enabled = options.Visible ~= false,
Parent = options.Parent or library:GetGuiParent(),
})
self._baseOrder = self.Gui.DisplayOrder
self._maid:Give(self.Gui)
library:_secureGui(self.Gui)
self._list = Create("Frame", {
Name = "List",
BackgroundTransparency = 1,
AutomaticSize = Enum.AutomaticSize.XY,
Size = UDim2.new(),
Parent = self.Gui,
})
self._layout = Create.list(self._list, 0)
self._editStroke = Create.stroke(self._list, Color3.new(1, 1, 1), 1, 0)
self._editStroke.Enabled = false
self._maid:Give(self._theme.Changed:Connect(function()
self:_recolor()
end))
self:_applyPosition()
self:_applyDriver()
return self
end
function HUD:_applyPosition()
local data = ANCHORS[self._options.Position]
local offset = self._options.Offset
self._list.AnchorPoint = data.Anchor
self._list.Position = self._customPosition or (data.Pos + UDim2.fromOffset(offset.X * -data.Sx, offset.Y * data.Sy))
self._layout.HorizontalAlignment = data.Sx == -1 and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
self._layout.VerticalAlignment = data.Sy == -1 and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
self._layout.Padding = UDim.new(0, self._options.Spacing)
end
function HUD:_applyDriver()
self._maid:Remove("driver")
local options = self._options
if options.ColorMode == "Rainbow" or (options.ColorMode == "Gradient" and options.GradientSpeed > 0) then
self._maid:GiveNamed(
"driver",
RunService.Heartbeat:Connect(function()
self:_recolor()
end)
)
end
end
local function measure(text, size, font)
return TextService:GetTextSize(text, size, Fonts.ToEnum(font, false), Vector2.new(1000, 1000)).X
end
function HUD:_font()
return self._options.Font or self._theme:Get("Font")
end
function HUD:_buildRow(entry, animateIn)
local options = self._options
local height = options.TextSize + 4
local row = Create("Frame", {
Name = "Row_" .. entry.Name,
Size = UDim2.fromOffset(0, 0),
AutomaticSize = Enum.AutomaticSize.X,
BackgroundColor3 = options.BackgroundColor,
BackgroundTransparency = options.Background and options.BackgroundTransparency or 1,
ClipsDescendants = true,
Parent = self._list,
})
local layout = Create.list(row, 0, true)
layout.VerticalAlignment = Enum.VerticalAlignment.Center
if options.CornerRadius > 0 then
Create.corner(row, options.CornerRadius)
end
local bar
local function makeBar(order)
bar = Create("Frame", { Name = "Bar", Size = UDim2.new(0, 2, 1, 0), LayoutOrder = order, Parent = row })
end
if options.AccentBar == "Left" then
makeBar(1)
end
local label = Create("TextLabel", {
Name = "Name",
Size = UDim2.new(0, 0, 1, 0),
AutomaticSize = Enum.AutomaticSize.X,
Text = entry.Name,
TextSize = options.TextSize,
Font = self:_font(),
TextTransparency = options.TextTransparency,
LayoutOrder = 2,
Parent = row,
})
Create.padding(label, 0, 3, 0, 5)
local info = Create("TextLabel", {
Name = "Info",
Size = UDim2.new(0, 0, 1, 0),
AutomaticSize = Enum.AutomaticSize.X,
Text = "",
TextSize = math.max(options.TextSize - 2, 8),
Font = self:_font(),
TextColor3 = Color3.fromRGB(170, 170, 180),
TextTransparency = options.TextTransparency,
LayoutOrder = 3,
Parent = row,
})
Create.padding(info, 0, 5, 0, 0)
if options.AccentBar == "Right" then
makeBar(4)
end
local stroke
if options.Border then
stroke = Create.stroke(row, Color3.new(1, 1, 1), options.BorderThickness, 0)
end
entry.Row, entry.Label, entry.InfoLabel, entry.Bar, entry.Stroke, entry.Height =
row, label, info, bar, stroke, height
local mode = options.Animation
local grow = mode == "Grow" or mode == "Both"
local fade = mode == "Fade" or mode == "Both"
if animateIn and (grow or fade) then
if fade then
row.BackgroundTransparency = 1
label.TextTransparency = 1
info.TextTransparency = 1
AnimationManager.Play(
row,
"Normal",
{ BackgroundTransparency = options.Background and options.BackgroundTransparency or 1 }
)
AnimationManager.Play(label, "Normal", { TextTransparency = options.TextTransparency })
AnimationManager.Play(info, "Normal", { TextTransparency = options.TextTransparency })
end
if grow then
AnimationManager.Play(row, "Normal", { Size = UDim2.fromOffset(0, height) })
else
row.Size = UDim2.fromOffset(0, height)
end
else
row.Size = UDim2.fromOffset(0, height)
end
end
function HUD:_refreshText(entry)
local showInfo = self._options.ShowInfo and entry.Info ~= nil and entry.Info ~= ""
entry.InfoLabel.Text = showInfo and entry.Info or ""
entry.InfoLabel.Visible = showInfo
end
function HUD:_resort()
local list = {}
for _, entry in self._entries do
if not entry.Removing then
table.insert(list, entry)
end
end
local mode = self._options.Sort
local font = self:_font()
if mode == "Length" then
for _, entry in list do
local text = entry.Name .. ((self._options.ShowInfo and entry.Info) and (" " .. entry.Info) or "")
entry.Width = measure(text, self._options.TextSize, font)
end
table.sort(list, function(a, b)
if a.Width == b.Width then
return a.Name < b.Name
end
return a.Width > b.Width
end)
elseif mode == "Alphabetical" then
table.sort(list, function(a, b)
return a.Name < b.Name
end)
else
table.sort(list, function(a, b)
return a.Id < b.Id
end)
end
for index, entry in list do
entry.Row.LayoutOrder = index
end
self._sorted = list
self:_recolor()
end
function HUD:_recolor()
local list = self._sorted
if not list then
return
end
local theme = self._theme
local options = self._options
local mode = options.ColorMode
local total = #list
local from = options.GradientFrom or theme:Get("Accent")
local to = options.GradientTo or theme:Get("AccentDark")
for index, entry in list do
local color
if mode == "Static" then
color = options.StaticColor
elseif mode == "Rainbow" then
color = Color3.fromHSV((os.clock() * 0.15 + index * 0.05) % 1, 0.65, 1)
elseif mode == "Gradient" then
local t = total > 1 and (index - 1) / (total - 1) or 0
if options.GradientSpeed > 0 then
local phase = (t + os.clock() * options.GradientSpeed) % 2
t = phase > 1 and 2 - phase or phase
end
color = from:Lerp(to, t)
else
color = theme:Get("Accent")
end
entry.Label.TextColor3 = color
if entry.Bar then
entry.Bar.BackgroundColor3 = color
end
if entry.Stroke then
entry.Stroke.Color = options.BorderColor or color
end
end
end
function HUD:AddEntry(name: string, info: string?)
local existing = self._entries[name]
if existing and not existing.Removing then
existing.Info = info
self:_refreshText(existing)
self:_resort()
return existing.Handle
end
self._nextId += 1
local entry = { Name = name, Info = info, Id = self._nextId }
self._entries[name] = entry
self:_buildRow(entry, true)
self:_refreshText(entry)
entry.Handle = {
Remove = function()
self:RemoveEntry(name)
end,
SetInfo = function(_, text)
self:SetEntryInfo(name, text)
end,
}
self:_resort()
return entry.Handle
end
function HUD:SetEntryInfo(name: string, info: string?)
local entry = self._entries[name]
if entry and not entry.Removing then
entry.Info = info
self:_refreshText(entry)
self:_resort()
end
end
function HUD:RemoveEntry(name: string)
local entry = self._entries[name]
if not entry or entry.Removing then
return
end
entry.Removing = true
self._entries[name] = nil
self:_resort()
local mode = self._options.Animation
if mode == "Fade" or mode == "Both" then
AnimationManager.Play(entry.Row, "Normal", { BackgroundTransparency = 1 })
AnimationManager.Play(entry.Label, "Normal", { TextTransparency = 1 })
AnimationManager.Play(entry.InfoLabel, "Normal", { TextTransparency = 1 })
end
if mode == "Grow" or mode == "Both" then
AnimationManager.Play(entry.Row, "Normal", { Size = UDim2.fromOffset(0, 0) })
end
task.delay(mode == "None" and 0 or AnimationManager.Time(0.25), function()
entry.Row:Destroy()
end)
end
function HUD:Clear()
for name in table.clone(self._entries) do
self:RemoveEntry(name)
end
end
function HUD:Attach(window)
if self._attached[window] then
return
end
local maid = Maid.new()
self._attached[window] = maid
window:_attachHUD(self)
local function sync(module)
if not module.ShowInHUD then
return
end
if module.Enabled then
self:AddEntry(module.Name, module.Info)
else
self:RemoveEntry(module.Name)
end
end
maid:Give(window.ModuleToggled:Connect(sync))
maid:Give(window.ModuleInfoChanged:Connect(function(module)
if module.ShowInHUD and module.Enabled then
self:SetEntryInfo(module.Name, module.Info)
end
end))
for _, module in window.Modules do
sync(module)
end
end
function HUD:Detach(window)
local maid = self._attached[window]
if maid then
self._attached[window] = nil
maid:Clean()
window:_detachHUD(self)
for _, module in window.Modules do
if module.ShowInHUD then
self:RemoveEntry(module.Name)
end
end
end
end
function HUD:_rebuild()
local snapshot = {}
for name, entry in self._entries do
if not entry.Removing then
table.insert(snapshot, { Name = name, Info = entry.Info, Id = entry.Id })
end
end
for _, entry in self._entries do
entry.Row:Destroy()
end
self._entries = {}
table.sort(snapshot, function(a, b)
return a.Id < b.Id
end)
for _, data in snapshot do
local entry = { Name = data.Name, Info = data.Info, Id = data.Id }
self._entries[data.Name] = entry
self:_buildRow(entry, false)
self:_refreshText(entry)
entry.Handle = {
Remove = function()
self:RemoveEntry(data.Name)
end,
SetInfo = function(_, text)
self:SetEntryInfo(data.Name, text)
end,
}
end
self:_resort()
end
function HUD:SetOption(key: string, value: any)
if key == "Visible" then
self:SetVisible(value)
return
end
assert(
self._options[key] ~= nil
or key == "Font"
or key == "GradientFrom"
or key == "GradientTo"
or key == "BorderColor",
`[ClickGUI] Unknown HUD option "{key}"`
)
self._options[key] = value
if key == "Position" then
assert(ANCHORS[value], "[ClickGUI] Invalid HUD position")
self._customPosition = nil
end
if key == "Position" or key == "Offset" or key == "Spacing" then
if key == "Offset" then
self._customPosition = nil
end
self:_applyPosition()
end
if key == "ColorMode" or key == "GradientSpeed" then
self:_applyDriver()
end
self:_rebuild()
end
function HUD:GetOption(key: string)
return self._options[key]
end
function HUD:SetOptions(values)
for key, value in values do
self._options[key] = value
end
if values.Position then
assert(ANCHORS[values.Position], "[ClickGUI] Invalid HUD position")
self._customPosition = nil
end
self:_applyPosition()
self:_applyDriver()
self:_rebuild()
end
function HUD:SetEditable(editable: boolean)
editable = editable == true
if editable == self._editable then
return
end
self._editable = editable
self._editStroke.Enabled = editable
self._list.Active = editable
self.Gui.DisplayOrder = editable and 940 or self._baseOrder
if editable then
if next(self._entries) == nil then
self._preview = true
for _, name in { "Preview A", "Preview B", "Preview C" } do
self:AddEntry(name, "drag me")
end
end
self._dragger = Draggable.new(self._list, self._list, {
OnDragEnd = function()
self._customPosition = self._list.Position
end,
})
local done = Create("TextButton", {
Name = "DoneEditing",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 70),
Size = UDim2.fromOffset(160, 30),
BackgroundTransparency = 0,
BackgroundColor3 = self._theme:Get("Accent"),
Text = "Done editing HUD",
TextColor3 = Color3.new(1, 1, 1),
Font = self._theme:Get("FontBold"),
Parent = self.Gui,
})
Create.corner(done, 8)
self._maid:GiveNamed("done", done)
self._maid:GiveNamed(
"doneClick",
done.MouseButton1Click:Connect(function()
self:SetEditable(false)
end)
)
else
self._maid:Remove("done")
self._maid:Remove("doneClick")
if self._dragger then
self._dragger:Destroy()
self._dragger = nil
end
if self._preview then
self._preview = false
for _, name in { "Preview A", "Preview B", "Preview C" } do
self:RemoveEntry(name)
end
end
end
end
function HUD:IsEditable(): boolean
return self._editable
end
function HUD:ResetPosition()
self._customPosition = nil
self:_applyPosition()
end
function HUD:Export()
local out = {}
for key, value in self._options do
local kind = typeof(value)
if kind == "Color3" then
out[key] = { math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255) }
elseif kind == "Vector2" then
out[key] = { value.X, value.Y }
elseif kind == "EnumItem" then
out[key] = value.Name
else
out[key] = value
end
end
if self._customPosition then
local p = self._customPosition
out.CustomPosition = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
end
out.Visible = self.Gui.Enabled
return out
end
function HUD:Import(data)
if type(data) ~= "table" then
return false
end
local values = {}
for key, value in data do
if key == "CustomPosition" or key == "Visible" then
continue
end
local current = self._options[key]
if COLOR_KEYS[key] and type(value) == "table" and #value == 3 then
values[key] = Color3.fromRGB(value[1], value[2], value[3])
elseif key == "Offset" and type(value) == "table" and #value == 2 then
values[key] = Vector2.new(value[1], value[2])
elseif key == "Font" and type(value) == "string" then
local ok, font = pcall(function()
return Enum.Font[value]
end)
if ok and font then
values[key] = font
end
elseif current ~= nil and type(current) == type(value) then
values[key] = value
end
end
if values.Position and not ANCHORS[values.Position] then
values.Position = nil
end
local p = data.CustomPosition
self:SetOptions(values)
if type(p) == "table" and #p == 4 then
self._customPosition = UDim2.new(p[1], p[2], p[3], p[4])
self:_applyPosition()
end
if data.Visible ~= nil then
self:SetVisible(data.Visible == true)
end
return true
end
function HUD:SetVisible(visible: boolean)
self.Gui.Enabled = visible
end
function HUD:IsVisible(): boolean
return self.Gui.Enabled
end
function HUD:Destroy()
for window in table.clone(self._attached) do
self:Detach(window)
end
if self._dragger then
self._dragger:Destroy()
end
self._maid:Clean()
self.Library:_removeHUD(self)
end
return HUD
end
__functions[__n_Core_InputManager] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Maid = require(script.Parent.Parent.Utilities.Maid)
local CAPTURE_ACTION = "ClickGUI_KeyCapture"
local KEY_NAMES: { [string]: string } = {
LeftShift = "LShift",
RightShift = "RShift",
LeftControl = "LCtrl",
RightControl = "RCtrl",
LeftAlt = "LAlt",
RightAlt = "RAlt",
Return = "Enter",
Backspace = "Back",
Escape = "Esc",
Insert = "Ins",
Delete = "Del",
PageUp = "PgUp",
PageDown = "PgDn",
Zero = "0",
One = "1",
Two = "2",
Three = "3",
Four = "4",
Five = "5",
Six = "6",
Seven = "7",
Eight = "8",
Nine = "9",
Backquote = "`",
Minus = "-",
Equals = "=",
LeftBracket = "[",
RightBracket = "]",
Semicolon = ";",
Quote = "'",
Comma = ",",
Period = ".",
Slash = "/",
BackSlash = "\\",
}
type Binding = {
SetKey: (self: Binding, key: Enum.KeyCode?) -> (),
GetKey: (self: Binding) -> Enum.KeyCode?,
Destroy: (self: Binding) -> (),
_key: Enum.KeyCode?,
_callback: () -> (),
_alive: boolean,
}
type CaptureCallback = (key: Enum.KeyCode?, cancelled: boolean) -> ()
local InputManager = {}
InputManager.__index = InputManager
type InputManager = typeof(setmetatable(
{} :: {
_maid: Maid.Maid,
_bindings: { Binding },
_capture: CaptureCallback?,
},
InputManager
))
local captureKeys: { Enum.KeyCode }? = nil
local function getCaptureKeys(): { Enum.KeyCode }
if captureKeys then
return captureKeys
end
local keys = {}
for _, item in Enum.KeyCode:GetEnumItems() do
if item ~= Enum.KeyCode.Unknown then
table.insert(keys, item)
end
end
captureKeys = keys
return keys
end
function InputManager.KeyName(key: Enum.KeyCode?): string
if key == nil or key == Enum.KeyCode.Unknown then
return "None"
end
return KEY_NAMES[key.Name] or key.Name
end
function InputManager.new(): InputManager
local self: InputManager = setmetatable({
_maid = Maid.new(),
_bindings = {},
_capture = nil,
}, InputManager)
self._maid:Give(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
if self._capture then
self:_handleCapture(input)
return
end
if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
return
end
local snapshot = table.clone(self._bindings)
for _, binding in snapshot do
if binding._alive and binding._key == input.KeyCode then
local ok, err = pcall(binding._callback)
if not ok then
warn("[ClickGUI] Keybind callback error: " .. tostring(err))
end
end
end
end))
return self
end
function InputManager.BindKey(self: InputManager, key: Enum.KeyCode?, callback: () -> ()): Binding
local binding: Binding = {
_key = key,
_callback = callback,
_alive = true,
SetKey = function(b: Binding, newKey: Enum.KeyCode?)
b._key = newKey
end,
GetKey = function(b: Binding): Enum.KeyCode?
return b._key
end,
Destroy = function(b: Binding)
b._alive = false
local index = table.find(self._bindings, b)
if index then
table.remove(self._bindings, index)
end
end,
}
table.insert(self._bindings, binding)
return binding
end
function InputManager.IsCapturing(self: InputManager): boolean
return self._capture ~= nil
end
local function unbindSink()
pcall(function()
ContextActionService:UnbindAction(CAPTURE_ACTION)
end)
end
function InputManager.Capture(self: InputManager, callback: CaptureCallback): () -> ()
self:CancelCapture()
self._capture = callback
pcall(function()
ContextActionService:BindActionAtPriority(CAPTURE_ACTION, function()
return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, table.unpack(getCaptureKeys()))
end)
return function()
if self._capture == callback then
self:CancelCapture()
end
end
end
function InputManager.CancelCapture(self: InputManager)
local callback = self._capture
if callback then
self._capture = nil
unbindSink()
task.spawn(callback, nil, true)
end
end
function InputManager._handleCapture(self: InputManager, input: InputObject)
local callback = self._capture
if not callback then
return
end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
self:CancelCapture()
return
end
if input.UserInputType ~= Enum.UserInputType.Keyboard then
return
end
self._capture = nil
unbindSink()
if input.KeyCode == Enum.KeyCode.Escape then
task.spawn(callback, nil, true)
elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
task.spawn(callback, nil, false)
else
task.spawn(callback, input.KeyCode, false)
end
end
function InputManager.Destroy(self: InputManager)
self._capture = nil
unbindSink()
for _, binding in table.clone(self._bindings) do
binding:Destroy()
end
self._maid:Clean()
end
return InputManager
end
__functions[__n_Core_Loader] = function(script, require)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local Signal = require(Utilities.Signal)
local Loader = {}
Loader.__index = Loader
Loader.StyleNames = { "Bar", "Spinner", "Dots", "Pulse", "Terminal", "Minimal" }
local BUILTIN = {
GameLoaded = function()
return game:IsLoaded()
end,
Character = function()
local player = Players.LocalPlayer
return player ~= nil and player.Character ~= nil
end,
Camera = function()
return workspace.CurrentCamera ~= nil
end,
PlayerGui = function()
local player = Players.LocalPlayer
return player ~= nil and player:FindFirstChildOfClass("PlayerGui") ~= nil
end,
}
local function percentText(value)
return string.format("%d%%", math.floor(value * 100 + 0.5))
end
local function buildBar(self, area, theme, accent)
area.Size = UDim2.fromOffset(320, 22)
local track = Create("Frame", {
Name = "Track",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.fromScale(0, 0.5),
Size = UDim2.new(1, -52, 0, 6),
BackgroundColor3 = theme:Get("Element"),
Parent = area,
})
Create.pill(track)
local fill = Create(
"Frame",
{ Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track }
)
Create.pill(fill)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(accent, theme:Get("AccentDark"))
gradient.Parent = fill
local label = Create("TextLabel", {
Name = "Percent",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.fromScale(1, 0.5),
Size = UDim2.fromOffset(44, 20),
TextXAlignment = Enum.TextXAlignment.Right,
TextColor3 = theme:Get("TextDim"),
Parent = area,
})
return function(progress)
fill.Size = UDim2.fromScale(progress, 1)
label.Text = percentText(progress)
end
end
local function buildSpinner(self, area, theme, accent)
area.Size = UDim2.fromOffset(72, 72)
local base =
Create("Frame", { Name = "Track", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = area })
Create.pill(base)
Create.stroke(base, theme:Get("Element"), 4, 0)
local ring =
Create("Frame", { Name = "Ring", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = area })
Create.pill(ring)
local stroke = Create.stroke(ring, accent, 4, 0)
local gradient = Instance.new("UIGradient")
gradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(0.65, 1),
NumberSequenceKeypoint.new(1, 1),
})
gradient.Parent = stroke
local label = Create("TextLabel", {
Name = "Percent",
Size = UDim2.fromScale(1, 1),
TextSize = 14,
TextColor3 = theme:Get("Text"),
Parent = area,
})
return function(progress, _, elapsed)
gradient.Rotation = (elapsed * 380) % 360
label.Text = percentText(progress)
end
end
local function buildDots(self, area, theme, accent)
area.Size = UDim2.fromOffset(120, 44)
local dots = {}
for index = 1, 3 do
local dot = Create("Frame", {
Name = "Dot" .. index,
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, (index - 2) * 24, 0, 14),
Size = UDim2.fromOffset(12, 12),
BackgroundColor3 = accent,
Parent = area,
})
Create.pill(dot)
dots[index] = dot
end
local label = Create("TextLabel", {
Name = "Percent",
AnchorPoint = Vector2.new(0.5, 1),
Position = UDim2.fromScale(0.5, 1),
Size = UDim2.fromOffset(60, 14),
TextSize = 11,
TextColor3 = theme:Get("TextDim"),
Parent = area,
})
return function(progress, _, elapsed)
for index, dot in dots do
local wave = math.max(math.sin(elapsed * 6 - index * 0.7), 0)
dot.Position = UDim2.new(0.5, (index - 2) * 24, 0, 14 - wave * 10)
dot.BackgroundTransparency = 0.5 - wave * 0.5
end
label.Text = percentText(progress)
end
end
local function buildPulse(self, area, theme, accent)
area.Size = UDim2.fromOffset(110, 110)
local rings = {}
for index = 1, 3 do
local ring = Create("Frame", {
Name = "Ring" .. index,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
BackgroundTransparency = 1,
Parent = area,
})
Create.pill(ring)
rings[index] = { Frame = ring, Stroke = Create.stroke(ring, accent, 2, 0) }
end
local core = Create("Frame", {
Name = "Core",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(26, 26),
BackgroundColor3 = accent,
Parent = area,
})
Create.pill(core)
return function(progress, _, elapsed)
for index, data in rings do
local phase = (elapsed * 0.7 + index / 3) % 1
local size = 26 + phase * 84
data.Frame.Size = UDim2.fromOffset(size, size)
data.Stroke.Transparency = phase
end
local beat = 1 + math.sin(elapsed * 5) * 0.08
core.Size = UDim2.fromOffset(26 * beat, 26 * beat)
core.BackgroundTransparency = 0.15 + (1 - progress) * 0.0
end
end
local function buildTerminal(self, area, theme, accent)
area.Size = UDim2.fromOffset(400, 170)
local box = Create(
"Frame",
{ Name = "Terminal", Size = UDim2.fromScale(1, 1), BackgroundColor3 = theme:Get("Panel"), Parent = area }
)
Create.corner(box, 8)
Create.stroke(box, theme:Get("Stroke"), 1, 0.3)
Create.padding(box, 10, 12, 10, 12)
local text = Create("TextLabel", {
Name = "Log",
Size = UDim2.fromScale(1, 1),
Font = Enum.Font.Code,
TextSize = 13,
TextColor3 = accent,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
Parent = box,
})
local last = ""
return function(progress, _, elapsed)
local lines = { "> boot " .. string.lower(self.Title) }
for _, item in self._items do
table.insert(lines, (item.Done and "[ OK ] " or "[ .. ] ") .. item.Name)
end
if #self._items == 0 then
table.insert(lines, "[ .. ] " .. (self._status or "working"))
end
local filled = math.floor(progress * 20 + 0.5)
table.insert(
lines,
"[" .. string.rep("#", filled) .. string.rep("-", 20 - filled) .. "] " .. percentText(progress)
)
table.insert(lines, (elapsed % 1 < 0.5) and "_" or " ")
local joined = table.concat(lines, "\n")
if joined ~= last then
last = joined
text.Text = joined
end
end
end
local function buildMinimal(self, area, theme, accent)
area.Size = UDim2.fromOffset(0, 0)
local line = Create("Frame", {
Name = "Line",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1),
Size = UDim2.new(0, 0, 0, 3),
BackgroundColor3 = accent,
Parent = self._root,
})
return function(progress)
line.Size = UDim2.new(progress, 0, 0, 3)
end
end
local BUILDERS = {
Bar = buildBar,
Spinner = buildSpinner,
Dots = buildDots,
Pulse = buildPulse,
Terminal = buildTerminal,
Minimal = buildMinimal,
}
function Loader.new(library, options: Types.LoaderOptions)
options = options or {}
local self = setmetatable({}, Loader)
local theme = library.Theme
self.Library = library
self.Title = options.Title or "Loading"
self.Subtitle = options.Subtitle
self.Style = BUILDERS[options.Style or "Bar"] and (options.Style or "Bar") or "Bar"
self.MinTime = options.MinTime or 1.5
self.Timeout = options.Timeout
self.TimeoutAction = options.TimeoutAction or "Finish"
self.Mode = options.Mode == "Any" and "Any" or "All"
self.AutoFinish = options.AutoFinish ~= false
self.Finished = Signal.new()
self.Failed = Signal.new()
self.ProgressChanged = Signal.new()
self._maid = Maid.new()
self._items = {}
self._elapsed = 0
self._display = 0
self._manual = nil
self._status = nil
self._finished = false
self._failed = false
self._destroyed = false
self._onTimeout = options.OnTimeout
for _, name in options.Tasks or {} do
table.insert(self._items, { Name = tostring(name), Done = false })
end
for _, condition in options.Conditions or {} do
self:AddCondition(condition)
end
local accent = options.Color or theme:Get("Accent")
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_Loader",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 950,
Parent = options.Parent or library:GetGuiParent(),
})
self._maid:Give(self.Gui)
library:_secureGui(self.Gui)
self._root = Create("CanvasGroup", {
Name = "Root",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = options.BackgroundColor or theme:Get("Background"),
BackgroundTransparency = options.BackgroundTransparency or 0,
Active = true,
Parent = self.Gui,
})
local center = Create("Frame", {
Name = "Center",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.new(),
AutomaticSize = Enum.AutomaticSize.XY,
BackgroundTransparency = 1,
Parent = self._root,
})
local layout = Create.list(center, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
if options.Logo then
local holder = Create("Frame", {
Name = "Logo",
Size = UDim2.fromOffset(64, 64),
BackgroundTransparency = 1,
LayoutOrder = 1,
Parent = center,
})
Visual.icon(
holder,
options.Logo,
56,
accent,
{ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }
)
end
self._titleLabel = Create("TextLabel", {
Name = "Title",
Size = UDim2.fromOffset(420, 34),
Text = self.Title,
TextSize = 28,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
LayoutOrder = 2,
Parent = center,
})
self._subtitleLabel = Create("TextLabel", {
Name = "Subtitle",
Size = UDim2.fromOffset(420, 16),
Text = self.Subtitle or "",
TextSize = 13,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
Visible = self.Subtitle ~= nil,
LayoutOrder = 3,
Parent = center,
})
local area = Create("Frame", { Name = "Style", BackgroundTransparency = 1, LayoutOrder = 4, Parent = center })
self._update = BUILDERS[self.Style](self, area, theme, accent)
self._statusLabel = Create("TextLabel", {
Name = "Status",
Size = UDim2.fromOffset(420, 16),
Text = "",
TextSize = 12,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
LayoutOrder = 5,
Parent = center,
})
self._theme = theme
self._maid:Give(RunService.Heartbeat:Connect(function(dt)
self:_step(dt)
end))
return self
end
function Loader:_itemsDone()
local done = 0
for _, item in self._items do
if item.Done then
done += 1
end
end
return done
end
function Loader:_requirementsMet()
if #self._items == 0 then
return true
end
local done = self:_itemsDone()
if self.Mode == "Any" then
return done >= 1
end
return done == #self._items
end
function Loader:_target()
if self._manual ~= nil then
return self._manual
end
if #self._items == 0 then
return 1
end
if self.Mode == "Any" then
return self:_requirementsMet() and 1 or 0.85
end
return self:_itemsDone() / #self._items
end
function Loader:_pendingText()
local pending = {}
for _, item in self._items do
if not item.Done then
table.insert(pending, item.Name)
end
end
if #pending == 0 then
return "Ready"
end
return (self.Mode == "Any" and "Waiting for any of: " or "Waiting for: ") .. table.concat(pending, ", ")
end
function Loader:_step(dt)
if self._destroyed or self._failed then
return
end
self._elapsed += dt
for _, item in self._items do
if not item.Done and item.Check then
local ok, result = pcall(item.Check)
if ok and result then
item.Done = true
end
end
end
local target = math.min(self:_target(), self._elapsed / math.max(self.MinTime, 0.01))
if self._finished then
target = 1
end
self._display += (target - self._display) * math.min(dt * 6, 1)
if math.abs(target - self._display) < 0.002 then
self._display = target
end
self.ProgressChanged:Fire(self._display)
self._statusLabel.Text = self._status or self:_pendingText()
self._update(self._display, dt, self._elapsed)
if self._finished then
return
end
if self.Timeout and self._elapsed >= self.Timeout then
if self._onTimeout then
pcall(self._onTimeout)
end
if self.TimeoutAction == "Fail" then
self:Fail("Timed out")
else
self:Finish()
end
return
end
if self.AutoFinish and self._elapsed >= self.MinTime and self:_requirementsMet() and self._display >= 0.985 then
self:Finish()
end
end
function Loader:SetProgress(value: number)
assert(type(value) == "number", "[ClickGUI] SetProgress expects a number (0-1)")
self._manual = math.clamp(value, 0, 1)
end
function Loader:GetProgress(): number
return self._display
end
function Loader:SetStatus(text: string?)
self._status = text
end
function Loader:SetTitle(text: string)
self.Title = text
self._titleLabel.Text = text
end
function Loader:SetSubtitle(text: string?)
self.Subtitle = text
self._subtitleLabel.Text = text or ""
self._subtitleLabel.Visible = text ~= nil
end
function Loader:AddTask(name: string)
local item = { Name = tostring(name), Done = false }
table.insert(self._items, item)
return {
Name = item.Name,
Complete = function()
item.Done = true
end,
IsDone = function()
return item.Done
end,
}
end
function Loader:CompleteTask(name: string)
for _, item in self._items do
if item.Name == name then
item.Done = true
end
end
end
function Loader:AddCondition(condition, check)
if type(condition) == "string" then
local fn = check or BUILTIN[condition]
assert(
type(fn) == "function",
`[ClickGUI] Unknown condition "{condition}" (GameLoaded, Character, Camera, PlayerGui or pass a function)`
)
table.insert(self._items, { Name = condition, Done = false, Check = fn })
elseif type(condition) == "function" then
table.insert(self._items, { Name = "Condition " .. (#self._items + 1), Done = false, Check = condition })
elseif type(condition) == "table" and type(condition.Check) == "function" then
table.insert(self._items, { Name = condition.Name or "Condition", Done = false, Check = condition.Check })
else
error("[ClickGUI] Invalid loader condition")
end
end
function Loader:Finish()
if self._finished or self._failed or self._destroyed then
return
end
self._finished = true
self._statusLabel.Text = "Done"
self.Finished:Fire()
AnimationManager.Play(
self._root,
TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
{ GroupTransparency = 1 }
)
task.delay(0.6, function()
self:Destroy()
end)
end
function Loader:Fail(message: string?)
if self._finished or self._failed or self._destroyed then
return
end
self._failed = true
local theme = self._theme
self._statusLabel.Text = "Failed: " .. tostring(message or "unknown error")
self._statusLabel.TextColor3 = theme:Get("Error")
local close = Create("TextButton", {
Name = "Dismiss",
AnchorPoint = Vector2.new(0.5, 1),
Position = UDim2.new(0.5, 0, 1, -40),
Size = UDim2.fromOffset(120, 32),
BackgroundTransparency = 0,
BackgroundColor3 = theme:Get("Element"),
Text = "Close",
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
Parent = self._root,
})
Create.corner(close, 8)
self._maid:Give(close.MouseButton1Click:Connect(function()
self:Destroy()
end))
self.Failed:Fire(message)
end
function Loader:IsFinished(): boolean
return self._finished
end
function Loader:Wait(): boolean
if self._finished then
return true
end
if self._failed or self._destroyed then
return false
end
local thread = coroutine.running()
local resumed = false
local function resume(ok)
if resumed then
return
end
resumed = true
task.spawn(thread, ok)
end
self.Finished:Once(function()
resume(true)
end)
self.Failed:Once(function()
resume(false)
end)
return coroutine.yield()
end
function Loader:Destroy()
if self._destroyed then
return
end
self._destroyed = true
self._maid:Clean()
self.Finished:Destroy()
self.Failed:Destroy()
self.ProgressChanged:Destroy()
self.Library:_removeLoader(self)
end
return Loader
end
__functions[__n_Core_Module] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Components = script.Parent.Parent.Components
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local Signal = require(Utilities.Signal)
local InputManager = require(script.Parent.InputManager)
local HEADER_HEIGHT = 30
local HEADER_HEIGHT_WITH_DESCRIPTION = 42
local KEYBIND_ORDER = 1000000
local PIN_ORDER = 1000000
local orderCounter = 0
local Module = {}
Module.__index = Module
local function escape(text)
text = string.gsub(text, "&", "&amp;")
text = string.gsub(text, "<", "&lt;")
return (string.gsub(text, ">", "&gt;"))
end
function Module.new(ctx, category, options: Types.ModuleOptions)
assert(
type(options) == "table" and type(options.Name) == "string",
"[ClickGUI] CreateModule needs an options table with a `Name`"
)
orderCounter += 1
local self = setmetatable({}, Module)
local theme = ctx.Theme
local S = ctx.Window.StyleData.Module
local row = S.Layout == "Row"
self.Name = options.Name
self.Description = options.Description
self.Category = category
self.Window = ctx.Window
self.Enabled = false
self.Toggleable = options.Toggleable ~= false
self.ShowInHUD = options.ShowInHUD ~= false and self.Toggleable
self.Info = nil
self.Components = {}
self.Changed = Signal.new()
self._ctx = ctx
self._callback = options.Callback
self._maid = Maid.new()
self._visible = true
self._searchMatch = true
self._expanded = false
self._hovered = false
self._destroyed = false
self._animating = false
self._animToken = 0
self._order = orderCounter
self._favorite = false
self._pinned = false
self._row = row
self._defaultEnabled = options.Default == true and self.Toggleable
self._iconActive = options.IconActiveColor
self._iconInactive = options.IconInactiveColor
local hasDescription = (not row) and options.Description ~= nil and options.Description ~= ""
local headerHeight = hasDescription and S.HeightDesc or S.Height
local iconSize = options.IconSize or 14
local leftPad = options.Icon and (10 + iconSize + 6) or 12
local nameSize = theme:Get("ModuleTextSize")
local nameHeight = nameSize + 5
local nameY, descY = 0, 0
if hasDescription then
local total = nameHeight + 2 + 15
nameY = math.floor((headerHeight - total) / 2)
descY = nameY + nameHeight + 2
end
local rightPad = row and 82 or (S.SwitchW + 70)
self.Frame = Create("Frame", {
Name = "Module_" .. options.Name,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundColor3 = theme:Get("Module"),
BackgroundTransparency = row and 1 or 0,
LayoutOrder = orderCounter,
Parent = category.List,
})
if row then
Visual.corner(theme, self.Frame, -4)
else
Visual.surface(theme, self.Frame, "module", 0.08)
theme:Bind(self.Frame, "BackgroundTransparency", function(t)
return t.ModuleTransparency or 0
end)
end
Create.list(self.Frame, 0)
self._header = Create("TextButton", {
Name = "Header",
Size = UDim2.new(1, 0, 0, headerHeight),
LayoutOrder = 1,
Parent = self.Frame,
})
if not row then
self._glow = Create("Frame", {
Name = "Glow",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = theme:Get("Accent"),
BackgroundTransparency = 1,
Parent = self._header,
})
Visual.corner(theme, self._glow, -2)
Create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = self._glow })
self._bar = Create("Frame", {
Name = "Bar",
Position = UDim2.new(0, 0, 0, 6),
Size = UDim2.new(0, 2, 1, -12),
BackgroundColor3 = theme:Get("Accent"),
BackgroundTransparency = 1,
Parent = self._header,
})
Create.pill(self._bar)
end
self._iconSize = iconSize
if options.Icon then
self._icon = Visual.icon(self._header, options.Icon, iconSize, theme:Get("TextDim"), {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
})
end
self._nameLabel = Create("TextLabel", {
Name = "Name",
Position = UDim2.fromOffset(leftPad, nameY),
Size = UDim2.new(1, -(leftPad + rightPad), 0, hasDescription and nameHeight or headerHeight),
Text = options.Name,
TextSize = nameSize,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Font = theme:Get(S.Layout == "Card" and S.HeightDesc > 50 and "FontBold" or "Font"),
TextColor3 = theme:Get("Text"),
Parent = self._header,
})
theme:Bind(self._nameLabel, "Font", S.Layout == "Card" and S.HeightDesc > 50 and "FontBold" or "Font")
theme:Bind(self._nameLabel, "TextSize", "ModuleTextSize")
if hasDescription then
self._descLabel = Create("TextLabel", {
Name = "Description",
Position = UDim2.fromOffset(leftPad, descY),
Size = UDim2.new(1, -(leftPad + rightPad), 0, 15),
Text = options.Description,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
Parent = self._header,
})
theme:Bind(self._descLabel, "TextColor3", "TextDim")
theme:Bind(self._descLabel, "Font", "Font")
end
if row then
self._keyTag = Create("TextLabel", {
Name = "KeyTag",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -56, 0.5, 0),
Size = UDim2.fromOffset(0, 14),
AutomaticSize = Enum.AutomaticSize.X,
Text = "",
TextSize = 11,
TextColor3 = theme:Get("TextDim"),
Font = theme:Get("Font"),
Parent = self._header,
})
theme:Bind(self._keyTag, "TextColor3", "TextDim")
end
local icons = ctx.Window.FavoriteIcons
local starX = row and -34 or ((self.Toggleable and -(S.SwitchW + 14)) or -8) - 26
self._star = Create("ImageButton", {
Name = "Favorite",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, starX, 0.5, 0),
Size = UDim2.fromOffset(18, 18),
Image = icons.Off,
ImageColor3 = theme:Get("TextDim"),
ImageTransparency = row and 1 or 0.35,
ZIndex = 3,
Parent = self._header,
})
self._starHover = false
self._maid:Give(self._star.MouseButton1Click:Connect(function()
self:SetFavorite(not self._favorite)
end))
self._maid:Give(self._star.MouseEnter:Connect(function()
self._starHover = true
self:_renderStar(true)
end))
self._maid:Give(self._star.MouseLeave:Connect(function()
self._starHover = false
self:_renderStar(true)
end))
self._pinMark = Create("Frame", {
Name = "Pinned",
Position = UDim2.fromOffset(leftPad, 0),
Size = UDim2.fromOffset(18, 2),
BackgroundColor3 = theme:Get("Accent"),
Visible = false,
Parent = self._header,
})
Create.pill(self._pinMark)
theme:Bind(self._pinMark, "BackgroundColor3", "Accent")
if self.Toggleable and not row then
local knobSize = S.SwitchH - 4
self._knobOn = UDim2.new(0, S.SwitchW - knobSize - 2, 0.5, 0)
self._track = Create("Frame", {
Name = "Switch",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.fromOffset(S.SwitchW, S.SwitchH),
BackgroundColor3 = theme:Get("Element"),
Parent = self._header,
})
Create.pill(self._track)
self._knob = Create("Frame", {
Name = "Knob",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 2, 0.5, 0),
Size = UDim2.fromOffset(knobSize, knobSize),
BackgroundColor3 = theme:Get("TextDim"),
Parent = self._track,
})
Create.pill(self._knob)
end
self._chevronButton = Create("TextButton", {
Name = "Expand",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, row and -6 or ((self.Toggleable and -(S.SwitchW + 14)) or -8), 0.5, 0),
Size = UDim2.fromOffset(24, 24),
Text = row and "" or "›",
TextSize = 20,
TextColor3 = theme:Get("TextDim"),
Visible = false,
Parent = self._header,
})
theme:Bind(self._chevronButton, "TextColor3", "TextDim")
if row then
self._dots = {}
for index = 0, 3 do
local dot = Create("Frame", {
Name = "Dot",
Position = UDim2.new(0.5, -4 + (index % 2) * 5, 0.5, -4 + math.floor(index / 2) * 5),
Size = UDim2.fromOffset(3, 3),
BackgroundColor3 = theme:Get("TextDim"),
Parent = self._chevronButton,
})
Create.pill(dot)
self._dots[index + 1] = dot
end
end
self._clip = Create("Frame", {
Name = "Settings",
Size = UDim2.new(1, 0, 0, 0),
BackgroundTransparency = 1,
ClipsDescendants = true,
LayoutOrder = 2,
Parent = self.Frame,
})
local separator = Create("Frame", {
Name = "Separator",
Position = UDim2.fromOffset(8, 0),
Size = UDim2.new(1, -16, 0, 1),
BackgroundColor3 = theme:Get("Stroke"),
BackgroundTransparency = row and 1 or 0.5,
Parent = self._clip,
})
theme:Bind(separator, "BackgroundColor3", "Stroke")
self._inner = Create("Frame", {
Name = "Content",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = self._clip,
})
Create.padding(self._inner, 8, 8, 8, 8)
Create.list(self._inner, 5)
self._maid:Give(self._header.MouseButton1Click:Connect(function()
if self.Toggleable then
self:Toggle()
else
self:ToggleExpanded()
end
end))
self._maid:Give(self._header.MouseButton2Click:Connect(function()
self:ToggleExpanded()
end))
self._maid:Give(self._chevronButton.MouseButton1Click:Connect(function()
self:ToggleExpanded()
end))
self._maid:Give(self._header.MouseEnter:Connect(function()
self._hovered = true
self:_renderStar(true)
self:_render(true)
end))
self._maid:Give(self._header.MouseLeave:Connect(function()
self._hovered = false
self:_renderStar(true)
self:_render(true)
end))
self._maid:Give(self._inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
self:_updateHeight()
end))
self._maid:Give(theme.Changed:Connect(function()
self:_render(true)
end))
self:_render(false)
self:_renderStar(false)
local tooltip = options.Tooltip or (row and options.Description or nil)
if tooltip then
self:SetTooltip(tooltip)
end
if self.Toggleable then
if options.ShowKeybind ~= false then
local keybind = self:CreateKeybind({
Name = "Keybind",
Default = options.Keybind,
OnPressed = function()
self:Toggle()
end,
})
keybind.Frame.LayoutOrder = KEYBIND_ORDER
self.KeybindComponent = keybind
if self._keyTag then
local function refresh(key)
self._keyTag.Text = key and ("[" .. InputManager.KeyName(key) .. "]") or ""
end
refresh(keybind.Value)
self._maid:Give(keybind.Changed:Connect(refresh))
end
elseif options.Keybind then
self._maid:Give(ctx.Input:BindKey(options.Keybind, function()
self:Toggle()
end))
if self._keyTag then
self._keyTag.Text = "[" .. InputManager.KeyName(options.Keybind) .. "]"
end
end
end
if options.Default and self.Toggleable then
task.defer(function()
if not self._destroyed then
self:SetEnabled(true)
end
end)
end
if options.Expanded then
task.defer(function()
if not self._destroyed then
self:SetExpanded(true)
end
end)
end
if options.Favorite then
self:SetFavorite(true)
end
if options.Pinned then
self:SetPinned(true)
end
return self
end
function Module:_render(animated)
local theme = self._ctx.Theme
local preset = animated and "Fast" or "Instant"
local accent = theme:Get("Accent")
local base = theme:Get("Module")
local hovered = self._hovered
local enabled = self.Enabled
if self._row then
local background, transparency = theme:Get("Element"), 1
if enabled then
transparency = 0.4
end
if hovered then
background = theme:Get("ModuleHover")
transparency = enabled and 0.25 or 0.55
end
AnimationManager.Play(
self.Frame,
preset,
{ BackgroundColor3 = background, BackgroundTransparency = transparency }
)
AnimationManager.Play(self._nameLabel, preset, {
TextColor3 = (enabled or not self.Toggleable) and theme:Get("Text")
or theme:Get("TextDim"):Lerp(theme:Get("Text"), hovered and 0.55 or 0.15),
})
for _, dot in self._dots do
AnimationManager.Play(dot, preset, { BackgroundColor3 = self._expanded and accent or theme:Get("TextDim") })
end
else
local background = base
if enabled then
background = base:Lerp(accent, 0.1)
end
if hovered then
background = background:Lerp(theme:Get("ModuleHover"), 0.7)
end
AnimationManager.Play(self.Frame, preset, {
BackgroundColor3 = background,
BackgroundTransparency = theme:Get("Transparency"),
})
AnimationManager.Play(
self._bar,
preset,
{ BackgroundTransparency = enabled and 0 or 1, BackgroundColor3 = accent }
)
AnimationManager.Play(
self._glow,
preset,
{ BackgroundTransparency = enabled and 0.82 or 1, BackgroundColor3 = accent }
)
AnimationManager.Play(self._nameLabel, preset, {
TextColor3 = (enabled or not self.Toggleable) and theme:Get("Text")
or theme:Get("TextDim"):Lerp(theme:Get("Text"), hovered and 0.6 or 0.25),
})
end
if self._icon then
local active = self._iconActive or accent
local inactive = self._iconInactive or theme:Get("TextDim")
AnimationManager.Play(self._icon.Instance, preset, {
[self._icon.Property] = (enabled or not self.Toggleable) and active or inactive,
})
end
if self._track then
AnimationManager.Play(self._track, preset, { BackgroundColor3 = enabled and accent or theme:Get("Element") })
AnimationManager.Play(self._knob, animated and "Pop" or "Instant", {
Position = enabled and self._knobOn or UDim2.new(0, 2, 0.5, 0),
BackgroundColor3 = enabled and Color3.new(1, 1, 1) or theme:Get("TextDim"),
})
end
end
function Module:_updateHeight()
if self._destroyed then
return
end
local target = 0
if self._expanded then
target = self._inner.AbsoluteSize.Y / math.max(self._ctx.GetScale(), 0.01)
end
AnimationManager.Play(self._clip, self._animating and "Expand" or "Instant", { Size = UDim2.new(1, 0, 0, target) })
end
function Module:_applyVisibility()
local window = self.Window
local favoriteOk = not window._favoritesOnly or self._favorite
self.Frame.Visible = self._visible and self._searchMatch and favoriteOk
end
function Module:_isShown()
return self.Frame.Visible
end
function Module:_refreshChevron()
self._chevronButton.Visible = #self.Components > 0
end
function Module:_setHighlight(query)
local label = self._nameLabel
local s, e
if query ~= "" then
s, e = string.find(string.lower(self.Name), query, 1, true)
end
if not s then
label.RichText = false
label.Text = self.Name
return
end
local accent = self._ctx.Theme:Get("Accent")
label.RichText = true
label.Text = escape(string.sub(self.Name, 1, s - 1))
.. '<font color="#'
.. accent:ToHex()
.. '"><b>'
.. escape(string.sub(self.Name, s, e))
.. "</b></font>"
.. escape(string.sub(self.Name, e + 1))
end
function Module:SetEnabled(state: boolean)
if not self.Toggleable then
return
end
state = not not state
if state == self.Enabled then
return
end
self.Enabled = state
self:_render(true)
self.Changed:Fire(state)
if self._callback then
local ok, err = pcall(self._callback, state)
if not ok then
warn(`[ClickGUI] Callback error in module "{self.Name}": {err}`)
end
end
self.Window.ModuleToggled:Fire(self, state)
end
function Module:Toggle()
self:SetEnabled(not self.Enabled)
end
function Module:IsEnabled(): boolean
return self.Enabled
end
function Module:SetInfo(text: string?)
if self.Info == text then
return
end
self.Info = text
self.Window.ModuleInfoChanged:Fire(self)
end
function Module:SetTooltip(text)
self._maid:Remove("tooltip")
local tooltip = self.Window.Tooltip
if text ~= nil and tooltip then
self._maid:GiveNamed("tooltip", tooltip:Attach(self._header, text))
end
end
function Module:_renderStar(animated)
if not self._star then
return
end
local theme = self._ctx.Theme
local icons = self.Window.FavoriteIcons
local preset = animated and "Fast" or "Instant"
local image, color, transparency
if self._favorite then
image, color, transparency = icons.On, theme:Get("Warning"), 0
elseif self._starHover then
image, color, transparency = icons.Hover, theme:Get("Warning"):Lerp(theme:Get("TextDim"), 0.4), 0
else
image, color = icons.Off, theme:Get("TextDim")
transparency = self._row and (self._hovered and 0.35 or 1) or 0.4
end
self._star.Image = image
AnimationManager.Play(self._star, preset, { ImageColor3 = color, ImageTransparency = transparency })
end
function Module:SetFavorite(value: boolean)
value = not not value
if value == self._favorite then
return
end
self._favorite = value
self:_renderStar(true)
self.Window:_onFavoritesChanged(self)
end
function Module:SetPinned(value: boolean)
value = not not value
if value == self._pinned then
return
end
self._pinned = value
self._pinMark.Visible = value
self.Frame.LayoutOrder = value and (self._order - PIN_ORDER) or self._order
self.Window:_onFavoritesChanged(self)
end
function Module:IsFavorite(): boolean
return self._favorite
end
function Module:IsPinned(): boolean
return self._pinned
end
function Module:SetIcon(spec)
if not self._icon then
warn("[ClickGUI] SetIcon needs the module to be created with an Icon")
return
end
local old = self._icon
self._icon = Visual.icon(self._header, spec, self._iconSize, old.Instance[old.Property], {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
})
old.Instance:Destroy()
self:_render(false)
end
function Module:SetVisible(visible: boolean)
self._visible = visible
self:_applyVisibility()
self.Window:_onModuleVisibilityChanged()
end
function Module:SetExpanded(expanded: boolean)
if #self.Components == 0 then
expanded = false
end
if expanded == self._expanded then
return
end
self._expanded = expanded
self._animating = true
self._animToken += 1
local token = self._animToken
task.delay(AnimationManager.Time(0.3), function()
if self._animToken == token then
self._animating = false
end
end)
if self._row then
self:_render(true)
else
AnimationManager.Play(self._chevronButton, "Normal", { Rotation = expanded and 90 or 0 })
end
self:_updateHeight()
end
function Module:Expand()
self:SetExpanded(true)
end
function Module:Collapse()
self:SetExpanded(false)
end
function Module:ToggleExpanded()
self:SetExpanded(not self._expanded)
end
function Module:_add(constructor, options)
assert(not self._destroyed, "[ClickGUI] This module was destroyed")
assert(type(options) == "table", "[ClickGUI] Component options must be a table")
local component = constructor(self._ctx, self._inner, options, self)
component.Module = self
table.insert(self.Components, component)
component.Frame.LayoutOrder = #self.Components
if options.Flag then
self.Window:_registerFlag(options.Flag, component)
end
if options.Tooltip then
component:SetTooltip(options.Tooltip)
end
if options.Disabled then
component:SetEnabled(false)
end
component._default = component:Serialize()
component._persist = options.Persist ~= false and not component.NoPersist
if component._initKeybind then
component:_initKeybind(options)
end
self:_refreshChevron()
return component
end
function Module:_removeComponent(component)
local index = table.find(self.Components, component)
if index then
table.remove(self.Components, index)
end
if not self._destroyed then
self:_refreshChevron()
if #self.Components == 0 then
self:SetExpanded(false)
end
end
end
local function lazy(name)
return function(self, options)
return self:_add(require(Components[name]).new, options)
end
end
Module.CreateToggle = lazy("Toggle")
Module.CreateSlider = lazy("Slider")
Module.CreateDropdown = lazy("Dropdown")
Module.CreateKeybind = lazy("Keybind")
Module.CreateColorPicker = lazy("ColorPicker")
Module.CreateGraphic = lazy("Graphic")
Module.CreateTextbox = lazy("Textbox")
Module.CreateButton = lazy("Button")
Module.CreateRangeSlider = lazy("RangeSlider")
Module.CreateInputNumber = lazy("InputNumber")
Module.CreateProgressBar = lazy("ProgressBar")
Module.CreateImageButton = lazy("ImageButton")
function Module:CreateSearchableDropdown(options)
options.Searchable = true
return self:CreateDropdown(options)
end
function Module:CreateKeybindList(options)
return self:_add(require(Components.KeybindList).new, options or {})
end
function Module:CreateSection(name: string)
return self:_add(require(Components.Section).new, { Name = name })
end
function Module:CreateLabel(text: string)
return self:_add(require(Components.Label).new, { Name = "Label", Text = text })
end
function Module:CreateCustom(constructor, options)
return self:_add(constructor, options or { Name = "Custom" })
end
function Module.RegisterComponent(name: string, constructor)
local method = "Create" .. name
assert(rawget(Module, method) == nil, `[ClickGUI] A component method named "{method}" already exists`)
Module[method] = function(self, options)
return self:_add(constructor, options)
end
end
function Module:GetComponent(name: string)
for _, component in self.Components do
if component.Name == name then
return component
end
end
return nil
end
function Module:Destroy()
if self._destroyed then
return
end
if self.Enabled then
self.Enabled = false
self.Window.ModuleToggled:Fire(self, false)
end
self._destroyed = true
self.Window:_unregisterModule(self)
for _, component in table.clone(self.Components) do
component:Destroy()
end
self._maid:Clean()
self.Changed:Destroy()
self.Frame:Destroy()
end
return Module
end
__functions[__n_Core_Notifications] = function(script, require)
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Utilities = script.Parent.Parent.Utilities
local Components = script.Parent.Parent.Components
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local Fonts = require(script.Parent.Fonts)
local UIShadow = require(Components.UIShadow)
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local Notifications = {}
Notifications.__index = Notifications
local GAP = 10
Notifications.Defaults =
{ Position = "BottomRight", MaxVisible = 5, Width = 300, Style = "Modern", Duration = 4, Margin = 16 }
local POSITIONS = {
BottomRight = { Anchor = Vector2.new(1, 1), Pos = UDim2.fromScale(1, 1), Bottom = true, Slide = Vector2.new(1, 0) },
BottomLeft = { Anchor = Vector2.new(0, 1), Pos = UDim2.fromScale(0, 1), Bottom = true, Slide = Vector2.new(-1, 0) },
BottomCenter = {
Anchor = Vector2.new(0.5, 1),
Pos = UDim2.fromScale(0.5, 1),
Bottom = true,
Slide = Vector2.new(0, 1),
},
TopRight = { Anchor = Vector2.new(1, 0), Pos = UDim2.fromScale(1, 0), Bottom = false, Slide = Vector2.new(1, 0) },
TopLeft = { Anchor = Vector2.new(0, 0), Pos = UDim2.fromScale(0, 0), Bottom = false, Slide = Vector2.new(-1, 0) },
TopCenter = {
Anchor = Vector2.new(0.5, 0),
Pos = UDim2.fromScale(0.5, 0),
Bottom = false,
Slide = Vector2.new(0, -1),
},
}
local GLYPHS = { Info = "i", Success = "✓", Warning = "!", Error = "×" }
local STYLES = { Modern = true, Minimal = true, Banner = true }
local function typeColor(theme, kind)
if kind == "Success" then
return theme:Get("Success")
elseif kind == "Warning" then
return theme:Get("Warning")
elseif kind == "Error" then
return theme:Get("Error")
end
return theme:Get("Info")
end
function Notifications.new(theme, parent, config, library)
local self = setmetatable({}, Notifications)
self._theme = theme
self._library = library
self._maid = Maid.new()
self._items = {}
self._config = table.clone(Notifications.Defaults)
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_Notifications",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 1000,
Parent = parent,
})
self._maid:Give(self.Gui)
self._container = Create("Frame", { Name = "Container", BackgroundTransparency = 1, Parent = self.Gui })
self:SetConfig(config or {})
if library then
library:_secureGui(self.Gui)
end
return self
end
function Notifications:GetConfig()
return table.clone(self._config)
end
function Notifications:SetConfig(config)
local current = self._config
for key, value in config do
if key == "Position" and not POSITIONS[value] then
warn(`[ClickGUI] Unknown notification position "{value}"`)
elseif key == "Style" and not STYLES[value] then
warn(`[ClickGUI] Unknown notification style "{value}" (Modern, Minimal, Banner)`)
elseif current[key] ~= nil then
current[key] = value
end
end
local data = POSITIONS[current.Position]
local margin = current.Margin
self._container.AnchorPoint = data.Anchor
self._container.Position = data.Pos
+ UDim2.fromOffset(
(data.Anchor.X == 1 and -margin) or (data.Anchor.X == 0 and margin or 0),
(data.Anchor.Y == 1 and -margin) or (data.Anchor.Y == 0 and margin or 0)
)
self._container.Size = UDim2.new(0, current.Width, 1, -margin * 2)
self:_layout(false)
end
function Notifications:_layout(animated)
local data = POSITIONS[self._config.Position]
local offset = 0
for index = #self._items, 1, -1 do
local item = self._items[index]
if not item.Dismissed then
local target
if data.Bottom then
item.Holder.AnchorPoint = Vector2.new(0, 1)
target = UDim2.new(0, 0, 1, -offset)
else
item.Holder.AnchorPoint = Vector2.new(0, 0)
target = UDim2.new(0, 0, 0, offset)
end
AnimationManager.Play(item.Holder, animated and "Expand" or "Instant", { Position = target })
offset += item.Height + GAP
end
end
end
function Notifications:_startTicker()
if self._ticking then
return
end
self._ticking = true
self._maid:GiveNamed(
"ticker",
RunService.Heartbeat:Connect(function(dt)
local active = false
for _, item in table.clone(self._items) do
if not item.Dismissed then
active = true
if not item.Sticky and not item.Paused then
item.Remaining -= dt
if item.Fill then
item.Fill.Size = UDim2.new(math.max(item.Remaining / item.Duration, 0), 0, 1, 0)
end
if item.Remaining <= 0 then
item.Dismiss()
end
end
end
end
if not active then
self._maid:Remove("ticker")
self._ticking = false
end
end)
)
end
local function measure(text, size, font, width)
if text == nil or text == "" then
return 0
end
return TextService:GetTextSize(text, size, font, Vector2.new(width, 10000)).Y
end
function Notifications:Notify(options: Types.NotifyOptions)
assert(type(options) == "table" and options.Content ~= nil, "[ClickGUI] Notify needs a `Content` string")
local theme = self._theme
local config = self._config
local data = POSITIONS[config.Position]
local style = STYLES[options.Style or ""] and options.Style or config.Style
local kind = options.Type or "Info"
local color = typeColor(theme, kind)
local duration = options.Duration
if duration == nil then
duration = config.Duration
end
local sticky = duration <= 0 or duration == math.huge
local closable = options.Closable ~= false
local showProgress = options.Progress ~= false and not sticky and style ~= "Minimal"
local active = 0
for _, item in self._items do
if not item.Dismissed then
active += 1
end
end
for _, item in self._items do
if active < config.MaxVisible then
break
end
if not item.Dismissed then
item.Dismiss()
active -= 1
end
end
local width = config.Width
local padX, padTop = 16, style == "Minimal" and 8 or 12
local badge = style == "Minimal" and 0 or 38
local rightPad = closable and 30 or 12
local textWidth = math.max(width - padX - badge - rightPad, 80)
local hasTitle = options.Title ~= nil and options.Title ~= ""
local body = tostring(options.Content)
local titleHeight = hasTitle and measure(options.Title, 14, Fonts.ToEnum(theme:Get("FontBold"), true), textWidth) or 0
local bodyHeight = measure(body, 12, Fonts.ToEnum(theme:Get("Font"), false), textWidth)
local textHeight = titleHeight + (hasTitle and bodyHeight > 0 and 3 or 0) + bodyHeight
local height =
math.max(padTop * 2 + math.max(textHeight, style == "Minimal" and 0 or 28) + 4 + (showProgress and 2 or 0), 48)
local holder = Create("Frame", {
Name = "Notification",
Size = UDim2.new(1, 0, 0, height),
BackgroundTransparency = 1,
Parent = self._container,
})
local shadow =
UIShadow.new({ Parent = holder, Preset = "Soft", CornerRadius = theme:Get("CornerRadius"), Opacity = 0.4 })
local card = Create("CanvasGroup", {
Name = "Card",
Size = UDim2.fromScale(1, 1),
GroupTransparency = 1,
BackgroundColor3 = style == "Banner" and theme:Get("Panel"):Lerp(color, 0.16) or theme:Get("Panel"),
BackgroundTransparency = 0.02,
ZIndex = 2,
Parent = holder,
})
local stroke = Visual.surface(theme, card, "panel", style == "Minimal" and 0 or 0.14)
stroke.Color = style == "Banner" and color or theme:Get("Stroke")
Create("Frame", {
Name = "Stripe",
Size = UDim2.new(0, style == "Minimal" and 2 or 3, 1, 0),
BackgroundColor3 = color,
Parent = card,
})
if style ~= "Minimal" then
local badgeFrame = Create("Frame", {
Name = "Badge",
Position = UDim2.fromOffset(padX, math.floor((height - (showProgress and 2 or 0) - 28) / 2)),
Size = UDim2.fromOffset(28, 28),
BackgroundColor3 = color,
BackgroundTransparency = 0.82,
Parent = card,
})
Create.pill(badgeFrame)
if options.Icon then
Visual.icon(
badgeFrame,
options.Icon,
16,
color,
{ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }
)
else
Create("TextLabel", {
Name = "Glyph",
Size = UDim2.fromScale(1, 1),
Text = GLYPHS[kind] or "i",
TextSize = 16,
Font = theme:Get("FontBold"),
TextColor3 = color,
Parent = badgeFrame,
})
end
end
local textTop = math.floor((height - (showProgress and 2 or 0) - textHeight) / 2)
local textX = padX + badge
if hasTitle then
local title = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(textX, textTop),
Size = UDim2.fromOffset(textWidth, titleHeight),
Text = options.Title,
TextSize = 14,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
Parent = card,
})
theme:Bind(title, "TextColor3", "Text")
end
local bodyLabel = Create("TextLabel", {
Name = "Body",
Position = UDim2.fromOffset(textX, textTop + titleHeight + (hasTitle and 3 or 0)),
Size = UDim2.fromOffset(textWidth, bodyHeight),
Text = body,
TextSize = 12,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
Parent = card,
})
theme:Bind(bodyLabel, "TextColor3", "TextDim")
local fill
if showProgress then
local track = Create("Frame", {
Name = "ProgressTrack",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1),
Size = UDim2.new(1, 0, 0, 2),
BackgroundColor3 = color,
BackgroundTransparency = 0.85,
Parent = card,
})
fill =
Create("Frame", { Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, Parent = track })
end
local clickArea = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })
local closeButton
if closable then
closeButton = Create("TextButton", {
Name = "Close",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -6, 0, 6),
Size = UDim2.fromOffset(22, 22),
Text = "×",
TextSize = 18,
TextColor3 = theme:Get("TextDim"),
ZIndex = 6,
Parent = card,
})
theme:Bind(closeButton, "TextColor3", "TextDim")
end
local slide = Vector2.new(data.Slide.X * (width + 40), data.Slide.Y * 60)
local item = {
Holder = holder,
Height = height,
Dismissed = false,
Paused = false,
Sticky = sticky,
Duration = duration,
Remaining = duration,
Fill = fill,
}
local strokeTarget = Visual.strokeTransparency(theme)
local function dismiss()
if item.Dismissed then
return
end
item.Dismissed = true
local index = table.find(self._items, item)
if index then
table.remove(self._items, index)
end
AnimationManager.Play(
card,
"Close",
{ GroupTransparency = 1, Position = UDim2.fromOffset(slide.X * 0.5, slide.Y * 0.5) }
)
AnimationManager.Play(shadow.Instance, "Close", { GroupTransparency = 1 })
AnimationManager.Play(stroke, "Close", { Transparency = 1 })
self:_layout(true)
task.delay(AnimationManager.Time(0.4), function()
shadow:Destroy()
holder:Destroy()
end)
end
item.Dismiss = dismiss
table.insert(self._items, item)
self:_layout(false)
self._maid:Give(clickArea.MouseButton1Click:Connect(function()
if options.OnClick then
local ok, err = pcall(options.OnClick)
if not ok then
warn("[ClickGUI] Notification OnClick error: " .. tostring(err))
end
end
dismiss()
end))
self._maid:Give(clickArea.MouseEnter:Connect(function()
item.Paused = true
end))
self._maid:Give(clickArea.MouseLeave:Connect(function()
item.Paused = false
end))
if closeButton then
self._maid:Give(closeButton.MouseButton1Click:Connect(dismiss))
self._maid:Give(closeButton.MouseEnter:Connect(function()
AnimationManager.Play(closeButton, "Fast", { TextColor3 = theme:Get("Error") })
end))
self._maid:Give(closeButton.MouseLeave:Connect(function()
AnimationManager.Play(closeButton, "Fast", { TextColor3 = theme:Get("TextDim") })
end))
end
AnimationManager.Play(card, "Instant", { Position = UDim2.fromOffset(slide.X, slide.Y) })
AnimationManager.Play(shadow.Instance, "Instant", { GroupTransparency = 1 })
AnimationManager.Play(stroke, "Instant", { Transparency = 1 })
AnimationManager.Play(card, "Expo", { GroupTransparency = 0, Position = UDim2.new() })
AnimationManager.Play(shadow.Instance, "Expo", { GroupTransparency = 0 })
AnimationManager.Play(stroke, "Expand", { Transparency = strokeTarget })
self:_startTicker()
return { Dismiss = dismiss }
end
function Notifications:Clear()
for _, item in table.clone(self._items) do
item.Dismiss()
end
end
function Notifications:Destroy()
self._maid:Clean()
table.clear(self._items)
end
return Notifications
end
__functions[__n_Core_Settings] = function(script, require)
local Config = require(script.Parent.Config)
local ThemeManager = require(script.Parent.ThemeManager)
local AnimationManager = require(script.Parent.AnimationManager)
local Fonts = require(script.Parent.Fonts)
local TargetHUD = require(script.Parent.TargetHUD)
local Watermark = require(script.Parent.Watermark)
local Settings = {}
local THEME_COLORS = {
{ "Background", "Background" },
{ "Panel", "Panel" },
{ "Header", "Header" },
{ "Module", "Module" },
{ "Module Hover", "ModuleHover" },
{ "Element", "Element" },
{ "Element Hover", "ElementHover" },
{ "Accent", "Accent" },
{ "Accent 2", "AccentDark" },
{ "Text", "Text" },
{ "Text Dim", "TextDim" },
{ "Stroke", "Stroke" },
{ "Success", "Success" },
{ "Warning", "Warning" },
{ "Error", "Error" },
{ "Info", "Info" },
{ "Shadow Color", "ShadowColor" },
{ "Backdrop Color", "BackdropColor" },
}
local function round(value, step)
return math.floor(value / step + 0.5) * step
end
local function buildWidget(category, widget, kind)
local isTarget = kind == "TargetHUD"
local name = (isTarget and "Target HUD - " or "Watermark - ") .. tostring(widget.Name)
local m = category:CreateModule({
Name = name,
Description = isTarget and "Style, size, position and debug" or "Text, position, colors and size",
Toggleable = false,
ShowKeybind = false,
Expanded = false,
})
m:CreateToggle({
Name = "Visible",
Default = widget:IsVisible(),
Callback = function(value)
widget:SetVisible(value)
end,
})
m:CreateDropdown({
Name = "Position",
Options = isTarget and TargetHUD.Positions or Watermark.Positions,
Default = widget._position,
Callback = function(value)
widget:SetPosition(value)
end,
})
m:CreateToggle({
Name = "Edit Position (drag)",
Default = false,
Tooltip = "Drag the widget anywhere, then press Done editing",
Callback = function(value)
widget:SetEditable(value)
end,
})
m:CreateButton({
Name = "Reset Position",
Callback = function()
widget:ResetPosition()
end,
})
if isTarget then
m:CreateDropdown({
Name = "Style",
Options = { "Card", "Compact", "Minimal" },
Default = widget._style,
Callback = function(value)
widget:SetStyle(value)
end,
})
m:CreateSlider({
Name = "Width",
Min = 140,
Max = 500,
Default = widget._width,
Increment = 5,
Suffix = " px",
Callback = function(value)
widget:SetWidth(value)
end,
})
m:CreateSlider({
Name = "Auto Hide (0 = never)",
Min = 0,
Max = 30,
Default = widget._autoHide or 0,
Increment = 1,
Suffix = " s",
Callback = function(value)
widget:SetAutoHide(value > 0 and value or nil)
end,
})
m:CreateDropdown({
Name = "Main Bar Color",
Options = { "Health", "Accent" },
Default = "Health",
Callback = function(value)
widget:SetBarColor(value)
end,
})
m:CreateToggle({
Name = "Debug Lines (FPS / Ping / Memory)",
Default = widget:IsDebug(),
Callback = function(value)
widget:SetDebug(value)
end,
})
else
m:CreateTextbox({
Name = "Text",
Default = widget._text,
Placeholder = "{fps} fps | {time}",
Callback = function(text)
widget:SetText(text)
end,
})
m:CreateSlider({
Name = "Text Size",
Min = 8,
Max = 32,
Default = widget._textSize,
Increment = 1,
Callback = function(value)
widget:SetTextSize(value)
end,
})
m:CreateToggle({
Name = "Background",
Default = widget._background,
Callback = function(value)
widget:SetBackground(value)
end,
})
m:CreateSlider({
Name = "Background Opacity",
Min = 0,
Max = 100,
Default = math.floor((1 - widget._backgroundTransparency) * 100 + 0.5),
Increment = 5,
Suffix = "%",
Callback = function(value)
widget:SetBackground(widget._background, 1 - value / 100)
end,
})
m:CreateColorPicker({
Name = "Custom Color",
Default = widget._color or Color3.new(1, 1, 1),
Callback = function(color)
widget:SetColor(color)
end,
})
m:CreateButton({
Name = "Use Theme Colors",
Callback = function()
widget:SetColor(nil)
widget:SetGradient(nil)
end,
})
end
return m
end
function Settings.build(window, name, options)
local sections = options.Sections
or { "Interface", "Appearance", "Animations", "Notifications", "HUD", "Widgets", "Config" }
local wanted = {}
for _, section in sections do
wanted[section] = true
end
local category = window:CreateCategory(name, options.Category)
local library = window.Library
local theme = window.Theme
local current = theme.Current
local modules = {}
local first = true
local tracked = {}
local function track(component, getter)
table.insert(tracked, { Component = component, Get = getter })
return component
end
local function onTheme(fn)
table.insert(tracked, { Run = fn })
end
local themeDropdown, accentPicker
local function newModule(title, description)
local module = category:CreateModule({
Name = title,
Description = description,
Toggleable = false,
ShowKeybind = false,
Expanded = first and options.Expanded ~= false,
})
first = false
modules[title] = module
return module
end
if wanted.Interface then
local m = newModule("Interface", "Theme, scale and behavior")
themeDropdown = m:CreateSearchableDropdown({
Name = "Theme",
Options = theme:GetNames(),
Default = current.Name,
Tooltip = "Switch the color palette",
Callback = function(value)
window:SetTheme(value)
end,
})
accentPicker = m:CreateColorPicker({
Name = "Accent",
Default = current.Accent,
Tooltip = "Main highlight color",
Callback = function(color)
window:SetAccent(color)
end,
})
m:CreateSlider({
Name = "UI Scale",
Min = 0.5,
Max = 1.5,
Default = math.clamp(round(window:GetScale(), 0.05), 0.5, 1.5),
Increment = 0.05,
Marks = { 1 },
Callback = function(value)
window:SetScale(value)
end,
})
m:CreateButton({
Name = "Auto Scale",
Callback = function()
window:SetScale(nil)
end,
})
if window.Layout == "Panels" then
m:CreateSlider({
Name = "Panel Width",
Min = 140,
Max = 360,
Default = window._defaultPanelWidth,
Increment = 5,
Callback = function(value)
window:SetPanelWidth(value)
end,
})
end
m:CreateToggle({
Name = "Dim Background",
Default = window._backdropEnabled,
Callback = function(value)
window:SetBackdrop(value)
end,
})
m:CreateToggle({
Name = "Tooltips",
Default = window.Tooltip.Enabled,
Callback = function(value)
window:SetTooltipsEnabled(value)
end,
})
m:CreateToggle({
Name = "Resizable",
Default = window:IsResizable(),
Callback = function(value)
window:SetResizable(value)
end,
})
m:CreateDropdown({
Name = "Open Animation",
Options = { "Rise", "Drop", "Slide", "Fade" },
Default = window._openAnimation,
Callback = function(value)
window:SetOpenAnimation(value)
end,
})
m:CreateToggle({
Name = "Show Counts",
Default = window._showCounts,
Callback = function(value)
window:SetShowCounts(value)
end,
})
m:CreateToggle({
Name = "Favorites Only",
Default = window:IsFavoritesOnly(),
Tooltip = "Click the star on a module to favorite it, then show only favorites here",
Callback = function(value)
window:SetFavoritesOnly(value)
end,
})
m:CreateKeybind({
Name = "Menu Key",
Default = window:GetToggleKey(),
Callback = function(key)
if key then
window:SetToggleKey(key)
end
end,
})
m:CreateButton({
Name = "Reset Layout",
Callback = function()
window:ResetLayout()
end,
})
end
if wanted.Appearance then
local m = newModule("Appearance", "Shape, colors, fonts and theme editor")
local function note(text, kind)
window:Notify({ Title = "Theme", Content = text, Type = kind or "Info", Duration = 3 })
end
local function same(value)
return value
end
local function percent(value)
return math.floor(value * 100 + 0.5)
end
local function fraction(value)
return value / 100
end
local function opacity(value)
return math.floor((1 - value) * 100 + 0.5)
end
local function transparency(value)
return 1 - value / 100
end
local function slider(name, key, min, max, step, suffix, toUi, fromUi, tip)
toUi = toUi or same
fromUi = fromUi or same
local component = m:CreateSlider({
Name = name,
Min = min,
Max = max,
Default = toUi(current[key]),
Increment = step,
Suffix = suffix,
Tooltip = tip,
Callback = function(value)
window:SetThemeValue(key, fromUi(value))
end,
})
return track(component, function(t)
return toUi(t[key])
end)
end
local function toggle(name, key, tip)
local component = m:CreateToggle({
Name = name,
Default = current[key],
Tooltip = tip,
Callback = function(value)
window:SetThemeValue(key, value)
end,
})
return track(component, function(t)
return t[key]
end)
end
local function dropdown(name, key, options)
local component = m:CreateDropdown({
Name = name,
Options = options,
Default = current[key],
Callback = function(value)
window:SetThemeValue(key, value)
end,
})
return track(component, function(t)
return t[key]
end)
end
local function validOption(options, value)
if table.find(options, value) then
return value
end
return options[1]
end
m:CreateSection("Shape")
slider("Corner Radius", "CornerRadius", 0, 16)
slider("Module Corner Radius", "ModuleCornerRadius", -1, 16, 1, nil, nil, nil, "-1 follows the window corner radius")
slider("Transparency", "Transparency", 0, 60, nil, "%", percent, fraction)
slider("Module Transparency", "ModuleTransparency", 0, 60, nil, "%", percent, fraction)
slider("Module Spacing", "ModuleSpacing", 0, 12)
slider("Module Text Size", "ModuleTextSize", 10, 18)
slider("Header Text Size", "HeaderTextSize", 10, 20)
dropdown("Header Align", "HeaderAlign", { "Center", "Left" })
slider("Scrollbar Size", "ScrollBarThickness", 1, 8)
m:CreateSection("Borders")
toggle("Borders", "Border")
slider("Border Thickness", "BorderThickness", 0, 4, 0.5)
slider("Border Opacity", "BorderTransparency", 0, 100, 5, "%", opacity, transparency)
toggle("Accent Border", "AccentBorder", "Use the accent color for borders")
m:CreateSection("Accent and Gradients")
toggle("Accent Line", "AccentLine")
slider("Accent Line Size", "AccentLineThickness", 0, 6, 0.5)
toggle("Gradients", "Gradients")
slider("Gradient Angle", "GradientRotation", 0, 360, 15, "°")
slider("Gradient Strength", "GradientStrength", 0, 3, 0.1)
slider("Sheen", "SheenStrength", 0, 40, nil, "%", percent, fraction)
toggle("Accent Gradient", "AccentGradient", "Blend Accent into Accent 2 on bars, sliders and the accent line")
slider("Accent Gradient Angle", "AccentGradientAngle", 0, 360, 15, "°")
m:CreateSection("Shadow and Backdrop")
dropdown("Shadow", "ShadowPreset", { "Off", "Soft", "Medium", "Strong" })
slider("Shadow Opacity", "ShadowOpacity", 0, 100, nil, "%", percent, fraction)
slider(
"Backdrop Dim",
"BackdropTransparency",
0,
100,
5,
"%",
opacity,
transparency,
"How dark the screen gets behind the menu (needs Dim Background)"
)
m:CreateSection("Typography")
local fontNames = Fonts.Names()
local titleNames = { "Auto" }
for _, fontName in fontNames do
table.insert(titleNames, fontName)
end
local titleChoice = Fonts.IsAuto(current) and "Auto" or Fonts.NameOf(current.FontBold)
local fontDropdown = m:CreateSearchableDropdown({
Name = "Font",
Options = fontNames,
Default = validOption(fontNames, Fonts.NameOf(current.Font)),
Tooltip = "Body font. Fonts that fail to load fall back to a built-in font",
Callback = function(value)
window:SetFont(value, titleChoice)
end,
})
track(fontDropdown, function(t)
return Fonts.NameOf(t.Font)
end)
local titleDropdown = m:CreateSearchableDropdown({
Name = "Title Font",
Options = titleNames,
Default = validOption(titleNames, titleChoice),
Tooltip = "Font for headers and titles. Auto matches the body font",
Callback = function(value)
titleChoice = value
window:SetTitleFont(value)
end,
})
track(titleDropdown, function(t)
titleChoice = Fonts.IsAuto(t) and "Auto" or Fonts.NameOf(t.FontBold)
return titleChoice
end)
m:CreateSection("Theme Editor")
local nameBox = m:CreateTextbox({ Name = "Theme Name", Default = current.Name, Placeholder = "My theme" })
local lastName = current.Name
onTheme(function(t)
if t.Name ~= lastName then
lastName = t.Name
nameBox:Set(t.Name, true)
end
end)
local function typedName()
return string.match(nameBox:Get() or "", "^%s*(.-)%s*$") or ""
end
m:CreateButton({
Name = "Save Theme",
Callback = function()
local ok, result, stored = window:SaveTheme(typedName())
if not ok then
note(result, "Warning")
return
end
if stored then
note("Saved '" .. result .. "'", "Success")
else
note("Saved '" .. result .. "' for this session only (no storage adapter set)", "Warning")
end
end,
})
m:CreateButton({
Name = "Delete Theme",
Callback = function()
local name = typedName()
if not theme:IsCustom(name) then
note("Only your saved themes can be deleted", "Warning")
return
end
window:DeleteTheme(name)
note("Deleted '" .. name .. "'", "Info")
end,
})
m:CreateButton({
Name = "Revert Edits",
Callback = function()
local name = theme.Current.Name
if theme._presets[name] then
window:SetTheme(name)
note("Reverted '" .. name .. "' to its saved version", "Info")
else
note("This theme has no saved version to revert to", "Warning")
end
end,
})
m:CreateSection("Theme Colors")
for _, item in THEME_COLORS do
local key = item[2]
local component = m:CreateColorPicker({
Name = item[1],
Default = current[key],
Callback = function(color)
window:SetThemeValue(key, color)
end,
})
track(component, function(t)
return t[key]
end)
end
m:CreateSection("Share Theme")
local jsonBox = m:CreateTextbox({ Name = "Theme JSON", Placeholder = "Paste a theme here to import it" })
m:CreateButton({
Name = "Export Theme JSON",
Callback = function()
local typed = typedName()
local text = window:ExportTheme(typed ~= "" and typed or nil)
jsonBox:Set(text, true)
local copied = type(setclipboard) == "function" and pcall(setclipboard, text)
note(copied and "Theme exported and copied to the clipboard" or "Theme exported to the JSON box", "Success")
end,
})
m:CreateButton({
Name = "Import Theme JSON",
Callback = function()
local ok, result = window:ImportTheme(jsonBox:Get())
note(ok and ("Imported and saved as '" .. result .. "'") or result, ok and "Success" or "Error")
end,
})
end
if wanted.Notifications then
local m = newModule("Notifications", "Style, position and tests")
m:CreateDropdown({
Name = "Style",
Options = { "Modern", "Minimal", "Banner" },
Default = "Modern",
Callback = function(value)
library:SetNotificationConfig({ Style = value })
end,
})
m:CreateDropdown({
Name = "Position",
Options = { "BottomRight", "BottomLeft", "BottomCenter", "TopRight", "TopLeft", "TopCenter" },
Default = "BottomRight",
Callback = function(value)
library:SetNotificationConfig({ Position = value })
end,
})
m:CreateSlider({
Name = "Duration",
Min = 1,
Max = 12,
Default = 4,
Suffix = "s",
Callback = function(value)
library:SetNotificationConfig({ Duration = value })
end,
})
m:CreateSlider({
Name = "Max Visible",
Min = 1,
Max = 8,
Default = 5,
Callback = function(value)
library:SetNotificationConfig({ MaxVisible = value })
end,
})
for _, kind in { "Info", "Success", "Warning", "Error" } do
m:CreateButton({
Name = "Test " .. kind,
Callback = function()
window:Notify({
Title = kind,
Content = "This is a " .. string.lower(kind) .. " notification.",
Type = kind,
})
end,
})
end
end
if wanted.Animations then
local config = AnimationManager.GetConfig()
local m = newModule("Animations", "Speed and style")
m:CreateToggle({
Name = "Enabled",
Default = config.Enabled,
Callback = function(value)
library:SetAnimationConfig({ Enabled = value })
end,
})
m:CreateSlider({
Name = "Speed",
Min = 0.25,
Max = 3,
Default = config.Speed,
Increment = 0.05,
Suffix = "x",
Callback = function(value)
library:SetAnimationConfig({ Speed = value })
end,
})
m:CreateDropdown({
Name = "Style",
Options = AnimationManager.GetPresetNames(),
Default = config.Preset,
Callback = function(value)
library:SetAnimationConfig({ Preset = value })
end,
})
end
if wanted.HUD then
local m = newModule("HUD", "ArrayList options")
local hud = options.HUD or library.HUDs[1]
if not hud then
m:CreateLabel(
"No HUD created yet. Use ClickGUI:CreateHUD() and pass { HUD = hud } to CreateSettingsCategory."
)
else
local function set(key)
return function(value)
hud:SetOption(key, value)
end
end
m:CreateToggle({ Name = "Visible", Default = hud:IsVisible(), Callback = set("Visible") })
m:CreateDropdown({
Name = "Position",
Options = { "TopLeft", "TopRight", "BottomLeft", "BottomRight" },
Default = hud:GetOption("Position"),
Callback = set("Position"),
})
m:CreateDropdown({
Name = "Color Mode",
Options = { "Accent", "Gradient", "Rainbow", "Static" },
Default = hud:GetOption("ColorMode"),
Callback = set("ColorMode"),
})
m:CreateDropdown({
Name = "Sort",
Options = { "Length", "Alphabetical", "None" },
Default = hud:GetOption("Sort"),
Callback = set("Sort"),
})
m:CreateDropdown({
Name = "Accent Bar",
Options = { "Left", "Right", "None" },
Default = hud:GetOption("AccentBar"),
Callback = set("AccentBar"),
})
m:CreateDropdown({
Name = "Animation",
Options = { "Both", "Grow", "Fade", "None" },
Default = hud:GetOption("Animation"),
Callback = set("Animation"),
})
m:CreateToggle({ Name = "Background", Default = hud:GetOption("Background"), Callback = set("Background") })
m:CreateSlider({
Name = "BG Transparency",
Min = 0,
Max = 100,
Default = hud:GetOption("BackgroundTransparency") * 100,
Suffix = "%",
Increment = 5,
Callback = function(v)
hud:SetOption("BackgroundTransparency", v / 100)
end,
})
m:CreateSlider({
Name = "Text Transparency",
Min = 0,
Max = 80,
Default = hud:GetOption("TextTransparency") * 100,
Suffix = "%",
Increment = 5,
Callback = function(v)
hud:SetOption("TextTransparency", v / 100)
end,
})
m:CreateSlider({
Name = "Text Size",
Min = 10,
Max = 28,
Default = hud:GetOption("TextSize"),
Callback = set("TextSize"),
})
m:CreateSlider({
Name = "Spacing",
Min = 0,
Max = 8,
Default = hud:GetOption("Spacing"),
Callback = set("Spacing"),
})
m:CreateSlider({
Name = "Gradient Speed",
Min = 0,
Max = 2,
Default = hud:GetOption("GradientSpeed"),
Increment = 0.1,
Callback = set("GradientSpeed"),
})
m:CreateToggle({ Name = "Border", Default = hud:GetOption("Border"), Callback = set("Border") })
m:CreateColorPicker({
Name = "Static Color",
Default = hud:GetOption("StaticColor"),
Callback = set("StaticColor"),
})
m:CreateColorPicker({
Name = "Background Color",
Default = hud:GetOption("BackgroundColor"),
Callback = set("BackgroundColor"),
})
m:CreateToggle({
Name = "Edit Position",
Default = false,
Tooltip = "Drag the HUD anywhere on screen",
Callback = function(v)
hud:SetEditable(v)
end,
})
m:CreateButton({
Name = "Reset HUD Position",
Callback = function()
hud:ResetPosition()
end,
})
end
end
if wanted.Widgets then
for widget, kind in window._widgets do
local m = buildWidget(category, widget, kind)
modules[m.Name] = m
end
end
if wanted.Config then
local m = newModule("Config", "Save, load, profiles and sharing")
m:CreateSection("Automatic")
m:CreateToggle({
Name = "Auto Save Config",
Default = window._autoSaveConfig,
Tooltip = "Saves the whole config every N seconds, when closing the menu and when unloading",
Callback = function(value)
window:SetAutoSave(value)
end,
})
m:CreateSlider({
Name = "Auto Save Every",
Min = 5,
Max = 900,
Default = math.clamp(window._autoSaveInterval, 5, 900),
Increment = 5,
Suffix = "s",
Callback = function(value)
window:SetAutoSaveInterval(value)
end,
})
m:CreateToggle({
Name = "Auto Load Config",
Default = window._autoLoadConfig,
Tooltip = "Loads the startup profile (or the current one) the first time the menu opens",
Callback = function(value)
window:SetAutoLoad(value)
end,
})
m:CreateToggle({
Name = "Auto Save Layout",
Default = window._autoSave,
Tooltip = "Remembers window / panel positions and sizes",
Callback = function(value)
window:SetAutoSaveLayout(value)
end,
})
m:CreateSection("Profiles")
local profileName = m:CreateTextbox({ Name = "Profile Name", Placeholder = "New or existing profile" })
local profileList =
m:CreateDropdown({ Name = "Profile", Options = window:GetProfiles(), Default = window:GetProfile() })
local function refreshProfiles()
profileList:SetOptions(window:GetProfiles())
pcall(function()
profileList:Set(window:GetProfile(), true)
end)
end
local function chosenProfile()
local typed = string.match(profileName:Get() or "", "^%s*(.-)%s*$")
if typed ~= "" then
return typed
end
return profileList:Get()
end
m:CreateButton({
Name = "Save Profile",
Callback = function()
local name = chosenProfile()
local ok = window:SaveProfile(name)
refreshProfiles()
window:Notify({
Title = "Profile",
Content = ok and ("Saved '" .. name .. "'") or "No storage adapter set (ClickGUI:SetStorage)",
Type = ok and "Success" or "Warning",
Duration = 3,
})
end,
})
m:CreateButton({
Name = "Load Profile",
Callback = function()
local name = chosenProfile()
local ok = window:LoadProfile(name)
refreshProfiles()
window:Notify({
Title = "Profile",
Content = ok and ("Loaded '" .. name .. "'") or ("No saved profile named '" .. name .. "'"),
Type = ok and "Success" or "Warning",
Duration = 3,
})
end,
})
m:CreateButton({
Name = "Delete Profile",
Callback = function()
local name = chosenProfile()
local ok = window:DeleteProfile(name)
refreshProfiles()
window:Notify({
Title = "Profile",
Content = ok and ("Deleted '" .. name .. "'") or "Cannot delete that profile",
Type = ok and "Info" or "Warning",
Duration = 3,
})
end,
})
m:CreateButton({
Name = "Use As Startup Profile",
Callback = function()
local name = chosenProfile()
window:SetStartupProfile(name)
window:Notify({
Title = "Profile",
Content = "'" .. name .. "' loads on startup (needs Auto Load Config)",
Type = "Info",
Duration = 4,
})
end,
})
m:CreateLabel(
window.Storage and "Storage: adapter connected"
or "Storage: none (memory only). Use ClickGUI:SetStorage(ClickGUI.Storage.File('MyClient'))"
)
m:CreateSection("Manual")
local box = m:CreateTextbox({ Name = "JSON", Placeholder = "Paste a config or theme here" })
local function status(text, kind)
window:Notify({ Title = "Config", Content = text, Type = kind or "Info", Duration = 3 })
end
m:CreateButton({
Name = "Save Layout",
Callback = function()
status(
window:SaveLayout() and "Layout saved" or "No storage adapter set (ClickGUI:SetStorage)",
window.Storage and "Success" or "Warning"
)
end,
})
m:CreateButton({
Name = "Load Layout",
Callback = function()
status(window:LoadLayout() and "Layout loaded" or "No saved layout found", "Info")
end,
})
m:CreateButton({
Name = "Save Config",
Callback = function()
status(
window:SaveConfig() and "Config saved" or "No storage adapter set (ClickGUI:SetStorage)",
window.Storage and "Success" or "Warning"
)
end,
})
m:CreateButton({
Name = "Load Config",
Callback = function()
status(window:LoadConfig() and "Config loaded" or "No saved config found", "Info")
end,
})
m:CreateButton({
Name = "Export Config -> JSON",
Callback = function()
box:Set(window:ExportConfig(), true)
status("Config exported to the text box", "Success")
end,
})
m:CreateButton({
Name = "Import Config <- JSON",
Callback = function()
status(window:ImportConfig(box:Get()) and "Config imported" or "Invalid config JSON", "Info")
end,
})
m:CreateButton({
Name = "Export Theme -> JSON",
Callback = function()
box:Set(Config.encode(theme:ExportTheme()), true)
status("Theme exported to the text box", "Success")
end,
})
m:CreateButton({
Name = "Import Theme <- JSON",
Callback = function()
local data = Config.decode(box:Get())
if data then
theme:SetTheme(ThemeManager.Deserialize(data))
status("Theme imported", "Success")
else
status("Invalid theme JSON", "Error")
end
end,
})
m:CreateButton({
Name = "Reset Everything",
Callback = function()
window:ResetConfig()
status("All settings were reset", "Warning")
end,
})
end
if themeDropdown then
track(themeDropdown, function(t)
return t.Name
end)
window._maid:Give(theme.ListChanged:Connect(function()
themeDropdown:SetOptions(theme:GetNames())
pcall(themeDropdown.Set, themeDropdown, theme.Current.Name, true)
end))
end
if accentPicker then
track(accentPicker, function(t)
return t.Accent
end)
end
if #tracked > 0 then
window._maid:Give(theme.Changed:Connect(function(t)
for _, item in tracked do
if item.Run then
pcall(item.Run, t)
else
local ok, value = pcall(item.Get, t)
if ok and value ~= nil then
pcall(item.Component.Set, item.Component, value, true)
end
end
end
end))
end
for _, module in modules do
for _, component in module.Components do
component._persist = false
end
end
return category, modules
end
return Settings
end
__functions[__n_Core_Styles] = function(script, require)
local Styles = {}
Styles.Names = { "Classic", "Flat", "Glass" }
Styles.Data = {
Classic = {
Name = "Classic",
Module = { Layout = "Card", Height = 30, HeightDesc = 42, SwitchW = 28, SwitchH = 14 },
Sidebar = "Classic",
Panels = { Header = "Classic", HeaderHeight = 34, Search = "Top", Palette = false },
Theme = {},
ShowCounts = true,
},
Flat = {
Name = "Flat",
Module = { Layout = "Row", Height = 30, HeightDesc = 30, SwitchW = 0, SwitchH = 0 },
Sidebar = "Classic",
Panels = { Header = "Plain", HeaderHeight = 42, Search = "Bottom", Palette = true },
Theme = {
Gradients = false,
AccentLine = false,
Border = true,
BorderThickness = 1,
BorderTransparency = 0.78,
CornerRadius = 14,
Transparency = 0.05,
ModuleSpacing = 2,
ModuleTextSize = 13,
HeaderTextSize = 14,
ShadowPreset = "Soft",
ShadowOpacity = 0.35,
SheenStrength = 0,
HeaderAlign = "Center",
},
ShowCounts = false,
},
Glass = {
Name = "Glass",
Module = { Layout = "Card", Height = 44, HeightDesc = 62, SwitchW = 38, SwitchH = 20 },
Sidebar = "Brand",
Panels = { Header = "Classic", HeaderHeight = 38, Search = "Top", Palette = false },
Theme = {
Gradients = true,
GradientStrength = 1.5,
AccentLine = false,
Border = true,
BorderThickness = 1,
BorderTransparency = 0.62,
CornerRadius = 16,
Transparency = 0.1,
ModuleSpacing = 8,
ModuleTextSize = 14,
HeaderTextSize = 15,
ShadowPreset = "Strong",
ShadowOpacity = 0.55,
SheenStrength = 0.1,
HeaderAlign = "Left",
},
ShowCounts = true,
},
}
return Styles
end
__functions[__n_Core_TargetHUD] = function(script, require)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utilities = script.Parent.Parent.Utilities
local Components = script.Parent.Parent.Components
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local UIShadow = require(Components.UIShadow)
local Create = require(Utilities.Create)
local Draggable = require(Utilities.Draggable)
local Maid = require(Utilities.Maid)
local TargetHUD = {}
TargetHUD.__index = TargetHUD
local ANCHORS = {
Center = { Anchor = Vector2.new(0.5, 0.5), Pos = UDim2.fromScale(0.5, 0.5), Offset = Vector2.new(0, 90) },
CenterLeft = { Anchor = Vector2.new(0, 0.5), Pos = UDim2.fromScale(0, 0.5), Offset = Vector2.new(16, 0) },
CenterRight = { Anchor = Vector2.new(1, 0.5), Pos = UDim2.fromScale(1, 0.5), Offset = Vector2.new(-16, 0) },
TopCenter = { Anchor = Vector2.new(0.5, 0), Pos = UDim2.fromScale(0.5, 0), Offset = Vector2.new(0, 80) },
BottomCenter = { Anchor = Vector2.new(0.5, 1), Pos = UDim2.fromScale(0.5, 1), Offset = Vector2.new(0, -110) },
TopLeft = { Anchor = Vector2.new(0, 0), Pos = UDim2.fromScale(0, 0), Offset = Vector2.new(16, 16) },
TopRight = { Anchor = Vector2.new(1, 0), Pos = UDim2.fromScale(1, 0), Offset = Vector2.new(-16, 16) },
BottomLeft = { Anchor = Vector2.new(0, 1), Pos = UDim2.fromScale(0, 1), Offset = Vector2.new(16, -16) },
BottomRight = { Anchor = Vector2.new(1, 1), Pos = UDim2.fromScale(1, 1), Offset = Vector2.new(-16, -16) },
}
TargetHUD.Positions = {
"Center",
"CenterLeft",
"CenterRight",
"TopCenter",
"BottomCenter",
"TopLeft",
"TopRight",
"BottomLeft",
"BottomRight",
}
local STYLES = { Card = true, Compact = true, Minimal = true }
local ROW_BAR, ROW_LINE, GAP = 18, 14, 4
local function healthColor(ratio)
return Color3.fromHSV(math.clamp(ratio, 0, 1) * 0.33, 0.75, 0.95)
end
local function formatNumber(value)
if value == math.floor(value) then
return string.format("%d", value)
end
return string.format("%.1f", value)
end
function TargetHUD.new(library, options)
options = options or {}
local self = setmetatable({}, TargetHUD)
local theme = library.Theme
self.Library = library
self.Name = options.Name or "TargetHUD"
self._theme = theme
self._maid = Maid.new()
self._width = options.Width or 230
self._style = STYLES[options.Style or ""] and options.Style or "Card"
self._position = ANCHORS[options.Position or ""] and options.Position or "Center"
self._offset = options.Offset
self._custom = typeof(options.Custom) == "UDim2" and options.Custom or nil
self._visible = options.Visible == true
self._editable = false
self._debug = options.Debug == true
self._autoHide = options.AutoHide
self._lastTouch = os.clock()
self._bars = {}
self._barMap = {}
self._lines = {}
self._lineMap = {}
self._title = options.Title or ""
self._subtitle = options.Subtitle
self._token = 0
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_TargetHUD_" .. self.Name,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 60,
Parent = options.Parent or library:GetGuiParent(),
})
self._maid:Give(self.Gui)
library:_secureGui(self.Gui)
self.Root = Create("Frame", {
Name = "Root",
Size = UDim2.fromOffset(self._width, 60),
BackgroundTransparency = 1,
Visible = self._visible,
Parent = self.Gui,
})
self._shadow = UIShadow.new({ Parent = self.Root, Preset = "Soft", CornerRadius = theme:Get("CornerRadius") })
self.Card = Create("CanvasGroup", {
Name = "Card",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = theme:Get("Panel"),
BackgroundTransparency = 0.06,
GroupTransparency = self._visible and 0 or 1,
ZIndex = 2,
Parent = self.Root,
})
theme:Bind(self.Card, "BackgroundColor3", "Panel")
self._stroke = Visual.surface(theme, self.Card, "panel", 0.1)
self._flash = Create(
"Frame",
{ Name = "Flash", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 9, Parent = self.Card }
)
self._titleLabel = Create("TextLabel", {
Name = "Title",
Text = self._title,
TextSize = 15,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Card,
})
theme:Bind(self._titleLabel, "TextColor3", "Text")
theme:Bind(self._titleLabel, "Font", "FontBold")
self._subtitleLabel = Create("TextLabel", {
Name = "Subtitle",
Text = self._subtitle or "",
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Visible = self._subtitle ~= nil,
Parent = self.Card,
})
theme:Bind(self._subtitleLabel, "TextColor3", "TextDim")
self._divider = Create("Frame", {
Name = "Divider",
BackgroundColor3 = theme:Get("Stroke"),
BackgroundTransparency = 0.4,
Visible = false,
Parent = self.Card,
})
theme:Bind(self._divider, "BackgroundColor3", "Stroke")
self._maid:Give(theme.Changed:Connect(function()
for _, bar in self._bars do
self:_applyBar(bar, true)
end
self:_relayout(false)
end))
if options.Image ~= nil then
self:SetImage(options.Image)
end
local main = options.Bar
if main ~= false then
self._main = self:AddBar("Main", type(main) == "table" and main or { Value = 1, Max = 1 })
end
for key, value in options.Lines or {} do
self:SetLine(key, value)
end
if self._debug then
self:_startDebug()
end
self:_applyPosition()
self:_relayout(false)
self:_startAutoHide()
return self
end
function TargetHUD:_touch()
self._lastTouch = os.clock()
if self._autoHide and not self._visible and not self._editable then
self:Show()
end
end
function TargetHUD:_startAutoHide()
self._maid:Remove("autohide")
if not self._autoHide then
return
end
self._maid:GiveNamed(
"autohide",
RunService.Heartbeat:Connect(function()
if self._visible and not self._editable and os.clock() - self._lastTouch > self._autoHide then
self:Hide()
end
end)
)
end
function TargetHUD:SetAutoHide(seconds)
self._autoHide = seconds
self._lastTouch = os.clock()
self:_startAutoHide()
end
function TargetHUD:_applyPosition()
local data = ANCHORS[self._position]
self.Root.AnchorPoint = data.Anchor
if self._custom then
self.Root.Position = self._custom
else
local offset = self._offset or data.Offset
self.Root.Position = data.Pos + UDim2.fromOffset(offset.X, offset.Y)
end
end
function TargetHUD:SetPosition(position)
if typeof(position) == "UDim2" then
self._custom = position
elseif ANCHORS[position] then
self._position = position
self._custom = nil
self._offset = nil
else
warn(`[ClickGUI] Unknown TargetHUD position "{tostring(position)}"`)
return
end
self:_applyPosition()
end
function TargetHUD:SetOffset(offset)
self._offset = offset
self._custom = nil
self:_applyPosition()
end
function TargetHUD:ResetPosition()
self._custom = nil
self._offset = nil
self:_applyPosition()
end
function TargetHUD:SetWidth(width)
self._width = math.clamp(width, 140, 500)
self:_relayout(false)
end
function TargetHUD:SetStyle(style)
if not STYLES[style] then
warn(`[ClickGUI] Unknown TargetHUD style "{tostring(style)}" (Card, Compact, Minimal)`)
return
end
self._style = style
self:_relayout(false)
end
function TargetHUD:SetTitle(text)
self._title = tostring(text or "")
self._titleLabel.Text = self._title
self:_touch()
end
function TargetHUD:SetSubtitle(text)
self._subtitle = text
self._subtitleLabel.Text = text and tostring(text) or ""
self._subtitleLabel.Visible = text ~= nil and text ~= ""
self:_relayout(true)
self:_touch()
end
function TargetHUD:SetImage(spec)
if self._image then
self._image.Frame:Destroy()
self._image = nil
end
if spec ~= nil and spec ~= false then
local frame = Create("Frame", {
Name = "Avatar",
Size = UDim2.fromOffset(44, 44),
BackgroundColor3 = self._theme:Get("Element"),
Parent = self.Card,
})
Create.corner(frame, 8)
self._theme:Bind(frame, "BackgroundColor3", "Element")
local icon = Visual.icon(
frame,
spec,
44,
Color3.new(1, 1, 1),
{ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) }
)
if icon.IsImage then
Create.corner(icon.Instance, 8)
else
icon.Instance.TextSize = 24
icon.Instance.TextColor3 = self._theme:Get("Accent")
self._theme:Bind(icon.Instance, "TextColor3", "Accent")
end
self._image = { Frame = frame, Icon = icon }
end
self:_relayout(true)
self:_touch()
end
function TargetHUD:SetPlayer(player, applyTitle)
local userId = tonumber(typeof(player) == "Instance" and player.UserId or player)
if not userId then
self:SetImage(nil)
return
end
self:SetImage(("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(userId))
if applyTitle ~= false then
local instance = typeof(player) == "Instance" and player or Players:GetPlayerByUserId(userId)
if instance then
self:SetTitle(instance.DisplayName)
self:SetSubtitle("@" .. instance.Name)
end
end
end
function TargetHUD:_applyBar(bar, animated)
local preset = animated and "Fast" or "Instant"
local ratio = bar.Max > 0 and math.clamp(bar.Value / bar.Max, 0, 1) or 0
local color
if typeof(bar.Color) == "Color3" then
color = bar.Color
elseif bar.Color == "Accent" then
color = self._theme:Get("Accent")
else
color = healthColor(ratio)
end
AnimationManager.Play(bar.Fill, preset, { Size = UDim2.fromScale(ratio, 1), BackgroundColor3 = color })
if bar.Format then
local ok, text = pcall(bar.Format, bar.Value, bar.Max)
bar.Text.Text = ok and tostring(text) or ""
elseif bar.CustomText then
bar.Text.Text = bar.CustomText
else
bar.Text.Text = formatNumber(bar.Value) .. " / " .. formatNumber(bar.Max)
end
bar.Label.Text = bar.LabelText or ""
end
function TargetHUD:AddBar(name, options)
options = options or {}
local theme = self._theme
local existing = self._barMap[name]
if existing then
return existing.Handle
end
local bar = {
Name = name,
Order = #self._bars + 1,
Value = options.Value or 0,
Max = options.Max or 1,
Color = options.Color,
LabelText = options.Label,
CustomText = options.Text,
Format = options.Format,
Visible = options.Visible ~= false,
ShowText = options.ShowText ~= false,
}
bar.Track =
Create("Frame", { Name = "Track_" .. name, BackgroundColor3 = theme:Get("Element"), Parent = self.Card })
Create.pill(bar.Track)
theme:Bind(bar.Track, "BackgroundColor3", "Element")
bar.Fill = Create(
"Frame",
{ Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = bar.Track }
)
Create.pill(bar.Fill)
bar.Text = Create("TextLabel", {
Name = "Value_" .. name,
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Right,
Parent = self.Card,
})
theme:Bind(bar.Text, "TextColor3", "Text")
bar.Label = Create("TextLabel", {
Name = "Label_" .. name,
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = self.Card,
})
theme:Bind(bar.Label, "TextColor3", "TextDim")
local handle = {}
local hud = self
function handle:Set(value, max, text)
bar.Value = tonumber(value) or 0
if max ~= nil then
bar.Max = math.max(tonumber(max) or 1, 0.0001)
end
bar.CustomText = text
hud:_applyBar(bar, true)
hud:_touch()
end
function handle:SetProgress(ratio, text)
bar.Max = 1
bar.Value = math.clamp(tonumber(ratio) or 0, 0, 1)
bar.CustomText = text or string.format("%d%%", math.floor(bar.Value * 100 + 0.5))
hud:_applyBar(bar, true)
hud:_touch()
end
function handle:SetColor(color)
bar.Color = color
hud:_applyBar(bar, true)
end
function handle:SetLabel(text)
bar.LabelText = text
hud:_applyBar(bar, false)
hud:_relayout(false)
end
function handle:SetFormat(fn)
bar.Format = fn
hud:_applyBar(bar, false)
end
function handle:SetVisible(visible)
bar.Visible = visible
hud:_relayout(true)
end
function handle:Get()
return bar.Value, bar.Max
end
function handle:Remove()
hud:RemoveBar(name)
end
bar.Handle = handle
self._barMap[name] = bar
table.insert(self._bars, bar)
self:_applyBar(bar, false)
self:_relayout(true)
return handle
end
function TargetHUD:GetBar(name)
local bar = self._barMap[name]
return bar and bar.Handle or nil
end
function TargetHUD:RemoveBar(name)
local bar = self._barMap[name]
if not bar then
return
end
self._barMap[name] = nil
table.remove(self._bars, table.find(self._bars, bar))
if self._main == bar.Handle then
self._main = nil
end
bar.Track:Destroy()
bar.Text:Destroy()
bar.Label:Destroy()
self:_relayout(true)
end
function TargetHUD:SetBar(value, max, text)
if not self._main then
self._main = self:AddBar("Main", {})
end
self._main:Set(value, max, text)
end
function TargetHUD:SetProgress(ratio, text)
if not self._main then
self._main = self:AddBar("Main", {})
end
self._main:SetProgress(ratio, text)
end
function TargetHUD:SetBarColor(color)
if self._main then
self._main:SetColor(color)
end
end
function TargetHUD:SetLine(key, value, color, debugOnly)
local theme = self._theme
local line = self._lineMap[key]
if not line then
line = { Key = key, Order = #self._lines + 1, Debug = debugOnly == true }
line.KeyLabel = Create("TextLabel", {
Name = "Key_" .. key,
Text = tostring(key),
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = self.Card,
})
theme:Bind(line.KeyLabel, "TextColor3", "TextDim")
line.ValueLabel = Create("TextLabel", {
Name = "Val_" .. key,
TextSize = 11,
Font = Enum.Font.Code,
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Right,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = self.Card,
})
line.Default = true
theme:Bind(line.ValueLabel, "TextColor3", "Text")
self._lineMap[key] = line
table.insert(self._lines, line)
end
line.ValueLabel.Text = tostring(value)
if color ~= nil then
line.ValueLabel.TextColor3 = color
end
self:_relayout(true)
self:_touch()
end
function TargetHUD:SetLines(map)
for key, value in map do
self:SetLine(key, value)
end
end
function TargetHUD:RemoveLine(key)
local line = self._lineMap[key]
if not line then
return
end
self._lineMap[key] = nil
table.remove(self._lines, table.find(self._lines, line))
line.KeyLabel:Destroy()
line.ValueLabel:Destroy()
self:_relayout(true)
end
function TargetHUD:ClearLines()
for _, line in table.clone(self._lines) do
self:RemoveLine(line.Key)
end
end
function TargetHUD:SetDebugLine(key, value, color)
self:SetLine(key, value, color, true)
end
function TargetHUD:_startDebug()
if self._debugOn then
return
end
self._debugOn = true
local frames, elapsed = 0, 0
self._maid:GiveNamed(
"debug",
RunService.Heartbeat:Connect(function(dt)
frames += 1
elapsed += dt
if elapsed >= 0.5 then
local fps = math.floor(frames / elapsed + 0.5)
frames, elapsed = 0, 0
self:SetLine(
"FPS",
fps,
fps >= 55 and Color3.fromRGB(120, 230, 140)
or (fps >= 30 and Color3.fromRGB(250, 204, 21) or Color3.fromRGB(248, 113, 113)),
true
)
local ok, ping = pcall(function()
return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
end)
if ok and tonumber(ping) then
self:SetLine("Ping", string.format("%d ms", tonumber(ping)), nil, true)
end
local okMem, memory = pcall(function()
return game:GetService("Stats"):GetTotalMemoryUsageMb()
end)
if okMem and tonumber(memory) then
self:SetLine("Memory", string.format("%d MB", tonumber(memory)), nil, true)
end
end
end)
)
end
function TargetHUD:SetDebug(enabled)
self._debug = enabled == true
if self._debug then
self:_startDebug()
else
self._debugOn = false
self._maid:Remove("debug")
for _, key in { "FPS", "Ping", "Memory" } do
self:RemoveLine(key)
end
end
self:_relayout(true)
end
function TargetHUD:IsDebug()
return self._debug
end
function TargetHUD:_relayout(animated)
if self._destroyed then
return
end
local W = self._width
local card = self._style == "Card"
local minimal = self._style == "Minimal"
local pad = 8
local hasImage = self._image ~= nil and not minimal
local textLeft = hasImage and (pad + 44 + 8) or pad
local y = pad
local hasSubtitle = self._subtitle ~= nil and self._subtitle ~= ""
self._titleLabel.Position = UDim2.fromOffset(textLeft, y)
self._titleLabel.Size = UDim2.fromOffset(W - textLeft - pad, 18)
self._titleLabel.TextSize = minimal and 13 or 15
local blockY = y + 18
if hasSubtitle then
self._subtitleLabel.Position = UDim2.fromOffset(textLeft, blockY)
self._subtitleLabel.Size = UDim2.fromOffset(W - textLeft - pad, 14)
blockY += 14
end
local mainBar
for _, bar in self._bars do
if bar == self._main and bar.Visible then
mainBar = bar
end
end
if mainBar then
blockY += 4
self:_placeBar(mainBar, textLeft, blockY, W - textLeft - pad, true)
blockY += ROW_BAR - 4
end
if self._image and hasImage then
self._image.Frame.Visible = true
self._image.Frame.Position = UDim2.fromOffset(pad, y)
blockY = math.max(blockY, y + 44)
elseif self._image then
self._image.Frame.Visible = false
end
y = blockY
for _, bar in self._bars do
if bar ~= mainBar then
if bar.Visible then
y += GAP
self:_placeBar(bar, pad, y, W - pad * 2, false)
y += ROW_BAR
else
bar.Track.Visible, bar.Text.Visible, bar.Label.Visible = false, false, false
end
end
end
local regular, debugLines = {}, {}
for _, line in self._lines do
if line.Debug then
table.insert(debugLines, line)
else
table.insert(regular, line)
end
end
local function placeLines(list)
for _, line in list do
y += 2
line.KeyLabel.Visible, line.ValueLabel.Visible = true, true
line.KeyLabel.Position = UDim2.fromOffset(pad, y)
line.KeyLabel.Size = UDim2.fromOffset(math.floor(W * 0.4), ROW_LINE)
line.ValueLabel.Position = UDim2.fromOffset(pad + math.floor(W * 0.4), y)
line.ValueLabel.Size = UDim2.fromOffset(W - pad * 2 - math.floor(W * 0.4), ROW_LINE)
y += ROW_LINE
end
end
if #regular > 0 then
y += GAP
placeLines(regular)
end
if #debugLines > 0 and self._debug then
y += GAP
self._divider.Visible = true
self._divider.Position = UDim2.fromOffset(pad, y)
self._divider.Size = UDim2.fromOffset(W - pad * 2, 1)
y += 3
placeLines(debugLines)
else
self._divider.Visible = false
for _, line in debugLines do
line.KeyLabel.Visible, line.ValueLabel.Visible = false, false
end
end
y += pad
AnimationManager.Play(
self.Root,
animated and "Expand" or "Instant",
{ Size = UDim2.fromOffset(W, math.max(y, minimal and 40 or 60)) }
)
end
function TargetHUD:_placeBar(bar, x, y, width, inline)
local labelWidth = (bar.LabelText and bar.LabelText ~= "") and 56 or 0
local textWidth = bar.ShowText and 52 or 0
bar.Label.Visible = labelWidth > 0
bar.Label.Position = UDim2.fromOffset(x, y)
bar.Label.Size = UDim2.fromOffset(labelWidth, ROW_BAR - 4)
bar.Track.Visible = true
bar.Track.Position = UDim2.fromOffset(x + labelWidth, y + 3)
bar.Track.Size = UDim2.fromOffset(math.max(width - labelWidth - textWidth - 4, 20), inline and 8 or 7)
bar.Text.Visible = bar.ShowText
bar.Text.Position = UDim2.fromOffset(x + width - textWidth, y)
bar.Text.Size = UDim2.fromOffset(textWidth, ROW_BAR - 4)
end
function TargetHUD:Show()
if self._visible then
return
end
self._visible = true
self._token += 1
self._lastTouch = os.clock()
self.Root.Visible = true
AnimationManager.Play(self.Card, "Instant", { GroupTransparency = 1, Position = UDim2.fromOffset(0, 10) })
AnimationManager.Play(self._shadow.Instance, "Instant", { GroupTransparency = 1 })
AnimationManager.Play(self._stroke, "Instant", { Transparency = 1 })
AnimationManager.Play(self.Card, "Expo", { GroupTransparency = 0, Position = UDim2.new() })
AnimationManager.Play(self._shadow.Instance, "Expo", { GroupTransparency = 0 })
AnimationManager.Play(self._stroke, "Expand", { Transparency = Visual.strokeTransparency(self._theme) })
end
function TargetHUD:Hide()
if not self._visible or self._editable then
return
end
self._visible = false
self._token += 1
local token = self._token
AnimationManager.Play(self.Card, "Close", { GroupTransparency = 1, Position = UDim2.fromOffset(0, 6) })
AnimationManager.Play(self._shadow.Instance, "Close", { GroupTransparency = 1 })
AnimationManager.Play(self._stroke, "Close", { Transparency = 1 })
task.delay(AnimationManager.Time(0.22), function()
if self._token == token and not self._visible then
self.Root.Visible = false
end
end)
end
function TargetHUD:SetVisible(visible)
if visible then
self:Show()
else
self:Hide()
end
end
function TargetHUD:Toggle()
self:SetVisible(not self._visible)
end
function TargetHUD:IsVisible()
return self._visible
end
function TargetHUD:Flash(color)
color = color or self._theme:Get("Accent")
self._flash.BackgroundColor3 = color
AnimationManager.Play(self._flash, "Instant", { BackgroundTransparency = 0.7 })
AnimationManager.Play(self._flash, "Slow", { BackgroundTransparency = 1 })
end
function TargetHUD:SetEditable(editable)
editable = editable == true
if editable == self._editable then
return
end
self._editable = editable
if editable then
self.Gui.DisplayOrder = 945
if not self._visible then
self:Show()
end
self._dragger = Draggable.new(self.Card, self.Root, {
OnDragEnd = function()
self._custom = self.Root.Position
end,
})
self.Card.Active = true
local done = Create("TextButton", {
Name = "Done",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 70),
Size = UDim2.fromOffset(150, 30),
BackgroundTransparency = 0,
BackgroundColor3 = self._theme:Get("Accent"),
Text = "Done editing",
TextColor3 = Color3.new(1, 1, 1),
Font = self._theme:Get("FontBold"),
Parent = self.Gui,
})
Create.corner(done, 8)
self._maid:GiveNamed("done", done)
self._maid:GiveNamed(
"doneClick",
done.MouseButton1Click:Connect(function()
self:SetEditable(false)
end)
)
else
self.Gui.DisplayOrder = 60
self._maid:Remove("done")
self._maid:Remove("doneClick")
if self._dragger then
self._dragger:Destroy()
self._dragger = nil
end
end
end
function TargetHUD:Export()
local out = { Position = self._position, Width = self._width, Style = self._style, Debug = self._debug }
if self._offset then
out.Offset = { self._offset.X, self._offset.Y }
end
if self._custom then
local p = self._custom
out.Custom = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
end
return out
end
function TargetHUD:Import(data)
if type(data) ~= "table" then
return false
end
if ANCHORS[data.Position] then
self._position = data.Position
end
if type(data.Width) == "number" then
self._width = math.clamp(data.Width, 140, 500)
end
if STYLES[data.Style] then
self._style = data.Style
end
self._offset = type(data.Offset) == "table" and #data.Offset == 2 and Vector2.new(data.Offset[1], data.Offset[2])
or nil
self._custom = type(data.Custom) == "table"
and #data.Custom == 4
and UDim2.new(data.Custom[1], data.Custom[2], data.Custom[3], data.Custom[4])
or nil
self:_applyPosition()
if data.Debug ~= nil then
self:SetDebug(data.Debug == true)
else
self:_relayout(false)
end
return true
end
function TargetHUD:Attach(window)
self._window = window
window:_attachWidget("TargetHUD", self)
end
function TargetHUD:Detach(window)
if self._window then
self._window:_detachWidget(self)
self._window = nil
end
end
function TargetHUD:Destroy()
if self._destroyed then
return
end
self._destroyed = true
self:Detach()
if self._dragger then
self._dragger:Destroy()
end
self._shadow:Destroy()
self._maid:Clean()
self.Library:_removeWidget(self)
end
return TargetHUD
end
__functions[__n_Core_ThemeManager] = function(script, require)
local Types = require(script.Parent.Parent.Types)
local Signal = require(script.Parent.Parent.Utilities.Signal)
local AnimationManager = require(script.Parent.AnimationManager)
local Fonts = require(script.Parent.Fonts)
type Theme = Types.Theme
local ThemeManager = {}
ThemeManager.__index = ThemeManager
type ThemeManager = typeof(setmetatable(
{} :: {
Current: Theme,
Changed: Signal.Signal,
ListChanged: Signal.Signal,
_presets: { [string]: Theme },
_custom: { [string]: boolean },
_builtin: { [string]: boolean },
_bindings: { [Instance]: { [string]: any } },
_initial: Theme,
},
ThemeManager
))
local function shade(accent: Color3): Color3
local h, s, v = accent:ToHSV()
return Color3.fromHSV((h + 0.06) % 1, s, v * 0.7)
end
local BASE: Theme = {
Name = "Base",
Background = Color3.fromRGB(16, 16, 20),
Panel = Color3.fromRGB(22, 22, 28),
Header = Color3.fromRGB(28, 28, 36),
Module = Color3.fromRGB(30, 30, 38),
ModuleHover = Color3.fromRGB(38, 38, 48),
Element = Color3.fromRGB(42, 42, 54),
ElementHover = Color3.fromRGB(52, 52, 66),
Accent = Color3.fromRGB(167, 139, 250),
AccentDark = shade(Color3.fromRGB(167, 139, 250)),
Text = Color3.fromRGB(236, 236, 244),
TextDim = Color3.fromRGB(138, 138, 156),
Stroke = Color3.fromRGB(56, 56, 72),
Success = Color3.fromRGB(74, 222, 128),
Warning = Color3.fromRGB(250, 204, 21),
Error = Color3.fromRGB(248, 113, 113),
Info = Color3.fromRGB(96, 165, 250),
Transparency = 0.06,
CornerRadius = 8,
Border = true,
BorderThickness = 1,
AccentLine = true,
AccentLineThickness = 2,
HeaderAlign = "Center",
ModuleSpacing = 4,
ModuleTextSize = 13,
HeaderTextSize = 14,
SheenStrength = 0.14,
GradientStrength = 1,
BorderTransparency = 0.35,
Gradients = true,
GradientRotation = 90,
ShadowPreset = "Medium",
ShadowOpacity = 0.45,
ShadowColor = Color3.new(0, 0, 0),
Font = Enum.Font.GothamMedium,
FontBold = Enum.Font.GothamBold,
AccentGradient = true,
AccentGradientAngle = 0,
AccentBorder = false,
ModuleCornerRadius = -1,
ModuleTransparency = 0,
BackdropColor = Color3.new(0, 0, 0),
BackdropTransparency = 0.55,
ScrollBarThickness = 3,
}
local function cleanName(name: any): string
local text = string.match(tostring(name or ""), "^%s*(.-)%s*$") or ""
text = string.gsub(text, "%c", "")
return string.sub(text, 1, 32)
end
local function derive(name: string, overrides: Types.PartialTheme): Theme
local theme: any = table.clone(BASE)
for key, value in overrides do
local resolved = value
if (key == "Font" or key == "FontBold") and type(value) == "string" then
resolved = Fonts.Deserialize(value, key == "FontBold") or (BASE :: any)[key]
end
theme[key] = resolved
end
theme.Name = name
if overrides.Accent and not overrides.AccentDark then
theme.AccentDark = shade(theme.Accent)
end
return theme :: Theme
end
local PRESETS: { [string]: Theme } = {
Violet = derive("Violet", { Accent = Color3.fromRGB(167, 139, 250) }),
Ocean = derive("Ocean", {
Accent = Color3.fromRGB(59, 130, 246),
Panel = Color3.fromRGB(16, 18, 26),
Header = Color3.fromRGB(22, 25, 36),
Module = Color3.fromRGB(24, 27, 38),
ModuleHover = Color3.fromRGB(32, 36, 50),
Element = Color3.fromRGB(34, 39, 54),
ElementHover = Color3.fromRGB(44, 50, 68),
Stroke = Color3.fromRGB(44, 52, 74),
}),
Mocha = derive("Mocha", {
Accent = Color3.fromRGB(236, 140, 64),
Background = Color3.fromRGB(30, 21, 19),
Panel = Color3.fromRGB(46, 33, 30),
Header = Color3.fromRGB(52, 38, 34),
Module = Color3.fromRGB(56, 41, 37),
ModuleHover = Color3.fromRGB(68, 50, 45),
Element = Color3.fromRGB(74, 55, 49),
ElementHover = Color3.fromRGB(88, 66, 59),
Text = Color3.fromRGB(245, 235, 225),
TextDim = Color3.fromRGB(165, 145, 134),
Stroke = Color3.fromRGB(92, 70, 62),
}),
Midnight = derive("Midnight", {
Accent = Color3.fromRGB(99, 102, 241),
Background = Color3.fromRGB(8, 10, 28),
Panel = Color3.fromRGB(14, 16, 42),
Header = Color3.fromRGB(18, 21, 54),
Module = Color3.fromRGB(22, 26, 64),
ModuleHover = Color3.fromRGB(30, 35, 80),
Element = Color3.fromRGB(32, 37, 84),
ElementHover = Color3.fromRGB(42, 48, 100),
Text = Color3.fromRGB(240, 242, 255),
TextDim = Color3.fromRGB(142, 148, 192),
Stroke = Color3.fromRGB(52, 60, 128),
}),
Ink = derive("Ink", {
Accent = Color3.fromRGB(168, 120, 255),
Background = Color3.fromRGB(10, 10, 18),
Panel = Color3.fromRGB(17, 17, 28),
Header = Color3.fromRGB(21, 21, 34),
Module = Color3.fromRGB(25, 25, 40),
ModuleHover = Color3.fromRGB(35, 35, 54),
Element = Color3.fromRGB(38, 38, 58),
ElementHover = Color3.fromRGB(50, 50, 74),
Text = Color3.fromRGB(232, 232, 246),
TextDim = Color3.fromRGB(132, 132, 164),
Stroke = Color3.fromRGB(46, 46, 72),
}),
Rose = derive("Rose", { Accent = Color3.fromRGB(244, 114, 182) }),
Crimson = derive("Crimson", { Accent = Color3.fromRGB(239, 68, 68) }),
Emerald = derive("Emerald", { Accent = Color3.fromRGB(16, 185, 129) }),
Sunset = derive("Sunset", { Accent = Color3.fromRGB(251, 146, 60) }),
Mono = derive("Mono", {
Accent = Color3.fromRGB(225, 225, 232),
AccentDark = Color3.fromRGB(140, 140, 150),
Panel = Color3.fromRGB(10, 10, 12),
Header = Color3.fromRGB(16, 16, 18),
Module = Color3.fromRGB(18, 18, 21),
ModuleHover = Color3.fromRGB(28, 28, 32),
Element = Color3.fromRGB(30, 30, 35),
ElementHover = Color3.fromRGB(42, 42, 48),
Stroke = Color3.fromRGB(46, 46, 52),
Transparency = 0.02,
}),
Light = derive("Light", {
Accent = Color3.fromRGB(99, 102, 241),
Background = Color3.fromRGB(238, 238, 243),
Panel = Color3.fromRGB(246, 246, 250),
Header = Color3.fromRGB(255, 255, 255),
Module = Color3.fromRGB(255, 255, 255),
ModuleHover = Color3.fromRGB(240, 240, 247),
Element = Color3.fromRGB(232, 232, 241),
ElementHover = Color3.fromRGB(220, 220, 232),
Text = Color3.fromRGB(28, 28, 38),
TextDim = Color3.fromRGB(116, 116, 136),
Stroke = Color3.fromRGB(208, 208, 222),
}),
}
function ThemeManager.new(initial: (string | Types.PartialTheme)?): ThemeManager
local presets: { [string]: Theme } = {}
for name, theme in PRESETS do
presets[name] = theme
end
local builtin: { [string]: boolean } = {}
for name in PRESETS do
builtin[name] = true
end
local self: ThemeManager = setmetatable({
Current = presets.Violet,
Changed = Signal.new(),
ListChanged = Signal.new(),
_presets = presets,
_custom = {},
_builtin = builtin,
_initial = presets.Violet,
_bindings = setmetatable({}, { __mode = "k" }) :: any,
}, ThemeManager)
if initial ~= nil then
self:SetTheme(initial, true)
end
self._initial = self.Current
self:_verifyFonts()
return self
end
function ThemeManager.Get(self: ThemeManager, key: string): any
return (self.Current :: any)[key]
end
function ThemeManager.GetTheme(self: ThemeManager): Theme
return self.Current
end
function ThemeManager.GetNames(self: ThemeManager): { string }
local names = {}
for name in self._presets do
table.insert(names, name)
end
table.sort(names)
return names
end
function ThemeManager.Register(self: ThemeManager, name: string, theme: Types.PartialTheme)
self._presets[name] = derive(name, theme)
self.ListChanged:Fire()
end
local function isTweenable(value: any): boolean
local kind = typeof(value)
return kind == "Color3" or kind == "number" or kind == "UDim2" or kind == "UDim" or kind == "Vector2"
end
local function resolveKey(self: ThemeManager, key: any): any
if type(key) == "function" then
return key(self.Current)
end
return (self.Current :: any)[key]
end
local function applyValue(instance: Instance, property: string, value: any, animated: boolean)
if property == "Font" and typeof(value) == "Font" then
(instance :: any).FontFace = value
elseif animated and isTweenable(value) then
AnimationManager.Play(instance, "Normal", { [property] = value })
else
(instance :: any)[property] = value
end
end
function ThemeManager.Bind(self: ThemeManager, instance: Instance, property: string, key: string | ((Theme) -> any))
local map = self._bindings[instance]
if not map then
map = {}
self._bindings[instance] = map
instance.Destroying:Once(function()
self._bindings[instance] = nil
end)
end
map[property] = key
applyValue(instance, property, resolveKey(self, key), false)
end
function ThemeManager.SetTheme(self: ThemeManager, theme: string | Types.PartialTheme, silent: boolean?)
local resolved: Theme
if type(theme) == "string" then
local found = self._presets[theme]
if not found then
warn(`[ClickGUI] Unknown theme "{theme}"`)
return
end
resolved = found
else
resolved = derive(theme.Name or "Custom", theme)
end
self.Current = resolved
if silent then
return
end
self:_refresh()
end
function ThemeManager.SetAccent(self: ThemeManager, color: Color3)
local theme: any = table.clone(self.Current)
theme.Accent = color
theme.AccentDark = shade(color)
self.Current = theme :: Theme
self:_refresh()
end
function ThemeManager.Patch(self: ThemeManager, values: { [string]: any })
local theme: any = table.clone(self.Current)
for key, value in values do
if (BASE :: any)[key] ~= nil then
local resolved = value
if (key == "Font" or key == "FontBold") and type(value) == "string" then
resolved = Fonts.Deserialize(value, key == "FontBold") or theme[key]
end
theme[key] = resolved
end
end
if values.Accent and not values.AccentDark then
theme.AccentDark = shade(values.Accent)
end
self.Current = theme :: Theme
self:_refresh()
end
function ThemeManager._refresh(self: ThemeManager)
for instance, map in self._bindings do
for property, key in map do
applyValue(instance, property, resolveKey(self, key), true)
end
end
self.Changed:Fire(self.Current)
self:_verifyFonts()
end
function ThemeManager._verifyFonts(self: ThemeManager)
for _, key in { "Font", "FontBold" } do
local value = (self.Current :: any)[key]
if typeof(value) == "Font" then
Fonts.Probe(value, function(ok)
if ok then
return
end
local current: any = self.Current
if current[key] ~= value then
return
end
local theme: any = table.clone(current)
theme[key] = Fonts.ToEnum(value, key == "FontBold")
self.Current = theme :: Theme
self:_refresh()
end)
end
end
end
function ThemeManager.Set(self: ThemeManager, key: string, value: any)
assert((BASE :: any)[key] ~= nil, `[ClickGUI] Unknown theme field "{key}"`)
local theme: any = table.clone(self.Current)
if (key == "Font" or key == "FontBold") and type(value) == "string" then
value = Fonts.Deserialize(value, key == "FontBold") or theme[key]
end
theme[key] = value
if key == "Accent" then
theme.AccentDark = shade(value)
end
self.Current = theme :: Theme
self:_refresh()
end
function ThemeManager.Restore(self: ThemeManager)
self.Current = self._initial
self:_refresh()
end
function ThemeManager.Serialize(theme: Theme): { [string]: any }
local out: { [string]: any } = {}
for key, value in theme :: any do
local kind = typeof(value)
if kind == "Color3" then
out[key] = { math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255) }
elseif kind == "EnumItem" or kind == "Font" then
out[key] = Fonts.Serialize(value)
else
out[key] = value
end
end
return out
end
function ThemeManager.Deserialize(data: { [string]: any }): Types.PartialTheme
local out: { [string]: any } = {}
for key, value in data do
local base = (BASE :: any)[key]
local kind = typeof(base)
if key == "Name" and type(value) == "string" then
out.Name = value
elseif kind == "Color3" and type(value) == "table" and #value == 3 then
out[key] = Color3.fromRGB(value[1], value[2], value[3])
elseif key == "Font" or key == "FontBold" then
local font = Fonts.Deserialize(value, key == "FontBold")
if font ~= nil then
out[key] = font
end
elseif base ~= nil and type(base) == type(value) then
out[key] = value
end
end
return out
end
function ThemeManager.ExportTheme(self: ThemeManager, name: string?): { [string]: any }
local out = ThemeManager.Serialize(self.Current)
local cleaned = name ~= nil and cleanName(name) or ""
if cleaned ~= "" then
out.Name = cleaned
end
return out
end
function ThemeManager.ImportTheme(self: ThemeManager, data: { [string]: any }, name: string?): boolean
if type(data) ~= "table" then
return false
end
local partial = ThemeManager.Deserialize(data)
local themeName = name or partial.Name or "Imported"
self:Register(themeName, partial)
self:SetTheme(themeName)
return true
end
function ThemeManager.SetFont(self: ThemeManager, name: string, titleName: string?): boolean
local entry = Fonts.Get(name)
if not entry then
warn(`[ClickGUI] Unknown font "{tostring(name)}"`)
return false
end
local theme: any = table.clone(self.Current)
theme.Font = Fonts.Resolve(entry.Name, false)
local title = (titleName ~= nil and titleName ~= "Auto") and Fonts.Get(titleName) or nil
if title then
theme.FontBold = Fonts.Resolve(title.Name, true, true)
else
theme.FontBold = Fonts.Resolve(entry.Name, true)
end
self.Current = theme :: Theme
self:_refresh()
return true
end
function ThemeManager.SetTitleFont(self: ThemeManager, name: string): boolean
local resolved
if name == "Auto" then
local entry = Fonts.Get(Fonts.NameOf((self.Current :: any).Font))
resolved = entry and Fonts.Resolve(entry.Name, true)
else
resolved = Fonts.Resolve(name, true, true)
end
if resolved == nil then
warn(`[ClickGUI] Unknown font "{tostring(name)}"`)
return false
end
local theme: any = table.clone(self.Current)
theme.FontBold = resolved
self.Current = theme :: Theme
self:_refresh()
return true
end
function ThemeManager.IsBuiltin(self: ThemeManager, name: string): boolean
return self._builtin[cleanName(name)] == true
end
function ThemeManager.IsCustom(self: ThemeManager, name: string): boolean
return self._custom[cleanName(name)] == true
end
function ThemeManager.GetCustomNames(self: ThemeManager): { string }
local names = {}
for name in self._custom do
table.insert(names, name)
end
table.sort(names)
return names
end
function ThemeManager.SaveCustom(self: ThemeManager, name: string, data: Types.PartialTheme?): (boolean, string)
local cleaned = cleanName(name)
if cleaned == "" then
return false, "Enter a theme name first"
end
if self._builtin[cleaned] then
return false, "That name belongs to a built-in theme"
end
local source: any = data or self.Current
local theme = derive(cleaned, source)
self._presets[cleaned] = theme
self._custom[cleaned] = true
self.ListChanged:Fire()
if data == nil then
self.Current = theme
self:_refresh()
end
return true, cleaned
end
function ThemeManager.DeleteCustom(self: ThemeManager, name: string): boolean
local cleaned = cleanName(name)
if not self._custom[cleaned] then
return false
end
self._custom[cleaned] = nil
self._presets[cleaned] = nil
self.ListChanged:Fire()
return true
end
function ThemeManager.ExportCustom(self: ThemeManager): { [string]: any }
local out = {}
for name in self._custom do
local theme = self._presets[name]
if theme then
out[name] = ThemeManager.Serialize(theme)
end
end
return out
end
function ThemeManager.LoadCustom(self: ThemeManager, map: any): number
if type(map) ~= "table" then
return 0
end
local count = 0
for name, data in map do
local cleaned = type(name) == "string" and cleanName(name) or ""
if cleaned ~= "" and not self._builtin[cleaned] and type(data) == "table" then
self._presets[cleaned] = derive(cleaned, ThemeManager.Deserialize(data))
self._custom[cleaned] = true
count += 1
end
end
if count > 0 then
self.ListChanged:Fire()
end
return count
end
function ThemeManager.Destroy(self: ThemeManager)
self.Changed:Destroy()
self.ListChanged:Destroy()
table.clear(self._bindings)
end
return ThemeManager
end
__functions[__n_Core_Tooltip] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Utilities = script.Parent.Parent.Utilities
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local Fonts = require(script.Parent.Fonts)
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local LONG_PRESS = 0.45
local TOUCH_VISIBLE = 1.6
local Tooltip = {}
Tooltip.__index = Tooltip
function Tooltip.new(window)
local self = setmetatable({}, Tooltip)
local theme = window.Theme
self._window = window
self._theme = theme
self._maid = Maid.new()
self._token = 0
self._shown = false
self.Enabled = true
self.Delay = 0.5
self.Frame = Create("Frame", {
Name = "Tooltip",
Size = UDim2.fromOffset(10, 10),
BackgroundTransparency = 1,
Visible = false,
ZIndex = 500,
Parent = window.Root,
})
self._canvas = Create("CanvasGroup", {
Name = "Canvas",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = theme:Get("Header"),
GroupTransparency = 1,
Parent = self.Frame,
})
theme:Bind(self._canvas, "BackgroundColor3", "Header")
self._stroke = Visual.surface(theme, self._canvas, "module")
self._label = Create("TextLabel", {
Name = "Text",
Position = UDim2.fromOffset(8, 5),
Size = UDim2.new(1, -16, 1, -10),
TextSize = 12,
TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
Font = theme:Get("Font"),
TextColor3 = theme:Get("Text"),
Parent = self._canvas,
})
theme:Bind(self._label, "TextColor3", "Text")
theme:Bind(self._label, "Font", "Font")
self._maid:Give(window.Closed:Connect(function()
self:Hide()
end))
return self
end
function Tooltip:_place(position)
local viewport = self._window.Gui.AbsoluteSize
local w, h = self._w or 0, self._h or 0
local x, y = position.X + 14, position.Y + 18
if x + w > viewport.X - 4 then
x = position.X - w - 10
end
if y + h > viewport.Y - 4 then
y = position.Y - h - 10
end
self.Frame.Position = UDim2.fromOffset(math.max(x, 4), math.max(y, 4))
end
function Tooltip:Show(text, position, follow)
if not self.Enabled or text == nil or text == "" then
return
end
local font = Fonts.ToEnum(self._theme:Get("Font"), false)
local bounds = TextService:GetTextSize(text, 12, font, Vector2.new(220, 1000))
self._label.Text = text
self._w, self._h = bounds.X + 18, bounds.Y + 12
self.Frame.Size = UDim2.fromOffset(self._w, self._h)
self.Frame.Visible = true
self:_place(position)
self._shown = true
AnimationManager.Play(self._canvas, "Instant", { Position = UDim2.fromOffset(0, 6) })
AnimationManager.Play(self._stroke, "Instant", { Transparency = 1 })
AnimationManager.Play(self._stroke, "Fast", { Transparency = Visual.strokeTransparency(self._theme, 0.3) })
AnimationManager.Play(self._canvas, "Fast", { GroupTransparency = 0, Position = UDim2.new() })
self._maid:Remove("follow")
if follow then
self._maid:GiveNamed(
"follow",
RunService.RenderStepped:Connect(function()
self:_place(UserInputService:GetMouseLocation())
end)
)
end
end
function Tooltip:Hide()
self._token += 1
if not self._shown then
return
end
self._shown = false
self._maid:Remove("follow")
AnimationManager.Play(self._canvas, "Fast", { GroupTransparency = 1 })
AnimationManager.Play(self._stroke, "Fast", { Transparency = 1 })
local token = self._token
task.delay(AnimationManager.Time(0.15), function()
if self._token == token and not self._shown then
self.Frame.Visible = false
end
end)
end
function Tooltip:Attach(gui, source)
local function read()
if type(source) == "function" then
local ok, value = pcall(source)
return ok and value or nil
end
return source
end
local maid = Maid.new()
maid:Give(gui.MouseEnter:Connect(function()
self._token += 1
local token = self._token
task.delay(self.Delay, function()
if self._token == token and self.Enabled and self._window:IsOpen() then
self:Show(read(), UserInputService:GetMouseLocation(), true)
end
end)
end))
maid:Give(gui.MouseLeave:Connect(function()
self:Hide()
end))
maid:Give(gui.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
self:Hide()
elseif input.UserInputType == Enum.UserInputType.Touch then
self._token += 1
local token = self._token
local position = Vector2.new(input.Position.X, input.Position.Y)
task.delay(LONG_PRESS, function()
if self._token == token and self.Enabled and input.UserInputState ~= Enum.UserInputState.End then
self:Show(read(), position, false)
task.delay(TOUCH_VISIBLE, function()
if self._token == token then
self:Hide()
end
end)
end
end)
end
end))
maid:Give(gui.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
self._token += 1
end
end))
return function()
maid:Clean()
end
end
function Tooltip:SetEnabled(enabled)
self.Enabled = enabled
if not enabled then
self:Hide()
end
end
function Tooltip:Destroy()
self._maid:Clean()
self.Frame:Destroy()
end
return Tooltip
end
__functions[__n_Core_Visual] = function(script, require)
local Create = require(script.Parent.Parent.Utilities.Create)
local Visual = {}
function Visual.corner(theme, parent, delta)
local corner = Instance.new("UICorner")
corner.Parent = parent
theme:Bind(corner, "CornerRadius", function(t)
return UDim.new(0, math.max(t.CornerRadius + (delta or 0), 0))
end)
return corner
end
function Visual.stroke(theme, parent, extraTransparency)
local stroke = Create.stroke(parent, theme:Get("Stroke"), 1, 0)
theme:Bind(stroke, "Color", function(t)
return t.AccentBorder and t.Accent or t.Stroke
end)
theme:Bind(stroke, "Thickness", function(t)
return t.Border and t.BorderThickness or 0
end)
theme:Bind(stroke, "Transparency", function(t)
return math.clamp(t.BorderTransparency + (extraTransparency or 0), 0, 1)
end)
return stroke
end
function Visual.strokeTransparency(theme, extra)
local t = theme.Current
return math.clamp(t.BorderTransparency + (extra or 0), 0, 1)
end
function Visual.gradient(theme, parent, strength, rotationOffset)
local gradient = Instance.new("UIGradient")
gradient.Parent = parent
theme:Bind(gradient, "Color", function(t)
local s = math.clamp(strength * t.GradientStrength, 0, 0.9)
return ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - s, 1 - s, 1 - s))
end)
theme:Bind(gradient, "Rotation", function(t)
return t.GradientRotation + (rotationOffset or 0)
end)
theme:Bind(gradient, "Enabled", "Gradients")
return gradient
end
function Visual.accentGradient(theme, parent)
local gradient = Instance.new("UIGradient")
gradient.Parent = parent
theme:Bind(gradient, "Color", function(t)
if t.AccentGradient == false then
return ColorSequence.new(t.Accent)
end
return ColorSequence.new(t.Accent, t.AccentDark)
end)
theme:Bind(gradient, "Rotation", function(t)
return t.AccentGradientAngle or 0
end)
return gradient
end
function Visual.sheen(theme, parent, strength)
local sheen = Instance.new("Frame")
sheen.Name = "Sheen"
sheen.Size = UDim2.fromScale(1, 1)
sheen.BackgroundColor3 = Color3.new(1, 1, 1)
sheen.BorderSizePixel = 0
sheen.Active = false
sheen.Parent = parent
local gradient = Instance.new("UIGradient")
gradient.Parent = sheen
theme:Bind(gradient, "Transparency", function(t)
return NumberSequence.new(1 - math.clamp(strength * t.SheenStrength / 0.14, 0, 0.9), 1)
end)
theme:Bind(gradient, "Rotation", "GradientRotation")
theme:Bind(gradient, "Enabled", "Gradients")
theme:Bind(sheen, "BackgroundTransparency", function(t)
return t.Gradients and 0 or 1
end)
return sheen
end
function Visual.surface(theme, instance, kind, strength)
local corner
if kind == "module" then
corner = Instance.new("UICorner")
corner.Parent = instance
theme:Bind(corner, "CornerRadius", function(t)
local custom = t.ModuleCornerRadius or -1
if custom >= 0 then
return UDim.new(0, custom)
end
return UDim.new(0, math.max(t.CornerRadius - 2, 0))
end)
else
corner = Visual.corner(theme, instance, 0)
end
local stroke = Visual.stroke(theme, instance, kind == "module" and 0.3 or 0)
if strength and strength > 0 then
if instance:IsA("CanvasGroup") then
Visual.sheen(theme, instance, strength)
else
Visual.gradient(theme, instance, strength)
end
end
return stroke, corner
end
function Visual.icon(parent, spec, size, color, props)
local text = tostring(spec)
local id = type(spec) == "number" and tostring(spec) or string.match(text, "^%d+$")
local isImage = id ~= nil or string.match(text, "^rbx") ~= nil
local instance
if isImage then
instance = Create("ImageLabel", {
Image = id and ("rbxassetid://" .. id) or text,
ImageColor3 = color,
ScaleType = Enum.ScaleType.Fit,
})
else
instance = Create("TextLabel", {
Text = text,
TextSize = math.max(size - 2, 8),
TextColor3 = color,
Font = Enum.Font.GothamMedium,
})
end
instance.Name = "Icon"
instance.Size = UDim2.fromOffset(size, size)
for key, value in props or {} do
instance[key] = value
end
instance.Parent = parent
return { Instance = instance, Property = isImage and "ImageColor3" or "TextColor3", IsImage = isImage }
end
return Visual
end
__functions[__n_Core_Watermark] = function(script, require)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utilities = script.Parent.Parent.Utilities
local Components = script.Parent.Parent.Components
local AnimationManager = require(script.Parent.AnimationManager)
local Visual = require(script.Parent.Visual)
local UIShadow = require(Components.UIShadow)
local Create = require(Utilities.Create)
local Draggable = require(Utilities.Draggable)
local Maid = require(Utilities.Maid)
local Watermark = {}
Watermark.__index = Watermark
local ANCHORS = {
TopLeft = { Anchor = Vector2.new(0, 0), Pos = UDim2.fromScale(0, 0), Offset = Vector2.new(12, 12) },
TopCenter = { Anchor = Vector2.new(0.5, 0), Pos = UDim2.fromScale(0.5, 0), Offset = Vector2.new(0, 12) },
TopRight = { Anchor = Vector2.new(1, 0), Pos = UDim2.fromScale(1, 0), Offset = Vector2.new(-12, 12) },
CenterLeft = { Anchor = Vector2.new(0, 0.5), Pos = UDim2.fromScale(0, 0.5), Offset = Vector2.new(12, 0) },
CenterRight = { Anchor = Vector2.new(1, 0.5), Pos = UDim2.fromScale(1, 0.5), Offset = Vector2.new(-12, 0) },
BottomLeft = { Anchor = Vector2.new(0, 1), Pos = UDim2.fromScale(0, 1), Offset = Vector2.new(12, -12) },
BottomCenter = { Anchor = Vector2.new(0.5, 1), Pos = UDim2.fromScale(0.5, 1), Offset = Vector2.new(0, -12) },
BottomRight = { Anchor = Vector2.new(1, 1), Pos = UDim2.fromScale(1, 1), Offset = Vector2.new(-12, -12) },
}
Watermark.Positions =
{ "TopLeft", "TopCenter", "TopRight", "CenterLeft", "CenterRight", "BottomLeft", "BottomCenter", "BottomRight" }
function Watermark.new(library, options)
options = options or {}
local self = setmetatable({}, Watermark)
local theme = library.Theme
self.Library = library
self.Name = options.Name or "Watermark"
self._theme = theme
self._maid = Maid.new()
self._text = options.Text or ""
self._position = ANCHORS[options.Position or ""] and options.Position or "TopLeft"
self._offset = options.Offset
self._custom = typeof(options.Custom) == "UDim2" and options.Custom or nil
self._variables = options.Variables or {}
self._rate = options.UpdateRate or 0.5
self._visible = options.Visible ~= false
self._background = options.Background ~= false
self._backgroundTransparency = options.BackgroundTransparency or 0.2
self._color = typeof(options.Color) == "Color3" and options.Color or nil
self._gradient = nil
if options.Gradient == false then
self._noGradient = true
elseif
type(options.Gradient) == "table"
and typeof(options.Gradient[1]) == "Color3"
and typeof(options.Gradient[2]) == "Color3"
then
self._gradient = { options.Gradient[1], options.Gradient[2] }
end
self._gradientRotation = options.GradientRotation or 0
self._textSize = options.TextSize or 14
self._imageSize = options.ImageSize or 20
self._font = options.Font
self._rounded = options.Rounded
self._editable = false
self._fps = 60
self._token = 0
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_Watermark_" .. self.Name,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 55,
Parent = options.Parent or library:GetGuiParent(),
})
self._maid:Give(self.Gui)
library:_secureGui(self.Gui)
self.Root = Create("Frame", {
Name = "Root",
Size = UDim2.new(),
AutomaticSize = Enum.AutomaticSize.XY,
BackgroundTransparency = 1,
Visible = self._visible,
Parent = self.Gui,
})
if options.Shadow ~= false then
self._shadow = UIShadow.new({
Parent = self.Root,
Preset = "Soft",
CornerRadius = options.Rounded or theme:Get("CornerRadius"),
})
end
self.Card = Create("CanvasGroup", {
Name = "Card",
Size = UDim2.new(),
AutomaticSize = Enum.AutomaticSize.XY,
BackgroundColor3 = theme:Get("Panel"),
BackgroundTransparency = self._background and self._backgroundTransparency or 1,
ZIndex = 2,
Parent = self.Root,
})
theme:Bind(self.Card, "BackgroundColor3", "Panel")
self.Root.AutomaticSize = Enum.AutomaticSize.None
self._maid:Give(self.Card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
self.Root.Size = UDim2.fromOffset(self.Card.AbsoluteSize.X, self.Card.AbsoluteSize.Y)
end))
local corner = Instance.new("UICorner")
corner.Parent = self.Card
if self._rounded then
corner.CornerRadius = UDim.new(0, self._rounded)
else
theme:Bind(corner, "CornerRadius", function(t)
return UDim.new(0, math.max(t.CornerRadius - 2, 0))
end)
end
self._stroke = Create.stroke(self.Card, theme:Get("Stroke"), 1, 0)
theme:Bind(self._stroke, "Color", "Stroke")
theme:Bind(self._stroke, "Transparency", function(t)
return self._background and math.clamp(t.BorderTransparency, 0, 1) or 1
end)
self._content = Create("Frame", {
Name = "Content",
Size = UDim2.new(),
AutomaticSize = Enum.AutomaticSize.XY,
BackgroundTransparency = 1,
Parent = self.Card,
})
Create.padding(self._content, 6, 12, 6, 12)
local layout = Create.list(self._content, 8, true)
layout.VerticalAlignment = Enum.VerticalAlignment.Center
self._label = Create("TextLabel", {
Name = "Text",
Size = UDim2.fromOffset(0, self._textSize + 6),
AutomaticSize = Enum.AutomaticSize.X,
Text = "",
TextSize = self._textSize,
Font = self._font or theme:Get("FontBold"),
TextColor3 = Color3.new(1, 1, 1),
RichText = options.RichText == true,
LayoutOrder = 2,
Parent = self._content,
})
self._textGradient = Instance.new("UIGradient")
self._textGradient.Parent = self._label
self._maid:Give(theme.Changed:Connect(function()
self:_applyColors()
end))
if options.Image ~= nil then
self:SetImage(options.Image)
end
self:SetText(self._text)
self:_applyColors()
self:_applyPosition()
self._maid:Give(RunService.Heartbeat:Connect(function(dt)
self._frames = (self._frames or 0) + 1
self._elapsed = (self._elapsed or 0) + dt
if self._elapsed >= self._rate then
self._fps = math.floor(self._frames / self._elapsed + 0.5)
self._frames, self._elapsed = 0, 0
self:_refreshText()
end
end))
return self
end
function Watermark:_applyColors()
local theme = self._theme
local gradient = self._textGradient
if self._color then
gradient.Enabled = false
self._label.TextColor3 = self._color
else
gradient.Enabled = true
self._label.TextColor3 = Color3.new(1, 1, 1)
local from, to
if self._gradient then
from, to = self._gradient[1], self._gradient[2]
elseif self._noGradient then
from, to = theme:Get("Accent"), theme:Get("Accent")
else
from, to = theme:Get("Accent"), theme:Get("AccentDark")
end
gradient.Color = ColorSequence.new(from, to)
gradient.Rotation = self._gradientRotation
end
if self._image then
local color = self._imageColor or (self._color or (self._gradient and self._gradient[1]) or theme:Get("Accent"))
AnimationManager.Play(self._image.Instance, "Fast", { [self._image.Property] = color })
end
end
local function resolveToken(self, key)
local custom = self._variables[key]
if custom ~= nil then
local value = custom
if type(custom) == "function" then
local ok, result = pcall(custom)
value = ok and result or "?"
end
return tostring(value)
end
if key == "fps" then
return tostring(self._fps)
elseif key == "ping" then
local ok, ping = pcall(function()
return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
end)
return (ok and tonumber(ping)) and tostring(math.floor(tonumber(ping) + 0.5)) or "0"
elseif key == "time" then
return os.date("%H:%M")
elseif key == "date" then
return os.date("%d/%m/%Y")
elseif key == "player" then
return Players.LocalPlayer and Players.LocalPlayer.Name or "Player"
elseif key == "display" then
return Players.LocalPlayer and Players.LocalPlayer.DisplayName or "Player"
elseif key == "memory" then
local ok, memory = pcall(function()
return game:GetService("Stats"):GetTotalMemoryUsageMb()
end)
return (ok and tonumber(memory)) and tostring(math.floor(tonumber(memory))) or "0"
elseif key == "version" then
return tostring(self.Library.Version)
end
return nil
end
function Watermark:_refreshText()
local result = string.gsub(self._text, "{(%w+)}", function(key)
local value = resolveToken(self, key)
return value ~= nil and tostring(value) or nil
end)
if self._label.Text ~= result then
self._label.Text = result
end
end
function Watermark:SetText(text)
self._text = tostring(text or "")
self:_refreshText()
self._label.Visible = self._text ~= ""
end
function Watermark:SetVariable(key, valueOrFunction)
self._variables[key] = valueOrFunction
self:_refreshText()
end
function Watermark:SetImage(spec)
if self._image then
self._image.Instance:Destroy()
self._image = nil
end
if spec ~= nil and spec ~= false then
self._image = Visual.icon(self._content, spec, self._imageSize, self._theme:Get("Accent"), { LayoutOrder = 1 })
self:_applyColors()
end
end
function Watermark:SetImageColor(color)
self._imageColor = color
self:_applyColors()
end
function Watermark:SetColor(color)
self._color = typeof(color) == "Color3" and color or nil
self:_applyColors()
end
function Watermark:SetGradient(from, to, rotation)
if from == nil or from == false then
self._gradient = nil
self._noGradient = from == false
else
self._gradient = { from, to or from }
self._noGradient = false
self._color = nil
end
if rotation then
self._gradientRotation = rotation
end
self:_applyColors()
end
function Watermark:SetTextSize(size)
self._textSize = size
self._label.TextSize = size
self._label.Size = UDim2.fromOffset(0, size + 6)
end
function Watermark:SetFont(font)
self._font = font
self._label.Font = font
end
function Watermark:SetBackground(enabled, transparency)
self._background = enabled ~= false
if transparency then
self._backgroundTransparency = transparency
end
self.Card.BackgroundTransparency = self._background and self._backgroundTransparency or 1
self._stroke.Transparency = self._background and math.clamp(self._theme:Get("BorderTransparency"), 0, 1) or 1
end
function Watermark:_applyPosition()
local data = ANCHORS[self._position]
self.Root.AnchorPoint = data.Anchor
if self._custom then
self.Root.Position = self._custom
else
local offset = self._offset or data.Offset
self.Root.Position = data.Pos + UDim2.fromOffset(offset.X, offset.Y)
end
end
function Watermark:SetPosition(position)
if typeof(position) == "UDim2" then
self._custom = position
elseif ANCHORS[position] then
self._position = position
self._custom = nil
self._offset = nil
else
warn(`[ClickGUI] Unknown Watermark position "{tostring(position)}"`)
return
end
self:_applyPosition()
end
function Watermark:SetOffset(offset)
self._offset = offset
self._custom = nil
self:_applyPosition()
end
function Watermark:ResetPosition()
self._custom = nil
self._offset = nil
self:_applyPosition()
end
function Watermark:SetVisible(visible)
visible = visible ~= false
if visible == self._visible then
return
end
self._visible = visible
self._token += 1
local token = self._token
if visible then
self.Root.Visible = true
AnimationManager.Play(self.Card, "Instant", { GroupTransparency = 1 })
AnimationManager.Play(self.Card, "Expand", { GroupTransparency = 0 })
else
AnimationManager.Play(self.Card, "Close", { GroupTransparency = 1 })
task.delay(AnimationManager.Time(0.22), function()
if self._token == token and not self._visible then
self.Root.Visible = false
end
end)
end
end
function Watermark:Show()
self:SetVisible(true)
end
function Watermark:Hide()
self:SetVisible(false)
end
function Watermark:Toggle()
self:SetVisible(not self._visible)
end
function Watermark:IsVisible()
return self._visible
end
function Watermark:SetEditable(editable)
editable = editable == true
if editable == self._editable then
return
end
self._editable = editable
if editable then
self.Gui.DisplayOrder = 944
self.Card.Active = true
self._dragger = Draggable.new(self.Card, self.Root, {
OnDragEnd = function()
self._custom = self.Root.Position
end,
})
local done = Create("TextButton", {
Name = "Done",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 70),
Size = UDim2.fromOffset(150, 30),
BackgroundTransparency = 0,
BackgroundColor3 = self._theme:Get("Accent"),
Text = "Done editing",
TextColor3 = Color3.new(1, 1, 1),
Font = self._theme:Get("FontBold"),
Parent = self.Gui,
})
Create.corner(done, 8)
self._maid:GiveNamed("done", done)
self._maid:GiveNamed(
"doneClick",
done.MouseButton1Click:Connect(function()
self:SetEditable(false)
end)
)
else
self.Gui.DisplayOrder = 55
self._maid:Remove("done")
self._maid:Remove("doneClick")
if self._dragger then
self._dragger:Destroy()
self._dragger = nil
end
end
end
function Watermark:Export()
local out = {
Text = self._text,
Position = self._position,
Visible = self._visible,
Background = self._background,
BackgroundTransparency = self._backgroundTransparency,
TextSize = self._textSize,
}
if self._offset then
out.Offset = { self._offset.X, self._offset.Y }
end
if self._custom then
local p = self._custom
out.Custom = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
end
if self._color then
out.Color =
{ math.round(self._color.R * 255), math.round(self._color.G * 255), math.round(self._color.B * 255) }
end
if self._gradient then
local a, b = self._gradient[1], self._gradient[2]
out.Gradient = {
{ math.round(a.R * 255), math.round(a.G * 255), math.round(a.B * 255) },
{ math.round(b.R * 255), math.round(b.G * 255), math.round(b.B * 255) },
}
end
return out
end
function Watermark:Import(data)
if type(data) ~= "table" then
return false
end
if type(data.Text) == "string" then
self:SetText(data.Text)
end
if ANCHORS[data.Position] then
self._position = data.Position
end
self._offset = type(data.Offset) == "table" and #data.Offset == 2 and Vector2.new(data.Offset[1], data.Offset[2])
or nil
self._custom = type(data.Custom) == "table"
and #data.Custom == 4
and UDim2.new(data.Custom[1], data.Custom[2], data.Custom[3], data.Custom[4])
or nil
if type(data.Color) == "table" and #data.Color == 3 then
self._color = Color3.fromRGB(data.Color[1], data.Color[2], data.Color[3])
elseif data.Color == nil then
self._color = nil
end
if type(data.Gradient) == "table" and #data.Gradient == 2 then
local a, b = data.Gradient[1], data.Gradient[2]
if type(a) == "table" and type(b) == "table" then
self._gradient = { Color3.fromRGB(a[1], a[2], a[3]), Color3.fromRGB(b[1], b[2], b[3]) }
end
end
if type(data.TextSize) == "number" then
self:SetTextSize(data.TextSize)
end
if data.Background ~= nil then
self:SetBackground(data.Background == true, data.BackgroundTransparency)
end
self:_applyPosition()
self:_applyColors()
if data.Visible ~= nil then
self:SetVisible(data.Visible == true)
end
return true
end
function Watermark:Attach(window)
self._window = window
window:_attachWidget("Watermark", self)
end
function Watermark:Detach()
if self._window then
self._window:_detachWidget(self)
self._window = nil
end
end
function Watermark:Destroy()
if self._destroyed then
return
end
self._destroyed = true
self:Detach()
if self._dragger then
self._dragger:Destroy()
end
if self._shadow then
self._shadow:Destroy()
end
self._maid:Clean()
self.Library:_removeWidget(self)
end
return Watermark
end
__functions[__n_Core_Window] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Utilities = script.Parent.Parent.Utilities
local Components = script.Parent.Parent.Components
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local InputManager = require(script.Parent.InputManager)
local Category = require(script.Parent.Category)
local Config = require(script.Parent.Config)
local Tooltip = require(script.Parent.Tooltip)
local Styles = require(script.Parent.Styles)
local Visual = require(script.Parent.Visual)
local ThemeManager = require(script.Parent.ThemeManager)
local Fonts = require(script.Parent.Fonts)
local UIShadow = require(Components.UIShadow)
local Create = require(Utilities.Create)
local Draggable = require(Utilities.Draggable)
local Resizer = require(Utilities.Resizer)
local Maid = require(Utilities.Maid)
local Signal = require(Utilities.Signal)
local HEADER_HEIGHT = 34
local PANEL_GAP = 10
local TITLEBAR_HEIGHT = 44
local MIN_PANEL = 140
local MAX_PANEL = 360
local BACKDROP_TRANSPARENCY = 0.55
local Window = {}
Window.__index = Window
function Window.new(library, options: Types.WindowOptions)
options = options or {}
local self = setmetatable({}, Window)
self.Library = library
self.Theme = library.Theme
if options.Theme then
self.Theme:SetTheme(options.Theme)
end
if options.Accent then
self.Theme:SetAccent(options.Accent)
end
local styleName = options.Style or "Classic"
if not Styles.Data[styleName] then
warn(`[ClickGUI] Unknown style "{styleName}" (Classic, Flat, Glass)`)
styleName = "Classic"
end
self.Style = styleName
self.StyleData = Styles.Data[styleName]
self._styleValues = options.ThemeValues
self:_reapplyStyle()
self._paletteOption = options.Palette
self._headerHeight = self.StyleData.Panels.HeaderHeight
self._brandIcon = options.Icon
self.Title = options.Title or "ClickGUI"
self.Subtitle = options.Subtitle
self.Layout = options.Layout or "Panels"
assert(self.Layout == "Panels" or self.Layout == "Sidebar", '[ClickGUI] Layout must be "Panels" or "Sidebar"')
self.Size = options.Size or UDim2.fromOffset(650, 430)
self.Categories = {}
self.Modules = {}
self.Flags = {}
self.Opened = Signal.new()
self.Closed = Signal.new()
self.ModuleToggled = Signal.new()
self.ModuleInfoChanged = Signal.new()
self.FavoritesChanged = Signal.new()
self.ModulesChanged = Signal.new()
self._initialSize = self.Size
self._minSize = options.MinSize or UDim2.fromOffset(450, 300)
self._maxSize = options.MaxSize or UDim2.fromOffset(1100, 800)
self._resizable = options.Resizable ~= false
self._maid = Maid.new()
self._open = false
self._destroyed = false
self._token = 0
self._scale = 1
self._userScale = options.Scale
self._scales = {}
self._shadows = {}
self._panels = {}
self._tabs = {}
self._handles = {}
self._resizers = {}
self._huds = {}
self._selected = nil
self._query = ""
self._searchOptions = { SearchNames = true, SearchDescriptions = true, SearchCategories = true }
self._favoritesOnly = false
self._zCounter = 10
self._userMoved = false
self._layoutQueued = false
self._layoutLoaded = false
self._saveToken = 0
self._defaultPanelWidth = options.PanelWidth or 190
self._maxPanelHeight = options.MaxPanelHeight or 380
self._backdropEnabled = options.Backdrop ~= false
self._toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
self._openAnimation = options.OpenAnimation or "Rise"
self.FavoriteIcons = {
On = (options.FavoriteIcons and options.FavoriteIcons.On) or library.FavoriteIcons.On,
Hover = (options.FavoriteIcons and options.FavoriteIcons.Hover) or library.FavoriteIcons.Hover,
Off = (options.FavoriteIcons and options.FavoriteIcons.Off) or library.FavoriteIcons.Off,
}
if options.ShowCounts == nil then
self._showCounts = self.StyleData.ShowCounts
else
self._showCounts = options.ShowCounts == true
end
self._searchKey = options.SearchKey == nil and Enum.KeyCode.F or options.SearchKey
self._configKey = options.ConfigKey or self.Title
self._autoSave = options.AutoSave == true
self._autoSaveConfig = options.AutoSaveConfig == true or options.AutoConfig == true
self._autoSaveInterval = math.max(tonumber(options.AutoSaveInterval) or 60, 5)
self._autoLoadConfig = options.AutoLoadConfig == true or options.AutoConfig == true
self._profile = options.Profile or "Default"
self._startupProfile = nil
self._autoToken = 0
self._widgets = {}
self._configLoaded = false
self.Storage = options.Storage or library.StorageAdapter
self:_loadPrefs(options)
self:_loadThemes()
self.Input = InputManager.new()
self._maid:Give(self.Input)
self.Context = {
Theme = self.Theme,
Input = self.Input,
Window = self,
Library = library,
GetScale = function()
return self._scale
end,
}
if options.Encrypt ~= nil then
library:SetEncrypt(options.Encrypt)
end
if options.EncryptNames ~= nil then
library:SetEncryptNames(options.EncryptNames)
end
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_" .. self.Title,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 100,
Parent = options.Parent or library:GetGuiParent(),
})
self._maid:Give(self.Gui)
library:_secureGui(self.Gui)
self.Root = Create(
"Frame",
{ Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Gui }
)
self._backdrop = Create("Frame", {
Name = "Backdrop",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = self.Theme:Get("BackdropColor"),
BackgroundTransparency = 1,
Active = self._backdropEnabled,
Parent = self.Root,
})
self.Theme:Bind(self._backdrop, "BackgroundColor3", "BackdropColor")
self._unlock = Create("TextButton", { Name = "MouseUnlock", Size = UDim2.new(), Modal = false, Parent = self.Root })
self.Container = Create(
"Frame",
{ Name = "Container", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = self.Root }
)
self.Tooltip = Tooltip.new(self)
self.Tooltip.Enabled = options.Tooltips ~= false
self._maid:Give(self.Tooltip)
if self.Layout == "Sidebar" then
self:_buildSidebar()
else
self:_buildPanelsExtras()
end
self._maid:Give(self.Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
self:_updateScale()
end))
self._maid:Give(self.Theme.Changed:Connect(function()
self:_updateHeader()
self:_applyShadows()
self:_refreshBackdrop()
end))
self:_updateScale()
self._toggleBinding = self.Input:BindKey(self._toggleKey, function()
self:Toggle()
end)
self._maid:Give(self._toggleBinding)
self._maid:Give(UserInputService.InputBegan:Connect(function(input)
if self._open and self._searchKey and input.KeyCode == self._searchKey and self._searchBox then
if
UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
then
task.defer(function()
if self._open and self._searchBox then
self._searchBox:CaptureFocus()
end
end)
end
end
end))
self._maid:Give(self.ModuleToggled:Connect(function()
self:_refreshCounts()
end))
self._maid:Give(self.ModulesChanged:Connect(function()
self:_refreshCounts()
end))
self:_refreshCounts()
self:_restartAutoSave()
if options.StartOpen ~= false then
task.defer(function()
if self._destroyed then
return
end
local loader = options.Loader
if loader and not loader:IsFinished() then
loader.Finished:Once(function()
if not self._destroyed then
self:Open()
end
end)
else
self:Open()
end
end)
end
return self
end
function Window:_applyShadows()
local theme = self.Theme.Current
for _, shadow in self._shadows do
if theme.ShadowPreset == "Off" then
shadow:SetEnabled(false)
else
shadow:SetEnabled(true)
shadow:SetPreset(theme.ShadowPreset)
shadow:SetOpacity(theme.ShadowOpacity)
shadow:SetColor(theme.ShadowColor)
shadow:SetCornerRadius(theme.CornerRadius)
end
end
end
function Window:_magnifier(parent, position)
local theme = self.Theme
local icon = Create("Frame", {
Name = "Magnifier",
AnchorPoint = Vector2.new(0, 0.5),
Position = position,
Size = UDim2.fromOffset(14, 14),
BackgroundTransparency = 1,
Parent = parent,
})
local ring = Create("Frame", { Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = icon })
Create.pill(ring)
local stroke = Create.stroke(ring, theme:Get("TextDim"), 1.5, 0)
theme:Bind(stroke, "Color", "TextDim")
local handle = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromOffset(11, 11),
Size = UDim2.fromOffset(6, 1.5),
Rotation = 45,
BackgroundColor3 = theme:Get("TextDim"),
Parent = icon,
})
theme:Bind(handle, "BackgroundColor3", "TextDim")
return icon
end
function Window:_createSearchBox(parent, size, position, anchor, variant)
local theme = self.Theme
local pill = variant == "pill"
local pillBox = variant == "pill-box"
local frame = Create("Frame", {
Name = "Search",
AnchorPoint = anchor,
Position = position,
Size = size,
BackgroundColor3 = theme:Get("Element"),
BackgroundTransparency = pill and 1 or 0,
Parent = parent,
})
if not pill then
local boxCorner = Visual.corner(theme, frame, -2)
theme:Bind(frame, "BackgroundColor3", "Element")
if pillBox then
theme:Bind(boxCorner, "CornerRadius", function()
return UDim.new(0.5, 0)
end)
frame.BackgroundTransparency = 0.35
Visual.stroke(theme, frame, 0.2)
end
end
local inset = 10
if pill or pillBox then
self:_magnifier(frame, UDim2.new(0, 14, 0.5, 0))
inset = 36
end
local box = Create("TextBox", {
Name = "Box",
Position = UDim2.fromOffset(inset, 0),
Size = UDim2.new(1, -(inset + 24), 1, 0),
PlaceholderText = (pill or pillBox) and "Search modules..." or "Search modules...",
PlaceholderColor3 = theme:Get("TextDim"),
TextColor3 = theme:Get("Text"),
Font = theme:Get("Font"),
TextXAlignment = Enum.TextXAlignment.Left,
ClipsDescendants = true,
Active = true,
Parent = frame,
})
theme:Bind(box, "TextColor3", "Text")
theme:Bind(box, "PlaceholderColor3", "TextDim")
local clear = Create("TextButton", {
Name = "Clear",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -3, 0.5, 0),
Size = UDim2.fromOffset(20, 20),
Text = "×",
TextSize = 16,
TextColor3 = theme:Get("TextDim"),
Visible = false,
Parent = frame,
})
theme:Bind(clear, "TextColor3", "TextDim")
self._maid:Give(box:GetPropertyChangedSignal("Text"):Connect(function()
clear.Visible = box.Text ~= ""
if not self._syncingSearch then
self:Search(box.Text)
end
end))
self._maid:Give(clear.MouseButton1Click:Connect(function()
box.Text = ""
end))
self._searchBox = box
return frame
end
function Window:_createSurface(name, size, position, anchor)
local theme = self.Theme
local holder = Create("Frame", {
Name = name,
AnchorPoint = anchor or Vector2.zero,
Position = position,
Size = size,
BackgroundTransparency = 1,
Parent = self.Container,
})
local scale = Create("UIScale", { Scale = self._scale, Parent = holder })
table.insert(self._scales, scale)
local shadow =
UIShadow.new({ Parent = holder, CornerRadius = theme:Get("CornerRadius"), Preset = theme:Get("ShadowPreset") })
table.insert(self._shadows, shadow)
local canvas = Create("CanvasGroup", {
Name = "Canvas",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = theme:Get("Panel"),
BackgroundTransparency = theme:Get("Transparency"),
Active = true,
Parent = holder,
})
theme:Bind(canvas, "BackgroundColor3", "Panel")
theme:Bind(canvas, "BackgroundTransparency", "Transparency")
local stroke = Visual.surface(theme, canvas, "panel", 0.14)
self:_applyShadows()
return holder, canvas, shadow, stroke
end
function Window:_accentLine(parent, position, anchor)
local line = Create("Frame", {
Name = "AccentLine",
AnchorPoint = anchor or Vector2.zero,
Position = position,
Size = UDim2.new(1, 0, 0, 2),
BackgroundColor3 = Color3.new(1, 1, 1),
ZIndex = 5,
Parent = parent,
})
self.Theme:Bind(line, "Size", function(t)
return UDim2.new(1, 0, 0, t.AccentLine and t.AccentLineThickness or 0)
end)
Visual.accentGradient(self.Theme, line)
return line
end
function Window:_createEmptyLabel(parent, props)
props.Name = "EmptyResults"
props.Text = "No modules found"
props.TextSize = 13
props.Visible = false
props.Font = self.Theme:Get("Font")
props.TextColor3 = self.Theme:Get("TextDim")
props.Parent = parent
local label = Create("TextLabel", props)
self.Theme:Bind(label, "TextColor3", "TextDim")
self._empty = label
return label
end
local DEFAULT_PALETTE =
{ "Violet", "Ocean", "Crimson", "Emerald", "Sunset", "Rose", "Mocha", "Midnight", "Ink", "Mono" }
function Window:_buildPalette(spec)
if self._paletteHolder then
self._paletteHolder.Holder:Destroy()
self._paletteHolder = nil
end
if not spec then
return
end
local theme = self.Theme
local items = {}
if type(spec) == "table" then
for _, value in spec do
table.insert(items, value)
end
else
for _, name in DEFAULT_PALETTE do
if theme._presets[name] then
table.insert(items, name)
end
end
end
if #items == 0 then
return
end
local width = #items * 12 + (#items - 1) * 9 + 28
local holder = Create("Frame", {
Name = "Palette",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 16),
Size = UDim2.fromOffset(width, 26),
BackgroundTransparency = 1,
Parent = self.Container,
})
local scale = Create("UIScale", { Scale = self._scale, Parent = holder })
table.insert(self._scales, scale)
local canvas = Create("CanvasGroup", {
Name = "Canvas",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = theme:Get("Header"),
Parent = holder,
})
theme:Bind(canvas, "BackgroundColor3", "Header")
local stroke, paletteCorner = Visual.surface(theme, canvas, "panel", 0)
theme:Bind(paletteCorner, "CornerRadius", function()
return UDim.new(0.5, 0)
end)
local dots = {}
for index, item in items do
local color = type(item) == "string"
and (theme._presets[item] and theme._presets[item].Accent or Color3.new(1, 1, 1))
or item
local dot = Create("TextButton", {
Name = "Dot",
Position = UDim2.fromOffset(14 + (index - 1) * 21, 7),
Size = UDim2.fromOffset(12, 12),
BackgroundTransparency = 0,
BackgroundColor3 = color,
Parent = canvas,
})
Create.pill(dot)
local ring = Create.stroke(dot, Color3.new(1, 1, 1), 1.5, 1)
dots[index] = { Item = item, Ring = ring }
self._maid:Give(dot.MouseButton1Click:Connect(function()
if type(item) == "string" then
self:SetTheme(item)
else
self:SetAccent(item)
end
end))
end
local function refresh()
local current = theme.Current
for _, data in dots do
local selected
if type(data.Item) == "string" then
selected = current.Name == data.Item
else
selected = current.Accent == data.Item
end
AnimationManager.Play(data.Ring, "Fast", { Transparency = selected and 0 or 1 })
end
end
self._maid:GiveNamed("paletteRefresh", theme.Changed:Connect(refresh))
refresh()
self._paletteHolder = { Holder = holder, Canvas = canvas, Stroke = stroke }
end
function Window:SetPalette(spec)
self:_buildPalette(spec)
end
function Window:_buildPanelsExtras()
local panelStyle = self.StyleData.Panels
local bottom = panelStyle.Search == "Bottom"
local holder = Create("Frame", {
Name = "SearchHolder",
AnchorPoint = Vector2.new(0.5, bottom and 1 or 0),
Position = bottom and UDim2.new(0.5, 0, 1, -36) or UDim2.new(0.5, 0, 0, 16),
Size = bottom and UDim2.fromOffset(190, 34) or UDim2.fromOffset(250, 30),
BackgroundTransparency = 1,
Parent = self.Container,
})
local scale = Create("UIScale", { Scale = self._scale, Parent = holder })
table.insert(self._scales, scale)
local canvas = Create("CanvasGroup", {
Name = "Canvas",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = self.Theme:Get("Header"),
Parent = holder,
})
self.Theme:Bind(canvas, "BackgroundColor3", "Header")
local searchStroke, searchCorner = Visual.surface(self.Theme, canvas, "panel", bottom and 0 or 0.2)
if bottom then
self.Theme:Bind(searchCorner, "CornerRadius", function()
return UDim.new(0.5, 0)
end)
self:_createSearchBox(canvas, UDim2.fromScale(1, 1), UDim2.new(), Vector2.zero, "pill")
else
self:_createSearchBox(canvas, UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4), Vector2.zero)
end
self._searchHolder = { Canvas = canvas, Stroke = searchStroke }
self:_createEmptyLabel(self.Container, {
AnchorPoint = Vector2.new(0.5, bottom and 1 or 0),
Position = bottom and UDim2.new(0.5, 0, 1, -82) or UDim2.new(0.5, 0, 0, 56),
Size = UDim2.fromOffset(240, 30),
BackgroundTransparency = 1,
})
local palette = self._paletteOption
if palette == nil then
palette = panelStyle.Palette
end
self:_buildPalette(palette or nil)
end
function Window:_sidebarWidth()
if self._sidebar and self._sidebar.Brand then
return math.clamp(math.floor(self.Size.X.Offset * 0.27), 170, 230)
end
return math.clamp(math.floor(self.Size.X.Offset * 0.23), 120, 190)
end
function Window:_layoutSidebar()
local sidebar = self._sidebar
if not sidebar then
return
end
local width = self:_sidebarWidth()
local top = sidebar.Top or TITLEBAR_HEIGHT
if sidebar.Brand then
sidebar.Frame.Position = UDim2.fromOffset(10, 10)
sidebar.Frame.Size = UDim2.new(0, width - 10, 1, -20)
else
sidebar.Frame.Position = UDim2.fromOffset(0, top)
sidebar.Frame.Size = UDim2.new(0, width, 1, -top)
end
sidebar.Content.Position = UDim2.fromOffset(width, top)
sidebar.Content.Size = UDim2.new(1, -width, 1, -top)
end
function Window:_addGrip(parent)
for _, offset in { { 12, 12 }, { 8, 12 }, { 12, 8 } } do
local dot = Create("Frame", {
Position = UDim2.new(1, -offset[1] - 2, 1, -offset[2] - 2),
Size = UDim2.fromOffset(2, 2),
BackgroundColor3 = self.Theme:Get("TextDim"),
BackgroundTransparency = 0.3,
Parent = parent,
})
self.Theme:Bind(dot, "BackgroundColor3", "TextDim")
end
end
function Window:_buildSidebarBrand()
local theme = self.Theme
local holder, canvas, shadow, surfaceStroke =
self:_createSurface("Window", self.Size, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
self._sidebar = { Holder = holder, Canvas = canvas, Shadow = shadow, Stroke = surfaceStroke, Top = 0, Brand = true }
local sidebar = Create("Frame", {
Name = "Sidebar",
BackgroundColor3 = theme:Get("Background"),
BackgroundTransparency = 0.45,
Parent = canvas,
})
theme:Bind(sidebar, "BackgroundColor3", "Background")
Visual.surface(theme, sidebar, "module", 0)
local brandBlock = Create(
"Frame",
{ Name = "Brand", Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, Active = true, Parent = sidebar }
)
local textX = 18
if self._brandIcon then
local icon = Visual.icon(brandBlock, self._brandIcon, 28, theme:Get("Accent"), {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 16, 0.5, 0),
})
theme:Bind(icon.Instance, icon.Property, "Accent")
textX = 54
end
local title = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(textX, self.Subtitle and 16 or 0),
Size = UDim2.new(1, -textX - 8, 0, self.Subtitle and 22 or 68),
Text = self.Title,
TextSize = 17,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = brandBlock,
})
theme:Bind(title, "TextColor3", "Text")
theme:Bind(title, "Font", "FontBold")
self._sidebar.TitleLabel = title
if self.Subtitle then
local subtitle = Create("TextLabel", {
Name = "Subtitle",
Position = UDim2.fromOffset(textX, 38),
Size = UDim2.new(1, -textX - 8, 0, 14),
Text = string.upper(self.Subtitle),
TextSize = 10,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = brandBlock,
})
theme:Bind(subtitle, "TextColor3", "TextDim")
self._sidebar.SubtitleLabel = subtitle
end
local tabs = Create("ScrollingFrame", {
Name = "Tabs",
Position = UDim2.fromOffset(0, 70),
Size = UDim2.new(1, 0, 1, -70),
ScrollBarThickness = 0,
Parent = sidebar,
})
Create.padding(tabs, 4, 10, 10, 10)
Create.list(tabs, 4)
self._sidebar.Frame = sidebar
self._sidebar.Tabs = tabs
local content = Create("CanvasGroup", { Name = "Content", BackgroundTransparency = 1, Parent = canvas })
self._sidebar.Content = content
local header = Create(
"Frame",
{ Name = "Header", Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1, Active = true, Parent = content }
)
self._sidebar.HeaderTitle = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(24, 12),
Size = UDim2.new(1, -330, 0, 28),
Text = "",
TextSize = 24,
RichText = true,
Font = theme:Get("Font"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = header,
})
theme:Bind(self._sidebar.HeaderTitle, "TextColor3", "Text")
self._sidebar.HeaderSub = Create("TextLabel", {
Name = "Subtitle",
Position = UDim2.fromOffset(24, 42),
Size = UDim2.new(1, -330, 0, 16),
Text = "",
TextSize = 12,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = header,
})
theme:Bind(self._sidebar.HeaderSub, "TextColor3", "TextDim")
self:_createSearchBox(header, UDim2.fromOffset(220, 34), UDim2.new(1, -62, 0.5, 0), Vector2.new(1, 0.5), "pill-box")
local close = Create("TextButton", {
Name = "Close",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -16, 0.5, 0),
Size = UDim2.fromOffset(30, 30),
Text = "×",
TextSize = 22,
TextColor3 = theme:Get("TextDim"),
Parent = header,
})
theme:Bind(close, "TextColor3", "TextDim")
self._maid:Give(close.MouseButton1Click:Connect(function()
self:Close()
end))
self._maid:Give(close.MouseEnter:Connect(function()
AnimationManager.Play(close, "Fast", { TextColor3 = theme:Get("Error") })
end))
self._maid:Give(close.MouseLeave:Connect(function()
AnimationManager.Play(close, "Fast", { TextColor3 = theme:Get("TextDim") })
end))
local pages = Create("Frame", {
Name = "Pages",
Position = UDim2.fromOffset(0, 72),
Size = UDim2.new(1, 0, 1, -72),
BackgroundTransparency = 1,
ClipsDescendants = true,
Parent = content,
})
self._sidebar.PagesHost = pages
local searchPage = Create("ScrollingFrame", {
Name = "SearchResults",
Size = UDim2.fromScale(1, 1),
Visible = false,
ScrollBarImageColor3 = theme:Get("Accent"),
Parent = pages,
})
theme:Bind(searchPage, "ScrollBarImageColor3", "Accent")
local searchList = Create("Frame", {
Name = "List",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = searchPage,
})
Create.padding(searchList, 6, 18, 14, 18)
local searchLayout = Create.list(searchList, 4)
theme:Bind(searchLayout, "Padding", function(t)
return UDim.new(0, t.ModuleSpacing)
end)
self._sidebar.SearchPage = searchPage
self._sidebar.SearchList = searchList
self:_createEmptyLabel(
pages,
{ Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 5 }
)
self:_layoutSidebar()
local function makeHandle(name, anchor, position, size, axisX, axisY)
local handle = Create(
"TextButton",
{ Name = name, AnchorPoint = anchor, Position = position, Size = size, ZIndex = 40, Parent = canvas }
)
local start = Vector2.zero
local resizer = Resizer.new(handle, {
OnStart = function()
start = Vector2.new(self.Size.X.Offset, self.Size.Y.Offset)
self:BringToFront()
end,
OnChange = function(dx, dy)
local scale = math.max(self._scale, 0.01)
self:_resizeTo(start.X + (axisX and dx / scale or 0), start.Y + (axisY and dy / scale or 0))
end,
OnEnd = function()
self:_queueSave()
end,
})
resizer.Enabled = self._resizable
handle.Visible = self._resizable
table.insert(self._handles, handle)
table.insert(self._resizers, resizer)
self._maid:Give(resizer)
return handle
end
makeHandle("ResizeRight", Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0, 5, 1, -18), true, false)
makeHandle("ResizeBottom", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, -18, 0, 5), false, true)
local corner =
makeHandle("ResizeCorner", Vector2.new(1, 1), UDim2.new(1, 0, 1, 0), UDim2.fromOffset(18, 18), true, true)
self:_addGrip(corner)
for _, handle in { brandBlock, header } do
local dragger = Draggable.new(handle, holder, {
Bounds = self.Container,
OnDragStart = function()
self:BringToFront()
end,
OnDragEnd = function()
self:_queueSave()
end,
})
self._maid:Give(dragger)
self._dragger = dragger
end
self._maid:Give(canvas.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
self:BringToFront()
end
end))
end
function Window:_buildSidebar()
if self.StyleData.Sidebar == "Brand" then
return self:_buildSidebarBrand()
end
local theme = self.Theme
local holder, canvas, shadow, surfaceStroke =
self:_createSurface("Window", self.Size, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
self._sidebar = { Holder = holder, Canvas = canvas, Shadow = shadow, Stroke = surfaceStroke }
local titlebar = Create("Frame", {
Name = "Titlebar",
Size = UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
BackgroundColor3 = theme:Get("Header"),
Active = true,
Parent = canvas,
})
theme:Bind(titlebar, "BackgroundColor3", "Header")
Visual.gradient(theme, titlebar, 0.25)
local titleLabel = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(14, self.Subtitle and 6 or 0),
Size = UDim2.new(0, 220, 0, self.Subtitle and 18 or TITLEBAR_HEIGHT),
Text = self.Title,
TextSize = 15,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = titlebar,
})
theme:Bind(titleLabel, "TextColor3", "Text")
theme:Bind(titleLabel, "Font", "FontBold")
self._sidebar.TitleLabel = titleLabel
if self.Subtitle then
local subtitle = Create("TextLabel", {
Name = "Subtitle",
Position = UDim2.fromOffset(14, 24),
Size = UDim2.new(0, 220, 0, 14),
Text = self.Subtitle,
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = titlebar,
})
theme:Bind(subtitle, "TextColor3", "TextDim")
self._sidebar.SubtitleLabel = subtitle
end
local close = Create("TextButton", {
Name = "Close",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.fromOffset(28, 28),
Text = "×",
TextSize = 22,
TextColor3 = theme:Get("TextDim"),
Parent = titlebar,
})
theme:Bind(close, "TextColor3", "TextDim")
self._maid:Give(close.MouseButton1Click:Connect(function()
self:Close()
end))
self._maid:Give(close.MouseEnter:Connect(function()
AnimationManager.Play(close, "Fast", { TextColor3 = theme:Get("Error") })
end))
self._maid:Give(close.MouseLeave:Connect(function()
AnimationManager.Play(close, "Fast", { TextColor3 = theme:Get("TextDim") })
end))
self:_createSearchBox(titlebar, UDim2.fromOffset(200, 26), UDim2.new(1, -46, 0.5, 0), Vector2.new(1, 0.5))
self:_accentLine(canvas, UDim2.fromOffset(0, TITLEBAR_HEIGHT), Vector2.new(0, 1))
local sidebar = Create("Frame", {
Name = "Sidebar",
Position = UDim2.fromOffset(0, TITLEBAR_HEIGHT),
BackgroundColor3 = theme:Get("Background"),
BackgroundTransparency = 0.5,
Parent = canvas,
})
theme:Bind(sidebar, "BackgroundColor3", "Background")
local tabs = Create(
"ScrollingFrame",
{ Name = "Tabs", Size = UDim2.new(1, 0, 1, -28), ScrollBarThickness = 0, Parent = sidebar }
)
Create.padding(tabs, 8, 8, 8, 8)
Create.list(tabs, 4)
self._sidebar.Frame = sidebar
self._sidebar.Tabs = tabs
self._sidebar.Footer = Create("TextLabel", {
Name = "Footer",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1),
Size = UDim2.new(1, 0, 0, 24),
TextSize = 11,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
Parent = sidebar,
})
theme:Bind(self._sidebar.Footer, "TextColor3", "TextDim")
local content = Create("CanvasGroup", { Name = "Content", BackgroundTransparency = 1, Parent = canvas })
self._sidebar.Content = content
local searchPage = Create("ScrollingFrame", {
Name = "SearchResults",
Size = UDim2.fromScale(1, 1),
Visible = false,
ScrollBarImageColor3 = theme:Get("Accent"),
Parent = content,
})
theme:Bind(searchPage, "ScrollBarImageColor3", "Accent")
local searchList = Create("Frame", {
Name = "List",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = searchPage,
})
Create.padding(searchList, 6, 6, 6, 6)
Create.list(searchList, 4)
self._sidebar.SearchPage = searchPage
self._sidebar.SearchList = searchList
self:_createEmptyLabel(
content,
{ Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 5 }
)
self:_layoutSidebar()
local function makeHandle(name, anchor, position, size, axisX, axisY)
local handle = Create(
"TextButton",
{ Name = name, AnchorPoint = anchor, Position = position, Size = size, ZIndex = 40, Parent = canvas }
)
local start = Vector2.zero
local resizer = Resizer.new(handle, {
OnStart = function()
start = Vector2.new(self.Size.X.Offset, self.Size.Y.Offset)
self:BringToFront()
end,
OnChange = function(dx, dy)
local scale = math.max(self._scale, 0.01)
self:_resizeTo(start.X + (axisX and dx / scale or 0), start.Y + (axisY and dy / scale or 0))
end,
OnEnd = function()
self:_queueSave()
end,
})
resizer.Enabled = self._resizable
handle.Visible = self._resizable
table.insert(self._handles, handle)
table.insert(self._resizers, resizer)
self._maid:Give(resizer)
return handle
end
makeHandle(
"ResizeRight",
Vector2.new(1, 0),
UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
UDim2.new(0, 5, 1, -TITLEBAR_HEIGHT - 18),
true,
false
)
makeHandle("ResizeBottom", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, -18, 0, 5), false, true)
local corner =
makeHandle("ResizeCorner", Vector2.new(1, 1), UDim2.new(1, 0, 1, 0), UDim2.fromOffset(18, 18), true, true)
self:_addGrip(corner)
self._dragger = Draggable.new(titlebar, holder, {
Bounds = self.Container,
OnDragStart = function()
self:BringToFront()
end,
OnDragEnd = function()
self:_queueSave()
end,
})
self._maid:Give(self._dragger)
self._maid:Give(canvas.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
self:BringToFront()
end
end))
end
function Window:_resizeTo(width, height)
if not self._sidebar then
return
end
local viewport = self.Gui.AbsoluteSize
local scale = math.max(self._scale, 0.01)
local minW, minH = self._minSize.X.Offset, self._minSize.Y.Offset
local maxW = math.max(minW, math.min(self._maxSize.X.Offset, viewport.X / scale - 8))
local maxH = math.max(minH, math.min(self._maxSize.Y.Offset, viewport.Y / scale - 8))
self.Size = UDim2.fromOffset(math.clamp(width, minW, maxW), math.clamp(height, minH, maxH))
self._sidebar.Holder.Size = self.Size
self:_layoutSidebar()
end
function Window:SetSize(size: UDim2)
assert(typeof(size) == "UDim2", "[ClickGUI] SetSize expects a UDim2")
if self.Layout == "Sidebar" then
self:_resizeTo(size.X.Offset, size.Y.Offset)
self:_queueSave()
else
self:SetPanelWidth(size.X.Offset)
end
end
function Window:GetSize(): UDim2
return self.Size
end
function Window:SetMinSize(size: UDim2)
self._minSize = size
self:_resizeTo(self.Size.X.Offset, self.Size.Y.Offset)
end
function Window:SetMaxSize(size: UDim2)
self._maxSize = size
self:_resizeTo(self.Size.X.Offset, self.Size.Y.Offset)
end
function Window:SetResizable(enabled: boolean)
self._resizable = enabled == true
for _, handle in self._handles do
handle.Visible = self._resizable
end
for _, resizer in self._resizers do
resizer.Enabled = self._resizable
end
end
function Window:IsResizable(): boolean
return self._resizable
end
local function escapeRich(text)
text = string.gsub(text, "&", "&amp;")
text = string.gsub(text, "<", "&lt;")
return (string.gsub(text, ">", "&gt;"))
end
function Window:_updateHeader()
local sidebar = self._sidebar
if not sidebar or not sidebar.HeaderTitle then
return
end
local theme = self.Theme
local category = self._selected
local hex = theme:Get("Accent"):ToHex()
if self._query ~= "" then
sidebar.HeaderTitle.Text = "<b>Search</b> results"
local count = 0
for _, module in self.Modules do
if module.Frame.Visible then
count += 1
end
end
sidebar.HeaderSub.Text = count .. " modules found"
elseif category then
sidebar.HeaderTitle.Text = '<font color="#'
.. hex
.. '"><i>'
.. escapeRich(category.Name)
.. "</i></font> <b>Modules</b>"
local total, enabled = 0, 0
for _, module in category.Modules do
total += 1
if module.Enabled then
enabled += 1
end
end
sidebar.HeaderSub.Text = total .. " modules · " .. enabled .. " enabled"
else
sidebar.HeaderTitle.Text = escapeRich(self.Title)
sidebar.HeaderSub.Text = ""
end
end
function Window:_ensureGroup(name)
self._groups = self._groups or {}
if self._groups[name] then
return self._groups[name]
end
local index = 0
for _ in self._groups do
index += 1
end
index += 1
local theme = self.Theme
local label = Create("TextLabel", {
Name = "Group_" .. name,
Size = UDim2.new(1, 0, 0, 22),
Text = string.upper(name),
TextSize = 10,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
LayoutOrder = index * 1000,
Parent = self._sidebar.Tabs,
})
Create.padding(label, 6, 0, 0, 10)
theme:Bind(label, "TextColor3", "TextDim")
self._groups[name] = { Index = index, Label = label, Count = 0 }
return self._groups[name]
end
function Window:_createTab(category)
local theme = self.Theme
local brand = self._sidebar.Brand == true
local tabs = self._sidebar.Tabs
local order = #self.Categories
if brand then
local group = self:_ensureGroup(category.Group or "Modules")
group.Count += 1
order = group.Index * 1000 + group.Count
end
local button = Create("TextButton", {
Name = "Tab_" .. category.Name,
Size = UDim2.new(1, 0, 0, brand and 36 or 32),
BackgroundColor3 = theme:Get("Element"),
BackgroundTransparency = 1,
LayoutOrder = order,
Parent = tabs,
})
Visual.corner(theme, button, brand and 0 or -2)
local bar
if not brand then
bar = Create("Frame", {
Name = "Bar",
Position = UDim2.new(0, 0, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Size = UDim2.new(0, 3, 0, 16),
BackgroundColor3 = theme:Get("Accent"),
BackgroundTransparency = 1,
Parent = button,
})
Create.pill(bar)
end
local labelX = brand and 14 or 14
local icon
if category.Icon then
icon = Visual.icon(button, category.Icon, category.IconSize, theme:Get("TextDim"), {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 12, 0.5, 0),
})
labelX = 12 + category.IconSize + 8
end
local label = Create("TextLabel", {
Name = "Label",
Position = UDim2.fromOffset(labelX, 0),
Size = UDim2.new(1, -labelX - (brand and 40 or 6), 1, 0),
Text = category.Name,
TextSize = 13,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = button,
})
local count
if brand then
count = Create("TextLabel", {
Name = "Count",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(30, 14),
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Right,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
Parent = button,
})
end
local tab =
{ Category = category, Button = button, Bar = bar, Label = label, Icon = icon, Count = count, Hovered = false }
self._tabs[category] = tab
self._maid:Give(button.MouseButton1Click:Connect(function()
self:SelectCategory(category)
end))
self._maid:Give(button.MouseEnter:Connect(function()
tab.Hovered = true
self:_renderTabs(true)
end))
self._maid:Give(button.MouseLeave:Connect(function()
tab.Hovered = false
self:_renderTabs(true)
end))
category.Page.Parent = self._sidebar.PagesHost or self._sidebar.Content
category.Page.Visible = false
if not self._selected then
self:SelectCategory(category)
end
self:_renderTabs(false)
self:_refreshCounts()
end
function Window:_renderTabs(animated)
local theme = self.Theme
local preset = animated and "Fast" or "Instant"
local brand = self._sidebar and self._sidebar.Brand
for category, tab in self._tabs do
local selected = category == self._selected
if brand then
AnimationManager.Play(tab.Button, preset, {
BackgroundColor3 = selected and theme:Get("Accent") or theme:Get("Element"),
BackgroundTransparency = selected and 0.12 or (tab.Hovered and 0.6 or 1),
})
AnimationManager.Play(tab.Label, preset, {
TextColor3 = selected and Color3.new(1, 1, 1)
or (tab.Hovered and theme:Get("Text") or theme:Get("TextDim")),
})
AnimationManager.Play(tab.Count, preset, {
TextColor3 = selected and Color3.new(1, 1, 1) or theme:Get("TextDim"),
})
if tab.Icon then
AnimationManager.Play(tab.Icon.Instance, preset, {
[tab.Icon.Property] = selected and Color3.new(1, 1, 1)
or (category.IconColor or theme:Get("TextDim")),
})
end
else
AnimationManager.Play(tab.Button, preset, {
BackgroundColor3 = theme:Get("Element"),
BackgroundTransparency = selected and 0.3 or (tab.Hovered and 0.7 or 1),
})
AnimationManager.Play(
tab.Bar,
preset,
{ BackgroundTransparency = selected and 0 or 1, BackgroundColor3 = theme:Get("Accent") }
)
AnimationManager.Play(
tab.Label,
preset,
{ TextColor3 = (selected or tab.Hovered) and theme:Get("Text") or theme:Get("TextDim") }
)
if tab.Icon then
AnimationManager.Play(tab.Icon.Instance, preset, {
[tab.Icon.Property] = selected and (category.IconColor or theme:Get("Accent"))
or theme:Get("TextDim"),
})
end
end
end
end
function Window:_updatePages()
if not self._sidebar then
return
end
for _, category in self.Categories do
category.Page.Visible = self._query == "" and category == self._selected
end
self._sidebar.SearchPage.Visible = self._query ~= ""
end
function Window:SelectCategory(category)
if type(category) == "string" then
category = self:GetCategory(category)
end
if self.Layout ~= "Sidebar" or not category or self._selected == category then
return
end
self._selected = category
self:_updatePages()
self:_renderTabs(true)
self:_pageTransition()
self:_updateHeader()
self:_updateEmpty()
self:_queueSave()
end
function Window:_pageTransition()
local content = self._sidebar and self._sidebar.Content
if not content or not self._open then
return
end
local width = self:_sidebarWidth()
local top = self._sidebar.Top or TITLEBAR_HEIGHT
AnimationManager.Play(
content,
"Instant",
{ GroupTransparency = 0.75, Position = UDim2.fromOffset(width + 14, top) }
)
AnimationManager.Play(content, "Expand", { GroupTransparency = 0, Position = UDim2.fromOffset(width, top) })
end
function Window:_createPanel(category)
local theme = self.Theme
local width = self._panelWidth or self._defaultPanelWidth
local hh = self._headerHeight
local plain = self.StyleData.Panels.Header == "Plain"
local holder, canvas, shadow, surfaceStroke = self:_createSurface(
"Panel_" .. category.Name,
UDim2.fromOffset(width, hh),
UDim2.fromOffset(20, 70),
Vector2.zero
)
local record = {
Category = category,
Holder = holder,
Canvas = canvas,
Shadow = shadow,
Stroke = surfaceStroke,
Collapsed = false,
Width = width,
}
local header = Create("Frame", {
Name = "Header",
Size = UDim2.new(1, 0, 0, hh),
BackgroundColor3 = theme:Get("Header"),
BackgroundTransparency = plain and 1 or 0,
Active = true,
Parent = canvas,
})
if not plain then
theme:Bind(header, "BackgroundColor3", "Header")
Visual.gradient(theme, header, 0.25)
end
local title
if plain then
local group = Create("Frame", {
Name = "Group",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.new(),
AutomaticSize = Enum.AutomaticSize.XY,
BackgroundTransparency = 1,
Parent = header,
})
local layout = Create.list(group, 7, true)
layout.VerticalAlignment = Enum.VerticalAlignment.Center
if category.Icon then
record.Icon = Visual.icon(
group,
category.Icon,
category.IconSize,
category.IconColor or theme:Get("Accent"),
{ LayoutOrder = 1 }
)
if not category.IconColor then
theme:Bind(record.Icon.Instance, record.Icon.Property, "Accent")
end
end
title = Create("TextLabel", {
Name = "Title",
Size = UDim2.fromOffset(0, 20),
AutomaticSize = Enum.AutomaticSize.X,
Text = category.Name,
TextSize = 14,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
LayoutOrder = 2,
Parent = group,
})
else
local titleOffset = 0
if category.Icon then
record.Icon =
Visual.icon(header, category.Icon, category.IconSize, category.IconColor or theme:Get("Accent"), {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
})
if not category.IconColor then
theme:Bind(record.Icon.Instance, record.Icon.Property, "Accent")
end
titleOffset = category.IconSize + 10
end
title = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(10 + titleOffset, 0),
Size = UDim2.new(1, -84 - titleOffset, 1, 0),
Text = category.Name,
TextSize = 14,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Center,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = header,
})
theme:Bind(title, "TextXAlignment", function(t)
return (category.Icon or t.HeaderAlign == "Left") and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
end)
end
theme:Bind(title, "TextColor3", "Text")
theme:Bind(title, "Font", "FontBold")
theme:Bind(title, "TextSize", "HeaderTextSize")
local chevron = Create("TextButton", {
Name = "Collapse",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -6, 0.5, 0),
Size = UDim2.fromOffset(26, 26),
Text = "›",
TextSize = 20,
Rotation = 90,
TextColor3 = theme:Get("TextDim"),
Visible = not plain,
Parent = header,
})
theme:Bind(chevron, "TextColor3", "TextDim")
record.Chevron = chevron
record.Count = Create("TextLabel", {
Name = "Count",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, plain and -12 or -34, 0.5, 0),
Size = UDim2.fromOffset(40, 14),
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Right,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
Parent = header,
})
theme:Bind(record.Count, "TextColor3", "TextDim")
category.Page.Position = UDim2.fromOffset(0, hh)
category.Page.Size = UDim2.new(1, 0, 1, -hh)
category.Page.Parent = canvas
category.Page.Visible = true
self:_accentLine(canvas, UDim2.new(0, 0, 1, 0), Vector2.new(0, 1))
record.Resize = function(animated)
if self._destroyed then
return
end
local content = category.List.AbsoluteSize.Y / math.max(self._scale, 0.01)
local body = record.Collapsed and 0 or math.min(content, self._maxPanelHeight)
AnimationManager.Play(
holder,
animated and "Normal" or "Instant",
{ Size = UDim2.fromOffset(record.Width, hh + body) }
)
end
self._maid:Give(category.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
record.Resize(false)
end))
self._maid:Give(chevron.MouseButton1Click:Connect(function()
self:_setCollapsed(record, not record.Collapsed, true)
self:_queueSave()
end))
if plain then
local lastClick = 0
self._maid:Give(header.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
local now = os.clock()
if now - lastClick < 0.35 then
self:_setCollapsed(record, not record.Collapsed, true)
self:_queueSave()
end
lastClick = now
end
end))
end
local function bringToFront()
self._zCounter += 1
holder.ZIndex = self._zCounter
self:BringToFront()
end
self._maid:Give(canvas.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
bringToFront()
end
end))
record.Dragger = Draggable.new(header, holder, {
Bounds = self.Container,
OnDragStart = function()
bringToFront()
self._userMoved = true
end,
OnDragEnd = function()
self:_queueSave()
end,
})
self._maid:Give(record.Dragger)
local handle = Create("TextButton", {
Name = "ResizeWidth",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, 0, 0, 0),
Size = UDim2.new(0, 5, 1, 0),
ZIndex = 40,
Visible = self._resizable,
Parent = canvas,
})
local startWidth = width
record.Resizer = Resizer.new(handle, {
OnStart = function()
startWidth = record.Width
end,
OnChange = function(dx)
record.Width = math.clamp(startWidth + dx / math.max(self._scale, 0.01), MIN_PANEL, MAX_PANEL)
record.Resize(false)
end,
OnEnd = function()
self:_scheduleLayout()
self:_queueSave()
end,
})
record.Resizer.Enabled = self._resizable
record.Handle = handle
table.insert(self._handles, handle)
table.insert(self._resizers, record.Resizer)
self._maid:Give(record.Resizer)
self._panels[category] = record
record.Resize(false)
end
function Window:_setCollapsed(record, collapsed, animated)
record.Collapsed = collapsed
AnimationManager.Play(record.Chevron, animated and "Normal" or "Instant", { Rotation = collapsed and 0 or 90 })
record.Resize(animated)
end
function Window:SetPanelWidth(width: number)
width = math.clamp(width, MIN_PANEL, MAX_PANEL)
self._panelWidth = width
for _, record in self._panels do
record.Width = width
record.Resize(false)
end
self:_updateScale()
self:_queueSave()
end
function Window:_updateScale()
if self._destroyed then
return
end
local viewport = self.Gui.AbsoluteSize
if viewport.X < 1 or viewport.Y < 1 then
return
end
local scale
if self._userScale then
scale = self._userScale
elseif self.Layout == "Panels" then
local total, count = 0, 0
for _, record in self._panels do
total += record.Width
count += 1
end
if count == 0 then
count, total = 1, self._defaultPanelWidth
end
local contentWidth = total + (count - 1) * PANEL_GAP + 40
local contentHeight = self._maxPanelHeight + self._headerHeight + 130
scale = math.min(viewport.X / contentWidth, viewport.Y / contentHeight, 1.15)
else
local size = self._initialSize
scale = math.min(viewport.X * 0.96 / size.X.Offset, viewport.Y * 0.94 / size.Y.Offset, 1.15)
end
scale = math.clamp(scale, 0.4, 2.5)
self._scale = scale
for index = #self._scales, 1, -1 do
local uiScale = self._scales[index]
if uiScale.Parent then
uiScale.Scale = scale
else
table.remove(self._scales, index)
end
end
self:_scheduleLayout()
end
function Window:_scheduleLayout()
if self._layoutQueued or self._destroyed then
return
end
self._layoutQueued = true
task.defer(function()
self._layoutQueued = false
if not self._destroyed then
self:_layoutPanels()
end
end)
end
function Window:_layoutPanels()
if self.Layout ~= "Panels" or self._userMoved then
return
end
local viewport = self.Gui.AbsoluteSize
if viewport.X < 1 then
return
end
local visible = {}
for _, category in self.Categories do
local record = self._panels[category]
if record and category._visible then
table.insert(visible, record)
end
end
if #visible == 0 then
return
end
local scale = self._scale
local total = 0
for _, record in visible do
total += record.Width * scale
end
total += (#visible - 1) * PANEL_GAP * scale
local x = math.floor((viewport.X - total) / 2)
local top = math.floor(math.max(64, viewport.Y * 0.14))
for _, record in visible do
record.Holder.Position = UDim2.fromOffset(x, top)
x += math.floor((record.Width + PANEL_GAP) * scale)
end
end
function Window:ResetLayout()
self._userMoved = false
self._panelWidth = self._defaultPanelWidth
for _, record in self._panels do
record.Width = self._defaultPanelWidth
self:_setCollapsed(record, false, false)
end
if self._sidebar then
self.Size = self._initialSize
self._sidebar.Holder.Size = self.Size
self._sidebar.Holder.Position = UDim2.fromScale(0.5, 0.5)
self:_layoutSidebar()
end
self:_updateScale()
self:_layoutPanels()
self:_queueSave()
end
function Window:SetScale(scale: number?)
self._userScale = scale
self:_updateScale()
end
function Window:GetScale(): number
return self._scale
end
function Window:BringToFront()
self.Gui.DisplayOrder = self.Library:_nextDisplayOrder()
end
function Window:CreateCategory(name: string, options: Types.CategoryOptions?)
assert(not self._destroyed, "[ClickGUI] This window was destroyed")
local category = Category.new(self.Context, self, name, options or {})
table.insert(self.Categories, category)
if self.Layout == "Panels" then
self:_createPanel(category)
else
self:_createTab(category)
end
self:_updateScale()
return category
end
function Window:GetCategory(name: string)
for _, category in self.Categories do
if category.Name == name then
return category
end
end
return nil
end
function Window:GetModules()
return table.clone(self.Modules)
end
function Window:GetModule(name: string)
for _, module in self.Modules do
if module.Name == name then
return module
end
end
return nil
end
function Window:_registerModule(module)
table.insert(self.Modules, module)
if self._query ~= "" then
self:Search(self._query)
end
self.ModulesChanged:Fire()
end
function Window:_unregisterModule(module)
local index = table.find(self.Modules, module)
if index then
table.remove(self.Modules, index)
end
local list = module.Category.Modules
local categoryIndex = table.find(list, module)
if categoryIndex then
table.remove(list, categoryIndex)
end
self.ModulesChanged:Fire()
self:_updateEmpty()
end
function Window:_removeCategory(category)
local index = table.find(self.Categories, category)
if not index then
return
end
table.remove(self.Categories, index)
for _, module in table.clone(category.Modules) do
module:Destroy()
end
local record = self._panels[category]
if record then
self._panels[category] = nil
record.Dragger:Destroy()
record.Resizer:Destroy()
record.Holder:Destroy()
end
local tab = self._tabs[category]
if tab then
self._tabs[category] = nil
tab.Button:Destroy()
if self._selected == category then
self._selected = nil
local fallback = self.Categories[1]
if fallback then
self:SelectCategory(fallback)
end
end
end
category.Page:Destroy()
self:_updateScale()
end
function Window:_onCategoryVisibilityChanged(category)
local tab = self._tabs[category]
if tab then
tab.Button.Visible = category._visible
end
self:_refreshPanelVisibility()
self:_scheduleLayout()
end
function Window:_onModuleVisibilityChanged()
self:_refreshPanelVisibility()
self:_updateEmpty()
end
function Window:_refreshPanelVisibility()
local filtering = self._query ~= "" or self._favoritesOnly
for category, record in self._panels do
local show = category._visible
if show and filtering then
show = false
for _, module in category.Modules do
if module.Frame.Visible then
show = true
break
end
end
end
record.Holder.Visible = show
end
end
function Window:_updateEmpty()
if not self._empty then
return
end
local filtering = self._query ~= "" or self._favoritesOnly
local any = false
for _, module in self.Modules do
if
module.Frame.Visible and (self.Layout == "Panels" or self._query ~= "" or module.Category == self._selected)
then
any = true
break
end
end
self._empty.Visible = filtering and not any
end
function Window:_matches(module, query, options)
if query == "" then
return true
end
if options.SearchNames and string.find(string.lower(module.Name), query, 1, true) then
return true
end
if
options.SearchDescriptions
and module.Description
and string.find(string.lower(module.Description), query, 1, true)
then
return true
end
if options.SearchCategories and string.find(string.lower(module.Category.Name), query, 1, true) then
return true
end
return false
end
function Window:Search(
query: string?,
options: { SearchNames: boolean?, SearchDescriptions: boolean?, SearchCategories: boolean? }?
)
local raw = query or ""
if options then
for _, key in { "SearchNames", "SearchDescriptions", "SearchCategories" } do
if options[key] ~= nil then
self._searchOptions[key] = options[key] == true
end
end
end
local normalized = string.lower(string.match(raw, "^%s*(.-)%s*$") or "")
self._query = normalized
if
self._searchBox
and self._searchBox.Text ~= raw
and normalized ~= string.lower(string.match(self._searchBox.Text, "^%s*(.-)%s*$") or "")
then
self._syncingSearch = true
self._searchBox.Text = raw
self._syncingSearch = false
end
local searchOptions = self._searchOptions
for _, module in self.Modules do
local match = self:_matches(module, normalized, searchOptions)
module._searchMatch = match
if self.Layout == "Sidebar" and self._sidebar then
module.Frame.Parent = (normalized ~= "" and match) and self._sidebar.SearchList or module.Category.List
end
module:_setHighlight(match and searchOptions.SearchNames and normalized or "")
module:_applyVisibility()
end
self:_updatePages()
self:_refreshPanelVisibility()
self:_updateEmpty()
self:_updateHeader()
end
function Window:SetSearchOptions(options)
self:Search(self._query, options)
end
function Window:ClearSearch()
self:Search("")
end
function Window:FocusSearch()
if self._searchBox then
self._searchBox:CaptureFocus()
end
end
function Window:_onFavoritesChanged(module)
if self._favoritesOnly then
self:Search(self._query)
end
self.FavoritesChanged:Fire(module)
self:_queueSave()
end
function Window:GetFavorites()
local list = {}
for _, module in self.Modules do
if module._favorite then
table.insert(list, module)
end
end
return list
end
function Window:GetPinned()
local list = {}
for _, module in self.Modules do
if module._pinned then
table.insert(list, module)
end
end
return list
end
function Window:SetFavoritesOnly(enabled: boolean)
self._favoritesOnly = enabled == true
self:Search(self._query)
end
function Window:IsFavoritesOnly(): boolean
return self._favoritesOnly
end
function Window:_animTargets()
local targets = {}
if self._searchHolder then
table.insert(targets, self._searchHolder)
end
if self._paletteHolder then
table.insert(targets, self._paletteHolder)
end
if self._sidebar then
table.insert(targets, self._sidebar)
end
for _, category in self.Categories do
local record = self._panels[category]
if record then
table.insert(targets, record)
end
end
return targets
end
local OPEN_OFFSETS = {
Rise = Vector2.new(0, 18),
Drop = Vector2.new(0, -18),
Slide = Vector2.new(-30, 0),
Fade = Vector2.new(0, 0),
}
function Window:SetOpenAnimation(name: string)
if OPEN_OFFSETS[name] then
self._openAnimation = name
else
warn(`[ClickGUI] Unknown open animation "{name}" (Rise, Drop, Slide, Fade)`)
end
end
function Window:_animate(opening: boolean, token: number)
local offset = OPEN_OFFSETS[self._openAnimation] or OPEN_OFFSETS.Rise
local backdropTarget = (opening and self._backdropEnabled) and self:_backdropTransparency() or 1
AnimationManager.Play(self._backdrop, opening and "Expo" or "Close", { BackgroundTransparency = backdropTarget })
local strokeTarget = Visual.strokeTransparency(self.Theme)
for index, target in self:_animTargets() do
local canvas, shadow, stroke = target.Canvas, target.Shadow, target.Stroke
if opening then
AnimationManager.Play(
canvas,
"Instant",
{ GroupTransparency = 1, Position = UDim2.fromOffset(offset.X, offset.Y) }
)
if shadow then
AnimationManager.Play(shadow.Instance, "Instant", { GroupTransparency = 1 })
end
if stroke then
AnimationManager.Play(stroke, "Instant", { Transparency = 1 })
end
end
local function run()
if self._token ~= token or self._destroyed then
return
end
local preset = opening and "Expo" or "Close"
AnimationManager.Play(canvas, preset, {
GroupTransparency = opening and 0 or 1,
Position = opening and UDim2.new() or UDim2.fromOffset(offset.X * 0.4, offset.Y * 0.4),
})
if shadow then
AnimationManager.Play(shadow.Instance, preset, { GroupTransparency = opening and 0 or 1 })
end
if stroke then
AnimationManager.Play(
stroke,
opening and "Expand" or "Close",
{ Transparency = opening and strokeTarget or 1 }
)
end
end
if opening and index > 1 and AnimationManager.Config.Enabled then
task.delay((index - 1) * 0.045 / AnimationManager.Config.Speed, run)
else
run()
end
end
if not opening then
task.delay(AnimationManager.Time(0.24), function()
if self._token == token and not self._destroyed then
self.Root.Visible = false
end
end)
end
end
function Window:Open()
if self._open or self._destroyed then
return
end
if not self._layoutLoaded and self._autoSave and self.Storage then
self._layoutLoaded = true
self:LoadLayout()
end
if self._autoLoadConfig and self.Storage and not self._configLoaded then
self._configLoaded = true
self:LoadConfig(self._startupProfile or self._profile)
end
self._open = true
self._token += 1
self.Root.Visible = true
self._unlock.Modal = true
self:BringToFront()
self:_animate(true, self._token)
self.Opened:Fire()
end
function Window:Close()
if not self._open or self._destroyed then
return
end
self._open = false
self._token += 1
self._unlock.Modal = false
self.Input:CancelCapture()
if self._autoSaveConfig and self.Storage then
self:SaveConfig()
end
local focused = UserInputService:GetFocusedTextBox()
if focused and focused:IsDescendantOf(self.Gui) then
focused:ReleaseFocus()
end
self:_animate(false, self._token)
self.Closed:Fire()
end
function Window:Toggle()
if self._open then
self:Close()
else
self:Open()
end
end
function Window:SetVisible(visible: boolean)
if visible then
self:Open()
else
self:Close()
end
end
function Window:IsOpen(): boolean
return self._open
end
function Window:SetToggleKey(key: Enum.KeyCode?)
self._toggleKey = key
self._toggleBinding:SetKey(key)
end
function Window:GetToggleKey(): Enum.KeyCode?
return self._toggleKey
end
function Window:_refreshCounts()
if self._countQueued then
return
end
self._countQueued = true
task.defer(function()
self._countQueued = false
if self._destroyed then
return
end
local totalAll, enabledAll = 0, 0
for _, category in self.Categories do
local total, enabled = 0, 0
for _, module in category.Modules do
if module.Toggleable then
total += 1
if module.Enabled then
enabled += 1
end
end
end
totalAll += total
enabledAll += enabled
local record = self._panels[category]
if record and record.Count then
record.Count.Text = (self._showCounts and total > 0) and (enabled .. "/" .. total) or ""
end
local tab = self._tabs[category]
if tab and tab.Count then
tab.Count.Text = self._showCounts and tostring(#category.Modules) or ""
end
end
if self._sidebar and self._sidebar.Footer then
self._sidebar.Footer.Text = self._showCounts and (enabledAll .. " / " .. totalAll .. " enabled") or ""
end
self:_updateHeader()
end)
end
function Window:SetShowCounts(enabled: boolean)
self._showCounts = enabled == true
self:_refreshCounts()
end
function Window:SetBackdrop(enabled: boolean)
self._backdropEnabled = enabled
self._backdrop.Active = enabled
if self._open then
AnimationManager.Play(
self._backdrop,
"Normal",
{ BackgroundTransparency = enabled and self:_backdropTransparency() or 1 }
)
end
end
function Window:SetTooltipsEnabled(enabled: boolean)
self.Tooltip:SetEnabled(enabled)
end
function Window:_reapplyStyle(except)
local patch = {}
for key, value in self.StyleData.Theme do
if not (except and except[key] ~= nil) then
patch[key] = value
end
end
if next(patch) then
self.Theme:Patch(patch)
end
if self._styleValues then
self.Theme:Patch(self._styleValues)
end
end
function Window:_backdropTransparency(): number
return self.Theme.Current.BackdropTransparency or BACKDROP_TRANSPARENCY
end
function Window:_refreshBackdrop()
if self._open and self._backdropEnabled and self._backdrop then
AnimationManager.Play(self._backdrop, "Fast", { BackgroundTransparency = self:_backdropTransparency() })
end
end
function Window:SetTheme(theme: string | Types.PartialTheme)
self.Theme:SetTheme(theme)
local except = nil
if type(theme) == "table" then
except = theme
elseif type(theme) == "string" and self.Theme:IsCustom(theme) then
except = self.Theme._presets[theme]
end
self:_reapplyStyle(except)
end
function Window:SetFont(name: string, titleName: string?): boolean
return self.Theme:SetFont(name, titleName)
end
function Window:SetTitleFont(name: string): boolean
return self.Theme:SetTitleFont(name)
end
function Window:GetFonts(): { string }
return Fonts.Names()
end
function Window:_themesKey()
return self:_storageKey("themes")
end
function Window:_loadThemes()
local data = Config.decode(Config.read(self.Storage, self:_themesKey()))
if data then
self.Theme:LoadCustom(data)
end
end
function Window:_writeThemes(): boolean
return Config.write(self.Storage, self:_themesKey(), Config.encode(self.Theme:ExportCustom()))
end
function Window:SaveTheme(name: string): (boolean, string, boolean)
local ok, result = self.Theme:SaveCustom(name)
if not ok then
return false, result, false
end
return true, result, self:_writeThemes()
end
function Window:DeleteTheme(name: string): boolean
if not self.Theme:DeleteCustom(name) then
return false
end
self:_writeThemes()
return true
end
function Window:GetCustomThemes(): { string }
return self.Theme:GetCustomNames()
end
function Window:ExportTheme(name: string?): string
return Config.encode(self.Theme:ExportTheme(name))
end
function Window:ImportTheme(source: any, name: string?): (boolean, string)
local data = source
if type(source) == "string" then
data = Config.decode(source)
end
if type(data) ~= "table" then
return false, "Invalid theme JSON"
end
local partial = ThemeManager.Deserialize(data)
local keys = 0
for key in partial do
if key ~= "Name" then
keys += 1
end
end
if keys == 0 then
return false, "Invalid theme JSON"
end
local base = name or partial.Name or "Imported"
if self.Theme:IsBuiltin(base) then
base = tostring(base) .. " (Imported)"
end
local ok, result = self.Theme:SaveCustom(base, partial)
if not ok then
return false, result
end
self:_writeThemes()
self:SetTheme(result)
return true, result
end
function Window:SetAccent(color: Color3)
self.Theme:SetAccent(color)
end
function Window:SetThemeValue(key: string, value: any)
self.Theme:Set(key, value)
end
function Window:Notify(options: Types.NotifyOptions)
return self.Library:Notify(options)
end
function Window:_registerFlag(flag: string, component)
if self.Flags[flag] ~= nil then
warn(`[ClickGUI] Duplicate flag "{flag}" - the newest component wins`)
end
self.Flags[flag] = component
component._flag = flag
end
function Window:GetFlag(flag: string)
local component = self.Flags[flag]
if component == nil then
return nil
end
return component:Get()
end
function Window:SetFlag(flag: string, value: any, silent: boolean?)
local component = self.Flags[flag]
if component then
component:Set(value, silent)
end
end
local function moduleKey(module)
return module.Category.Name .. "/" .. module.Name
end
local function componentKey(module, component)
local count = 0
for _, other in module.Components do
if other.Name == component.Name then
count += 1
end
if other == component then
break
end
end
local base = moduleKey(module) .. "/" .. component.Name
return count > 1 and (base .. "#" .. count) or base
end
function Window:_collectLayout()
local layout = { Panels = {}, UserMoved = self._userMoved, Favorites = {}, Pinned = {} }
for category, record in self._panels do
local position = record.Holder.Position
layout.Panels[category.Name] = {
XS = position.X.Scale,
X = position.X.Offset,
YS = position.Y.Scale,
Y = position.Y.Offset,
Width = record.Width,
Collapsed = record.Collapsed,
}
end
if self._sidebar then
local position = self._sidebar.Holder.Position
layout.Sidebar = {
XS = position.X.Scale,
X = position.X.Offset,
YS = position.Y.Scale,
Y = position.Y.Offset,
Width = self.Size.X.Offset,
Height = self.Size.Y.Offset,
Selected = self._selected and self._selected.Name or nil,
}
end
for _, module in self.Modules do
if module._favorite then
table.insert(layout.Favorites, moduleKey(module))
end
if module._pinned then
table.insert(layout.Pinned, moduleKey(module))
end
end
return layout
end
function Window:_applyLayout(layout)
if type(layout) ~= "table" then
return
end
local viewport = self.Gui.AbsoluteSize
if type(layout.Panels) == "table" then
for _, category in self.Categories do
local record = self._panels[category]
local data = layout.Panels[category.Name]
if record and type(data) == "table" then
if type(data.Width) == "number" then
record.Width = math.clamp(data.Width, MIN_PANEL, MAX_PANEL)
end
if type(data.X) == "number" and type(data.Y) == "number" then
local x, y = data.X, data.Y
if viewport.X > 0 and (data.XS or 0) == 0 and (data.YS or 0) == 0 then
x = math.clamp(x, 0, math.max(viewport.X - 80, 0))
y = math.clamp(y, 0, math.max(viewport.Y - 40, 0))
end
record.Holder.Position = UDim2.new(data.XS or 0, x, data.YS or 0, y)
end
self:_setCollapsed(record, data.Collapsed == true, false)
end
end
if layout.UserMoved then
self._userMoved = true
end
end
local sidebar = layout.Sidebar
if type(sidebar) == "table" and self._sidebar then
if type(sidebar.Width) == "number" and type(sidebar.Height) == "number" then
self:_resizeTo(sidebar.Width, sidebar.Height)
end
if type(sidebar.X) == "number" and type(sidebar.Y) == "number" then
self._sidebar.Holder.Position = UDim2.new(sidebar.XS or 0.5, sidebar.X, sidebar.YS or 0.5, sidebar.Y)
end
if type(sidebar.Selected) == "string" then
self:SelectCategory(sidebar.Selected)
end
end
local function applyList(list, setter)
if type(list) ~= "table" then
return
end
local lookup = {}
for _, key in list do
lookup[key] = true
end
for _, module in self.Modules do
setter(module, lookup[moduleKey(module)] == true)
end
end
applyList(layout.Favorites, function(module, value)
module:SetFavorite(value)
end)
applyList(layout.Pinned, function(module, value)
module:SetPinned(value)
end)
self:_updateScale()
end
function Window:SetStorage(adapter)
assert(
adapter == nil or (type(adapter.Get) == "function" and type(adapter.Set) == "function"),
"[ClickGUI] Storage adapter needs Get and Set"
)
self.Storage = adapter
self:_loadThemes()
end
function Window:_storageKey(suffix)
local safe = string.gsub(tostring(self._configKey), "[^%w_%-]", "_")
return "ClickGUI_" .. safe .. "_" .. string.gsub(tostring(suffix), "/", "_")
end
function Window:_queueSave()
if not self._autoSave or not self.Storage or self._destroyed then
return
end
self._saveToken += 1
local token = self._saveToken
task.delay(1, function()
if self._saveToken == token and not self._destroyed then
self:SaveLayout()
end
end)
end
function Window:SaveLayout(): boolean
if not self.Storage then
return false
end
return Config.write(self.Storage, self:_storageKey("layout"), Config.encode(self:_collectLayout()))
end
function Window:LoadLayout(): boolean
local layout = Config.decode(Config.read(self.Storage, self:_storageKey("layout")))
if not layout then
return false
end
self:_applyLayout(layout)
return true
end
function Window:_buildConfig()
local data = {
Version = Config.Version,
Flags = {},
Modules = {},
Favorites = {},
Pinned = {},
Layout = self:_collectLayout(),
Theme = self.Theme:ExportTheme(),
Themes = self.Theme:ExportCustom(),
Scale = self._userScale or false,
Animation = AnimationManager.GetConfig(),
Tooltips = self.Tooltip.Enabled,
Backdrop = self._backdropEnabled,
FavoritesOnly = self._favoritesOnly,
Resizable = self._resizable,
HUD = {},
}
if self._selected then
data.Selected = self._selected.Name
end
data.Auto, data.Binds = {}, {}
for flag, component in self.Flags do
data.Flags[flag] = component:Serialize()
end
for _, module in self.Modules do
for _, component in module.Components do
local key = componentKey(module, component)
if component._persist and component._flag == nil then
local value = component:Serialize()
if value ~= nil then
data.Auto[key] = value
end
end
if component._hasKeyAction then
data.Binds[key] = component._bindKey and component._bindKey.Name or false
end
end
end
for _, module in self.Modules do
if module.Toggleable then
data.Modules[moduleKey(module)] = module.Enabled
end
if module._favorite then
table.insert(data.Favorites, moduleKey(module))
end
if module._pinned then
table.insert(data.Pinned, moduleKey(module))
end
end
for hud in self._huds do
data.HUD[hud.Name] = hud:Export()
end
data.Notifications = self.Library:GetNotificationConfig()
data.ToggleKey = self._toggleKey and self._toggleKey.Name or false
data.OpenAnimation = self._openAnimation
data.ShowCounts = self._showCounts
data.SearchOptions = table.clone(self._searchOptions)
data.Profile = self._profile
data.Widgets = {}
for widget, kind in self._widgets do
data.Widgets[kind] = data.Widgets[kind] or {}
data.Widgets[kind][widget.Name] = widget:Export()
end
return data
end
function Window:ExportConfig(): string
return Config.encode(self:_buildConfig())
end
function Window:ImportConfig(config): boolean
local data = config
if type(config) == "string" then
data = Config.decode(config)
if not data then
warn("[ClickGUI] Invalid config")
return false
end
end
data = Config.migrate(data)
if not data then
return false
end
if type(data.Themes) == "table" then
self.Theme:LoadCustom(data.Themes)
end
if type(data.Theme) == "table" then
self.Theme:SetTheme(ThemeManager.Deserialize(data.Theme))
end
if type(data.Animation) == "table" then
AnimationManager.SetConfig(data.Animation)
end
if data.Tooltips ~= nil then
self:SetTooltipsEnabled(data.Tooltips == true)
end
if data.Backdrop ~= nil then
self:SetBackdrop(data.Backdrop == true)
end
if data.Resizable ~= nil then
self:SetResizable(data.Resizable == true)
end
if type(data.Scale) == "number" then
self:SetScale(data.Scale)
elseif data.Scale == false then
self:SetScale(nil)
end
for flag, value in data.Flags do
local component = self.Flags[flag]
if component then
local ok, err = pcall(component.Deserialize, component, value)
if not ok then
warn(`[ClickGUI] Could not load flag "{flag}": {err}`)
end
end
end
for key, enabled in data.Modules do
for _, module in self.Modules do
if moduleKey(module) == key then
module:SetEnabled(enabled == true)
end
end
end
for _, module in self.Modules do
for _, component in module.Components do
local key = componentKey(module, component)
local saved = data.Auto[key]
if saved ~= nil and component._persist and component._flag == nil then
local ok, err = pcall(component.Deserialize, component, saved)
if not ok then
warn(`[ClickGUI] Could not load "{key}": {err}`)
end
end
local bind = data.Binds[key]
if bind ~= nil and component._hasKeyAction then
component:SetKeybind(bind or nil)
end
end
end
local layout = type(data.Layout) == "table" and data.Layout or {}
layout.Favorites = data.Favorites
layout.Pinned = data.Pinned
if data.Legacy then
layout.Favorites, layout.Pinned = nil, nil
end
self:_applyLayout(layout)
if type(data.Selected) == "string" then
self:SelectCategory(data.Selected)
end
if data.FavoritesOnly ~= nil then
self:SetFavoritesOnly(data.FavoritesOnly == true)
end
if type(data.Notifications) == "table" then
self.Library:SetNotificationConfig(data.Notifications)
end
if type(data.ToggleKey) == "string" then
local ok, key = pcall(function()
return Enum.KeyCode[data.ToggleKey]
end)
if ok and key then
self:SetToggleKey(key)
end
elseif data.ToggleKey == false then
self:SetToggleKey(nil)
end
if type(data.OpenAnimation) == "string" then
self:SetOpenAnimation(data.OpenAnimation)
end
if data.ShowCounts ~= nil then
self:SetShowCounts(data.ShowCounts == true)
end
if type(data.SearchOptions) == "table" then
self._searchOptions.SearchNames = data.SearchOptions.SearchNames ~= false
self._searchOptions.SearchDescriptions = data.SearchOptions.SearchDescriptions ~= false
self._searchOptions.SearchCategories = data.SearchOptions.SearchCategories ~= false
end
if type(data.Widgets) == "table" then
for widget, kind in self._widgets do
local group = data.Widgets[kind]
local saved = type(group) == "table" and group[widget.Name]
if type(saved) == "table" then
pcall(widget.Import, widget, saved)
end
end
end
if type(data.HUD) == "table" then
for hud in self._huds do
local saved = data.HUD[hud.Name]
if type(saved) == "table" then
hud:Import(saved)
end
end
end
return true
end
function Window:_profileKey(name)
if name == nil or name == "Default" then
return self:_storageKey("config")
end
return self:_storageKey("profile/" .. name)
end
local function cleanProfileName(name)
name = string.match(tostring(name or ""), "^%s*(.-)%s*$") or ""
name = string.gsub(name, "[%c/\\]", "")
return string.sub(name, 1, 32)
end
function Window:GetProfile(): string
return self._profile
end
function Window:GetProfiles(): { string }
local list = { "Default" }
local stored = Config.decode(Config.read(self.Storage, self:_storageKey("profiles")))
if type(stored) == "table" then
for _, name in stored do
if type(name) == "string" and name ~= "Default" and not table.find(list, name) then
table.insert(list, name)
end
end
end
return list
end
function Window:_writeProfiles(list)
local out = {}
for _, name in list do
if name ~= "Default" then
table.insert(out, name)
end
end
Config.write(self.Storage, self:_storageKey("profiles"), Config.encode(out))
end
function Window:SaveConfig(profile: string?): boolean
if not self.Storage then
return false
end
profile = profile and cleanProfileName(profile) or self._profile
if profile == "" then
return false
end
local ok = Config.write(self.Storage, self:_profileKey(profile), self:ExportConfig())
if ok and profile ~= "Default" then
local list = self:GetProfiles()
if not table.find(list, profile) then
table.insert(list, profile)
self:_writeProfiles(list)
end
end
return ok
end
function Window:LoadConfig(profile: string?): boolean
profile = profile and cleanProfileName(profile) or self._profile
local text = Config.read(self.Storage, self:_profileKey(profile))
if not text then
return false
end
local ok = self:ImportConfig(text)
if ok then
self._profile = profile
end
return ok
end
function Window:SaveProfile(name: string): boolean
name = cleanProfileName(name)
if name == "" then
return false
end
self._profile = name
return self:SaveConfig(name)
end
function Window:LoadProfile(name: string): boolean
return self:LoadConfig(name)
end
function Window:DeleteProfile(name: string): boolean
name = cleanProfileName(name)
if name == "" or name == "Default" or not self.Storage then
return false
end
local key = self:_profileKey(name)
if type(self.Storage.Remove) == "function" then
pcall(self.Storage.Remove, self.Storage, key)
else
Config.write(self.Storage, key, "")
end
local list = {}
for _, existing in self:GetProfiles() do
if existing ~= name then
table.insert(list, existing)
end
end
self:_writeProfiles(list)
if self._startupProfile == name then
self._startupProfile = nil
self:_savePrefs()
end
if self._profile == name then
self._profile = "Default"
end
return true
end
function Window:SetStartupProfile(name: string?)
self._startupProfile = name and cleanProfileName(name) or nil
self:_savePrefs()
end
function Window:GetStartupProfile(): string?
return self._startupProfile
end
function Window:_loadPrefs(options)
local prefs = Config.decode(Config.read(self.Storage, self:_storageKey("prefs")))
if not prefs then
return
end
if options.AutoSaveConfig == nil and options.AutoConfig == nil and type(prefs.AutoSaveConfig) == "boolean" then
self._autoSaveConfig = prefs.AutoSaveConfig
end
if options.AutoSaveInterval == nil and type(prefs.AutoSaveInterval) == "number" then
self._autoSaveInterval = math.max(prefs.AutoSaveInterval, 5)
end
if options.AutoLoadConfig == nil and options.AutoConfig == nil and type(prefs.AutoLoadConfig) == "boolean" then
self._autoLoadConfig = prefs.AutoLoadConfig
end
if options.AutoSave == nil and type(prefs.AutoSaveLayout) == "boolean" then
self._autoSave = prefs.AutoSaveLayout
end
if type(prefs.Startup) == "string" and prefs.Startup ~= "" then
self._startupProfile = prefs.Startup
end
end
function Window:_savePrefs()
if not self.Storage then
return
end
Config.write(
self.Storage,
self:_storageKey("prefs"),
Config.encode({
AutoSaveConfig = self._autoSaveConfig,
AutoSaveInterval = self._autoSaveInterval,
AutoLoadConfig = self._autoLoadConfig,
AutoSaveLayout = self._autoSave,
Startup = self._startupProfile or "",
})
)
end
function Window:_restartAutoSave()
self._autoToken += 1
if not self._autoSaveConfig or not self.Storage or self._destroyed then
return
end
local token = self._autoToken
local function tick()
if token ~= self._autoToken or self._destroyed then
return
end
self:SaveConfig()
task.delay(self._autoSaveInterval, tick)
end
task.delay(self._autoSaveInterval, tick)
end
function Window:SetAutoSave(enabled: boolean, interval: number?)
self._autoSaveConfig = enabled == true
if interval then
self._autoSaveInterval = math.max(tonumber(interval) or 60, 5)
end
self:_restartAutoSave()
self:_savePrefs()
end
function Window:SetAutoSaveInterval(seconds: number)
self._autoSaveInterval = math.max(tonumber(seconds) or 60, 5)
self:_restartAutoSave()
self:_savePrefs()
end
function Window:SetAutoLoad(enabled: boolean)
self._autoLoadConfig = enabled == true
self:_savePrefs()
end
function Window:SetAutoSaveLayout(enabled: boolean)
self._autoSave = enabled == true
self:_savePrefs()
end
function Window:GetAutoSave(): (boolean, number)
return self._autoSaveConfig, self._autoSaveInterval
end
function Window:GetAutoLoad(): boolean
return self._autoLoadConfig
end
function Window:CreateWatermark(options)
local watermark = self.Library:CreateWatermark(options)
watermark:Attach(self)
return watermark
end
function Window:CreateTargetHUD(options)
local hud = self.Library:CreateTargetHUD(options)
hud:Attach(self)
return hud
end
function Window:_attachWidget(kind, widget)
self._widgets[widget] = kind
end
function Window:_detachWidget(widget)
self._widgets[widget] = nil
end
function Window:ResetConfig()
for _, module in self.Modules do
for _, component in module.Components do
if component._default ~= nil then
pcall(component.Deserialize, component, component._default)
end
if component._hasKeyAction then
component:SetKeybind(component._defaultBind, true)
end
end
module:SetEnabled(module._defaultEnabled)
module:SetFavorite(false)
module:SetPinned(false)
end
self.Theme:Restore()
self:_reapplyStyle()
AnimationManager.ResetConfig()
self:SetScale(nil)
self:SetTooltipsEnabled(true)
self:SetBackdrop(true)
self._favoritesOnly = false
self:Search("")
self:ResetLayout()
return true
end
function Window:_attachHUD(hud)
self._huds[hud] = true
end
function Window:_detachHUD(hud)
self._huds[hud] = nil
end
function Window:CreateSettingsCategory(name: string?, options)
return require(script.Parent.Settings).build(self, name or "Settings", options or {})
end
function Window:SetTitle(text: string)
self.Title = tostring(text)
local sidebar = self._sidebar
if sidebar and sidebar.TitleLabel then
sidebar.TitleLabel.Text = self.Title
end
self:_updateHeader()
end
function Window:SetSubtitle(text: string?)
self.Subtitle = text
local sidebar = self._sidebar
if sidebar and sidebar.SubtitleLabel then
sidebar.SubtitleLabel.Text = (sidebar.Brand and text) and string.upper(text) or (text or "")
end
end
function Window:SetAutoConfig(enabled: boolean)
self:SetAutoSave(enabled, nil)
self:SetAutoLoad(enabled)
end
function Window:Destroy()
if self._destroyed then
return
end
if self._autoSaveConfig and self.Storage then
pcall(self.SaveConfig, self)
end
self._autoToken += 1
self._saveToken += 1
if self._open then
self._unlock.Modal = false
end
for hud in table.clone(self._huds) do
hud:Detach(self)
end
for widget in table.clone(self._widgets) do
pcall(widget.Destroy, widget)
end
for _, category in table.clone(self.Categories) do
category:Destroy()
end
self._destroyed = true
self.Closed:Fire()
for _, signal in
{
self.Opened,
self.Closed,
self.ModuleToggled,
self.ModuleInfoChanged,
self.FavoritesChanged,
self.ModulesChanged,
}
do
signal:Destroy()
end
for _, shadow in self._shadows do
shadow:Destroy()
end
self._maid:Clean()
self.Library:_removeWindow(self)
end
return Window
end
__functions[__n_Types] = function(script, require)
type Theme = {
Name: string,
Background: Color3,
Panel: Color3,
Header: Color3,
Module: Color3,
ModuleHover: Color3,
Element: Color3,
ElementHover: Color3,
Accent: Color3,
AccentDark: Color3,
Text: Color3,
TextDim: Color3,
Stroke: Color3,
Success: Color3,
Warning: Color3,
Error: Color3,
Info: Color3,
Transparency: number,
CornerRadius: number,
Border: boolean,
BorderThickness: number,
AccentLine: boolean,
AccentLineThickness: number,
HeaderAlign: string,
ModuleSpacing: number,
ModuleTextSize: number,
HeaderTextSize: number,
SheenStrength: number,
GradientStrength: number,
BorderTransparency: number,
Gradients: boolean,
GradientRotation: number,
ShadowPreset: string,
ShadowOpacity: number,
ShadowColor: Color3,
Font: (Enum.Font | Font),
FontBold: (Enum.Font | Font),
AccentGradient: boolean,
AccentGradientAngle: number,
AccentBorder: boolean,
ModuleCornerRadius: number,
ModuleTransparency: number,
BackdropColor: Color3,
BackdropTransparency: number,
ScrollBarThickness: number,
}
type PartialTheme = { [string]: any }
type Layout = "Panels" | "Sidebar"
type StorageAdapter = {
Get: (self: StorageAdapter, key: string) -> string?,
Set: (self: StorageAdapter, key: string, value: string) -> (),
Remove: ((self: StorageAdapter, key: string) -> ())?,
}
type WindowOptions = {
Encrypt: boolean?,
EncryptNames: boolean?,
FavoriteIcons: { On: string?, Hover: string?, Off: string? }?,
AutoSaveConfig: boolean?,
AutoSaveInterval: number?,
AutoLoadConfig: boolean?,
Profile: string?,
AutoConfig: boolean?,
Style: ("Classic" | "Flat" | "Glass")?,
Palette: any?,
Icon: (string | number)?,
ThemeValues: { [string]: any }?,
Loader: any?,
OpenAnimation: ("Rise" | "Drop" | "Slide" | "Fade")?,
MinSize: UDim2?,
MaxSize: UDim2?,
Resizable: boolean?,
Tooltips: boolean?,
SearchKey: Enum.KeyCode?,
ConfigKey: string?,
AutoSave: boolean?,
Storage: StorageAdapter?,
Title: string?,
Subtitle: string?,
Layout: Layout?,
Size: UDim2?,
ToggleKey: Enum.KeyCode?,
Theme: string?,
Accent: Color3?,
Scale: number?,
StartOpen: boolean?,
Backdrop: boolean?,
PanelWidth: number?,
MaxPanelHeight: number?,
DisplayOrder: number?,
Parent: Instance?,
}
type CategoryOptions = {
Group: string?,
Icon: string?,
IconSize: number?,
IconColor: Color3?,
}
type ModuleOptions = {
Name: string,
Description: string?,
Default: boolean?,
Callback: ((enabled: boolean) -> ())?,
Keybind: Enum.KeyCode?,
ShowKeybind: boolean?,
Toggleable: boolean?,
ShowInHUD: boolean?,
Expanded: boolean?,
Tooltip: string?,
Icon: string?,
IconSize: number?,
IconActiveColor: Color3?,
IconInactiveColor: Color3?,
Favorite: boolean?,
Pinned: boolean?,
}
type ToggleOptions = {
Name: string,
Default: boolean?,
Callback: ((value: boolean) -> ())?,
Flag: string?,
}
type SliderOptions = {
Name: string,
Min: number,
Max: number,
Default: number?,
Increment: number?,
Suffix: string?,
Callback: ((value: number) -> ())?,
Flag: string?,
}
type DropdownOptions = {
Name: string,
Options: { string },
Default: (string | { string })?,
Multi: boolean?,
Callback: ((value: any) -> ())?,
Flag: string?,
}
type KeybindOptions = {
Name: string,
Default: Enum.KeyCode?,
Callback: ((key: Enum.KeyCode?) -> ())?,
OnPressed: (() -> ())?,
Flag: string?,
}
type ColorPickerOptions = {
Name: string,
Default: Color3?,
Callback: ((color: Color3) -> ())?,
Flag: string?,
}
type GraphicOptions = {
Name: string,
Mode: ("Gradient" | "Curve")?,
Default: (ColorSequence | NumberSequence | Color3 | number)?,
Callback: ((value: ColorSequence | NumberSequence) -> ())?,
Flag: string?,
Tooltip: string?,
MaxPoints: number?,
Smooth: boolean?,
Expanded: boolean?,
}
type TextboxOptions = {
Name: string,
Default: string?,
Placeholder: string?,
Numeric: boolean?,
ClearOnFocus: boolean?,
Callback: ((text: string, enterPressed: boolean) -> ())?,
Flag: string?,
}
type ButtonOptions = {
Name: string,
Text: string?,
Callback: (() -> ())?,
}
type LoaderOptions = {
Title: string?,
Subtitle: string?,
Logo: (string | number)?,
Style: ("Bar" | "Spinner" | "Dots" | "Pulse" | "Terminal" | "Minimal")?,
MinTime: number?,
Timeout: number?,
TimeoutAction: ("Finish" | "Fail")?,
OnTimeout: (() -> ())?,
Mode: ("All" | "Any")?,
AutoFinish: boolean?,
Tasks: { string }?,
Conditions: { any }?,
Color: Color3?,
BackgroundColor: Color3?,
BackgroundTransparency: number?,
DisplayOrder: number?,
Parent: Instance?,
}
type NotifyType = "Info" | "Success" | "Warning" | "Error"
type NotifyOptions = {
Style: ("Modern" | "Minimal" | "Banner")?,
Icon: (string | number)?,
Closable: boolean?,
Progress: boolean?,
OnClick: (() -> ())?,
Title: string?,
Content: string,
Duration: number?,
Type: NotifyType?,
}
type HUDPosition = "TopLeft" | "TopRight" | "BottomLeft" | "BottomRight"
type HUDOptions = {
Style: ("Block" | "Pill")?,
CornerRadius: number?,
Name: string?,
Font: Enum.Font?,
Spacing: number?,
Border: boolean?,
BorderColor: Color3?,
BorderThickness: number?,
TextTransparency: number?,
BackgroundColor: Color3?,
GradientFrom: Color3?,
GradientTo: Color3?,
GradientSpeed: number?,
Animation: ("Both" | "Grow" | "Fade" | "None")?,
Position: HUDPosition?,
Offset: Vector2?,
TextSize: number?,
Sort: ("Length" | "Alphabetical" | "None")?,
Background: boolean?,
BackgroundTransparency: number?,
AccentBar: ("Left" | "Right" | "None")?,
ColorMode: ("Accent" | "Gradient" | "Rainbow" | "Static")?,
StaticColor: Color3?,
ShowInfo: boolean?,
Visible: boolean?,
DisplayOrder: number?,
Parent: Instance?,
}
return {}
end
__functions[__n_Utilities_Create] = function(script, require)
local WHITE = Color3.new(1, 1, 1)
local DEFAULTS: { [string]: { [string]: any } } = {
Frame = { BorderSizePixel = 0 },
CanvasGroup = { BorderSizePixel = 0 },
TextLabel = {
BorderSizePixel = 0,
BackgroundTransparency = 1,
Font = Enum.Font.GothamMedium,
TextSize = 12,
TextColor3 = WHITE,
Text = "",
},
TextButton = {
BorderSizePixel = 0,
BackgroundTransparency = 1,
AutoButtonColor = false,
Font = Enum.Font.GothamMedium,
TextSize = 12,
TextColor3 = WHITE,
Text = "",
},
TextBox = {
BorderSizePixel = 0,
BackgroundTransparency = 1,
ClearTextOnFocus = false,
Font = Enum.Font.GothamMedium,
TextSize = 12,
TextColor3 = WHITE,
Text = "",
},
ImageLabel = { BorderSizePixel = 0, BackgroundTransparency = 1 },
ImageButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false },
ScrollingFrame = {
BorderSizePixel = 0,
BackgroundTransparency = 1,
ScrollBarThickness = 3,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollingDirection = Enum.ScrollingDirection.Y,
ElasticBehavior = Enum.ElasticBehavior.Never,
VerticalScrollBarInset = Enum.ScrollBarInset.None,
},
}
local Create = {}
function Create.new(className: string, properties: { [string]: any }?, children: { Instance }?): any
local instance: any = Instance.new(className)
local defaults = DEFAULTS[className]
if defaults then
for key, value in defaults do
instance[key] = value
end
end
local parent: Instance? = nil
if properties then
for key, value in properties do
if key == "Parent" then
parent = value
elseif key == "Font" and typeof(value) == "Font" then
instance.FontFace = value
else
instance[key] = value
end
end
end
if children then
for _, child in children do
child.Parent = instance
end
end
if parent then
instance.Parent = parent
end
return instance
end
function Create.corner(parent: Instance, radius: number?): UICorner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, radius or 6)
corner.Parent = parent
return corner
end
function Create.pill(parent: Instance): UICorner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = parent
return corner
end
function Create.stroke(parent: Instance, color: Color3, thickness: number?, transparency: number?): UIStroke
local stroke = Instance.new("UIStroke")
stroke.Color = color
stroke.Thickness = thickness or 1
stroke.Transparency = transparency or 0
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = parent
return stroke
end
function Create.padding(parent: Instance, top: number, right: number?, bottom: number?, left: number?): UIPadding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, top)
padding.PaddingRight = UDim.new(0, right or top)
padding.PaddingBottom = UDim.new(0, bottom or top)
padding.PaddingLeft = UDim.new(0, left or right or top)
padding.Parent = parent
return padding
end
function Create.list(parent: Instance, spacing: number?, horizontal: boolean?): UIListLayout
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, spacing or 0)
layout.FillDirection = if horizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
layout.Parent = parent
return layout
end
return setmetatable(Create, {
__call = function(_, className: string, properties: { [string]: any }?, children: { Instance }?): any
return Create.new(className, properties, children)
end,
})
end
__functions[__n_Utilities_Draggable] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Maid = require(script.Parent.Maid)
type Options = {
Bounds: GuiObject?,
OnDragStart: (() -> ())?,
OnDragEnd: (() -> ())?,
}
local Draggable = {}
Draggable.__index = Draggable
type Draggable = typeof(setmetatable(
{} :: {
Enabled: boolean,
Dragging: boolean,
_maid: Maid.Maid,
_handle: GuiObject,
_target: GuiObject,
_options: Options,
_startInput: Vector2,
_startPosition: UDim2,
_startAbsolute: Vector2,
_dragInput: InputObject?,
},
Draggable
))
local VISIBLE_MARGIN_X = 80
local VISIBLE_MARGIN_Y = 40
local function isPointer(input: InputObject): boolean
return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
function Draggable.new(handle: GuiObject, target: GuiObject, options: Options?): Draggable
local self: Draggable = setmetatable({
Enabled = true,
Dragging = false,
_maid = Maid.new(),
_handle = handle,
_target = target,
_options = options or {},
_startInput = Vector2.zero,
_startPosition = target.Position,
_startAbsolute = Vector2.zero,
_dragInput = nil,
}, Draggable)
self._maid:Give(handle.InputBegan:Connect(function(input: InputObject)
if not self.Enabled or not isPointer(input) then
return
end
self.Dragging = true
self._dragInput = input
self._startInput = Vector2.new(input.Position.X, input.Position.Y)
self._startPosition = target.Position
self._startAbsolute = target.AbsolutePosition
if self._options.OnDragStart then
self._options.OnDragStart()
end
end))
self._maid:Give(UserInputService.InputChanged:Connect(function(input: InputObject)
if not self.Dragging then
return
end
local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
or (input.UserInputType == Enum.UserInputType.Touch and input == self._dragInput)
if not isMove then
return
end
local delta = Vector2.new(input.Position.X, input.Position.Y) - self._startInput
local bounds = self._options.Bounds
if bounds then
local boundsPosition, boundsSize = bounds.AbsolutePosition, bounds.AbsoluteSize
local size = target.AbsoluteSize
local desired = self._startAbsolute + delta
local clamped = Vector2.new(
math.clamp(
desired.X,
boundsPosition.X - size.X + VISIBLE_MARGIN_X,
boundsPosition.X + boundsSize.X - VISIBLE_MARGIN_X
),
math.clamp(desired.Y, boundsPosition.Y, boundsPosition.Y + boundsSize.Y - VISIBLE_MARGIN_Y)
)
delta = clamped - self._startAbsolute
end
local start = self._startPosition
target.Position = UDim2.new(start.X.Scale, start.X.Offset + delta.X, start.Y.Scale, start.Y.Offset + delta.Y)
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input: InputObject)
if self.Dragging and isPointer(input) then
self.Dragging = false
self._dragInput = nil
if self._options.OnDragEnd then
self._options.OnDragEnd()
end
end
end))
return self
end
function Draggable.Destroy(self: Draggable)
self.Dragging = false
self._maid:Clean()
end
return Draggable
end
__functions[__n_Utilities_Maid] = function(script, require)
local Maid = {}
Maid.__index = Maid
type Maid = typeof(setmetatable({} :: { _tasks: { [any]: any }, _counter: number, _cleaning: boolean }, Maid))
local function cleanItem(item: any)
local kind = typeof(item)
if kind == "RBXScriptConnection" then
item:Disconnect()
elseif kind == "Instance" then
item:Destroy()
elseif kind == "function" then
item()
elseif kind == "thread" then
pcall(task.cancel, item)
elseif kind == "table" then
if type(item.Destroy) == "function" then
item:Destroy()
elseif type(item.Disconnect) == "function" then
item:Disconnect()
end
end
end
function Maid.new(): Maid
return setmetatable({ _tasks = {}, _counter = 0, _cleaning = false }, Maid)
end
function Maid.Give<T>(self: Maid, item: T): T
self._counter += 1
self._tasks[self._counter] = item
return item
end
function Maid.GiveNamed<T>(self: Maid, name: string, item: T): T
local previous = self._tasks[name]
if previous ~= nil then
self._tasks[name] = nil
cleanItem(previous)
end
self._tasks[name] = item
return item
end
function Maid.Remove(self: Maid, name: string)
local previous = self._tasks[name]
if previous ~= nil then
self._tasks[name] = nil
cleanItem(previous)
end
end
function Maid.Clean(self: Maid)
if self._cleaning then
return
end
self._cleaning = true
local tasks = self._tasks
self._tasks = {}
for _, item in tasks do
local ok, err = pcall(cleanItem, item)
if not ok then
warn("[ClickGUI] Maid cleanup error: " .. tostring(err))
end
end
self._cleaning = false
end
Maid.Destroy = Maid.Clean
return Maid
end
__functions[__n_Utilities_Resizer] = function(script, require)
local UserInputService = game:GetService("UserInputService")
local Maid = require(script.Parent.Maid)
local Resizer = {}
Resizer.__index = Resizer
local function isPointer(input)
return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
function Resizer.new(handle, options)
local self = setmetatable({ Active = false, Enabled = true, _maid = Maid.new(), _options = options or {} }, Resizer)
local start, dragInput
self._maid:Give(handle.InputBegan:Connect(function(input)
if not self.Enabled or not isPointer(input) then
return
end
self.Active = true
dragInput = input
start = Vector2.new(input.Position.X, input.Position.Y)
if self._options.OnStart then
self._options.OnStart()
end
end))
self._maid:Give(UserInputService.InputChanged:Connect(function(input)
if not self.Active then
return
end
if
input.UserInputType == Enum.UserInputType.MouseMovement
or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
then
local delta = Vector2.new(input.Position.X, input.Position.Y) - start
self._options.OnChange(delta.X, delta.Y)
end
end))
self._maid:Give(UserInputService.InputEnded:Connect(function(input)
if self.Active and isPointer(input) then
self.Active = false
if self._options.OnEnd then
self._options.OnEnd()
end
end
end))
return self
end
function Resizer:Destroy()
self.Active = false
self._maid:Clean()
end
return Resizer
end
__functions[__n_Utilities_Signal] = function(script, require)
type Handler = (...any) -> ()
type Connection = {
Connected: boolean,
Disconnect: (self: Connection) -> (),
}
local Signal = {}
Signal.__index = Signal
type Signal = typeof(setmetatable(
{} :: { _handlers: { [number]: Handler }, _nextId: number, _destroyed: boolean },
Signal
))
function Signal.new(): Signal
return setmetatable({ _handlers = {}, _nextId = 0, _destroyed = false }, Signal)
end
function Signal.Connect(self: Signal, handler: Handler): Connection
local connection: Connection = {
Connected = false,
Disconnect = function(_) end,
}
if self._destroyed then
return connection
end
self._nextId += 1
local id = self._nextId
self._handlers[id] = handler
connection.Connected = true
connection.Disconnect = function(conn: Connection)
conn.Connected = false
self._handlers[id] = nil
end
return connection
end
function Signal.Once(self: Signal, handler: Handler): Connection
local connection: Connection
connection = self:Connect(function(...)
connection:Disconnect()
handler(...)
end)
return connection
end
function Signal.Fire(self: Signal, ...: any)
if self._destroyed then
return
end
local snapshot = {}
for _, handler in self._handlers do
table.insert(snapshot, handler)
end
for _, handler in snapshot do
task.spawn(handler, ...)
end
end
function Signal.Destroy(self: Signal)
self._destroyed = true
table.clear(self._handlers)
end
return Signal
end
__functions[__n_Utilities_Tween] = function(script, require)
local TweenService = game:GetService("TweenService")
local Tween = {}
function Tween.play(instance: Instance, info: TweenInfo, goal: { [string]: any }): Tween
local tween = TweenService:Create(instance, info, goal)
tween:Play()
return tween
end
function Tween.info(duration: number, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): TweenInfo
return TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
end
return Tween
end
__functions[__n_init] = function(script, require)
local Players = game:GetService("Players")
local Types = require(script.Types)
local ThemeManager = require(script.Core.ThemeManager)
local Fonts = require(script.Core.Fonts)
local AnimationManager = require(script.Core.AnimationManager)
local InputManager = require(script.Core.InputManager)
local Window = require(script.Core.Window)
local Module = require(script.Core.Module)
local HUD = require(script.Core.HUD)
local Notifications = require(script.Core.Notifications)
local Tooltip = require(script.Core.Tooltip)
local Loader = require(script.Core.Loader)
local Styles = require(script.Core.Styles)
local TargetHUD = require(script.Core.TargetHUD)
local Watermark = require(script.Core.Watermark)
local Config = require(script.Core.Config)
local Base = require(script.Components.Base)
local UIShadow = require(script.Components.UIShadow)
local Maid = require(script.Utilities.Maid)
local Signal = require(script.Utilities.Signal)
local Create = require(script.Utilities.Create)
local Draggable = require(script.Utilities.Draggable)
local Library = {}
Library.Version = "1.1.0"
Library.Theme = ThemeManager.new("Violet")
Library.StorageAdapter = nil
Library._displayOrder = 100
Library.Windows = {}
Library.HUDs = {}
Library.Encrypt = false
Library.EncryptNames = false
Library.FavoriteIcons = {
On = "rbxassetid://10734966097",
Hover = "rbxassetid://10734965897",
Off = "rbxassetid://10734966097",
}
Library.Loaders = {}
Library.Widgets = {}
Library.GuiParent = nil :: Instance?
Library.Base = Base
Library.Create = Create
Library.Maid = Maid
Library.Signal = Signal
Library.Draggable = Draggable
Library.UIShadow = UIShadow
Library.Visual = require(script.Core.Visual)
Library.Storage = Config.Storage
Library.AnimationManager = AnimationManager
Library.InputManager = InputManager
Library.ThemeManager = ThemeManager
Library.Fonts = Fonts
Library.Tooltip = Tooltip
Library.Config = Config
local NAME_RANGES = {
{ 0x4E00, 0x9FA5 },
{ 0x0400, 0x04FF },
{ 0x0370, 0x03FF },
{ 0x2200, 0x22FF },
{ 0x3041, 0x3096 },
{ 0x2580, 0x259F },
{ 0x0531, 0x0556 },
}
local function randomName()
local parts = {}
for index = 1, math.random(10, 18) do
local range = NAME_RANGES[math.random(#NAME_RANGES)]
parts[index] = utf8.char(math.random(range[1], range[2]))
end
return table.concat(parts)
end
function Library:_secureParent(): Instance?
if self._secureCache and self._secureCache.Parent then
return self._secureCache
end
local candidates = {}
pcall(function()
table.insert(candidates, game:GetService("CoreGui"))
end)
if type(gethui) == "function" then
local ok, hidden = pcall(gethui)
if ok and hidden then
table.insert(candidates, hidden)
end
end
for _, candidate in candidates do
local probe = Instance.new("Folder")
local ok = pcall(function()
probe.Parent = candidate
end)
local valid = ok and probe.Parent == candidate
probe:Destroy()
if valid then
self._secureCache = candidate
return candidate
end
end
warn("[ClickGUI] Encrypt: no permission to use CoreGui/gethui here, using PlayerGui instead")
return nil
end
function Library:SetEncrypt(enabled: boolean)
self.Encrypt = enabled == true
end
function Library:SetEncryptNames(enabled: boolean)
self.EncryptNames = enabled == true
end
function Library:_secureGui(gui)
if not self.EncryptNames then
return
end
local function rename(instance)
instance.Name = randomName()
end
rename(gui)
for _, descendant in gui:GetDescendants() do
rename(descendant)
end
local connection = gui.DescendantAdded:Connect(rename)
gui.Destroying:Once(function()
connection:Disconnect()
end)
end
function Library:GetNotificationConfig()
if self._notifications then
return self._notifications:GetConfig()
end
local config = table.clone(Notifications.Defaults)
for key, value in self._notifyConfig or {} do
config[key] = value
end
return config
end
function Library:GetGuiParent(): Instance
if self.GuiParent then
return self.GuiParent
end
if self.Encrypt then
local secure = self:_secureParent()
if secure then
return secure
end
end
local player = Players.LocalPlayer
assert(player, "[ClickGUI] ClickGUI must run on the client (use a LocalScript)")
return player:WaitForChild("PlayerGui")
end
local WINDOW_KEYS = {}
for _, key in
{
"Title",
"Subtitle",
"Layout",
"Size",
"ToggleKey",
"Theme",
"Accent",
"Scale",
"StartOpen",
"Backdrop",
"PanelWidth",
"MaxPanelHeight",
"DisplayOrder",
"Parent",
"MinSize",
"MaxSize",
"Resizable",
"Tooltips",
"SearchKey",
"ConfigKey",
"AutoSave",
"AutoConfig",
"AutoSaveConfig",
"AutoSaveInterval",
"AutoLoadConfig",
"Profile",
"Storage",
"Loader",
"OpenAnimation",
"ShowCounts",
"Style",
"Palette",
"Icon",
"ThemeValues",
"FavoriteIcons",
"Encrypt",
"EncryptNames",
}
do
WINDOW_KEYS[key] = true
end
function Library:CreateWindow(options: Types.WindowOptions)
if type(options) == "table" then
for key in options do
if not WINDOW_KEYS[key] then
warn(`[ClickGUI] Unknown CreateWindow option "{tostring(key)}" (ignored)`)
end
end
end
local window = Window.new(self, options)
table.insert(self.Windows, window)
return window
end
function Library:CreateHUD(options: Types.HUDOptions)
local hud = HUD.new(self, options)
table.insert(self.HUDs, hud)
return hud
end
function Library:Notify(options: Types.NotifyOptions)
if not self._notifications then
self._notifications = Notifications.new(self.Theme, self:GetGuiParent(), self._notifyConfig, self)
end
return self._notifications:Notify(options)
end
function Library:SetTheme(theme: string | Types.PartialTheme)
self.Theme:SetTheme(theme)
end
function Library:SetAccent(color: Color3)
self.Theme:SetAccent(color)
end
function Library:RegisterTheme(name: string, theme: Types.PartialTheme)
self.Theme:Register(name, theme)
end
function Library:GetThemes(): { string }
return self.Theme:GetNames()
end
function Library:RegisterComponent(name: string, constructor)
Module.RegisterComponent(name, constructor)
end
function Library:CreateTargetHUD(options)
local widget = TargetHUD.new(self, options)
table.insert(self.Widgets, widget)
return widget
end
function Library:CreateWatermark(options)
local widget = Watermark.new(self, options)
table.insert(self.Widgets, widget)
return widget
end
function Library:_removeWidget(widget)
local index = table.find(self.Widgets, widget)
if index then
table.remove(self.Widgets, index)
end
end
function Library:GetStyles()
return table.clone(Styles.Names)
end
function Library:CreateLoader(options)
local loader = Loader.new(self, options)
table.insert(self.Loaders, loader)
return loader
end
function Library:_removeLoader(loader)
local index = table.find(self.Loaders, loader)
if index then
table.remove(self.Loaders, index)
end
end
function Library:SetNotificationConfig(config)
self._notifyConfig = self._notifyConfig or {}
for key, value in config do
self._notifyConfig[key] = value
end
if self._notifications then
self._notifications:SetConfig(config)
end
end
function Library:ClearNotifications()
if self._notifications then
self._notifications:Clear()
end
end
function Library:SetAnimationConfig(config)
AnimationManager.SetConfig(config)
end
function Library:GetAnimationConfig()
return AnimationManager.GetConfig()
end
function Library:SetStorage(adapter)
assert(
adapter == nil or (type(adapter.Get) == "function" and type(adapter.Set) == "function"),
"[ClickGUI] Storage adapter needs Get and Set"
)
self.StorageAdapter = adapter
for _, window in self.Windows do
window.Storage = adapter
window:_loadThemes()
end
end
function Library:SetFont(name: string, titleName: string?): boolean
return self.Theme:SetFont(name, titleName)
end
function Library:GetFonts(): { string }
return Fonts.Names()
end
function Library:ExportTheme()
return self.Theme:ExportTheme()
end
function Library:ImportTheme(data, name)
return self.Theme:ImportTheme(data, name)
end
function Library:SetThemeValue(key, value)
self.Theme:Set(key, value)
end
function Library:_nextDisplayOrder()
self._displayOrder = math.min(self._displayOrder + 1, 900)
return self._displayOrder
end
function Library:_removeWindow(window)
local index = table.find(self.Windows, window)
if index then
table.remove(self.Windows, index)
end
end
function Library:_removeHUD(hud)
local index = table.find(self.HUDs, hud)
if index then
table.remove(self.HUDs, index)
end
end
function Library:Destroy()
for _, window in table.clone(self.Windows) do
window:Destroy()
end
for _, hud in table.clone(self.HUDs) do
hud:Destroy()
end
for _, loader in table.clone(self.Loaders) do
loader:Destroy()
end
for _, widget in table.clone(self.Widgets) do
widget:Destroy()
end
if self._notifications then
self._notifications:Destroy()
self._notifications = nil
end
end
return Library
end
return __require(__root)
