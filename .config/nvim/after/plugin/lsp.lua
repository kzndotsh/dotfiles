local lsp = require("lsp-zero").preset({
   name = "minimal",
   set_lsp_keymaps = true,
   manage_nvim_cmp = true,
   suggest_lsp_servers = true,
   configure_diagnosticnostics = true,
})

local map = vim.keymap.set
local diagnostic = vim.diagnostic
local buf = vim.lsp.buf

diagnostic.config({
   virtual_text = true,
   virtual_lines = false,
})

lsp.ensure_installed({
   "rust_analyzer",
})

lsp.set_preferences({
   suggest_lsp_servers = true,
})

lsp.set_sign_icons({
   error = ' ',
   warn = ' ',
   hint = ' ',
   info = '󰌶 '
})

lsp.on_attach(function(client, bufnr)
   local opts = { buffer = bufnr, remap = false }

   map("n", "gd", function() buf.definition() end, opts)
   map("n", "K", function() buf.hover() end, opts)
   map("n", "vw", function() buf.workspace_symbol() end, { buffer = bufnr, remap = false, desc = "workspace symbols" })
   map("n", "vd", function() diagnostic.open_float() end, { buffer = bufnr, remap = false, desc = "" })
   map("n", "[d", function() diagnostic.goto_next() end, { buffer = bufnr, remap = false, desc = "diagnostic next" })
   map("n", "]d", function() diagnostic.goto_prev() end, { buffer = bufnr, remap = false, desc = "diagnostic previous" })
   map("n", "vv", function() buf.code_action() end, { buffer = bufnr, remap = false, desc = "code actions" })
   map("n", "vr", function() buf.references() end, { buffer = bufnr, remap = false, desc = "references" })
   map("n", "gr", function() buf.rename() end, { buffer = bufnr, remap = false, desc = "rename reference" })
   map("i", "<C-h>", function() buf.signature_help() end, opts)
end)

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
lsp.setup()
