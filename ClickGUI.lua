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
local __n_Core_HUD = __newNode("HUD", __n_Core)
local __n_Core_InputManager = __newNode("InputManager", __n_Core)
local __n_Core_Module = __newNode("Module", __n_Core)
local __n_Core_Notifications = __newNode("Notifications", __n_Core)
local __n_Core_Settings = __newNode("Settings", __n_Core)
local __n_Core_ThemeManager = __newNode("ThemeManager", __n_Core)
local __n_Core_Tooltip = __newNode("Tooltip", __n_Core)
local __n_Core_Visual = __newNode("Visual", __n_Core)
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
self:_play(self.Frame, { Size = UDim2.new(1, 0, 0, height) }, true, "Normal")
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
self:_play(self.Frame, { Size = UDim2.new(1, 0, 0, total) }, animated, "Normal")
self:_play(self._list, { Size = UDim2.new(1, 0, 0, listHeight) }, animated, "Normal")
self:_play(self._arrow, { Rotation = self._open and 90 or 0 }, animated, "Normal")
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
animated
)
else
self:_play(self._knob, {
Position = on and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
BackgroundColor3 = on and Color3.new(1, 1, 1) or theme:Get("TextDim"),
}, animated)
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
self.IconColor = options and options.IconColor
self._ctx = ctx
self._visible = true
self.Page = Create("ScrollingFrame", {
Name = "Page_" .. name,
Size = UDim2.fromScale(1, 1),
ScrollBarImageColor3 = theme:Get("Accent"),
})
theme:Bind(self.Page, "ScrollBarImageColor3", "Accent")
self.List = Create("Frame", {
Name = "List",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = self.Page,
})
Create.padding(self.List, 6, 6, 6, 6)
Create.list(self.List, 4)
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
local Config = {}
Config.Version = 2
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
for _, key in { "Flags", "Modules", "Favorites", "Pinned" } do
if type(out[key]) ~= "table" then
out[key] = {}
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
end
return ok
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
__functions[__n_Core_HUD] = function(script, require)
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
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
BackgroundTransparency = options.BackgroundTransparency or 0.45,
BackgroundColor = options.BackgroundColor or Color3.new(0, 0, 0),
AccentBar = options.AccentBar or "Right",
ColorMode = options.ColorMode or "Gradient",
StaticColor = options.StaticColor or Color3.new(1, 1, 1),
GradientFrom = options.GradientFrom,
GradientTo = options.GradientTo,
GradientSpeed = options.GradientSpeed or 0,
ShowInfo = options.ShowInfo ~= false,
Font = options.Font,
Spacing = options.Spacing or 0,
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
return TextService:GetTextSize(text, size, font, Vector2.new(1000, 1000)).X
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
self.Gui.DisplayOrder = editable and 950 or self._baseOrder
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
self._defaultEnabled = options.Default == true and self.Toggleable
self._iconActive = options.IconActiveColor
self._iconInactive = options.IconInactiveColor
local hasDescription = options.Description ~= nil and options.Description ~= ""
local headerHeight = hasDescription and HEADER_HEIGHT_WITH_DESCRIPTION or HEADER_HEIGHT
local iconSize = options.IconSize or 14
local leftPad = options.Icon and (10 + iconSize + 6) or 12
self.Frame = Create("Frame", {
Name = "Module_" .. options.Name,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundColor3 = theme:Get("Module"),
LayoutOrder = orderCounter,
Parent = category.List,
})
Visual.surface(theme, self.Frame, "module", 0.08)
Create.list(self.Frame, 0)
self._header = Create("TextButton", {
Name = "Header",
Size = UDim2.new(1, 0, 0, headerHeight),
LayoutOrder = 1,
Parent = self.Frame,
})
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
if options.Icon then
self._icon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
Size = UDim2.fromOffset(iconSize, iconSize),
Image = options.Icon,
ImageColor3 = theme:Get("TextDim"),
Parent = self._header,
})
end
self._nameLabel = Create("TextLabel", {
Name = "Name",
Position = UDim2.fromOffset(leftPad, hasDescription and 5 or 0),
Size = UDim2.new(1, -(leftPad + 74), 0, hasDescription and 18 or headerHeight),
Text = options.Name,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Font = theme:Get("Font"),
TextColor3 = theme:Get("Text"),
Parent = self._header,
})
theme:Bind(self._nameLabel, "Font", "Font")
if hasDescription then
self._descLabel = Create("TextLabel", {
Name = "Description",
Position = UDim2.fromOffset(leftPad, 23),
Size = UDim2.new(1, -(leftPad + 74), 0, 14),
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
self._favMark = Create("Frame", {
Name = "Favorite",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -6, 0, 6),
Size = UDim2.fromOffset(6, 6),
Rotation = 45,
BackgroundColor3 = theme:Get("Warning"),
Visible = false,
Parent = self._header,
})
theme:Bind(self._favMark, "BackgroundColor3", "Warning")
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
if self.Toggleable then
self._track = Create("Frame", {
Name = "Switch",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.fromOffset(28, 14),
BackgroundColor3 = theme:Get("Element"),
Parent = self._header,
})
Create.pill(self._track)
self._knob = Create("Frame", {
Name = "Knob",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 2, 0.5, 0),
Size = UDim2.fromOffset(10, 10),
BackgroundColor3 = theme:Get("TextDim"),
Parent = self._track,
})
Create.pill(self._knob)
end
self._chevronButton = Create("TextButton", {
Name = "Expand",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, self.Toggleable and -42 or -8, 0.5, 0),
Size = UDim2.fromOffset(24, 24),
Text = "›",
TextSize = 20,
TextColor3 = theme:Get("TextDim"),
Visible = false,
Parent = self._header,
})
theme:Bind(self._chevronButton, "TextColor3", "TextDim")
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
BackgroundTransparency = 0.5,
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
self._maid:Give(self._header.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton3 then
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
self:SetPinned(not self._pinned)
else
self:SetFavorite(not self._favorite)
end
end
end))
self._maid:Give(self._chevronButton.MouseButton1Click:Connect(function()
self:ToggleExpanded()
end))
self._maid:Give(self._header.MouseEnter:Connect(function()
self._hovered = true
self:_render(true)
end))
self._maid:Give(self._header.MouseLeave:Connect(function()
self._hovered = false
self:_render(true)
end))
self._maid:Give(self._inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
self:_updateHeight()
end))
self._maid:Give(theme.Changed:Connect(function()
self:_render(true)
end))
self:_render(false)
if options.Tooltip then
self:SetTooltip(options.Tooltip)
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
elseif options.Keybind then
self._maid:Give(ctx.Input:BindKey(options.Keybind, function()
self:Toggle()
end))
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
AnimationManager.Play(self._bar, preset, { BackgroundTransparency = enabled and 0 or 1, BackgroundColor3 = accent })
AnimationManager.Play(
self._glow,
preset,
{ BackgroundTransparency = enabled and 0.82 or 1, BackgroundColor3 = accent }
)
AnimationManager.Play(self._nameLabel, preset, {
TextColor3 = (enabled or not self.Toggleable) and theme:Get("Text")
or theme:Get("TextDim"):Lerp(theme:Get("Text"), hovered and 0.6 or 0.25),
})
if self._icon then
local active = self._iconActive or accent
local inactive = self._iconInactive or theme:Get("TextDim")
AnimationManager.Play(
self._icon,
preset,
{ ImageColor3 = (enabled or not self.Toggleable) and active or inactive }
)
end
if self._track then
AnimationManager.Play(self._track, preset, { BackgroundColor3 = enabled and accent or theme:Get("Element") })
AnimationManager.Play(self._knob, preset, {
Position = enabled and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
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
AnimationManager.Play(self._clip, self._animating and "Normal" or "Instant", { Size = UDim2.new(1, 0, 0, target) })
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
function Module:SetFavorite(value: boolean)
value = not not value
if value == self._favorite then
return
end
self._favorite = value
self._favMark.Visible = value
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
function Module:SetIcon(image: string?)
if self._icon then
self._icon.Image = image or ""
end
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
AnimationManager.Play(self._chevronButton, "Normal", { Rotation = expanded and 90 or 0 })
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
local Utilities = script.Parent.Parent.Utilities
local Types = require(script.Parent.Parent.Types)
local AnimationManager = require(script.Parent.AnimationManager)
local Create = require(Utilities.Create)
local Maid = require(Utilities.Maid)
local MAX_VISIBLE = 5
local WIDTH = 270
local Notifications = {}
Notifications.__index = Notifications
function Notifications.new(theme, parent: Instance)
local self = setmetatable({}, Notifications)
self._theme = theme
self._maid = Maid.new()
self._active = {}
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_Notifications",
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = 1000,
Parent = parent,
})
self._maid:Give(self.Gui)
local container = Create("Frame", {
Name = "Container",
AnchorPoint = Vector2.new(1, 1),
Position = UDim2.new(1, -16, 1, -16),
Size = UDim2.new(0, WIDTH, 1, -32),
BackgroundTransparency = 1,
Parent = self.Gui,
})
local layout = Create.list(container, 8)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
self._container = container
return self
end
local function typeColor(theme, kind: string): Color3
if kind == "Success" then
return theme:Get("Success")
elseif kind == "Warning" then
return theme:Get("Warning")
elseif kind == "Error" then
return theme:Get("Error")
end
return theme:Get("Info")
end
function Notifications.Notify(self, options: Types.NotifyOptions)
assert(type(options) == "table" and options.Content ~= nil, "[ClickGUI] Notify needs a `Content` string")
local theme = self._theme
local color = typeColor(theme, options.Type or "Info")
local duration = math.max(options.Duration or 4, 0.5)
self._counter = (self._counter or 0) + 1
while #self._active >= MAX_VISIBLE do
self._active[1].Dismiss()
end
local holder = Create("Frame", {
Name = "Notification",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
LayoutOrder = self._counter,
Parent = self._container,
})
local card = Create("CanvasGroup", {
Name = "Card",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Position = UDim2.fromOffset(40, 0),
GroupTransparency = 1,
BackgroundColor3 = theme:Get("Panel"),
Parent = holder,
})
Create.corner(card, 8)
Create.stroke(card, theme:Get("Stroke"), 1, 0.2)
Create("Frame", { Name = "Bar", Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = color, Parent = card })
local content = Create("Frame", {
Name = "Content",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = card,
})
Create.padding(content, 9, 12, 12, 14)
Create.list(content, 3)
local order = 1
if options.Title and options.Title ~= "" then
Create("TextLabel", {
Name = "Title",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Text = options.Title,
TextSize = 13,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = Enum.TextXAlignment.Left,
TextWrapped = true,
LayoutOrder = order,
Parent = content,
})
order += 1
end
Create("TextLabel", {
Name = "Body",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Text = tostring(options.Content),
TextSize = 12,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
LayoutOrder = order,
Parent = content,
})
local progress = Create("Frame", {
Name = "Progress",
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1),
Size = UDim2.new(1, 0, 0, 2),
BackgroundColor3 = color,
BackgroundTransparency = 0.3,
Parent = card,
})
local clickArea =
Create("TextButton", { Name = "Dismiss", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })
local handle = { Dismissed = false }
local function dismiss()
if handle.Dismissed then
return
end
handle.Dismissed = true
local index = table.find(self._active, handle)
if index then
table.remove(self._active, index)
end
if not holder.Parent then
return
end
local height = holder.AbsoluteSize.Y
holder.AutomaticSize = Enum.AutomaticSize.None
holder.Size = UDim2.new(1, 0, 0, height)
AnimationManager.Play(card, "Normal", { GroupTransparency = 1, Position = UDim2.fromOffset(40, 0) })
task.delay(0.2, function()
if holder.Parent then
AnimationManager.Play(holder, "Fast", { Size = UDim2.new(1, 0, 0, 0) })
end
end)
task.delay(0.4, function()
holder:Destroy()
end)
end
handle.Dismiss = dismiss
table.insert(self._active, handle)
clickArea.MouseButton1Click:Connect(dismiss)
AnimationManager.Play(card, "Normal", { GroupTransparency = 0, Position = UDim2.new() })
AnimationManager.Play(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
task.delay(duration, dismiss)
return handle
end
function Notifications.Destroy(self)
self._maid:Clean()
table.clear(self._active)
end
return Notifications
end
__functions[__n_Core_Settings] = function(script, require)
local Config = require(script.Parent.Config)
local ThemeManager = require(script.Parent.ThemeManager)
local AnimationManager = require(script.Parent.AnimationManager)
local Settings = {}
local FONTS = {
"Gotham",
"GothamMedium",
"GothamSemibold",
"GothamBold",
"SourceSans",
"SourceSansSemibold",
"Ubuntu",
"Code",
"Roboto",
"Arial",
"Fredoka",
}
local function round(value, step)
return math.floor(value / step + 0.5) * step
end
function Settings.build(window, name, options)
local sections = options.Sections or { "Interface", "Appearance", "Animations", "HUD", "Config" }
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
m:CreateSearchableDropdown({
Name = "Theme",
Options = theme:GetNames(),
Default = current.Name,
Tooltip = "Switch the color palette",
Callback = function(value)
window:SetTheme(value)
end,
})
m:CreateColorPicker({
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
m:CreateToggle({
Name = "Favorites Only",
Default = window:IsFavoritesOnly(),
Tooltip = "Middle-click a module to favorite it (Shift + middle-click pins it)",
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
local m = newModule("Appearance", "Borders, gradients, shadows")
m:CreateSlider({
Name = "Corner Radius",
Min = 0,
Max = 16,
Default = current.CornerRadius,
Callback = function(value)
window:SetThemeValue("CornerRadius", value)
end,
})
m:CreateSlider({
Name = "Transparency",
Min = 0,
Max = 60,
Default = math.floor(current.Transparency * 100 + 0.5),
Suffix = "%",
Callback = function(value)
window:SetThemeValue("Transparency", value / 100)
end,
})
m:CreateToggle({
Name = "Borders",
Default = current.Border,
Callback = function(value)
window:SetThemeValue("Border", value)
end,
})
m:CreateSlider({
Name = "Border Thickness",
Min = 0,
Max = 4,
Default = current.BorderThickness,
Increment = 0.5,
Callback = function(value)
window:SetThemeValue("BorderThickness", value)
end,
})
m:CreateSlider({
Name = "Border Opacity",
Min = 0,
Max = 100,
Default = math.floor((1 - current.BorderTransparency) * 100 + 0.5),
Increment = 5,
Suffix = "%",
Callback = function(value)
window:SetThemeValue("BorderTransparency", 1 - value / 100)
end,
})
m:CreateToggle({
Name = "Gradients",
Default = current.Gradients,
Callback = function(value)
window:SetThemeValue("Gradients", value)
end,
})
m:CreateSlider({
Name = "Gradient Angle",
Min = 0,
Max = 360,
Default = current.GradientRotation,
Increment = 15,
Suffix = "°",
Callback = function(value)
window:SetThemeValue("GradientRotation", value)
end,
})
m:CreateColorPicker({
Name = "Accent 2",
Default = current.AccentDark,
Tooltip = "Second color used in accent gradients",
Callback = function(color)
window:SetThemeValue("AccentDark", color)
end,
})
m:CreateColorPicker({
Name = "Panel Color",
Default = current.Panel,
Callback = function(color)
window:SetThemeValue("Panel", color)
end,
})
m:CreateColorPicker({
Name = "Module Color",
Default = current.Module,
Callback = function(color)
window:SetThemeValue("Module", color)
end,
})
m:CreateDropdown({
Name = "Shadow",
Options = { "Off", "Soft", "Medium", "Strong" },
Default = current.ShadowPreset,
Callback = function(value)
window:SetThemeValue("ShadowPreset", value)
end,
})
m:CreateSlider({
Name = "Shadow Opacity",
Min = 0,
Max = 100,
Default = math.floor(current.ShadowOpacity * 100 + 0.5),
Increment = 5,
Suffix = "%",
Callback = function(value)
window:SetThemeValue("ShadowOpacity", value / 100)
end,
})
m:CreateColorPicker({
Name = "Shadow Color",
Default = current.ShadowColor,
Callback = function(color)
window:SetThemeValue("ShadowColor", color)
end,
})
m:CreateSearchableDropdown({
Name = "Font",
Options = FONTS,
Default = current.Font.Name,
Callback = function(value)
local ok, font = pcall(function()
return Enum.Font[value]
end)
if ok and font then
window:SetThemeValue("Font", font)
end
end,
})
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
if wanted.Config then
local m = newModule("Config", "Save, load and share")
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
return category, modules
end
return Settings
end
__functions[__n_Core_ThemeManager] = function(script, require)
local Types = require(script.Parent.Parent.Types)
local Signal = require(script.Parent.Parent.Utilities.Signal)
local AnimationManager = require(script.Parent.AnimationManager)
type Theme = Types.Theme
local ThemeManager = {}
ThemeManager.__index = ThemeManager
type ThemeManager = typeof(setmetatable(
{} :: {
Current: Theme,
Changed: Signal.Signal,
_presets: { [string]: Theme },
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
BorderTransparency = 0.35,
Gradients = true,
GradientRotation = 90,
ShadowPreset = "Medium",
ShadowOpacity = 0.45,
ShadowColor = Color3.new(0, 0, 0),
Font = Enum.Font.GothamMedium,
FontBold = Enum.Font.GothamBold,
}
local function derive(name: string, overrides: Types.PartialTheme): Theme
local theme: any = table.clone(BASE)
for key, value in overrides do
theme[key] = value
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
local self: ThemeManager = setmetatable({
Current = presets.Violet,
Changed = Signal.new(),
_presets = presets,
_initial = presets.Violet,
_bindings = setmetatable({}, { __mode = "k" }) :: any,
}, ThemeManager)
if initial ~= nil then
self:SetTheme(initial, true)
end
self._initial = self.Current
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
if animated and isTweenable(value) then
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
function ThemeManager._refresh(self: ThemeManager)
for instance, map in self._bindings do
for property, key in map do
applyValue(instance, property, resolveKey(self, key), true)
end
end
self.Changed:Fire(self.Current)
end
function ThemeManager.Set(self: ThemeManager, key: string, value: any)
assert((BASE :: any)[key] ~= nil, `[ClickGUI] Unknown theme field "{key}"`)
local theme: any = table.clone(self.Current)
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
elseif kind == "EnumItem" then
out[key] = value.Name
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
elseif kind == "EnumItem" and type(value) == "string" then
local ok, item = pcall(function()
return (Enum.Font :: any)[value]
end)
if ok and item then
out[key] = item
end
elseif base ~= nil and type(base) == type(value) then
out[key] = value
end
end
return out
end
function ThemeManager.ExportTheme(self: ThemeManager): { [string]: any }
return ThemeManager.Serialize(self.Current)
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
function ThemeManager.Destroy(self: ThemeManager)
self.Changed:Destroy()
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
Visual.surface(theme, self._canvas, "module")
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
local font = self._theme:Get("Font")
local bounds = TextService:GetTextSize(text, 12, font, Vector2.new(220, 1000))
self._label.Text = text
self._w, self._h = bounds.X + 18, bounds.Y + 12
self.Frame.Size = UDim2.fromOffset(self._w, self._h)
self.Frame.Visible = true
self:_place(position)
self._shown = true
AnimationManager.Play(self._canvas, "Instant", { Position = UDim2.fromOffset(0, 6) })
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
theme:Bind(stroke, "Color", "Stroke")
theme:Bind(stroke, "Thickness", function(t)
return t.Border and t.BorderThickness or 0
end)
theme:Bind(stroke, "Transparency", function(t)
return math.clamp(t.BorderTransparency + (extraTransparency or 0), 0, 1)
end)
return stroke
end
function Visual.gradient(theme, parent, strength, rotationOffset)
local gradient = Instance.new("UIGradient")
gradient.Parent = parent
theme:Bind(gradient, "Color", function()
return ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - strength, 1 - strength, 1 - strength))
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
return ColorSequence.new(t.Accent, t.AccentDark)
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
gradient.Transparency = NumberSequence.new(1 - strength, 1)
gradient.Parent = sheen
theme:Bind(gradient, "Rotation", "GradientRotation")
theme:Bind(gradient, "Enabled", "Gradients")
return sheen
end
function Visual.surface(theme, instance, kind, strength)
Visual.corner(theme, instance, kind == "module" and -2 or 0)
local stroke = Visual.stroke(theme, instance, kind == "module" and 0.3 or 0)
if strength and strength > 0 then
if instance:IsA("CanvasGroup") then
Visual.sheen(theme, instance, strength)
else
Visual.gradient(theme, instance, strength)
end
end
return stroke
end
return Visual
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
local Visual = require(script.Parent.Visual)
local ThemeManager = require(script.Parent.ThemeManager)
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
self._searchKey = options.SearchKey == nil and Enum.KeyCode.F or options.SearchKey
self._configKey = options.ConfigKey or self.Title
self._autoSave = options.AutoSave == true
self.Storage = options.Storage or library.StorageAdapter
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
self.Gui = Create("ScreenGui", {
Name = "ClickGUI_" .. self.Title,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
DisplayOrder = options.DisplayOrder or 100,
Parent = options.Parent or library:GetGuiParent(),
})
self._maid:Give(self.Gui)
self.Root = Create(
"Frame",
{ Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Gui }
)
self._backdrop = Create("Frame", {
Name = "Backdrop",
Size = UDim2.fromScale(1, 1),
BackgroundColor3 = Color3.new(0, 0, 0),
BackgroundTransparency = 1,
Active = self._backdropEnabled,
Parent = self.Root,
})
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
self:_applyShadows()
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
if options.StartOpen ~= false then
task.defer(function()
if not self._destroyed then
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
function Window:_createSearchBox(parent, size, position, anchor)
local theme = self.Theme
local frame = Create("Frame", {
Name = "Search",
AnchorPoint = anchor,
Position = position,
Size = size,
BackgroundColor3 = theme:Get("Element"),
Parent = parent,
})
Visual.corner(theme, frame, -2)
theme:Bind(frame, "BackgroundColor3", "Element")
local box = Create("TextBox", {
Name = "Box",
Position = UDim2.fromOffset(10, 0),
Size = UDim2.new(1, -34, 1, 0),
PlaceholderText = "Search modules...",
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
Visual.surface(theme, canvas, "panel", 0.14)
self:_applyShadows()
return holder, canvas, shadow
end
function Window:_accentLine(parent, position)
local line = Create("Frame", {
Name = "AccentLine",
Position = position,
Size = UDim2.new(1, 0, 0, 2),
BackgroundColor3 = Color3.new(1, 1, 1),
ZIndex = 5,
Parent = parent,
})
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
function Window:_buildPanelsExtras()
local holder = Create("Frame", {
Name = "SearchHolder",
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 16),
Size = UDim2.fromOffset(250, 30),
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
Visual.surface(self.Theme, canvas, "panel", 0.2)
self:_createSearchBox(canvas, UDim2.new(1, -8, 1, -8), UDim2.fromOffset(4, 4), Vector2.zero)
self._searchHolder = { Canvas = canvas }
self:_createEmptyLabel(self.Container, {
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 56),
Size = UDim2.fromOffset(240, 30),
BackgroundTransparency = 1,
})
end
function Window:_sidebarWidth()
return math.clamp(math.floor(self.Size.X.Offset * 0.23), 120, 190)
end
function Window:_layoutSidebar()
local sidebar = self._sidebar
if not sidebar then
return
end
local width = self:_sidebarWidth()
sidebar.Frame.Size = UDim2.new(0, width, 1, -TITLEBAR_HEIGHT)
sidebar.Content.Position = UDim2.fromOffset(width, TITLEBAR_HEIGHT)
sidebar.Content.Size = UDim2.new(1, -width, 1, -TITLEBAR_HEIGHT)
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
function Window:_buildSidebar()
local theme = self.Theme
local holder, canvas, shadow =
self:_createSurface("Window", self.Size, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
self._sidebar = { Holder = holder, Canvas = canvas, Shadow = shadow }
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
self:_accentLine(canvas, UDim2.fromOffset(0, TITLEBAR_HEIGHT - 1))
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
{ Name = "Tabs", Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, Parent = sidebar }
)
Create.padding(tabs, 8, 8, 8, 8)
Create.list(tabs, 4)
self._sidebar.Frame = sidebar
self._sidebar.Tabs = tabs
local content =
Create("Frame", { Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true, Parent = canvas })
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
function Window:_createTab(category)
local theme = self.Theme
local tabs = self._sidebar.Tabs
local button = Create("TextButton", {
Name = "Tab_" .. category.Name,
Size = UDim2.new(1, 0, 0, 32),
BackgroundColor3 = theme:Get("Element"),
BackgroundTransparency = 1,
LayoutOrder = #self.Categories,
Parent = tabs,
})
Visual.corner(theme, button, -2)
local bar = Create("Frame", {
Name = "Bar",
Position = UDim2.new(0, 0, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Size = UDim2.new(0, 3, 0, 16),
BackgroundColor3 = theme:Get("Accent"),
BackgroundTransparency = 1,
Parent = button,
})
Create.pill(bar)
local labelX = 14
local icon
if category.Icon then
icon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 12, 0.5, 0),
Size = UDim2.fromOffset(category.IconSize, category.IconSize),
Image = category.Icon,
Parent = button,
})
labelX = 12 + category.IconSize + 8
end
local label = Create("TextLabel", {
Name = "Label",
Position = UDim2.fromOffset(labelX, 0),
Size = UDim2.new(1, -labelX - 6, 1, 0),
Text = category.Name,
TextSize = 13,
Font = theme:Get("Font"),
TextColor3 = theme:Get("TextDim"),
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = button,
})
local tab = { Category = category, Button = button, Bar = bar, Label = label, Icon = icon, Hovered = false }
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
category.Page.Parent = self._sidebar.Content
category.Page.Visible = false
if not self._selected then
self:SelectCategory(category)
end
self:_renderTabs(false)
end
function Window:_renderTabs(animated)
local theme = self.Theme
local preset = animated and "Fast" or "Instant"
for category, tab in self._tabs do
local selected = category == self._selected
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
AnimationManager.Play(
tab.Icon,
preset,
{ ImageColor3 = selected and (category.IconColor or theme:Get("Accent")) or theme:Get("TextDim") }
)
end
end
end
function Window:_updatePages()
for _, category in self.Categories do
category.Page.Visible = self._query == "" and category == self._selected
end
if self._sidebar then
self._sidebar.SearchPage.Visible = self._query ~= ""
end
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
self:_updateEmpty()
self:_queueSave()
end
function Window:_createPanel(category)
local theme = self.Theme
local width = self._panelWidth or self._defaultPanelWidth
local holder, canvas, shadow = self:_createSurface(
"Panel_" .. category.Name,
UDim2.fromOffset(width, HEADER_HEIGHT),
UDim2.fromOffset(20, 70),
Vector2.zero
)
local record =
{ Category = category, Holder = holder, Canvas = canvas, Shadow = shadow, Collapsed = false, Width = width }
local header = Create("Frame", {
Name = "Header",
Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
BackgroundColor3 = theme:Get("Header"),
Active = true,
Parent = canvas,
})
theme:Bind(header, "BackgroundColor3", "Header")
Visual.gradient(theme, header, 0.25)
local titleOffset = 0
if category.Icon then
record.Icon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
Size = UDim2.fromOffset(category.IconSize, category.IconSize),
Image = category.Icon,
ImageColor3 = category.IconColor or theme:Get("Accent"),
Parent = header,
})
if not category.IconColor then
theme:Bind(record.Icon, "ImageColor3", "Accent")
end
titleOffset = category.IconSize + 10
end
local title = Create("TextLabel", {
Name = "Title",
Position = UDim2.fromOffset(10 + titleOffset, 0),
Size = UDim2.new(1, -44 - titleOffset, 1, 0),
Text = category.Name,
TextSize = 14,
Font = theme:Get("FontBold"),
TextColor3 = theme:Get("Text"),
TextXAlignment = category.Icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = header,
})
theme:Bind(title, "TextColor3", "Text")
theme:Bind(title, "Font", "FontBold")
local chevron = Create("TextButton", {
Name = "Collapse",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -6, 0.5, 0),
Size = UDim2.fromOffset(26, 26),
Text = "›",
TextSize = 20,
Rotation = 90,
TextColor3 = theme:Get("TextDim"),
Parent = header,
})
theme:Bind(chevron, "TextColor3", "TextDim")
record.Chevron = chevron
category.Page.Position = UDim2.fromOffset(0, HEADER_HEIGHT)
category.Page.Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT)
category.Page.Parent = canvas
category.Page.Visible = true
self:_accentLine(canvas, UDim2.new(0, 0, 1, -2))
record.Resize = function(animated)
if self._destroyed then
return
end
local content = category.List.AbsoluteSize.Y / math.max(self._scale, 0.01)
local body = record.Collapsed and 0 or math.min(content, self._maxPanelHeight)
AnimationManager.Play(
holder,
animated and "Normal" or "Instant",
{ Size = UDim2.fromOffset(record.Width, HEADER_HEIGHT + body) }
)
end
self._maid:Give(category.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
record.Resize(false)
end))
self._maid:Give(chevron.MouseButton1Click:Connect(function()
self:_setCollapsed(record, not record.Collapsed, true)
self:_queueSave()
end))
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
local contentHeight = self._maxPanelHeight + HEADER_HEIGHT + 130
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
function Window:_animate(opening: boolean, token: number)
local backdropTarget = (opening and self._backdropEnabled) and BACKDROP_TRANSPARENCY or 1
AnimationManager.Play(self._backdrop, "Normal", { BackgroundTransparency = backdropTarget })
for index, target in self:_animTargets() do
local canvas, shadow = target.Canvas, target.Shadow
if opening then
AnimationManager.Play(canvas, "Instant", { GroupTransparency = 1, Position = UDim2.fromOffset(0, 16) })
if shadow then
AnimationManager.Play(shadow.Instance, "Instant", { GroupTransparency = 1 })
end
end
local function run()
if self._token ~= token or self._destroyed then
return
end
AnimationManager.Play(canvas, "Normal", {
GroupTransparency = opening and 0 or 1,
Position = opening and UDim2.new() or UDim2.fromOffset(0, 10),
})
if shadow then
AnimationManager.Play(shadow.Instance, "Normal", { GroupTransparency = opening and 0 or 1 })
end
end
if opening and index > 1 and AnimationManager.Config.Enabled then
task.delay((index - 1) * 0.03 / AnimationManager.Config.Speed, run)
else
run()
end
end
if not opening then
task.delay(AnimationManager.Time(0.3), function()
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
function Window:SetBackdrop(enabled: boolean)
self._backdropEnabled = enabled
self._backdrop.Active = enabled
if self._open then
AnimationManager.Play(
self._backdrop,
"Normal",
{ BackgroundTransparency = enabled and BACKDROP_TRANSPARENCY or 1 }
)
end
end
function Window:SetTooltipsEnabled(enabled: boolean)
self.Tooltip:SetEnabled(enabled)
end
function Window:SetTheme(theme: string | Types.PartialTheme)
self.Theme:SetTheme(theme)
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
end
function Window:_storageKey(suffix)
return "ClickGUI/" .. self._configKey .. "/" .. suffix
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
for flag, component in self.Flags do
data.Flags[flag] = component:Serialize()
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
function Window:SaveConfig(): boolean
if not self.Storage then
return false
end
return Config.write(self.Storage, self:_storageKey("config"), self:ExportConfig())
end
function Window:LoadConfig(): boolean
local text = Config.read(self.Storage, self:_storageKey("config"))
if not text then
return false
end
return self:ImportConfig(text)
end
function Window:ResetConfig()
for _, module in self.Modules do
for _, component in module.Components do
if component._default ~= nil then
pcall(component.Deserialize, component, component._default)
end
end
module:SetEnabled(module._defaultEnabled)
module:SetFavorite(false)
module:SetPinned(false)
end
self.Theme:Restore()
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
function Window:Destroy()
if self._destroyed then
return
end
self._saveToken += 1
if self._open then
self._unlock.Modal = false
end
for hud in table.clone(self._huds) do
hud:Detach(self)
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
BorderTransparency: number,
Gradients: boolean,
GradientRotation: number,
ShadowPreset: string,
ShadowOpacity: number,
ShadowColor: Color3,
Font: Enum.Font,
FontBold: Enum.Font,
}
type PartialTheme = { [string]: any }
type Layout = "Panels" | "Sidebar"
type StorageAdapter = {
Get: (self: StorageAdapter, key: string) -> string?,
Set: (self: StorageAdapter, key: string, value: string) -> (),
Remove: ((self: StorageAdapter, key: string) -> ())?,
}
type WindowOptions = {
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
type NotifyType = "Info" | "Success" | "Warning" | "Error"
type NotifyOptions = {
Title: string?,
Content: string,
Duration: number?,
Type: NotifyType?,
}
type HUDPosition = "TopLeft" | "TopRight" | "BottomLeft" | "BottomRight"
type HUDOptions = {
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
local AnimationManager = require(script.Core.AnimationManager)
local InputManager = require(script.Core.InputManager)
local Window = require(script.Core.Window)
local Module = require(script.Core.Module)
local HUD = require(script.Core.HUD)
local Notifications = require(script.Core.Notifications)
local Tooltip = require(script.Core.Tooltip)
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
Library.GuiParent = nil :: Instance?
Library.Base = Base
Library.Create = Create
Library.Maid = Maid
Library.Signal = Signal
Library.Draggable = Draggable
Library.UIShadow = UIShadow
Library.Storage = Config.Storage
Library.AnimationManager = AnimationManager
Library.InputManager = InputManager
Library.ThemeManager = ThemeManager
Library.Tooltip = Tooltip
Library.Config = Config
function Library:GetGuiParent(): Instance
if self.GuiParent then
return self.GuiParent
end
local player = Players.LocalPlayer
assert(player, "[ClickGUI] ClickGUI must run on the client (use a LocalScript)")
return player:WaitForChild("PlayerGui")
end
function Library:CreateWindow(options: Types.WindowOptions)
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
self._notifications = Notifications.new(self.Theme, self:GetGuiParent())
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
end
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
if self._notifications then
self._notifications:Destroy()
self._notifications = nil
end
end
return Library
end
return __require(__root)
