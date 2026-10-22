-- 语言智能层：LSP（mason 自动装 server）+ 补全 + 格式化 + 调试
return {
  -- ===== 语言服务器安装器 =====
  {
    "mason-org/mason.nvim",
    lazy = false,
    priority = 900,
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- ===== LSP 客户端配置（nvim 0.11+ 的 vim.lsp.config / enable 方式）=====
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim" },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          -- 首次启动自动安装；装好的 server 会被自动 vim.lsp.enable()
          ensure_installed = {
            "lua_ls",
            "clangd",
            "pyright",
            "vtsls",
            "bashls",
            "jsonls",
            "yamlls",
            "marksman",
          },
        },
      },
    },
    config = function()
      -- 补全能力（cmp 提供）
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 全局默认：所有 server 都套用
      vim.lsp.config("*", {
        capabilities = capabilities,
        handlers = {
          -- 未使用/多余的代码不要被染灰：LSP 诊断带 DiagnosticTag.Unnecessary(1) 时，
          -- nvim 会追加 DiagnosticUnnecessary 高亮（暗灰色，和注释一样），打字时很难看清。
          -- 这里把 Unnecessary 标记摘掉，保留 Deprecated(2) 的删除线提示。
          ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            if result and result.diagnostics then
              for _, d in ipairs(result.diagnostics) do
                if d.tags then
                  local keep = {}
                  for _, tag in ipairs(d.tags) do
                    if tag ~= 1 then
                      keep[#keep + 1] = tag
                    end
                  end
                  d.tags = #keep > 0 and keep or nil
                end
              end
            end
            return vim.lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
          end,
        },
        on_attach = function(client, bufnr)
          -- 你不喜欢 inlay hints，这里对所有 server 强制关闭
          if client.server_capabilities.inlayHintProvider then
            pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
          end
        end,
      })

      -- hint 级诊断（比如 TS 的“声明了但没被引用”）只在 sign 列留一个小标记，
      -- 不在代码上画波浪线；error / warning 的波浪线保持不变。
      vim.diagnostic.config({
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
      })

      -- 逐个 server 的细节配置
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
            hint = { enable = false }, -- 关掉 lua_ls 自带的 inlay hint
          },
        },
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--fallback-style=Google",
          "--function-arg-placeholders=false",
        },
        init_options = { usePlaceholders = false },
        capabilities = (function()
          local caps = vim.deepcopy(require("cmp_nvim_lsp").default_capabilities())
          caps.textDocument.completion.completionItem.snippetSupport = false
          return caps
        end)(),
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              inlayHints = { variableTypes = false, functionReturnTypes = false, callArgumentNames = false },
            },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            schemaStore = { enable = false },
            validate = true,
          },
        },
      })

      vim.lsp.config("vtsls", {
        settings = {
          typescript = {
            inlayHints = { parameterNames = false, variableTypes = false, propertyDeclarationTypes = false },
          },
        },
      })

      -- 显式启用（mason-lspconfig 也会自动 enable，这里双重保险且不重复）
      vim.lsp.enable({ "lua_ls", "clangd", "pyright", "vtsls", "bashls", "jsonls", "yamlls", "marksman" })
    end,
  },

  -- ===== 补全 =====
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "", Field = "󰜢",
              Variable = "󰀫", Class = "󰠱", Interface = "", Module = "", Property = "󰜢",
              Unit = "󰑭", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "",
              Color = "󰏘", File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕", TypeParameter = "",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
            item.menu = ({
              nvim_lsp = "[LSP]",
              buffer = "[Buf]",
              path = "[Path]",
              luasnip = "[Snip]",
            })[entry.source.name]
            return item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        experimental = { ghost_text = false },
      })
    end,
  },

  -- ===== 保存自动格式化 / 手动 <leader>cf =====
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        cuda = { "clang_format" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        go = { "gofmt" },
        rust = { "rustfmt" },
      },
      formatters = {
        -- 走 ~/.clang-format（已软链到 dotfiles/clang-format），找不到就用 Google
        clang_format = {
          prepend_args = { "--style=file", "--fallback-style=Google" },
        },
      },
      -- 保存时格式化：白名单 + 明确排除 markdown（尊重你「md 不自动格式化」的规则）
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "markdown" or ft == "markdown.mdx" then
          return nil
        end
        local enabled = {
          c = true, cpp = true, objc = true, cuda = true,
          python = true, javascript = true, javascriptreact = true,
          typescript = true, typescriptreact = true,
          json = true, jsonc = true, css = true, scss = true,
          html = true, yaml = true, sh = true, bash = true, lua = true,
        }
        if not enabled[ft] then
          return nil
        end
        return { timeout_ms = 1500, lsp_format = "never" }
      end,
    },
  },

  -- ===== 调试（DAP）：C/C++ 用 codelldb，Python 用 debugpy =====
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      { "jay-babu/mason-nvim-dap.nvim", dependencies = { "mason-org/mason.nvim" } },
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Start/Continue debugging" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Conditional breakpoint: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug panel" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Evaluate", mode = { "n", "v" } },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Rerun last session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate session" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy" },
        automatic_installation = true,
        handlers = {},
      })

      require("nvim-dap-virtual-text").setup({})

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "" },
        controls = {
          enabled = true,
          element = "repl",
          icons = { pause = "", play = "", step_into = "", step_over = "", step_out = "", step_back = "", run_last = "", terminate = "" },
        },
        floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
      })

      dap.listeners.after.event_initialized["user_dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["user_dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["user_dapui"] = function() dapui.close() end

      -- C/C++：codelldb 由 mason 安装
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = "codelldb", args = { "--port", "${port}" } },
      }

      local function pick_program()
        return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/", "file")
      end

      local cpp_configs = {
        {
          name = "Launch program",
          type = "codelldb",
          request = "launch",
          program = pick_program,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch program (with args)",
          type = "codelldb",
          request = "launch",
          program = pick_program,
          args = function()
            local input = vim.fn.input("Program arguments: ")
            return vim.split(input, " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.c = cpp_configs
      dap.configurations.cpp = cpp_configs

      -- Python：用 mason 安装的 debugpy
      local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if vim.uv.fs_stat(debugpy_python) then
        dap.adapters.python = {
          type = "executable",
          command = debugpy_python,
          args = { "-m", "debugpy.adapter" },
        }
      end
      dap.configurations.python = {
        {
          name = "Launch file",
          type = "python",
          request = "launch",
          program = "${file}",
          pythonPath = function()
            return vim.fn.exepath("python3") or "python3"
          end,
          console = "integratedTerminal",
          justMyCode = false,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
