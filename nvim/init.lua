if vim.g.neovide then
  vim.g.neovide_refresh_rate = 140
  vim.opt.guifont = { "JetBrains Mono", ":h12", ":b" }
  vim.g.neovide_cursor_animation_length = 0
end

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

for k,v in pairs(options) do
	vim.opt[k] = v
end

local globals = {
  netrw_browsex_viewer = "powershell.exe start",
  completeopt = 'menu,menuone,noinsert,noselect'
}

for k,v in pairs(globals) do
	vim.g[k] = v
end

vim.cmd[[autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
local plugins = {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function() 
      require('nvim-treesitter').setup {}
    end,
  }, {
    "neovim/nvim-lspconfig",
    dependencies = {
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
    },
    config = function()
      local lspconfig = require("lspconfig")
      local servers = { "clangd", "rust_analyzer", "zls", "lua_ls", "ols" }
      for _, server in pairs(servers) do
        lspconfig[server].setup {}
      end
    end
  }, {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      dap.adapters.lldb = {
        name = 'lldb',
        type = 'executable',
        command = '/usr/bin/lldb-vscode'
      }

      dap.configurations.cpp = {
        {
          name = 'Launch',
          type = 'lldb',
          request = 'launch',
          program = function ()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        }
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
      dap.configurations.rust[1]['initCommands'] = function ()
        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

        local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

        local commands = {}
        local file = io.open(commands_file, 'r')
        if file then
          for line in file:lines() do
            table.insert(commands, line)
          end
          file:close()
        end
        table.insert(commands, 1, script_import)

        return commands
      end
    end,
  }, {
    'rcarriga/nvim-dap-ui',
    config = function()
      require('dapui').setup {}

      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  }, {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' },
  }, {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function() 
      require("lsp_signature").setup {}
    end,
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
      require('indent_blankline').setup {
        show_current_context = true,
      }
    end,
  }, {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
    config = function ()
      require('Comment').setup()
    end,
  }, {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {}
    end,
  }, {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup {}
    end,
  }, {
    "folke/neodev.nvim",
  }, {
    "NeogitOrg/neogit",
    dependencies = 'nvim-lua/plenary.nvim',
    config = function ()
      require('neogit').setup {}
    end
  }, {
    "ahmedkhalf/project.nvim",
    dependenceis = 'nvim-telescope/telescope.nvim', 
    config = function ()
      require("project_nvim").setup {
        require("telescope").load_extension('projects')
      }
    end
  }, {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    config = function()
      require('catppuccin').setup {
        dim_inactive = {
          enabled = true,
          shade = 'dark',
          percentage = 0.3,
        },
      }
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  }, {
    'morhetz/gruvbox',
    lazy = false,
    priority = 1000,
  }, {
    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[let g:edge_style = 'light']])
    end,
  }, {
    'rose-pine/neovim',
    lazy = false,
    priority = 1000,
    name = 'rose-pine'
  }, {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  }, {
    'pappasam/papercolor-theme-slim',
    lazy = false,
    priority = 1000,
  }
}

require("lazy").setup(plugins)

-- keymaps
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
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Prev Diagnostic')
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', 'Next Diagnostic')
    map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help')
    map('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help')

    local buf_map = function(l, r, desc)
      vim.api.nvim_buf_set_keymap(ev.buf, 'n', l, r, { desc = desc, noremap = true, silent = true })
    end

    buf_map('<leader>ld', '<cmd>Telescope lsp_definitions<cr>', '[d]efinition')
    buf_map('<leader>lD', '<cmd>Telescope lsp_declarations<cr>', '[D]eclaration')
    buf_map('<leader>lt', '<cmd>Telescope lsp_type_definitions<cr>', '[t]ype Definition')
    buf_map('<leader>lr', '<cmd>Telescope lsp_references<cr>', '[r]eferences')
    buf_map('<leader>li', '<cmd>Telescope lsp_implementations<cr>', '[i]mplementation')
    buf_map('<leader>lw', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', '[w]orkspace symbol')
    buf_map('<leader>lb', '<cmd>Telescope lsp_document_symbols<cr>', '[b]uffer symbol')
    buf_map('<leader>lh', '<cmd>lua vim.lsp.buf.hover()<cr>', '[h]over')
  end,
})

-- Dap
wk.register({
  d = {
    name = '[d]ap',
    c = { '<cmd>lua require(\'dap\').continue()<cr>', '[c]ontinue' },
    b = { '<cmd>lua require(\'dap\').toggle_breakpoint()<cr>', 'toggle [b]reakpoint' },
    s = { '<cmd>lua require(\'dap\').step_into()<cr>', '[s]tep' },
    n = { '<cmd>lua require(\'dap\').step_over()<cr>', '[n]ext' },
    u = { '<cmd>lua require(\'dap\').up()<cr>', '[u]p call stack' },
    d = { '<cmd>lua require(\'dap\').down()<cr>', '[d]own call stack' },
    t = { '<cmd>lua require(\'dap\').terminate()<cr>', '[t]erminate' },
  }
}, { prefix = '<leader>' })

-- Config
wk.register({
  c = {
    name = '[c]onfig',
    o = { ":e ~/.config/nvim/init.lua<cr>", "[o]pen" },
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
    f = { '<cmd>NvimTreeFindFile<cr>', '[F]ind file'}
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
}, { prefix = '<leader>'})

-- Projects
wk.register({
  p = {
    name = '[p]roject',
    o = { '<cmd>Telescope projects<cr>', '[o]pen' },
  }
}, { prefix = '<leader>'})

vim.cmd([[colorscheme rose-pine-dawn]])
