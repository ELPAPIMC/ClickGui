--[[
	EJEMPLO COMPLETO DE ClickGUI 1.2.0 (usa TODAS las funciones, incluidas las nuevas)

	Carga:  loadstring(game:HttpGet(URL))()
	Tecla para abrir/cerrar: RightShift.   Ctrl+F enfoca la busqueda.
	Favoritos: pulsa la estrella (☆ -> ★ amarilla) de cada modulo. Shift + estrella = fijar (pin).

	NOVEDADES DE ESTA VERSION (marcadas con [NUEVO]):
	  - Encrypt / EncryptNames        : GUI en CoreGui + nombres aleatorios con caracteres raros
	  - Estrella de favorito          : en cada modulo
	  - Watermark                     : texto / logo, posicion y color propios
	  - TargetHUD                     : Target / Info / Debug, con Track, Bind, Update...
	  - AutoSave / AutoLoad / Perfiles: con slider de intervalo en Settings > Config
	  - Config ampliada               : guarda notificaciones, ventana, watermarks, TargetHUDs
	  - Notificaciones sin solaparse  : Width, Scale, Margin configurables
	  - Estilo Flat corregido         : ya no sale en blanco
]]

local URL = "https://raw.githubusercontent.com/ELPAPIMC/ClickGui/refs/heads/main/ClickGUI.lua"
local ClickGUI = loadstring(game:HttpGet(URL))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LAYOUT = "Panels" -- "Panels" | "Sidebar"
local STYLE = "Flat" -- "Classic" | "Flat" | "Glass"
local THEME = "Mocha"
local ICON = "⚔" -- emoji, numero de imagen o "rbxassetid://..."

-- ============================================================================
-- 1. CONFIGURACION GLOBAL (antes de crear ventanas / loader)
-- ============================================================================

-- 1.1 [NUEVO] Encrypt: TODO lo que cree la libreria (ventanas, HUD, loader, notificaciones,
--     watermark, TargetHUD) va a gethui()/CoreGui. EncryptNames: nombres raros y aleatorios.
--     Hazlo ANTES de crear el Loader para que tambien quede protegido.
--     Tambien puedes ponerlo como opciones de CreateWindow (Encrypt / EncryptNames).
--     Si CoreGui no esta disponible (ej. Studio) avisa y usa PlayerGui.
ClickGUI:SetEncrypt(true, true) -- (enabled, names). nil deja un valor sin cambiar: SetEncrypt(nil, false)
print("Encrypt:", ClickGUI.Encrypt, "EncryptNames:", ClickGUI.EncryptNames)

-- 1.2 Animaciones
ClickGUI:SetAnimationConfig({ Enabled = true, Speed = 1, Preset = "Smooth" })

-- 1.3 Almacenamiento (necesario para AutoSave / AutoLoad / perfiles).
--     Usa writefile/readfile si existen (executor); si no, guarda en un atributo del jugador.
local hasFiles = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
if hasFiles then
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" and not isfolder("MyClient") then
		makefolder("MyClient")
	end
	local function path(key)
		return "MyClient/" .. string.gsub(key, "[^%w_%-]", "_") .. ".json"
	end
	ClickGUI:SetStorage(ClickGUI.Storage.Custom(function(key)
		return isfile(path(key)) and readfile(path(key)) or nil
	end, function(key, value)
		writefile(path(key), value)
	end, function(key)
		if typeof(delfile) == "function" and isfile(path(key)) then
			delfile(path(key))
		end
	end))
else
	ClickGUI:SetStorage(ClickGUI.Storage.Attribute(Players.LocalPlayer))
	-- ClickGUI:SetStorage(ClickGUI.Storage.Memory()) -- solo durante la sesion
end

-- 1.4 Tema propio
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

-- 1.5 [NUEVO] Notificaciones: ahora con Width, Scale y Margin (y se guardan en la config)
ClickGUI:SetNotificationConfig({
	Position = "BottomRight", -- BottomRight|BottomLeft|BottomCenter|TopRight|TopLeft|TopCenter
	Style = "Modern", -- Modern | Minimal | Banner
	MaxVisible = 5,
	Width = 300,
	Duration = 4,
	Margin = 16,
	Scale = 1,
})
print("Config de notificaciones:", ClickGUI:GetNotificationConfig().Style)

