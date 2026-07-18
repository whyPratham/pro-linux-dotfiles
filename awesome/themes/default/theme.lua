---------------------------
-- Catppuccin Mocha + Sapphire Theme --
---------------------------
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gfs = require("gears.filesystem")
local themes_path = gfs.get_configuration_dir() .. "themes/"

local theme = {}

-- Catppuccin Mocha Palette
local mocha = {
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
	surface0 = "#313244",
	surface1 = "#45475a",
	surface2 = "#585b70",
	text = "#cdd6f4",
	subtext = "#a6adc8",
	sapphire = "#74c7ec",
	lavender = "#b4befe",
	blue = "#89b4fa",
	green = "#a6e3a1",
	yellow = "#f9e2af",
	red = "#f38ba8",
	mauve = "#cba6f7", --accent
	peach = "#fab387",
}

-- =============================
-- ACCENT COLOR — change this one line to switch accent
-- Options: mocha.mauve | mocha.sapphire | mocha.blue | mocha.peach | mocha.green
local accent = mocha.mauve
-- =============================

-- Font
theme.font = "JetBrainsMono Nerd Font 10"

-- Background colors
theme.bg_normal = mocha.base
theme.bg_focus = mocha.surface0
theme.bg_urgent = mocha.red
theme.bg_minimize = mocha.mantle
theme.bg_systray = mocha.base

-- Foreground colors
theme.fg_normal = mocha.text
theme.fg_focus = accent
theme.fg_urgent = mocha.base
theme.fg_minimize = mocha.subtext

-- Gaps and borders
theme.useless_gap = dpi(6)
theme.border_width = dpi(2)
theme.border_normal = mocha.surface1
theme.border_focus = accent
theme.border_marked = mocha.red

-- Taglist
theme.taglist_bg_focus = mocha.surface0
theme.taglist_fg_focus = accent
theme.taglist_bg_occupied = mocha.base
theme.taglist_fg_occupied = mocha.subtext
theme.taglist_bg_empty = mocha.base
theme.taglist_fg_empty = mocha.surface2
theme.taglist_bg_urgent = mocha.red
theme.taglist_fg_urgent = mocha.base

-- Tasklist
theme.tasklist_bg_focus = mocha.surface0
theme.tasklist_fg_focus = accent
theme.tasklist_bg_normal = mocha.base
theme.tasklist_fg_normal = mocha.subtext

-- Titlebar
theme.titlebar_bg_normal = mocha.mantle
theme.titlebar_bg_focus = mocha.surface0
theme.titlebar_fg_normal = mocha.subtext
theme.titlebar_fg_focus = mocha.text

-- Wibar
theme.wibar_bg = mocha.base
theme.wibar_fg = mocha.text
theme.wibar_height = dpi(30)

-- Tooltips
theme.tooltip_bg = mocha.surface0
theme.tooltip_fg = mocha.text
theme.tooltip_border_color = accent
theme.tooltip_border_width = dpi(2)
theme.tooltip_opacity = 1

-- Menu
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
theme.menu_height = dpi(20)
theme.menu_width = dpi(150)
theme.menu_bg_normal = mocha.base
theme.menu_bg_focus = mocha.surface0
theme.menu_fg_normal = mocha.text
theme.menu_fg_focus = accent
theme.menu_border_color = accent
theme.menu_border_width = dpi(2)

-- Hotkeys popup
theme.hotkeys_bg = mocha.base
theme.hotkeys_fg = mocha.text
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_border_color = accent
theme.hotkeys_modifiers_fg = accent
theme.hotkeys_label_bg = mocha.surface0
theme.hotkeys_label_fg = mocha.text
theme.hotkeys_font = "JetBrainsMono Nerd Font 10"
theme.hotkeys_description_font = "JetBrainsMono Nerd Font 10"

-- Notifications
theme.notification_font = "JetBrainsMono Nerd Font 10"
theme.notification_bg = mocha.base
theme.notification_fg = mocha.text
theme.notification_border_color = accent
theme.notification_border_width = dpi(2)
theme.notification_margin = dpi(10)

-- Prompt
theme.prompt_fg = accent
theme.prompt_bg = mocha.base
theme.prompt_fg_cursor = mocha.base
theme.prompt_bg_cursor = accent

-- Taglist squares (disabled in favour of clean text tags)
theme.taglist_squares_sel = nil
theme.taglist_squares_unsel = nil

-- Titlebar buttons
theme.titlebar_close_button_normal = themes_path .. "default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = themes_path .. "default/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themes_path .. "default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themes_path .. "default/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themes_path .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themes_path .. "default/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themes_path .. "default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path .. "default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themes_path .. "default/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = themes_path .. "default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = themes_path .. "default/titlebar/maximized_focus_active.png"

-- Layout icons
theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

-- Awesome icon
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, mocha.surface0, accent)

-- Icon theme
theme.icon_theme = "Papirus"

return theme
