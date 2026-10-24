-- 编辑器基础选项：对齐 ~/dotfiles 里 vimrc 的老习惯（4 空格、相对行号、共享剪贴板……）
local opt = vim.opt

-- ===== 行号 / 光标 =====
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- ===== 缩进：tab = 4 空格 =====
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true

-- ===== 搜索 =====
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- ===== 界面 =====
opt.termguicolors = true
-- 必须显式设置：Neovide 0.16 起会按系统主题自动改这个选项。这里按运行环境钉死：
-- Neovide 保持 master 的深色配色，终端里的 nvim 用亮色。
opt.background = vim.g.neovide and "dark" or "light"
opt.mouse = "a"
opt.mousescroll = "ver:3,hor:6"
opt.splitright = true
opt.splitbelow = true
opt.showmode = false          -- lualine 已经显示模式
opt.ruler = false
opt.laststatus = 3            -- 全局状态栏（lualine）
opt.cmdheight = 0             -- noice.nvim 接管命令行，留 0 行更干净
opt.pumheight = 12
opt.winborder = "rounded"     -- 0.11+：浮动窗口圆角边框
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "" }
opt.completeopt = { "menuone", "noselect" }
opt.shortmess:append({ I = true, c = true, C = true })

-- ===== 折行：半屏 / 窄分屏时一行也不丢内容 =====
-- 默认折行：文档、注释、长行代码都按窗口宽度换行，不用左右滚（Neovide + 平铺半屏时最明显）。
-- breakindent 让续行跟随原行缩进，showbreak 用 ↪ 标出「这是折行，不是真的换行」。
-- 偶尔要看不可折的超长行（minified JSON、单行 data URI）时按 <leader>uw 在当前窗口临时关掉。
opt.wrap = true
opt.linebreak = true          -- 只在空白/词边界断行，不把英文单词切开
opt.breakindent = true
opt.showbreak = "↪ "
opt.foldlevel = 99
opt.foldlevelstart = 99

-- ===== 文件 / 撤销 / 剪贴板 =====
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.autoread = true
opt.confirm = true
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.clipboard = "unnamedplus" -- WSLg 下走 xclip/wl-copy；Neovide 自己也有剪贴板通道
opt.updatetime = 250
opt.timeoutlen = 400
opt.ttimeoutlen = 50

-- ===== 杂项 =====
opt.history = 500
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
