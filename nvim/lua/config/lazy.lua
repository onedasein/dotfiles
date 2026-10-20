-- lazy.nvim 引导：首次启动自动 clone，然后加载 lua/plugins/ 下所有文件
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim bootstrap failed:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = false }, -- 不自动检查更新，手动 :Lazy update
  change_detection = { notify = false },
  ui = {
    border = "rounded",
    icons = { cmd = " ", config = "🛠", event = "📅", ft = "📂", init = "⚙",
      import = "📦", keys = "⌨", lazy = "💤", loaded = "●", not_loaded = "○",
      plugin = "🔌", runtime = "🧩", require = "📦", source = "📄", start = "🚀",
      task = "📌" },
  },
})
