-- My Neovim Config

local function setupFrontends()
  if vim.g.neovide then
    vim.g.neovide_refresh_rate = 140
    vim.opt.guifont = { "JetBrains Mono", ":h12" }
    vim.g.neovide_cursor_animation_length = 0
  end
end

local function setupOptions()
  -- leader key
  vim.g.mapleader = " "

  -- options
  local options = {
    backup = false,
    swapfile = false,
    undofile = true,
    fileencoding = 'utf-8',

    termguicolors = true,

    showmode = false,

    splitbelow = true,
    splitright = true,

    laststatus = 3,

    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,

    cursorline = true,

    number = true,
    relativenumber = true,

    wrap = false,
    scrolloff = 10,
  }

  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  local globals = {
    netrw_browsex_viewer = "powershell.exe start",
    completeopt = 'menu,menuone,noinsert,noselect'
  }

  for k, v in pairs(globals) do
    vim.g[k] = v
  end
end

local function setupPlugins()
  local function bootstrap_pckr()
    local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

    if not vim.loop.fs_stat(pckr_path) then
      vim.fn.system({
        'git',
        'clone',
        "--filter=blob:none",
        'https://github.com/lewis6991/pckr.nvim',
        pckr_path
      })
    end

    vim.opt.rtp:prepend(pckr_path)
  end

  bootstrap_pckr()

  require('pckr').add {
    {
      'nvim-treesitter/nvim-treesitter',
      build = ":TSUpdate",
      config = function()
        require('nvim-treesitter').setup {}
      end,
  }, {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    requires = { 'nvim-lua/plenary.nvim' },
  }, {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {
        check_ts = true,
      }
    end,
  }, {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('ibl').setup {
        show_current_context = true,
      }
    end,
  }, {
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {
        renderer = {
          indent_markers = {
            enable = true,
          },
        }
      }
    end,
  }, {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {}
    end,
  }, {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('symbols-outline').setup {}
    end,
  }, {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  }, {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {}
    end,
  }, {
    "NeogitOrg/neogit",
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('neogit').setup {}
    end
  }, {
    "ahmedkhalf/project.nvim",
    requires = 'nvim-telescope/telescope.nvim',
    config = function()
      require("project_nvim").setup {
        require("telescope").load_extension('projects')
      }
    end
  }
  }

  local function setupLSP()
    require('pckr').add {
      "neovim/nvim-lspconfig",
      {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
          require("lsp_lines").setup {}
          vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = {
              only_current_line = true,
              hightlight_whole_line = false,
            }
          })
        end,
      }, {
        "simrat39/rust-tools.nvim"
      }, {
      "ray-x/lsp_signature.nvim",
      config = function()
        require("lsp_signature").setup {}
      end,
      }
    }

    local lspconfig = require('lspconfig')
    local servers = { 'rust_analyzer', 'clangd', 'zls', 'gopls', 'lua_ls' }

    local attach_codelens_refresh = function(client, bufnr)
      local status_ok, codelens_supported = pcall(function()
        return client.supports_method "textDocument/codeLens"
      end)
      if not status_ok or not codelens_supported then
        return
      end
      local group = "lsp_code_lens_refresh"
      local cl_events = { "CursorHold", "CursorHoldI", "InsertLeave" }
      local ok, cl_autocmds = pcall(vim.api.nvim_get_autocmds, {
        group = group,
        buffer = bufnr,
        event = cl_events,
      })

      if ok and #cl_autocmds > 0 then
        return
      end
      vim.api.nvim_create_augroup(group, { clear = false })
      vim.api.nvim_create_autocmd(cl_events, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
      })
      print("Hello World")
    end

    local on_attach = function(client, bufnr)
      attach_codelens_refresh(client, bufnr)
    end

    require('rust-tools').setup {
      server = {
        on_attach = on_attach
      }
    }
    lspconfig.clangd.setup{
      on_attach = on_attach
    }
    lspconfig.zls.setup{
      on_attach = on_attach
    }
    lspconfig.gopls.setup{
      on_attach = on_attach
    }
    lspconfig.lua_ls.setup{
      on_attach = on_attach,
      settings = {
        lua = {
          diagnostics = {
            globals = { 'vim' }
          }
        }
      }
    }
  end
  setupLSP()
end

