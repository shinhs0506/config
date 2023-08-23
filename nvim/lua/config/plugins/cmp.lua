return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    'hrsh7th/cmp-cmdline',
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      completion = { completeopt = 'menu,menuone,noinsert,noselect' },
      preselect = cmp.PreselectMode.None,
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<c-n>'] = cmp.mapping.select_next_item(),
        ['<c-p>'] = cmp.mapping.select_prev_item(),
        ['<c-d>'] = cmp.mapping.scroll_docs(-4),
        ['<c-u>'] = cmp.mapping.scroll_docs(4),
        ['<c-space>'] = cmp.mapping.confirm(),
        ['<tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end),
        ['<s-tab>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end)
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
      }), 
      completion = {
        autocomplete = false,
      }
    })

    cmp.setup.cmdline({'/'}, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'path' }
      }
    })

    cmp.setup.cmdline({':'}, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources ({
        { name = 'path' }
      }, {
        { name = 'cmdline'}
      })
    })
  end
}
