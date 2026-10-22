-- WezTerm 配置（niri / Wayland）
-- 文件位置: ~/.config/wezterm/wezterm.lua
-- 修改后无需重启 WezTerm：它会在保存时自动重载（除少数设置外）。
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 默认 shell
config.default_prog = { "/usr/bin/bash", "-l" }
config.default_cwd = wezterm.home_dir

-- 字体：Nerd Font 图标 + 中文字体回退（写代码/看中文都不缺字）
-- 与 Alacritty、Neovide 保持一致，都用 FiraCode Nerd Font
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"Noto Sans Mono CJK SC",
	"Noto Sans CJK SC",
})
config.font_size = 14.0

-- 关连字：WezTerm 走 harfbuzz，默认开启 calt/liga/clig/dlig，
-- 所以 "->" "!=" "=>" "ffi" 会被合并成单字形。全部置 0 关掉，
-- 效果和 Alacritty（根本不支持连字）一致。
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0", "dlig=0" }

-- 配色与外观
-- 亮色主题：Catppuccin Latte 原生米白底 #eff1f5（比纯白柔和，久看不刺眼）。
-- 不用内置 color_scheme，逐项写死方便单独微调；想更白就改下面 background。
-- Latte 的 white 是 #acb0be，在米白底上几乎看不见，第 8 个 ansi 色加深成 overlay0。
config.colors = {
	foreground = "#4c4f69",
	background = "#eff1f5",
	cursor_bg = "#dc8a78",
	cursor_fg = "#eff1f5",
	cursor_border = "#dc8a78",
	selection_fg = "#4c4f69",
	selection_bg = "#ccd0da",
	scrollbar_thumb = "#ccd0da",
	split = "#dce0e8",
	ansi = {
		"#5c5f77",
		"#d20f39",
		"#40a02b",
		"#df8e1d",
		"#1e66f5",
		"#8839ef",
		"#179299",
		"#6c6f85",
	},
	brights = {
		"#6c6f85",
		"#d20f39",
		"#40a02b",
		"#df8e1d",
		"#1e66f5",
		"#8839ef",
		"#179299",
		"#8c8fa1",
	},
}
-- 1.0 = 完全不透明；亮色米白底必须不透明，否则会透出桌面。
-- 想再要「透出桌面」就调回 0.9 左右。
config.window_background_opacity = 1.0
config.window_decorations = "NONE" -- 无边框，交给 niri 平铺管理
config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
config.initial_cols = 110
config.initial_rows = 30

-- Wayland / 输入法
config.enable_wayland = true

-- 标签栏（只有多个标签时出现）
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- 杂项
config.window_close_confirmation = "NeverPrompt"
config.check_for_updates = false
config.scrollback_lines = 20000
config.audible_bell = "Disabled"

-- 复制粘贴键位
-- 1) Ctrl+Shift+C / Ctrl+Shift+V：终端圈的老规矩，明确绑定
-- 2) Ctrl+V：直接粘贴（很多人习惯 Ctrl+V，就在终端里也让它工作）
-- 3) Ctrl+C：有选中内容时=复制；没有选中时=照旧发送 ^C 中断（不会挡住 Ctrl+C 杀进程）
--    若想 Ctrl+C 永远只发中断，删掉最后那条 callback 即可
-- 4) Ctrl+Insert / Shift+Insert：X11 老习惯
config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "Insert", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "Insert", mods = "SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			-- pcall 兜底：万一这个 API 不存在，就退回发 ^C，绝不会让 Ctrl+C 失效
			local ok, sel = pcall(function()
				return window:get_selection_text_for_pane(pane)
			end)
			if ok and sel and sel ~= "" then
				window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
			else
				window:perform_action(wezterm.action.SendString("\x03"), pane)
			end
		end),
	},
}

return config
