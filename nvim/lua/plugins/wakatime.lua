-- 编码时长统计（WakaTime）：把 vim-wakatime 插件挂进 lazy。
-- 插件本身只负责收集心跳并调用 wakatime-cli；配置与 key 都在 ~/.wakatime.cfg /
-- 环境变量里，不进本仓库。
return {
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
    init = function()
      -- 复用已在 ~/.wakatime 装好的 CLI，避免插件重复下载一份
      vim.g.wakatime_CLIPath = vim.fn.expand("~/.wakatime/wakatime-cli")
    end,
  },
}
