-- 界面层：主题、状态栏、标签栏、提示浮窗、缩进线、图标
return {
	-- 主题：tokyonight（你在 vim 里就用它，这里延续同一套配色）
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "moon",
			transparent = false,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				sidebars = { "qf", "help", "neo-tree", "Trouble" },
				floats = "dark",
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- 图标（neo-tree / lualine / telescope 都要）
	{ "nvim-tree/nvim-web-devicons", lazy = true, opts = { default = true } },

	-- 状态栏
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				theme = "tokyonight",
				globalstatus = true,
				icons_enabled = true,
				section_separators = { left = "", right = "" },
				component_separators = { left = "│", right = "│" },
				disabled_filetypes = { statusline = { "dashboard", "alpha", "lazy", "mason" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "branch" },
					{ "diff" },
					{ "diagnostics" },
				},
				lualine_c = {
					{ "filename", path = 1, symbols = { modified = " ●", readonly = " 󰌾", newfile = " 󰎔" } },
				},
				lualine_x = { "filetype", "encoding", "fileformat" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		},
	},

	-- 顶部缓冲区标签栏
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				mode = "buffers",
				numbers = "none",
				indicator = { style = "underline" },
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 24,
				tab_size = 20,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
				separator_style = "thin",
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = false,
				always_show_bufferline = true,
				sort_by = "id",
			},
		},
		keys = {
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
			{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
			{ "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
			{ "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
		},
	},

	-- 按键提示
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "classic",
			win = { border = "rounded", padding = { 1, 2 } },
			spec = {
				{ "<leader>b", group = "Buffers/Tabs" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>r", group = "Refactor" },
				{ "<leader>t", group = "Terminal" },
				{ "<leader>x", group = "Diagnostics/List" },
			},
		},
	},

	-- 命令行 / 通知美化
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			routes = {
				-- 保存时别刷 "written" 消息
				{ filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
			},
			views = {
				cmdline_popup = {
					border = { style = "rounded" },
					position = { row = "50%", col = "50%" },
					size = { width = 60, height = "auto" },
				},
				popupmenu = {
					border = { style = "rounded" },
				},
			},
		},
	},

	{
		"rcarriga/nvim-notify",
		lazy = true,
		opts = {
			timeout = 2000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
	},

	-- 缩进参考线
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			indent = { char = "│", tab_char = "│" },
			scope = { enabled = true, show_start = false, show_end = false },
			exclude = {
				filetypes = { "help", "alpha", "dashboard", "lazy", "mason", "neo-tree", "Trouble", "toggleterm" },
			},
		},
	},
	vim.api.nvim_set_hl(0, "LineNr", { fg = "#8A8A8A", bg = "NONE" }),
}
