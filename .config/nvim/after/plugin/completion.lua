vim.o.completeopt = 'menuone,noselect'

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

luasnip.setup({
   region_check_events = "CursorHold,InsertLeave",
   delete_check_events = "TextChanged,InsertEnter",
})

local lspkind = require('lspkind')

cmp.setup({
   sources = {
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'luasnip' },
      { name = 'buffer',  keyword_length = 5 },
      { name = "orgmode" },
      { name = "snippy" },
   },

   snippet = {
      expand = function(args)
         require("snippy").expand_snippet(args.body)
      end
   },

   formatting = {
      format = lspkind.cmp_format({
         mode = 'symbol_text', -- show only symbol annotations
         before = function(entry, vim_item)
            -- set a name for each source
            vim_item.menu = ({
               buffer = "[Buff]",
               nvim_lsp = "[LSP]",
               luasnip = "[LuaSnip]",
               nvim_lua = "[Lua]",
               latex_symbols = "[Latex]"
            })[entry.source.name]
            return vim_item
         end
      })
   },

   mapping = cmp.mapping.preset.insert({
      ["<Up>"] = cmp.mapping.select_prev_item(cmp_select),
      ["<Down>"] = cmp.mapping.select_next_item(cmp_select),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({
         behavior = cmp.ConfirmBehavior.Replace,
         select = true,
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_next_item()
         elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
         else
            fallback()
         end
      end, {"i", "s"}),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_prev_item()
         elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
         else
            fallback()
         end
      end, {"i", "s"})
   })
})
