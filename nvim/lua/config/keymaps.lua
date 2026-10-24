-- 通用快捷键（不依赖插件的部分）。插件相关的键都在各自 lazy spec 的 keys 里声明。
local map = vim.keymap.set

-- 保存 / 退出
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- 插入模式按 jk 退出（等价 Esc，和 vim 里的 inoremap jk <esc> 保持一致）
map("i", "jk", "<Esc>", { desc = "Exit insert mode (jk)" })
-- 双击空格保存（normal / visual，和 vim 里的 <space><space> 保持一致）
map({ "n", "x" }, "<Space><Space>", "<cmd>silent! write<cr>", { desc = "Save file (space space)" })

-- 窗口导航（沿用你在 vim 里的 C-h/j/k/l 习惯）
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- 窗口尺寸（Alt + -/+/方向）
map("n", "<M-=>", "<cmd>resize +3<cr>", { desc = "Increase height" })
map("n", "<M-->", "<cmd>resize -3<cr>", { desc = "Decrease height" })
map("n", "<M-]>", "<cmd>vertical resize +3<cr>", { desc = "Increase width" })
map("n", "<M-[>", "<cmd>vertical resize -3<cr>", { desc = "Decrease width" })

-- 行内移动 / 重排（视觉模式下拖动行）
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join next line, keep cursor" })

-- 滚动时保持光标居中
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll half page up" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centered)" })

-- 剪贴板：粘贴时不覆盖寄存器
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole" })

-- 缓冲区：Tab / Shift-Tab 切换
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Close other buffers" })

-- 快速调整（视觉模式缩进后保持选中）
map("x", "<", "<gv", { desc = "Decrease indent" })
map("x", ">", ">gv", { desc = "Increase indent" })

-- 折行开关（窗口级）：默认折行，想看横着的长行时临时关掉
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. (vim.wo.wrap and "on" or "off"), vim.log.levels.INFO)
end, { desc = "Toggle line wrap" })

-- 重新加载配置文件
map("n", "<leader>R", "<cmd>source $MYVIMRC<cr>", { desc = "Reload init.lua" })
