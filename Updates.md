local ClickGUI = require(script.Parent:WaitForChild("ClickGUI"))
local STYLE = "Slate"
local LAYOUT = "Panels"
local window = ClickGUI:CreateWindow({
Title = "Styles Demo",
Subtitle = "Slate and Mist",
Style = STYLE,
Layout = LAYOUT,
})
local function fill(category, names)
for index, name in names do
local module = category:CreateModule({
Name = name,
Description = "Short description for " .. name,
Keybind = index == 1 and Enum.KeyCode.R or nil,
Default = index == 2,
})
module:CreateToggle({ Name = "Enabled option", Default = true })
module:CreateSlider({ Name = "Range", Min = 0, Max = 20, Default = 6, Increment = 0.5, Suffix = " st" })
module:CreateDropdown({ Name = "Mode", Options = { "Nearest", "Head", "Body" }, Default = "Nearest" })
module:CreateColorPicker({ Name = "Color", Default = Color3.fromRGB(140, 160, 220) })
module:CreateKeybind({ Name = "Bind" })
end
end
fill(window:CreateCategory("Combat", { Group = "Gameplay" }), { "Aim Assist", "Trigger", "Auto Clicker", "Velocity" })
fill(window:CreateCategory("Movement", { Group = "Gameplay" }), { "Sprint", "Fly", "Step" })
fill(window:CreateCategory("Visuals", { Group = "Render" }), { "ESP", "Tracers", "Fullbright", "Zoom" })
fill(window:CreateCategory("Misc", { Group = "Render" }), { "Spammer", "Panic" })
window:CreateSettingsCategory("Settings")
