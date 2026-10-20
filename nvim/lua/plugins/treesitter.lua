-- Treesitter：语法高亮 / 折叠 / 缩进。
-- 注意：main 分支不支持 lazy-loading，必须 lazy=false；parser 用 `:TSUpdate` 维护。
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- 常用语言；没装的第一次启动会异步下载编译（需要 tree-sitter CLI + gcc）
      require("nvim-treesitter").install({
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "bash",
        "html",
        "css",
        "dockerfile",
        "gitcommit",
        "gitignore",
        "rust",
        "go",
        "cmake",
        "comment",
        "regex",
        "latex",
      })
    end,
  },
}
