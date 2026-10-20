-- 编辑器层：查找、文件树、Git、诊断列表、文本操作、终端、Markdown 渲染
return {
  -- 模糊查找（IDE 的 Ctrl+P / Ctrl+Shift+F）
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Word under cursor" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fC", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy find in file" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "  ",
          selection_caret = "  ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
            preview_width = 0.55,
            horizontal = { preview_width = 0.55 },
          },
          border = true,
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          path_display = { "smart" },
          file_ignore_patterns = { "node_modules", "%.git/", "dist/", "build/", "__pycache__", "%.o$", "%.pdf$" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
            n = { ["<esc>"] = actions.close, ["q"] = actions.close },
          },
        },
        pickers = {
          find_files = { hidden = true },
          buffers = {
            sort_lastused = true,
            mappings = { i = { ["<C-d>"] = actions.delete_buffer } },
          },
          colorscheme = { enable_preview = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- 文件树（取代 NERDTree）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus file tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { with_markers = true, indent_marker = "│", last_indent_marker = "└", expander_collapsed = "󰅂", expander_expanded = "󰅀" },
        git_status = { symbols = { added = "✚", modified = "󰏫", deleted = "✖", renamed = "󰁕", untracked = "?", ignored = "◌", unstaged = "󰄱", staged = "", conflict = "" } },
      },
      window = {
        width = 34,
        mappings = {
          ["<space>"] = "none",
          ["<cr>"] = "open",
          ["o"] = { "open", config = { use_float = false } },
          ["l"] = "open",
          ["h"] = "close_node",
          ["a"] = { "add", config = { show_path = "relative" } },
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["/"] = "filter_on_submit",
          ["q"] = "close_window",
        },
      },
      filesystem = {
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git", "__pycache__" },
        },
      },
      buffers = {
        follow_current_file = { enabled = true },
        show_unloaded = true,
      },
      git_status = { window = { position = "float" } },
    },
  },

  -- Git 标记 + hunk 操作
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = { add = { text = "▎" }, change = { text = "▎" } },
      current_line_blame = false,
      preview_config = { border = "rounded" },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Previous hunk")
        map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Line blame")
        map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
      end,
    },
    keys = {
      { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
      { "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff this file" },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview changes" },
      { "<leader>gs", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage whole file" },
      { "<leader>gu", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset whole file" },
    },
  },

  -- 诊断 / 符号 / 引用列表（取代 quickfix 的现代版）
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols outline" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP references/definitions" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "quickfix" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "loclist" },
    },
    opts = {
      auto_close = false,
      focus = false,
      win = { border = "rounded" },
    },
  },

  -- TODO / FIXME 高亮与检索
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "All TODOs" },
      { "<leader>]t", "<cmd>TodoLocList<cr>", desc = "Document TODOs" },
    },
  },

  -- 快速跳转（s / S）
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { jump_labels = true } }, label = { uppercase = false } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Jump by syntax node" },
    },
  },

  -- mini.nvim：文本对象 / 包围 / 自动括号 / 注释 / 移动 / 缓冲区删除
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
      require("mini.pairs").setup()
      require("mini.comment").setup()
      require("mini.bufremove").setup()
      -- 用 Alt+方向 移动行（避开 visual 模式 J/K 的自定义映射）
      require("mini.move").setup({
        mappings = { left = "<M-h>", right = "<M-l>", down = "<M-j>", up = "<M-k>", line_down = "<M-j>", line_up = "<M-k>" },
      })
    end,
  },

  -- 终端
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=12 direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical terminal" },
    },
    opts = {
      size = 14,
      open_mapping = [[<M-\>]],
      insert_mappings = false,
      terminal_mappings = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = { border = "rounded", winblend = 0 },
    },
  },

  -- Markdown 渲染（标题、代码块、表格在编辑器内直接好看）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = { sign = false },
      code = { sign = false, width = "block", right_pad = 1 },
      bullet = { right_pad = 1 },
    },
  },

  -- diff 视图
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