-- 1.6 Pantalla de carga
local Loader = ClickGUI:CreateLoader({
	Title = "My Client",
	Subtitle = "Preparando todo...",
	Logo = "⚡",
	Style = "Bar", -- Bar | Spinner | Dots | Pulse | Terminal | Minimal
	MinTime = 2,
	Mode = "All",
	Tasks = { "Cargando modulos", "Leyendo configuracion" },
	Conditions = { "GameLoaded" },
	Timeout = 25,
	TimeoutAction = "Finish",
	OnTimeout = function()
		warn("La carga tardo demasiado")
	end,
})

-- ============================================================================
-- 2. VENTANA
-- ============================================================================
local Window = ClickGUI:CreateWindow({
	Title = "My Client",
	Subtitle = "ClickGUI",
	Layout = LAYOUT,
	Style = STYLE,
	Icon = "⚡",
	Palette = true, -- Flat: barra de colores. true | false | { "Violet", "Mocha", Color3.fromRGB(255, 0, 100) }
	ThemeValues = { CornerRadius = 14 },
	ToggleKey = Enum.KeyCode.RightShift,
	Theme = THEME,
	StartOpen = true,
	Loader = Loader,
	OpenAnimation = "Rise", -- Rise | Drop | Slide | Fade
	ShowCounts = true,
	Backdrop = true,
	Tooltips = true,
	Resizable = true,
	Size = UDim2.fromOffset(700, 460), -- Sidebar
	MinSize = UDim2.fromOffset(480, 320),
	MaxSize = UDim2.fromOffset(1000, 750),
	PanelWidth = 200, -- Panels
	MaxPanelHeight = 400, -- Panels
	SearchKey = Enum.KeyCode.F,
	ConfigKey = "MyClient", -- nombre base del guardado

	-- [NUEVO] seguridad (equivale a ClickGUI:SetEncrypt)
	Encrypt = true, -- GUI en CoreGui / gethui
	EncryptNames = true, -- nombres aleatorios con caracteres raros

	-- [NUEVO] guardado automatico
	AutoSave = true, -- guarda el perfil actual cada AutoSaveInterval segundos (y el layout al moverlo)
	AutoSaveInterval = 30, -- segundos (5 - 3600). Tambien hay slider en Settings > Config
	AutoLoad = true, -- carga el perfil actual al iniciar
	Profile = "default", -- perfil con el que se guarda / carga
})

-- ============================================================================
-- 3. HUD (ArrayList)
-- ============================================================================
local HUD = ClickGUI:CreateHUD({
	Name = "MainHUD",
	Style = "Pill",
	Position = "TopRight",
	Offset = Vector2.new(8, 8),
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	Spacing = 1,
	Sort = "Length",
	Background = true,
	BackgroundTransparency = 0.45,
	AccentBar = "Right",
	ColorMode = "Gradient",
	GradientFrom = Color3.fromRGB(0, 255, 170),
	GradientTo = Color3.fromRGB(0, 140, 255),
	GradientSpeed = 0.2,
	ShowInfo = true,
	Animation = "Both",
})
HUD:Attach(Window) -- muestra los modulos activados
HUD:AddEntry("Watermark", "v" .. ClickGUI.Version)

-- ============================================================================
-- 4. [NUEVO] WATERMARK
-- ============================================================================
-- Window:CreateWatermark(...) lo liga a la ventana: se guarda/carga con la config y se destruye con ella.
-- ClickGUI:CreateWatermark(...) crea uno independiente.
--
-- Text: texto con marcadores  {fps} {ping} {time} {date} {player} {display} {game} {players} {placeid}
--       o una funcion  function(watermark) return "texto" end
-- ColorMode: "Theme" (acento del ClickGUI) | "Gradient" | "Static" | "Rainbow"
-- Position: TopLeft TopCenter TopRight CenterLeft Center CenterRight BottomLeft BottomCenter BottomRight
local Watermark = Window:CreateWatermark({
	Name = "Main",
	Text = "My Client | {display} | {fps} fps | {ping} ms | {time}",
	Image = "⚡", -- emoji, numero de imagen, "rbxassetid://..." o ID de TU logo
	ImageSize = 16,
	Position = "TopLeft",
	Offset = Vector2.new(8, 8),
	ColorMode = "Gradient", -- adopta el color/degradado del tema del ClickGUI
	TextSize = 14,
	Background = true,
	BackgroundTransparency = 0.35,
	CornerRadius = 6,
	Border = false,
	AccentLine = "Bottom", -- Bottom | Left | None
	UpdateRate = 0.5, -- cada cuanto se refrescan {fps}, {time}...
})

