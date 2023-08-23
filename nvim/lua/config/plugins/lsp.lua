return {
	"neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp"
  },
  config = function()
    local lspconfig = require("lspconfig")
    local servers = { "clangd", "rust_analyzer", "zls", "lua_ls", "ols" }
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    for _, server in pairs(servers) do
      lspconfig[server].setup {
        capabilities = capabilities
      }
    end
  end
}
