return {
	{
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
