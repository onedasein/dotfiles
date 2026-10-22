-- Neovide 专属设置。终端里跑 nvim 时这段完全不执行（vim.g.neovide 为 nil）。
-- 应用级配置（窗口大小/边框）在 ~/.config/neovide/config.toml，见仓库 README。
-- 这套设置 Windows 版 Neovide（neovide.exe --wsl）和 WSLg 版共用，
-- 带 "仅 Windows" 注释的几项在 WSLg 下会被 Neovide 忽略。
if not vim.g.neovide then
	return
end

-- 字体不在这里设，写在 neovide 的 config.toml / neovide.toml 的 [font] 段里。
-- 原因：Neovide 解析 guifont 时会整体替换字体选项（caching_shaper.rs 的
-- update_font_options 末尾 `self.options = options`），config 里的 [font.features]
-- 会被一起丢掉，连字（calt/liga）就关不掉了。两端共用同一份 toml，回退家族也在那里写。
vim.o.linespace = 1

vim.g.neovide_scale_factor = 1.0
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_confirm_quit = false
vim.g.neovide_detach_on_quit = "always_quit"
vim.g.neovide_hide_mouse_when_typing = true

-- 外观：Win11 圆角（仅 Windows，0.16+）+ 画面留白
vim.g.neovide_corner_preference = "round"
vim.g.neovide_padding_top = 6
vim.g.neovide_padding_bottom = 6
vim.g.neovide_padding_left = 8
vim.g.neovide_padding_right = 8

-- 主题：0.16+ 支持 "light" / "dark" / "auto"。
-- 亮色主题必须写 light：默认 auto 会跟随系统，系统是深色时标题栏和系统配色会变深。
vim.g.neovide_theme = "light"

-- 标题栏配色（仅 Windows；标题栏平时被 GlazeWM 隐藏，这里只是兜底用）
-- 亮色主题下用米白底 + 深灰字，和窗口内容连成一片。
vim.g.neovide_title_background_color = "#eff1f5"
vim.g.neovide_title_text_color = "#4c4f69"

-- 浮动窗口（telescope / noice 的命令行与补全菜单 / hover 等）：影子 + 圆角 + 轻微模糊
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 12
vim.g.neovide_light_angle_degrees = 50
vim.g.neovide_light_radius = 6
vim.g.neovide_floating_corner_radius = 0.35
vim.g.neovide_floating_blur_amount_x = 3.0
vim.g.neovide_floating_blur_amount_y = 3.0

-- 透明度：1.0 = 完全不透明。亮色 + 米白背景必须关掉透明，
-- 否则会透出桌面/其他窗口的深色内容，白色看起来发灰。
-- 想重新要透明效果就把这两个值调回 0.85 左右。
vim.g.neovide_opacity = 1.0
vim.g.neovide_normal_opacity = 1.0

-- 动效：短一点更跟手，太长会晕
vim.g.neovide_position_animation_length = 0.12
vim.g.neovide_scroll_animation_length = 0.18
vim.g.neovide_scroll_animation_far_lines = 6
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_short_animation_length = 0.02
vim.g.neovide_cursor_trail_size = 0.6
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_vfx_mode = "" -- 想要拖尾粒子：railgun / torpedo / pixiedust

-- 缩放快捷键（0.5x ~ 2.5x，超出不响应）
local map = vim.keymap.set
local function zoom(delta)
	local scale = (vim.g.neovide_scale_factor or 1.0) + delta
	if scale < 0.5 or scale > 2.5 then
		return
	end
	vim.g.neovide_scale_factor = scale
end
map("n", "<C-=>", function()
	zoom(0.1)
end, { desc = "Zoom in" })
map("n", "<C-->", function()
	zoom(-0.1)
end, { desc = "Zoom out" })
map("n", "<C-0>", function()
	vim.g.neovide_scale_factor = 1.0
end, { desc = "Reset zoom" })

-- 工作目录：Windows 版 Neovide 从 Windows 路径启动时，nvim 的 cwd 会落在
-- /mnt/c/... （C 盘）。没有任何文件参数时，直接切回 WSL 家目录，
-- 这样 :e / :Ex / terminal 默认都落在 ~ 而不是 C 盘。
-- 打开的是目录或文件时不干预（声明了参数就尊重参数）。
if vim.fn.getcwd():match("^/mnt/") and vim.fn.argc() == 0 then
	vim.cmd.cd(vim.fn.expand("~"))
end
