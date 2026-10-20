-- 自动命令：treesitter 高亮/折叠、注释不自动延续、光标位置恢复、yank 高亮
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- 关闭「注释自动延续」（和 ~/dotfiles 里 vime_no_comment_continue 等价）
-- o = Normal 模式 o/O 后自动补注释符；r = 插入模式回车后自动补注释符
autocmd("FileType", {
  group = augroup,
  callback = function()
    vim.opt_local.formatoptions:remove({ "o", "r" })
  end,
})

-- Treesitter：有 parser 的语言自动开高亮 + 折叠，没有就安静跳过
autocmd("FileType", {
  group = augroup,
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      return
    end
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldlevel = 99
    -- C/C++ 用 treesitter 的缩进太激进，保留 smartindent 的默认行为
    if vim.tbl_contains({ "c", "cpp", "objc", "cuda" }, vim.bo[args.buf].filetype) then
      vim.bo[args.buf].indentexpr = ""
    end
  end,
})

-- 打开文件时回到上次编辑位置
autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- yank 时短暂高亮
autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 窗口大小变化时平均分配
autocmd("VimResized", {
  group = augroup,
  command = "tabdo wincmd =",
})

-- 打开帮助/终端等特殊 buffer 时不做相对行号（更清爽）
autocmd("FileType", {
  group = augroup,
  pattern = { "help", "lazy", "mason", "Trouble", "neo-tree", "notify" },
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.cursorline = false
  end,
})

-- LSP 挂载到 buffer 后设置局部快捷键
autocmd("LspAttach", {
  group = augroup,
  callback = function(event)
    local buf = event.buf
    local function map(keys, fn, desc, modes)
      vim.keymap.set(modes or "n", keys, fn, { buffer = buf, desc = desc })
    end
    local tb = require("telescope.builtin")

    map("gd", tb.lsp_definitions, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gi", tb.lsp_implementations, "Go to implementation")
    map("gr", tb.lsp_references, "Find references")
    map("gy", tb.lsp_type_definitions, "Type definition")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("gK", vim.lsp.buf.signature_help, "Function signature")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
    map("<leader>cf", function()
      require("conform").format({ async = true, lsp_format = "never" })
    end, "Format", { "n", "x" })
    map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("<leader>cl", vim.lsp.codelens.run, "CodeLens")
    map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
    map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
    map("<leader>ci", "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls")
    map("<leader>co", "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls")
  end,
})
