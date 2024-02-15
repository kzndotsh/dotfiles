local map = vim.keymap.set
local cmd = vim.cmd

-- file management --
map({"n", "v", "x", "o"}, "<leader>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", {silent=true, desc = "Open file browser" })
map({"n", "v", "x", "o"}, "<leader>w", cmd.w, { desc = "Save current file" })
map({"n", "v", "x", "o"}, "<leader>r", cmd.so, { desc = "Source current file" })
map({"n", "v", "x", "o"}, "<leader>q", cmd.q, { desc = "Quit" })

-- easy window split --
--map({"n", "v", "x", "o"}, "<leader>a", cmd.vsp, { desc = "Split vertically" })
--map({"n", "v", "x", "o"}, "<leader>s", cmd.sp, { desc = "Split horizontally" })

-- buffer management --
--map({"n", "v", "x", "o"}, "H", cmd.bprev, { silent = true, desc = "Previous Buffer"})
--map({"n", "v", "x", "o"}, "L", cmd.bnext, { silent = true, desc = "Next Buffer"})
--map({"n", "v", "x", "o"}, "<leader>bd", cmd.bdel, { silent = true, desc = "Delete Buffer"})

-- easy window switch --
--map({"n", "v", "x", "o"}, "<M-h>", "<C-w>h")
--map({"n", "v", "x", "o"}, "<M-j>", "<C-w>j")
--map({"n", "v", "x", "o"}, "<M-k>", "<C-w>k")
--map({"n", "v", "x", "o"}, "<M-l>", "<C-w>l")

-- easy resizing --
--map({"n", "v", "x", "o"}, "<M-H>", "<C-w>5<")
--map({"n", "v", "x", "o"}, "<M-J>", "<C-w>5+")
--map({"n", "v", "x", "o"}, "<M-K>", "<C-w>5-")
--map({"n", "v", "x", "o"}, "<M-L>", "<C-w>5>")

-- toggles --
--map({"n", "v", "x", "o"}, "<leader>lw", ":set wrap!<CR>:set wrap?<CR>", { silent = true, desc = "Toggle line wrapping"})
--map({"n", "v", "x", "o"}, "<leader>ln", ":set nu!<CR>:set nu?<CR>", { silent = true, desc = "Toggle line wrapping"})
--map({"n", "v", "x", "o"}, "<leader>lrn", ":set rnu!<CR>:set rnu?<CR>", { silent = true, desc = "Toggle line relative numbers"})

-- better search --
--map({"n", "v", "x", "o"}, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
--map({"n", "v", "x", "o"}, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- word under cursor
--map("n", "<leader>R", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Change word under cursor"})
--map("n", '<leader>W', '*N', { desc = 'Search word under cursor' })

-- make current buffer executable --
--map("n", "<leader>x", ":!chmod +x % <CR>", { desc = "Make current file executable" })

-- line manipulation --
--map("v", "J", ":m '>+1<CR>gv=gv")
--map("v", "K", ":m '<-2<CR>gv=gv")
--map("n", "<leader><Tab>", ">>", { desc = "Indent line" })
--map("n", "<leader><S-Tab>", "<<", { desc = "Unindent line" })
--map("v", "<leader><Tab>", ":'<,'>><CR>", { desc = "Indent line" })
--map("v", "<leader><S-Tab>", ":'<,'><<CR>", { desc = "Unindent line" })

-- ignore paste buffer --
--map("n", "x", '"_x')
--map("n", "s", '"_s')

-- term --
-- map("n", "<leader>tt", ":vsp | cd %:p:h | terminal<CR>i")

-- kakoune --
map("n", "gk", "gg")
map("n", "gj", "G")

