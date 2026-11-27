local Players = game:GetService("Players")
local ClickGUI = require(script.Parent:WaitForChild("ClickGUI"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local previewGui = Instance.new("ScreenGui")
previewGui.Name = "GraphicDemoPreview"
previewGui.ResetOnSpawn = false
previewGui.DisplayOrder = 50
previewGui.Parent = playerGui
local backdrop = Instance.new("Frame")
backdrop.AnchorPoint = Vector2.new(0.5, 1)
backdrop.Position = UDim2.new(0.5, 0, 1, -24)
backdrop.Size = UDim2.fromOffset(360, 64)
backdrop.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
backdrop.BorderSizePixel = 0
backdrop.Parent = previewGui
local preview = Instance.new("Frame")
preview.Size = UDim2.fromScale(1, 1)
preview.BackgroundColor3 = Color3.new(1, 1, 1)
preview.BorderSizePixel = 0
preview.Parent = backdrop
local previewGradient = Instance.new("UIGradient")
previewGradient.Parent = preview
local window = ClickGUI:CreateWindow({ Title = "CreateGraphic Demo", Layout = "Panels" })
local category = window:CreateCategory("Demo")
local module = category:CreateModule({
Name = "CreateGraphic",
Description = "Gradient and Curve editors",
Toggleable = false,
Expanded = true,
})
local ramp = module:CreateGraphic({
Name = "Color Ramp",
Mode = "Gradient",
Flag = "demo_color_ramp",
Tooltip = "Click the bar to add a point, drag to move, right click or Delete to remove",
Default = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 120)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 60)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255)),
}),
Callback = function(sequence)
previewGradient.Color = sequence
end,
})
local fade = module:CreateGraphic({
Name = "Transparency Curve",
Mode = "Curve",
Flag = "demo_transparency",
Tooltip = "Click the panel to add a point, values go from 0 to 1",
Default = NumberSequence.new(0, 1),
Callback = function(sequence)
previewGradient.Transparency = sequence
end,
})
previewGradient.Color = ramp:Get()
previewGradient.Transparency = fade:Get()
module:CreateButton({
Name = "Random Gradient",
Callback = function()
ramp:Set(ColorSequence.new(Color3.fromHSV(math.random(), 1, 1), Color3.fromHSV(math.random(), 1, 1)))
end,
})
module:CreateButton({
Name = "Export then Import",
Callback = function()
local text = window:ExportConfig()
print("[Demo] Config length:", #text)
print("[Demo] ImportConfig:", window:ImportConfig(text))
print("[Demo] Gradient points:", #ramp:Get().Keypoints, "Curve keypoints:", #fade:Get().Keypoints)
end,
})
module:CreateButton({
Name = "Reset Config",
Callback = function()
window:ResetConfig()
end,
})
