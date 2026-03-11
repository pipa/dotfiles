-- LSP Configuration
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jose-elias-alvarez/null-ls.nvim",
    "jay-babu/mason-null-ls.nvim",
    "j-hui/fidget.nvim",
    "folke/neodev.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀦 ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
        },
      },
    },
    inlay_hints = {
      enabled = true,
    },
    capabilities = {},
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    servers = {
      -- TypeScript / JavaScript
      tsserver = {
        keys = {
          { "<leader>co", "<cmd>TypescriptOrganizeImports<CR>", desc = "Organize Imports" },
          { "<leader>cR", "<cmd>TypescriptRenameFile<CR>", desc = "Rename File" },
        },
        settings = {
          typescript = {
            format = {
              indentSize = "inherit",
            },
          },
          javascript = {
            format = {
              indentSize = "inherit",
            },
          },
          completions = {
            completeFunctionCalls = true,
          },
        },
      },

      -- HTML
      html = {
        filetypes = { "html", "htmldjango" },
      },

      -- CSS
      cssls = {},
      tailwindcss = {},
      styledComponents = {},

      -- JSON
      jsonls = {
        settings = {
          json = {
            format = { enable = true },
            validate = { enable = true },
          },
        },
      },

      -- YAML
      yamlls = {
        settings = {
          yaml = {
            format = { enable = true },
            validate = { enable = true },
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
          },
        },
      },

      -- Markdown
      marksman = {},
      remark_ls = {},

      -- Bash
      bashls = {},

      -- Docker
      dockerls = {},
      docker_compose_language_service = {},

      -- Python
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      },
      ruff_lsp = {},

      -- Go
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            gofumpt = true,
          },
        },
      },

      -- Rust
      rust_analyzer = {
        keys = {
          { "<leader>K", "<cmd>RustHoverActions<CR>", desc = "Hover actions (Rust)" },
          { "<leader>aR", "<cmd>RustCodeActionGroup<CR>", desc = "Code action group (Rust)" },
          { "<leader>er", "<cmd>RustExpandMacro<CR>", desc = "Expand macro (Rust)" },
          { "<leader>tr", "<cmd>RustRunnables<CR>", desc = "Runnables (Rust)" },
        },
      },

      -- Lua
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
              },
            },
          },
        },
      },

      -- Terraform
      terraformls = {},
      tflint = {},

      -- Vue / Svelte
      volar = {},
      svelte = {},

      -- SQL
      sqlls = {},
    },
    setup = {},
  },
  config = function(_, opts)
    -- Setup diagnostics
    for name, icon in pairs(opts.diagnostics.signs.text) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end

    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    -- Setup capabilities
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities(),
      opts.capabilities or {}
    )

    -- Setup LSP servers
    local servers = opts.servers
    local function setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          return
        end
      end
      require("lspconfig")[server].setup(server_opts)
    end

    local have_mason, mlsp = pcall(require, "mason-lspconfig")
    local all_mslp_servers = {}
    if have_mason then
      all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
    end

    local ensure_installed = {}
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts = server_opts == true and {} or server_opts
        if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
          setup(server)
        else
          ensure_installed[#ensure_installed + 1] = server
        end
      end
    end

    if have_mason then
      mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
    end
  end,
}