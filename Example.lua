--[[
	EJEMPLO COMPLETO DE ClickGUI (usa TODAS las funciones de la libreria)

	Carga:  loadstring(game:HttpGet(URL))()
	Cambia LAYOUT entre "Panels" y "Sidebar" para ver los dos disenos.
	Tecla para abrir/cerrar: RightShift.   Ctrl+F enfoca la busqueda.
	Click del medio en un modulo = favorito, Shift + click del medio = fijado (pinned).
]]

local URL = "https://raw.githubusercontent.com/ELPAPIMC/ClickGui/refs/heads/main/ClickGUI.lua"
local ClickGUI = loadstring(game:HttpGet(URL))()

-- ============================================================================
-- ESTILOS (Style) - el aspecto de la GUI. Se elige al crear la ventana.
-- ============================================================================
--   "Classic" : tarjetas con degradado y switch (el estilo original)
--   "Flat"    : como las capturas de paneles oscuros: filas planas sin tarjetas, el modulo activo
--               queda resaltado, la tecla se ve como [R], puntitos si tiene ajustes (click), barra de
--               colores arriba (Palette) y buscador en forma de pildora abajo. Combina con tema "Mocha" o "Ink".
--   "Glass"   : ventana tipo "Prestige" (con Layout = "Sidebar"): barra lateral con logo, secciones
--               (Group), contador por categoria, titulo grande "<Categoria> Modules", buscador arriba a la
--               derecha y tarjetas grandes con descripcion + chevron + switch. Combina con tema "Midnight".
-- Los layouts siguen siendo solo dos: "Panels" y "Sidebar". El estilo cambia su apariencia.
-- Temas incluidos: Violet, Ocean, Crimson, Emerald, Sunset, Rose, Mocha, Midnight, Ink, Mono, Light (+ los tuyos)
local LAYOUT = "Panels"
local STYLE = "Flat" -- "Classic" | "Flat" | "Glass"
local THEME = "Mocha"

-- ============================================================================
-- COMO FUNCIONAN LOS ICONOS (Icon = ...)
-- ============================================================================
-- Category:  { Icon = ..., IconSize = 16, IconColor = Color3 }   -> sale en el encabezado del panel / pestana del sidebar
-- Module:    { Icon = ..., IconSize = 14, IconActiveColor, IconInactiveColor } -> sale a la izquierda del nombre del modulo
--
-- "Icon" acepta 3 formas (usa la que prefieras):
--   1) Emoji o texto corto, SIN assets:   Icon = "⚔"   Icon = "🏃"   Icon = "★"   Icon = "FX"
--   2) Numero de un asset de IMAGEN:      Icon = 7733715400
--   3) Texto "rbxassetid://ID":           Icon = "rbxassetid://7733715400"
-- IMPORTANTE: para imagenes necesitas el ID de la IMAGEN (Creator Hub > Assets > Images),
-- no el ID de un Decal. Los emojis/texto cambian de color con IconColor / IconActiveColor;
-- los emojis a color mantienen su color original.
-- Despues puedes cambiarlo: Module:SetIcon("🔥")
local ICON = "⚔" -- cambia por un emoji, un numero o "rbxassetid://..."

-- ============================================================================
-- 1. CONFIGURACION GLOBAL (antes de crear ventanas)
-- ============================================================================

-- 1.1 Animaciones: Enabled (global), Speed (0.1 - 5), Preset: Smooth | Snappy | Bouncy | Soft | Linear
ClickGUI:SetAnimationConfig({ Enabled = true, Speed = 1, Preset = "Smooth" })
print("Animaciones:", ClickGUI:GetAnimationConfig().Preset)

-- 1.2 Almacenamiento (persistencia). Roblox no tiene archivos en LocalScripts normales,
--     asi que usas un "adapter". Incluidos: Memory (solo sesion), Attribute (guarda en un Instance).
--     Tambien puedes hacer el tuyo con Storage.Custom(get, set, remove) (ej. writefile/readfile).
local Players = game:GetService("Players")
ClickGUI:SetStorage(ClickGUI.Storage.Attribute(Players.LocalPlayer))
-- Si tu executor tiene writefile/readfile, guarda en archivos reales (carpeta "MyClient"):
-- ClickGUI:SetStorage(ClickGUI.Storage.File("MyClient"))
-- ClickGUI:SetStorage(ClickGUI.Storage.Memory())
-- ClickGUI:SetStorage(ClickGUI.Storage.Custom(
--     function(key) return isfile and isfile(key .. ".json") and readfile(key .. ".json") or nil end,
--     function(key, value) if writefile then writefile(key .. ".json", value) end end,
--     function(key) if delfile and isfile and isfile(key .. ".json") then delfile(key .. ".json") end end
-- ))