-- Otros usos:
Watermark:SetText("My Client | {fps} fps") -- cambiar el texto
Watermark:SetText(function(wm) -- texto dinamico con funcion
	return string.format("My Client | %d jugadores | %s", #Players:GetPlayers(), os.date("%H:%M"))
end)
Watermark:SetColorMode("Theme") -- usa el acento del tema
Watermark:SetGradient(Color3.fromRGB(255, 0, 120), Color3.fromRGB(120, 0, 255)) -- degradado propio
-- Watermark:SetColor(Color3.fromRGB(255, 255, 255))   -- color fijo (Static)
-- Watermark:SetColorMode("Rainbow")
Watermark:SetPosition("TopLeft")
-- Watermark:SetCustomPosition(UDim2.new(0.5, 0, 0, 20)) -- posicion propia (se guarda)
-- Watermark:ResetPosition()
-- Watermark:SetOption("TextSize", 16)    -- cualquier opcion en vivo
-- Watermark:SetImage("rbxassetid://7733715400")
-- Watermark:SetEditable(true)            -- arrastralo con el mouse; (false) para terminar
-- Watermark:SetVisible(true) / :Show() / :Hide() / :Toggle() / :IsVisible()
-- Watermark:Export() / :Import(tabla)    -- (Window:ExportConfig ya lo incluye)

-- Un segundo watermark solo con logo, abajo a la izquierda:
local Logo = Window:CreateWatermark({
	Name = "Logo",
	Text = "",
	Image = "⚡",
	ImageSize = 22,
	Position = "BottomLeft",
	ColorMode = "Rainbow",
	Background = false,
	AccentLine = "None",
})
Logo:SetVisible(false) -- oculto por defecto; enciendelo desde Settings > Watermark

-- ============================================================================
-- 5. [NUEVO] TARGET HUD (Target / Info / Debug)
-- ============================================================================
-- Style "Target": avatar + nombre + barra + texto "20 / 20"  (como la captura)
-- Style "Info"  : avatar + titulo + subtitulo + lineas, sin barra
-- Style "Debug" : fuente monoespaciada con filas clave/valor
local TargetHUD = Window:CreateTargetHUD({
	Name = "Target",
	Style = "Target",
	Position = "BottomCenter",
	Offset = Vector2.new(0, 130),
	Width = 250,
	Title = "dodger___",
	Max = 20,
	Value = 20,
	BarMode = "Health", -- Health (verde->rojo) | Accent | Gradient | Static
	ShowBarText = true,
	Animation = "Pop", -- Fade | Pop | None
	AutoHide = 6, -- se oculta solo tras 6 s sin cambios
	ImageShape = "Square", -- Square | Round
})

-- Usos:
TargetHUD:SetPlayer(Players.LocalPlayer, true) -- nombre + avatar de un jugador (true = DisplayName)
TargetHUD:SetTitle("dodger___")
TargetHUD:SetSubtitle("Distancia: 12 studs") -- SetSubtitle(nil) lo quita
TargetHUD:SetProgress(15, 20) -- (valor, maximo). Con Max = 1 muestra porcentaje
TargetHUD:SetBarText(nil) -- texto propio de la barra, o nil para el automatico
TargetHUD:SetFormat(function(value, max, alpha) -- formato propio del texto de la barra
	return string.format("%d / %d HP", value, max)
end)
-- TargetHUD:SetBarColor(Color3.fromRGB(255, 80, 80)) -- color fijo (nil = automatico)
TargetHUD:SetLine("Arma", "Espada", Color3.fromRGB(255, 200, 80)) -- linea extra (clave, valor, color?)
TargetHUD:SetLine("Ping", "42 ms")
TargetHUD:RemoveLine("Ping")
TargetHUD:SetLines({ { "Equipo", "Rojo" }, { "Nivel", 12 } }) -- reemplaza todas (en orden) | { Clave = valor } (alfabetico)
TargetHUD:Update({ Title = "dodger___", Subtitle = "En combate", Value = 20, Max = 20 }) -- varias cosas a la vez
TargetHUD:Show(5) -- mostrar 5 s (sin numero usa AutoHide)
-- TargetHUD:Hide() / :Toggle() / :SetVisible(bool) / :IsVisible()
-- TargetHUD:SetStyle("Info")             -- cambia el estilo en vivo
-- TargetHUD:SetOption("Width", 280)      -- cualquier opcion en vivo
-- TargetHUD:SetPosition("TopCenter") / :SetCustomPosition(UDim2) / :ResetPosition()
-- TargetHUD:SetEditable(true)            -- arrastrar; (false) al terminar
-- TargetHUD.Shown:Connect(function() end); TargetHUD.Hidden:Connect(function() end)

-- Seguimiento automatico de un jugador (vida + avatar + nombre), acepta Player | Humanoid | Model | nombre | UserId
-- TargetHUD:Track(Players.LocalPlayer, { UseDisplayName = true, AutoShow = true, Timeout = 8 })
-- TargetHUD:Untrack()

-- TargetHUD tipo Info (solo informacion, sin barra):
local InfoHUD = Window:CreateTargetHUD({
	Name = "Info",
	Style = "Info",
	Position = "CenterLeft",
	Offset = Vector2.new(12, 0),
	Title = "Servidor",
	Subtitle = game.Name,
	Image = "🌐",
	Width = 220,
})
InfoHUD:SetLines({ Jugadores = #Players:GetPlayers(), PlaceId = game.PlaceId })

-- TargetHUD tipo Debug (se actualiza solo con Bind):
local DebugHUD = Window:CreateTargetHUD({
	Name = "Debug",
	Style = "Debug",
	Title = "DEBUG",
	Position = "TopLeft",
	Offset = Vector2.new(10, 60),
	Width = 210,
	Animation = "Fade",
})
local frames, elapsed, fps = 0, 0, 60
RunService.Heartbeat:Connect(function(dt)
	frames += 1
	elapsed += dt
	if elapsed >= 0.5 then
		fps = frames / elapsed
		frames, elapsed = 0, 0
	end
end)
DebugHUD:Bind(function(hud) -- se llama cada 0.25 s
	hud:SetLines({
		{ "FPS", math.floor(fps + 0.5) },
		{ "Modulos activos", #HUD.Library.Windows[1].Modules },
		{ "Jugadores", #Players:GetPlayers() },
	})
end, 0.25)
DebugHUD:Hide() -- enciendelo desde Settings > TargetHUD o con DebugHUD:Show()
-- DebugHUD:Unbind()

-- ============================================================================
-- 6. CATEGORIAS Y MODULOS
-- ============================================================================
local Combat = Window:CreateCategory(
	"Combat",
	{ Icon = ICON, IconSize = 16, IconColor = Color3.fromRGB(255, 90, 90), Group = "Modules" }
)
local Movement = Window:CreateCategory("Movement", { Icon = ICON, Group = "Modules" })
local Visual = Window:CreateCategory("Visual", { Group = "Modules" })

local KillAura = Combat:CreateModule({
	Name = "KillAura",
	Description = "Ataca jugadores cercanos",
	Tooltip = "Click: activar | Click derecho: ajustes | Estrella: favorito",
	Icon = ICON,
	IconSize = 14,
	IconActiveColor = Color3.fromRGB(255, 90, 90),
	IconInactiveColor = Color3.fromRGB(120, 120, 130),
	Keybind = Enum.KeyCode.R,
	Default = false,
	Favorite = true, -- [NUEVO] arranca con la estrella amarilla (★)
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
		-- ejemplo: mostrar el TargetHUD cuando el modulo esta activo
		if enabled then
			TargetHUD:Update({ Title = "dodger___", Value = 20, Max = 20 })
			TargetHUD:Show(5)
		end
	end,
})

KillAura:CreateSection("Basicos")

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

KillAura:CreateRangeSlider({
	Name = "CPS",
	Min = 1,
	Max = 20,
	Default = { 8, 12 },
	Increment = 1,
	MinGap = 1,
	Flag = "cps",
	Callback = function(low, high)
		print("CPS:", low, high)
	end,
})

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
	Multi = true,
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
	Callback = function(key)
		print("Nueva tecla:", key)
	end,
	OnPressed = function()
		print("Tecla pulsada")
	end,
})

KillAura:CreateColorPicker({
	Name = "Color",
	Default = Color3.fromRGB(255, 80, 120),
	Flag = "color",
	Callback = function(color)
		print("Color:", color)
		Watermark:SetColor(color) -- ejemplo: el watermark usa el color elegido
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
	Keybind = Enum.KeyCode.N,
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
KillAura:CreateKeybindList({ Name = "Atajos", Height = 150 })

onlyPlayers:SetKeybind(Enum.KeyCode.B)
print("Tecla del toggle:", onlyPlayers:GetKeybind())

task.delay(2, function()
	range:Set(5)
	mode:Set("Switch", true)
	onlyPlayers:SetEnabled(false)
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

-- Modulos que controlan los nuevos elementos
local Overlays = Visual:CreateModule({ Name = "Overlays", Description = "Watermark y paneles", Toggleable = false })
Overlays:CreateToggle({
	Name = "Watermark",
	Default = true,
	Callback = function(v)
		Watermark:SetVisible(v)
	end,
})
Overlays:CreateToggle({
	Name = "Logo",
	Default = false,
	Callback = function(v)
		Logo:SetVisible(v)
	end,
})
Overlays:CreateToggle({
	Name = "Debug",
	Default = false,
	Callback = function(v)
		DebugHUD:SetVisible(v)
	end,
})
Overlays:CreateToggle({
	Name = "Info del servidor",
	Default = false,
	Callback = function(v)
		InfoHUD:SetVisible(v)
	end,
})
Overlays:CreateToggle({
	Name = "Editar posiciones",
	Tooltip = "Arrastra watermark y paneles con el mouse",
	Callback = function(v)
		Watermark:SetEditable(v)
		TargetHUD:SetEditable(v)
		DebugHUD:SetEditable(v)
		InfoHUD:SetEditable(v)
	end,
})

-- Modulo sin interruptor
local Info = Visual:CreateModule({ Name = "Opciones", Toggleable = false, ShowKeybind = false, ShowInHUD = false })
Info:CreateLabel("Modulo sin interruptor: el click solo despliega.")

-- Control de modulos por codigo
Sprint:SetEnabled(true)
Speed:SetPinned(true) -- fijar arriba (Shift + estrella tambien)
KillAura:SetFavorite(true) -- [NUEVO] equivale a pulsar la estrella
Speed:SetVisible(true)
KillAura:SetInfo("Single")
KillAura:SetDescription("Ataca jugadores cercanos (v2)") -- [NUEVO]
print("Favoritos:", #Window:GetFavorites(), "Fijados:", #Window:GetPinned(), "KillAura favorito:", KillAura:IsFavorite())
-- KillAura:Expand() / :Collapse() / :Toggle() / :Destroy()
-- Window:ToggleModule("Sprint")        -- [NUEVO] alternar por nombre
-- Window:ToggleModule("Sprint", true)  -- o fijar el estado

-- ============================================================================
-- 7. COMPONENTE PROPIO
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
ClickGUI:RegisterComponent("Counter", Counter.new)
KillAura:CreateCounter({ Name = "Contador", Callback = print })

-- ============================================================================
-- 8. BUSQUEDA, FAVORITOS, TOOLTIPS, TAMANO, TEMAS
-- ============================================================================
Window:Search("movement", { SearchNames = true, SearchDescriptions = true, SearchCategories = true })
Window:Search("")
Window:SetFavoritesOnly(false) -- true = solo modulos con estrella
Window:SetTooltipsEnabled(true)
Window:SetTitle("My Client") -- [NUEVO] cambiar el titulo en vivo

Window:SetMinSize(UDim2.fromOffset(480, 320))
Window:SetMaxSize(UDim2.fromOffset(1000, 750))
Window:SetPanelWidth(200)
Window:SetScale(nil) -- nil = automatica
Window:ResetLayout()
Window:BringToFront()

Window:SetTheme(THEME)
Window:SetAccent(Color3.fromRGB(255, 0, 120))
Window:SetThemeValue("CornerRadius", 12)
Window:SetThemeValue("Transparency", 0.1)
Window:SetTheme({ Accent = Color3.fromRGB(120, 200, 255) })
local themeData = ClickGUI:ExportTheme()
ClickGUI:ImportTheme(themeData, "Guardado")
Window:SetPalette({ "Violet", "Mocha", "Midnight", "Ink", Color3.fromRGB(255, 80, 120) })
Window:SetTheme(THEME)

-- ============================================================================
-- 9. CATEGORIA DE AJUSTES LISTA
-- ============================================================================
-- [NUEVO] Secciones: Interface, Appearance, Animations, Notifications, HUD, Watermark, TargetHUD, Config, Security
--   Config  : perfiles (guardar/cargar/borrar/lista), Auto Save + Save Interval (slider), Auto Load, layout, JSON
--   Security: toggles Encrypt (CoreGui) y Encrypt Names
Window:CreateSettingsCategory("Settings", {
	HUD = HUD,
	Watermark = Watermark, -- cual watermark controla la seccion
	TargetHUD = TargetHUD, -- cual TargetHUD controla la seccion
	Category = { Group = "General" },
	Sections = {
		"Interface",
		"Appearance",
		"Animations",
		"Notifications",
		"HUD",
		"Watermark",
		"TargetHUD",
		"Config",
		"Security",
	},
})

-- ============================================================================
-- 10. [NUEVO] CONFIGURACION: perfiles, auto save, auto load
-- ============================================================================
-- Que se guarda: valores de TODOS los componentes, estado y teclas de modulos, favoritos/fijados,
-- posiciones/tamanos, tema, escala, animaciones, notificaciones (estilo, posicion, ancho...),
-- ajustes de la ventana, HUD, watermarks y TargetHUDs. Persist = false excluye un componente.
Window:SetAutoSave(true, 45) -- (activado, segundos). Tambien: Window:GetAutoSave() -> activado, segundos
Window:SetAutoLoad(true) -- Window:GetAutoLoad()
Window:SetProfile("default") -- perfil actual (Window:GetProfile())

-- Guardar / cargar perfiles a mano (devuelven true si funcionaron):
-- Window:SaveConfig()            -- guarda el perfil actual
-- Window:SaveConfig("legit")     -- guarda en el perfil "legit"
-- Window:LoadConfig("legit")     -- carga ese perfil
-- Window:DeleteConfig("legit")   -- lo borra
-- Window:LoadAuto()              -- lo mismo que hace AutoLoad (si lo llamas tu, hazlo tras crear todo)
print("Perfiles guardados:", table.concat(Window:ListConfigs(), ", "))

-- JSON (para compartir):
local json = Window:ExportConfig()
Window:ImportConfig(json) -- tambien acepta una tabla y configs de versiones anteriores
print("Valor de flag:", Window:GetFlag("range"))
Window:SetFlag("range", 3, true)
Window:SaveLayout()
Window:LoadLayout()
-- Window:ResetConfig() -- vuelve todo a los valores por defecto (incluye notificaciones)

-- Eventos de la config
Window.ConfigSaved:Connect(function(profile)
	print("Perfil guardado:", profile)
end)
Window.ConfigImported:Connect(function()
	print("Config cargada")
end)

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
	print("Favorito cambiado:", module.Name, module:IsFavorite())
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
-- Style (Modern|Minimal|Banner), Icon, Closable, Progress, OnClick
local handle = ClickGUI:Notify({
	Title = "Con accion",
	Content = "Haz click para ejecutar algo. Las notificaciones largas ya no se solapan: la altura se calcula segun el texto.",
	Type = "Success",
	Style = "Banner",
	Icon = "🎉",
	Duration = 5,
	OnClick = function()
		print("Click en la notificacion")
	end,
})
-- handle:Dismiss()  |  ClickGUI:ClearNotifications()
-- ClickGUI:SetNotificationConfig({ Position = "TopCenter", Scale = 1.1 }) -- cambia en vivo y se guarda
-- ClickGUI:ResetNotificationConfig()

-- ============================================================================
-- 13. SOMBRAS (UIShadow) por separado
-- ============================================================================
-- local shadow = ClickGUI.UIShadow.new({ Parent = miFrame, Preset = "Soft", CornerRadius = 8 })
-- shadow:SetOpacity(0.5); shadow:SetColor(Color3.new(0, 0, 0)); shadow:SetOffset(Vector2.new(0, 4))

-- ============================================================================
-- 14. LIMPIEZA
-- ============================================================================
-- Window:Destroy()        -- solo esta ventana (y los Watermark/TargetHUD creados con Window:Create...)
-- Watermark:Destroy()
-- TargetHUD:Destroy()
-- HUD:Destroy()
-- ClickGUI:Destroy()      -- todo (ventanas, HUDs, watermarks, TargetHUDs, loaders, notificaciones)
-- ClickGUI:Unload()       -- alias de Destroy
