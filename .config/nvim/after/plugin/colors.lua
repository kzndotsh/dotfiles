vim.cmd[[colorscheme omni]]

vim.cmd[[augroup MyCustomColors
    autocmd!
    autocmd ColorScheme * highlight IndentLine guibg=#404040 ctermbg=235
augroup END
]]