-- 1.3 Tema propio. Campos: Background, Panel, Header, Module, ModuleHover, Element, ElementHover,
--     Accent, AccentDark, Text, TextDim, Stroke, Success, Warning, Error, Info,
--     Transparency, CornerRadius, Border, BorderThickness, BorderTransparency,
--     Gradients, GradientRotation, ShadowPreset (Off/Soft/Medium/Strong), ShadowOpacity, ShadowColor,
--     Font, FontBold
ClickGUI:RegisterTheme("Neon", {
	Accent = Color3.fromRGB(0, 255, 170),
	AccentDark = Color3.fromRGB(0, 140, 255),
	Panel = Color3.fromRGB(8, 14, 14),
	Header = Color3.fromRGB(12, 22, 22),
	Module = Color3.fromRGB(14, 26, 26),
	ModuleHover = Color3.fromRGB(20, 38, 38),
	Element = Color3.fromRGB(22, 40, 40),
	ElementHover = Color3.fromRGB(30, 54, 54),
	Stroke = Color3.fromRGB(30, 70, 60),
	CornerRadius = 10,
	BorderThickness = 1.5,
	ShadowPreset = "Strong",
	ShadowColor = Color3.fromRGB(0, 255, 170),
	ShadowOpacity = 0.35,
	GradientRotation = 45,
})
print("Temas:", table.concat(ClickGUI:GetThemes(), ", "))

-- 1.4 Notificaciones: Position (BottomRight|BottomLeft|BottomCenter|TopRight|TopLeft|TopCenter),
--     Style (Modern|Minimal|Banner), MaxVisible, Width, Duration, Margin
ClickGUI:SetNotificationConfig({ Position = "BottomRight", Style = "Modern", MaxVisible = 5, Width = 300, Duration = 4 })