local function setupKeymaps()
  require('pckr').add {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end
  }
  require('which-key').setup {}
  local wk = require('which-key')

  local map = function(mode, l, r, desc)
    vim.api.nvim_set_keymap(mode, l, r, { desc = desc, noremap = true, silent = true })
  end

  -- indent
  map('v', '>', '>gv', 'Indent Right')
  map('v', '<', '<gv', 'Indent Left')

  -- comment
  map('v', '<leader>/', 'gc', 'Comment')
  map('n', '<leader>/', 'gcc', 'Uncomment')

  -- terminal
  map('t', '<esc>', '<c-\\><c-n>', 'Exit Terminal')

  -- lsp
  wk.register({
    l = {
      name = '[l]sp',
    }
  }, { prefix = '<leader>' })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      vim.api.nvim_buf_set_option(ev.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      map('n', '<leader>le', '<cmd>lua vim.diagnostic.open_float()<cr>', 'Op[e]n Float')
      map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev({ float = false })<cr>', 'Prev Diagnostic')
      map('n', ']d', '<cmd>lua vim.diagnostic.goto_next({ float = false })<cr>', 'Next Diagnostic')
      map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help')
      map('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help')

      local buf_map = function(l, r, desc)
        vim.api.nvim_buf_set_keymap(ev.buf, 'n', l, r, { desc = desc, noremap = true, silent = true })
      end

      buf_map('<leader>ld', '<cmd>Telescope lsp_definitions<cr>', '[d]efinition')
      buf_map('<leader>lD', '<cmd>Telescope lsp_declarations<cr>', '[D]eclaration')
      buf_map('<leader>lt', '<cmd>Telescope lsp_type_definitions<cr>', '[t]ype Definition')
      buf_map('<leader>lr', '<cmd>lua vim.lsp.buf.references()<cr>', '[r]eferences')
      buf_map('<leader>li', '<cmd>Telescope lsp_implementations<cr>', '[i]mplementation')
      buf_map('<leader>lw', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', '[w]orkspace symbol')
      buf_map('<leader>lb', '<cmd>Telescope lsp_document_symbols<cr>', '[b]uffer symbol')
      buf_map('<leader>lh', '<cmd>lua vim.lsp.buf.hover()<cr>', '[h]over')
      buf_map('<leader>lc', '<cmd>lua vim.lsp.codelens.run()<cr>', '[c]odelens')
    end,
  })

  -- Config
  wk.register({
    c = {
      name = '[c]onfig',
      o = { ":e ~/.config/nvim/init.lua<cr>", "[o]pen" },
      l = { ":source ~/.config/nvim/init.lua<cr>", "[l]oad" }
    }
  }, { prefix = '<leader>' })

  -- Find
  wk.register({
    f = {
      name = '[f]ind',
      b = { "<cmd>Telescope buffers<cr>", "[b]uffer" },
      f = { '<cmd>Telescope find_files<cr>', 'Find [f]ile' },
      g = { '<cmd>Telescope git_files<cr>', 'Find [g]it File' },
      l = { '<cmd>Telescope live_grep<cr>', '[l]ive grep' },
      h = { '<cmd>Telescope help_tags<cr>', '[h]elp tags' },
      k = { '<cmd>Telescope keymaps<cr>', '[k]ey maps' },
      c = { '<cmd>Telescope commands<cr>', '[k]ey maps' },
      ['/'] = { '<cmd>Telescope resume<cr>', 'Resume' },
    }
  }, { prefix = '<leader>' })

  -- Explorer
  wk.register({
    e = {
      name = '[e]xplore',
      o = { '<cmd>NvimTreeOpen<cr>', '[o]pen Explorer' },
      c = { '<cmd>NvimTreeClose<cr>', '[c]lose Explorer' },
      t = { '<cmd>NvimTreeToggle<cr>', '[t]oggle Explorer' },
      f = { '<cmd>NvimTreeFindFile<cr>', '[F]ind file' }
    }
  }, { prefix = '<leader>' })

  -- symbols
  wk.register({
    s = {
      name = '[s]ymbol',
      o = { '<cmd>SymbolsOutlineOpen<cr>', '[o]pen Symbols' },
      c = { '<cmd>SymbolsOutlineClose<cr>', '[c]lose Symbols' },
      t = { '<cmd>SymbolsOutline<cr>', '[t]oggle Symbols' },
    }
  }, { prefix = '<leader>' })

  -- Projects
  wk.register({
    p = {
      name = '[p]roject',
      o = { '<cmd>Telescope projects<cr>', '[o]pen' },
    }
  }, { prefix = '<leader>' })

  -- Buffers
  wk.register({
    b = {
      name = '[b]uffer',
      n = { '<cmd>bnext<cr>', '[n]ext' },
      p = { '<cmd>bprev<cr>', '[p]rev' },
    }
  }, { prefix = '<leader>' })

  -- Quickfix
  wk.register({
    q = {
      name = '[q]uickfix',
      n = { '<cmd>cnext<cr>', '[n]ext' },
      p = { '<cmd>cprev<cr>', '[p]rev' },
      o = { '<cmd>copen<cr>', '[o]pen' },
      c = { '<cmd>cclose<cr>', '[c]lose' },
    }
  }, { prefix = '<leader>' })
end

local function setupColorschemes()
  require('pckr').add {
    {
      'catppuccin/nvim',
      name = "catppuccin",
      config = function()
        require('catppuccin').setup {
          dim_inactive = {
            enabled = true,
            shade = 'dark',
            percentage = 0.3,
          },
        }
      end,
    }, {
    'morhetz/gruvbox',
  }, {
    'projekt0n/github-nvim-theme',
    config = function()
      vim.cmd([[let g:edge_style = 'light']])
    end,
  }, {
    'rose-pine/neovim',
    name = 'rose-pine'
  }, {
    'folke/tokyonight.nvim',
  }, {
    'pappasam/papercolor-theme-slim',
  }, {
    'mcchrish/zenbones.nvim',
    requires = 'rktjmp/lush.nvim',
    config   = function()
      vim.g.zenburned_darken_comments = 70
      vim.g.zenburned_combat = 1
    end
  }
  }
  vim.cmd([[colorscheme zenburned]])
end

setupFrontends()
setupOptions()
setupPlugins()
setupKeymaps()
setupColorschemes()
