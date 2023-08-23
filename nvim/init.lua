if vim.g.neovide then
  vim.g.neovide_refresh_rate = 140
  vim.opt.guifont = { "JetBrains Mono", ":h12", ":b" }
  vim.g.neovide_cursor_animation_length = 0
end

require('config.lazy')
require('config.options')
require('config.keymaps')

vim.cmd([[colorscheme rose-pine-dawn]])