-- 1.5 PANTALLA DE CARGA (opcional). Estilos: Bar | Spinner | Dots | Pulse | Terminal | Minimal
--     La pantalla SOLO termina cuando se cumple todo lo que pidas:
--       Tasks      = pasos que TU marcas como completados (Loader:CompleteTask("nombre"))
--       Conditions = nombres integrados ("GameLoaded", "Character", "Camera", "PlayerGui")
--                    o funciones que devuelven true cuando algo esta listo
--       Mode       = "All" (todo debe cumplirse) | "Any" (basta con UNO: "esto o esto")
--       MinTime    = tiempo minimo visible, Timeout = tiempo maximo (TimeoutAction "Finish" o "Fail")
local Loader = ClickGUI:CreateLoader({
	Title = "My Client",
	Subtitle = "Preparando todo...",
	Logo = "⚡", -- mismo formato que Icon (emoji, numero o rbxassetid://)
	Style = "Bar",
	MinTime = 2,
	Mode = "All",
	Tasks = { "Cargando modulos", "Leyendo configuracion" },
	Conditions = {
		"GameLoaded",
		function()
			return true
		end,
	},
	Timeout = 25,
	TimeoutAction = "Finish",
	OnTimeout = function()
		warn("La carga tardo demasiado")
	end,
})
-- Loader:SetProgress(0.5)   -- progreso manual (0-1)
-- Loader:SetStatus("texto") -- texto de estado
-- Loader:AddTask("otra")    -- devuelve { Complete = function }
-- Loader:AddCondition(function() return workspace:FindFirstChild("Map") ~= nil end)
-- Loader:Finish() / Loader:Fail("motivo") / Loader:Wait() / Loader:IsFinished() / Loader:Destroy()
-- Loader.Finished:Connect(function() ... end)

-- ============================================================================
-- 2. VENTANA
-- ============================================================================
local Window = ClickGUI:CreateWindow({
	Title = "My Client",
	Subtitle = "ClickGUI",
	Layout = LAYOUT, -- "Panels" | "Sidebar" (son los unicos dos)
	Style = STYLE, -- Classic | Flat | Glass
	Icon = "⚡", -- logo de marca (solo Glass): emoji, numero o rbxassetid://
	Palette = true, -- Flat: barra de colores arriba. true = todos los temas | false = ocultar |
	--               { "Violet", "Mocha", Color3.fromRGB(255, 0, 100) } = tu lista (nombres de tema o colores de acento)
	ThemeValues = { CornerRadius = 14 }, -- valores del tema que quieres forzar por encima del estilo
	ToggleKey = Enum.KeyCode.RightShift,
	Theme = THEME,
	-- Accent = Color3.fromRGB(255, 0, 100),
	-- Scale = 1,                              -- nil = escala automatica
	StartOpen = true, -- con Loader, la ventana se abre sola cuando la carga termina
	Loader = Loader,
	OpenAnimation = "Rise", -- Rise | Drop | Slide | Fade (tambien Window:SetOpenAnimation)
	ShowCounts = true, -- contador de modulos activos en paneles / sidebar
	Backdrop = true,
	Tooltips = true,
	Resizable = true,
	Size = UDim2.fromOffset(700, 460), -- Sidebar: tamano inicial
	MinSize = UDim2.fromOffset(480, 320), -- Sidebar: minimo
	MaxSize = UDim2.fromOffset(1000, 750), -- Sidebar: maximo
	PanelWidth = 200, -- Panels: ancho inicial de cada columna
	MaxPanelHeight = 400, -- Panels: alto maximo antes de hacer scroll
	SearchKey = Enum.KeyCode.F, -- Ctrl + F enfoca la busqueda (nil lo desactiva)
	ConfigKey = "MyClient", -- nombre usado para guardar
	AutoSave = true, -- guarda posiciones/tamanos solo y los carga al abrir
	-- Config automatica (tambien se cambia desde Settings > Config, y esas preferencias se recuerdan):
	AutoSaveConfig = true, -- guarda TODA la config cada N segundos, al cerrar el menu y al descargar
	AutoSaveInterval = 60, -- cada cuantos segundos (minimo 5)
	AutoLoadConfig = true, -- carga la config (o el perfil de inicio) la primera vez que se abre el menu
	Profile = "Default", -- perfil actual (ver Window:SaveProfile / LoadProfile mas abajo)
	-- Ocultar la GUI: Encrypt = todo (ventana, HUD, notificaciones, loader, widgets) dentro de CoreGui
	-- (si el executor no deja, usa gethui y si no PlayerGui). EncryptNames = nombres raros en cada instancia.
	Encrypt = false,
	EncryptNames = false,
	-- Estrella de favorito (clic en la estrella de cada modulo). Puedes cambiar los iconos:
	FavoriteIcons = {
		On = "rbxassetid://10734966097",
		Hover = "rbxassetid://10734965897",
		Off = "rbxassetid://10734966097",
	},
})

-- ============================================================================
-- 3. HUD (ArrayList independiente)
-- ============================================================================
local HUD = ClickGUI:CreateHUD({
	Name = "MainHUD",
	Style = "Pill", -- "Block" (barras) | "Pill" (pastillas redondeadas como la captura del ArrayList)
	Position = "TopRight", -- TopLeft | TopRight | BottomLeft | BottomRight
	Offset = Vector2.new(8, 8),
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	Spacing = 1,
	Sort = "Length", -- Length | Alphabetical | None
	Background = true,
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.45,
	TextTransparency = 0,
	AccentBar = "Right", -- Left | Right | None
	Border = false,
	BorderThickness = 1,
	ColorMode = "Gradient", -- Accent | Gradient | Rainbow | Static
	GradientFrom = Color3.fromRGB(0, 255, 170),
	GradientTo = Color3.fromRGB(0, 140, 255),
	GradientSpeed = 0.2,
	ShowInfo = true,
	Animation = "Both", -- Both | Grow | Fade | None
})
HUD:Attach(Window) -- muestra automaticamente los modulos activados

HUD:AddEntry("Watermark", "v1.1") -- entrada manual

-- ============================================================================
-- 3b. WATERMARK (texto y/o imagen, sigue el color/gradiente del tema o uno propio)
-- ============================================================================
-- Variables en el texto: {fps} {ping} {time} {date} {player} {display} {memory} {version} y las tuyas (Variables)
-- Window:CreateWatermark(...) igual que ClickGUI:CreateWatermark pero su posicion/estilo se guarda en la config
local Mark = Window:CreateWatermark({
	Name = "Brand",
	Text = "My Client | {fps} fps | {ping} ms | {time}",
	Image = "⚡", -- logo: emoji, numero o rbxassetid://... (o nil para solo texto)
	ImageSize = 20,
	Position = "TopLeft", -- TopLeft | TopCenter | TopRight | CenterLeft | CenterRight | BottomLeft | BottomCenter | BottomRight
	Offset = Vector2.new(12, 12),
	-- Custom = UDim2.fromScale(0.4, 0.05),       -- posicion propia (reemplaza a Position)
	Background = true,
	BackgroundTransparency = 0.2,
	-- Color = Color3.fromRGB(255, 255, 255),      -- color fijo; sin Color usa gradiente del tema
	-- Gradient = { Color3.fromRGB(255, 80, 120), Color3.fromRGB(120, 80, 255) }, -- gradiente propio (false = color solido del acento)
	GradientRotation = 0,
	TextSize = 14,
	UpdateRate = 0.5,
	Variables = {
		server = function()
			return game.JobId ~= "" and "online" or "studio"
		end,
	},
})
-- Mark:SetText("Nuevo {server}"); Mark:SetImage(nil); Mark:SetColor(Color3.new(1, 1, 0)); Mark:SetGradient(a, b, 45)
-- Mark:SetPosition("TopRight"); Mark:SetBackground(false); Mark:SetTextSize(16); Mark:Toggle(); Mark:SetEditable(true) -- arrastrar
-- Mark:SetVariable("server", "hola"); Mark:Destroy()

-- ============================================================================
-- 3c. TARGET HUD generico (info de objetivo, barras, lineas, debug...)
-- ============================================================================
local Target = Window:CreateTargetHUD({
	Name = "Target",
	Title = "dodger___",
	Subtitle = "@dodger___",
	Image = "🎯", -- imagen/emoji/rbxthumb: o usa Target:SetPlayer(player) para su avatar automatico
	Style = "Card", -- Card (con avatar) | Compact | Minimal
	Position = "Center", -- Center | CenterLeft | CenterRight | TopCenter | BottomCenter | TopLeft | TopRight | BottomLeft | BottomRight
	Width = 230,
	Bar = { Value = 20, Max = 20, Color = "Health" }, -- barra principal: "Health" (verde->rojo), "Accent" o un Color3
	AutoHide = 4, -- se oculta solo tras N segundos sin actualizarse (y reaparece al actualizar)
	Debug = false,
})
Target:SetPlayer(Players.LocalPlayer) -- avatar + nombre automaticos
Target:SetBar(14, 20) -- valor, maximo (texto "14 / 20")
Target:SetProgress(0.7, "Cargando 70%") -- como la barra del loader: 0-1 + texto propio
Target:SetBarColor(Color3.fromRGB(80, 200, 120)) -- "Health" | "Accent" | Color3
local Shield = Target:AddBar("Shield", { Max = 10, Value = 6, Label = "Shield", Color = Color3.fromRGB(80, 160, 255) })
Shield:Set(8, 10) -- Shield:SetColor / :SetLabel / :SetVisible / :Remove
Target:SetLine("Distancia", "4.2 blk") -- lineas clave/valor (solo informacion)
Target:SetLines({ Modo = "Single", Prioridad = "Distancia" })
Target:SetDebug(true) -- agrega FPS / Ping / Memoria + las lineas SetDebugLine
Target:SetDebugLine("Tick", 1234)
-- Target:Show() / :Hide() / :Toggle() / :Flash(Color3.new(1, 0, 0)) / :SetEditable(true) (arrastrar) / :ResetPosition()
-- Target:RemoveLine("Distancia") / :ClearLines() / :SetStyle("Compact") / :SetWidth(260) / :Destroy()
Target:Show()
HUD:SetEntryInfo("Watermark", "v1.1.0")
-- HUD:RemoveEntry("Watermark")
-- HUD:SetOption("ColorMode", "Rainbow")     -- cambia una opcion en vivo
-- HUD:SetOptions({ TextSize = 18, Spacing = 2 })
-- HUD:SetEditable(true)                     -- modo editor: arrastra el HUD y pulsa "Done"
-- HUD:ResetPosition()
-- HUD:SetVisible(false)

-- ============================================================================
-- 4. CATEGORIAS Y MODULOS
-- ============================================================================
-- Group = nombre de seccion en la barra lateral del estilo Glass ("MODULES", "GENERAL"...)
local Combat = Window:CreateCategory(
	"Combat",
	{ Icon = ICON, IconSize = 16, IconColor = Color3.fromRGB(255, 90, 90), Group = "Modules" }
)
local Movement = Window:CreateCategory("Movement", { Icon = ICON, Group = "Modules" })
local Visual = Window:CreateCategory("Visual", { Group = "Modules" })

local KillAura = Combat:CreateModule({
	Name = "KillAura",
	Description = "Ataca jugadores cercanos",
	Tooltip = "Click: activar | Click derecho: ajustes | Click medio: favorito",
	Icon = ICON,
	IconSize = 14,
	IconActiveColor = Color3.fromRGB(255, 90, 90),
	IconInactiveColor = Color3.fromRGB(120, 120, 130),
	Keybind = Enum.KeyCode.R, -- tecla que activa/desactiva el modulo
	Default = false,
	Favorite = true,
	Pinned = false,
	Expanded = false,
	Callback = function(enabled)
		print("KillAura:", enabled)
		Window:Notify({
			Title = "KillAura",
			Content = enabled and "Activado" or "Desactivado",
			Type = enabled and "Success" or "Warning",
			Duration = 2.5,
		})
	end,
})

KillAura:CreateSection("Basicos")

-- Toggle: Style Switch | Checkbox, colores propios, Disabled, Tooltip, Flag.
--   Keybind = tecla que activa/desactiva el toggle. Tambien puedes cambiarla EN EL MENU con click derecho
--   sobre el toggle (Esc cancela, Backspace/Delete borra). Lo mismo funciona en Button, ImageButton y Dropdown.
local onlyPlayers = KillAura:CreateToggle({
	Keybind = Enum.KeyCode.B,
	Name = "Solo jugadores",
	Default = true,
	Style = "Switch",
	ActiveColor = Color3.fromRGB(80, 220, 120),
	InactiveColor = Color3.fromRGB(60, 60, 70),
	Tooltip = "Ignora NPCs",
	Flag = "onlyPlayers",
	Callback = function(value)
		print("Solo jugadores:", value)
	end,
})
KillAura:CreateToggle({ Name = "Casilla", Style = "Checkbox", Default = false })
KillAura:CreateToggle({ Name = "Bloqueado", Default = true, Disabled = true, Tooltip = "Desactivado por codigo" })

-- Slider: Increment, Precision, Suffix, Marks, edicion numerica (click en el numero), flechas con el mouse encima
local range = KillAura:CreateSlider({
	Name = "Rango",
	Min = 1,
	Max = 6,
	Default = 4,
	Increment = 0.1,
	Precision = 1,
	Suffix = " studs",
	Marks = { 1, 3.5, 6 },
	Flag = "range",
	Callback = function(value)
		print("Rango:", value)
	end,
})

-- RangeSlider: dos puntos, callback con (min, max)
KillAura:CreateRangeSlider({
	Name = "CPS",
	Min = 1,
	Max = 20,
	Default = { 8, 12 }, -- tambien: DefaultMin / DefaultMax
	Increment = 1,
	MinGap = 1,
	Flag = "cps",
	Callback = function(low, high)
		print("CPS:", low, high)
	end,
})

-- InputNumber: caja numerica con + y -
KillAura:CreateInputNumber({
	Name = "Delay (ms)",
	Min = 0,
	Max = 1000,
	Default = 100,
	Increment = 10,
	Precision = 0,
	Flag = "delay",
	Callback = function(value)
		print("Delay:", value)
	end,
})

KillAura:CreateSection("Listas")

local mode = KillAura:CreateDropdown({
	Name = "Modo",
	Options = { "Single", "Switch", "Multi" },
	Default = "Single",
	Flag = "mode",
	Callback = function(value)
		KillAura:SetInfo(value) -- el HUD muestra el modo al lado del nombre
	end,
})

KillAura:CreateSearchableDropdown({
	Name = "Objetivos",
	Options = { "Players", "NPCs", "Friends", "Teammates", "Invisible", "Sleeping", "Dead" },
	Default = { "Players" },
	Multi = true, -- seleccion multiple: el callback recibe una tabla
	Flag = "targets",
	Callback = function(list)
		print("Objetivos:", table.concat(list, ", "))
	end,
})

KillAura:CreateSection("Entrada")

KillAura:CreateKeybind({
	Name = "Tecla extra",
	Default = Enum.KeyCode.Q,
	Flag = "extraKey",
	Callback = function(key) -- cuando CAMBIA la tecla (Esc cancela, Backspace/Delete borra)
		print("Nueva tecla:", key)
	end,
	OnPressed = function() -- cuando se PRESIONA la tecla
		print("Tecla pulsada")
	end,
})

KillAura:CreateColorPicker({
	Name = "Color",
	Default = Color3.fromRGB(255, 80, 120),
	Flag = "color",
	Callback = function(color)
		print("Color:", color)
	end,
})

KillAura:CreateTextbox({
	Name = "Prefijo",
	Default = ".",
	Placeholder = "Prefijo",
	Flag = "prefix",
	Callback = function(text, enter)
		print("Prefijo:", text, enter)
	end,
})
KillAura:CreateTextbox({
	Name = "Cantidad",
	Numeric = true,
	Default = "5",
	ClearOnFocus = true,
	Callback = function(text)
		print(tonumber(text))
	end,
})

KillAura:CreateSection("Acciones")

KillAura:CreateLabel("Los botones ejecutan una accion al hacer click.")
KillAura:CreateButton({
	Name = "Notificar",
	Keybind = Enum.KeyCode.N, -- ejecuta el boton con la tecla N (click derecho para cambiarla)
	Callback = function()
		Window:Notify({ Title = "Hola", Content = "Esto es una notificacion", Type = "Info", Duration = 4 })
	end,
})
KillAura:CreateImageButton({
	Name = "Boton imagen",
	Text = "Con imagen",
	Image = ICON,
	HoverImage = ICON,
	ImageSize = 18,
	ImageColor = Color3.fromRGB(220, 220, 230),
	HoverColor = Color3.fromRGB(0, 255, 170),
	Callback = function()
		print("ImageButton")
	end,
})
local progress = KillAura:CreateProgressBar({ Name = "Carga", Default = 0, ShowPercent = true })
KillAura:CreateKeybindList({ Name = "Atajos", Height = 150 }) -- gestor central de teclas de todos los modulos

-- Teclas de componentes por codigo:
onlyPlayers:SetKeybind(Enum.KeyCode.B) -- cambiar / SetKeybind(nil) para quitar
print("Tecla del toggle:", onlyPlayers:GetKeybind())

-- Control por codigo de cualquier componente
task.delay(2, function()
	range:Set(5) -- dispara el callback
	mode:Set("Switch", true) -- true = silencioso (sin callback)
	onlyPlayers:SetEnabled(false) -- gris y bloqueado
	progress:Set(0.75)
	print(range:Get(), mode:Get(), onlyPlayers:IsEnabled())
end)

-- Otros modulos
local Sprint = Movement:CreateModule({ Name = "Sprint", Description = "Siempre corriendo", Default = true })
Sprint:CreateToggle({ Name = "Omnidireccional" })
local Speed = Movement:CreateModule({ Name = "Speed", Keybind = Enum.KeyCode.V })
Speed:CreateSlider({ Name = "Multiplicador", Min = 1, Max = 5, Default = 1.5, Increment = 0.1, Suffix = "x" })
Movement:CreateModule({ Name = "Fly" }):CreateSlider({ Name = "Velocidad", Min = 1, Max = 100, Default = 20 })
Movement:CreateModule({ Name = "Step", Description = "Subir bloques" })
local ESP = Visual:CreateModule({ Name = "ESP", Description = "Resalta jugadores" })
ESP:CreateColorPicker({ Name = "Contorno", Default = Color3.fromRGB(167, 139, 250) })
Visual:CreateModule({ Name = "Fullbright" })

-- Modulo que solo tiene ajustes (sin interruptor)
local Info = Visual:CreateModule({ Name = "Opciones", Toggleable = false, ShowKeybind = false, ShowInHUD = false })
Info:CreateLabel("Modulo sin interruptor: el click solo despliega.")

-- Control de modulos por codigo
Sprint:SetEnabled(true)
KillAura:SetFavorite(true) -- tambien se marca con la ESTRELLA a la derecha de cada modulo (clic = amarilla)
Speed:SetPinned(true)
Speed:SetVisible(true)
KillAura:SetInfo("Single")
-- KillAura:Expand() / :Collapse() / :Toggle() / :Destroy()

-- ============================================================================
-- 5. COMPONENTE PROPIO
-- ============================================================================
local Base = ClickGUI.Base
local Create = ClickGUI.Create
local Counter = setmetatable({}, { __index = Base })
Counter.__index = Counter
function Counter.new(ctx, parent, options)
	local self = setmetatable(Base.new(ctx, parent, options.Name, 24), Counter)
	self._callback = options.Callback
	self.Value = 0
	self:_label({
		Size = UDim2.new(1, -60, 1, 0),
		Text = options.Name,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame,
	})
	local button = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(54, 20),
		BackgroundTransparency = 0,
		BackgroundColor3 = self._theme:Get("Element"),
		Text = "0",
		TextColor3 = self._theme:Get("Text"),
		Parent = self.Frame,
	})
	Create.corner(button, 5)
	self._button = button
	self._maid:Give(button.MouseButton1Click:Connect(function()
		self:Set(self.Value + 1)
	end))
	return self
