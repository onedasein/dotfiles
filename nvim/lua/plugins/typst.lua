return {
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		version = "1.*",
		keys = {
			{ "<leader>tp", "<cmd>TypstPreview<cr>", desc = "启动Typst预览"},
			{ "<leader>ts", "<cmd>TypstPreviewStop<cr>", desc = "停止Typst预览"},
			{ "<leader>tt", "<cmd>TypstPreviewToggler<cr>", desc = "切换Typst预览"},
		},
		opts = {},
	},
}
