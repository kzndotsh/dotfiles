local g = vim.g
local opt = vim.opt

-- cursor --
opt.cursorline = true
opt.cursorcolumn = false

-- line number --
opt.relativenumber = true
opt.number = true
opt.numberwidth = 1

vim.cmd[[syntax enable]]

vim.cmd "hi Normal guibg=none"
vim.cmd "hi NonText guibg=none"
vim.cmd "hi Normal ctermbg=none"
vim.cmd "hi NonText ctermbg=none"
vim.cmd "hi Normal guifg=none"
vim.cmd "hi NonText guifg=none"
vim.cmd "hi cursorline guibg=none"
vim.cmd "hi EndOfBuffer guibg=NONE ctermbg=NONE"

-- netrw --
--g.netrw_banner = 0
--g.netrw_liststyle = 1
--g.netrw_sizestyle = 'h'
--g.netrw_list_hide = '^./'

-- chars --
--opt.fillchars = 'eob: '

-- color stuff --
--opt.termguicolors = true

-- disable standart mode display --
--opt.showmode = false

-- show lines below cursor --
--opt.scrolloff = 3

-- indenting --
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- search --
--opt.ignorecase = true
--opt.smartcase = true
--opt.hlsearch = false
--opt.incsearch = true