end
function Counter:Set(value, silent)
	self.Value = value
	self._button.Text = tostring(value)
	if not silent then
		self:_emit(value)
	end
end
ClickGUI:RegisterComponent("Counter", Counter.new) -- agrega Module:CreateCounter
KillAura:CreateCounter({ Name = "Contador", Callback = print })

-- ============================================================================
-- 6. BUSQUEDA, FAVORITOS, TOOLTIPS
-- ============================================================================
Window:Search("movement", { SearchNames = true, SearchDescriptions = true, SearchCategories = true })
Window:Search("") -- limpia (tambien: Window:ClearSearch(), Window:FocusSearch())
print("Favoritos:", #Window:GetFavorites(), "Fijados:", #Window:GetPinned())
Window:SetFavoritesOnly(false)
Window:SetTooltipsEnabled(true)

-- ============================================================================
-- 7. TAMANO, POSICION Y ESCALA
-- ============================================================================
Window:SetMinSize(UDim2.fromOffset(480, 320))
Window:SetMaxSize(UDim2.fromOffset(1000, 750))
Window:SetSize(UDim2.fromOffset(720, 480)) -- Sidebar: tamano de ventana | Panels: ancho de columnas
Window:SetResizable(true) -- Sidebar: esquina/bordes | Panels: borde derecho de cada columna
Window:SetPanelWidth(200) -- Panels
Window:SetScale(nil) -- nil = automatica; Window:SetScale(1.2) = fija
Window:ResetLayout()
Window:BringToFront()

-- ============================================================================
-- 8. TEMAS EN VIVO
-- ============================================================================
Window:SetTheme("Neon") -- por nombre
Window:SetAccent(Color3.fromRGB(255, 0, 120))
Window:SetThemeValue("CornerRadius", 12) -- cualquier campo del tema
Window:SetThemeValue("BorderThickness", 2)
Window:SetThemeValue("Gradients", true)
Window:SetThemeValue("ShadowPreset", "Medium")
Window:SetThemeValue("Transparency", 0.1)
Window:SetTheme({ Accent = Color3.fromRGB(120, 200, 255) }) -- tabla parcial
local themeData = ClickGUI:ExportTheme() -- tabla serializable (JSON)
ClickGUI:ImportTheme(themeData, "Guardado")
-- Barra de colores (Flat): cambiarla en vivo
Window:SetPalette({ "Violet", "Mocha", "Midnight", "Ink", Color3.fromRGB(255, 80, 120) })
Window:SetTheme(THEME) -- el estilo se mantiene al cambiar de tema

-- ============================================================================
-- 9. CATEGORIA DE AJUSTES LISTA (tema, apariencia, animaciones, HUD, config)
-- ============================================================================
Window:CreateSettingsCategory("Settings", {
	HUD = HUD,
	Category = { Group = "General" },
	Sections = { "Interface", "Appearance", "Animations", "Notifications", "HUD", "Config" },
})

-- ============================================================================
-- 10. CONFIGURACION: exportar, importar, guardar, cargar, resetear
-- ============================================================================
-- Que se guarda: TODOS los valores de componentes (toggles, sliders, dropdowns, colores, textboxes...),
-- el estado de cada modulo, las TECLAS de modulos y de componentes (Keybind), favoritos/fijados,
-- posiciones y tamanos de paneles/ventana, tema, escala, animaciones, HUD...
-- No necesitas Flag para que se guarde; Flag solo sirve para leerlo por nombre (Window:GetFlag).
-- Un componente puede excluirse con Persist = false.
local json = Window:ExportConfig() -- JSON con valores, modulos, favoritos, layout, tema, animaciones, HUD...
Window:ImportConfig(json) -- tambien acepta una tabla y configs de la version anterior
print("Valor de flag:", Window:GetFlag("range"))
Window:SetFlag("range", 3, true)
-- Perfiles de configuracion (varias configs con nombre, ademas de la "Default"):
Window:SaveProfile("Legit") -- guarda la config actual con ese nombre
Window:SaveProfile("Rage")
print("Perfiles:", table.concat(Window:GetProfiles(), ", "), "| actual:", Window:GetProfile())
Window:LoadProfile("Legit")
Window:SetStartupProfile("Legit") -- con AutoLoadConfig se carga solo al iniciar
Window:DeleteProfile("Rage")
-- Config automatica en vivo: Window:SetAutoSave(true, 120); Window:SetAutoLoad(true); Window:SetAutoSaveLayout(true)
-- Window:SetTitle("Otro titulo"); Window:SetSubtitle("v2")
-- Se guardan tambien: tema de notificaciones, tecla del menu, animacion de apertura, contadores, busqueda y
-- las posiciones de HUD / Watermark / TargetHUD.
Window:SaveLayout() -- posiciones, tamanos, favoritos en el storage
Window:LoadLayout()
Window:SaveConfig() -- todo en el storage
Window:LoadConfig()
-- Window:ResetConfig()                      -- vuelve todo a los valores por defecto

-- Terminar la pantalla de carga (cuando tu codigo termino de preparar todo):
Loader:CompleteTask("Cargando modulos")
Loader:CompleteTask("Leyendo configuracion")

-- ============================================================================
-- 11. EVENTOS
-- ============================================================================
Window.Opened:Connect(function()
	print("Abierta")
end)
Window.Closed:Connect(function()
	print("Cerrada")
end)
Window.ModuleToggled:Connect(function(module, enabled)
	print(module.Name, enabled)
end)
Window.FavoritesChanged:Connect(function(module)
	print("Favorito cambiado:", module.Name)
end)
KillAura.Changed:Connect(function(enabled)
	print("Evento del modulo:", enabled)
end)
onlyPlayers.Changed:Connect(function(value)
	print("Evento del componente:", value)
end)

-- ============================================================================
-- 12. NOTIFICACIONES
-- ============================================================================
ClickGUI:Notify({
	Title = "ClickGUI " .. ClickGUI.Version,
	Content = "Pulsa RightShift para abrir el menu.",
	Type = "Info",
	Duration = 6,
})
-- Opciones por notificacion: Title, Content, Type (Info|Success|Warning|Error), Duration (0 = fija),
-- Style (Modern|Minimal|Banner), Icon (emoji/numero/rbxassetid), Closable, Progress, OnClick
local handle = ClickGUI:Notify({
	Title = "Con accion",
	Content = "Haz click para ejecutar algo.",
	Type = "Success",
	Style = "Banner",
	Icon = "🎉",
	Duration = 5,
	OnClick = function()
		print("Click en la notificacion")
	end,
})
-- handle:Dismiss()  |  ClickGUI:ClearNotifications()
-- Pasar el mouse por encima pausa el temporizador.

-- ============================================================================
-- 13. SOMBRAS (UIShadow) por separado, util para tus propios frames
-- ============================================================================
-- local shadow = ClickGUI.UIShadow.new({ Parent = miFrame, Preset = "Soft", CornerRadius = 8 })
-- shadow:SetOpacity(0.5); shadow:SetColor(Color3.new(0, 0, 0)); shadow:SetOffset(Vector2.new(0, 4))
-- shadow:SetSpread(4); shadow:SetLayers(8); shadow:SetEnabled(true); shadow:Destroy()

-- ============================================================================
-- 14. LIMPIEZA
-- ============================================================================
-- Window:Destroy()      -- solo esta ventana
-- HUD:Destroy()
-- ClickGUI:Destroy()    -- todo (ventanas, HUDs, notificaciones)
