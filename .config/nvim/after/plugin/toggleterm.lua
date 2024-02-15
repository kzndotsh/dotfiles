local Terminal      = require('toggleterm.terminal').Terminal
local pid           = vim.fn.system("echo $PPID")
vim.cmd("silent !mkdir /tmp/nvxplr")
local tmp_xplr_path = "/tmp/nvxplr/xplr" ..pid
local xplr_dir = "xplr " ..tmp_xplr_path
require("toggleterm").setup({
    -- size can be a number or function which is passed the current terminal
    vim.api.nvim_set_keymap("n", "<leader>s",  "<cmd>lua _spotifytui_toggle()<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>b",  "<cmd>lua _btop_toggle()<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>g",  "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>f",  "<cmd>lua _floatingterm_toggle()<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>j",  "<cmd>lua _horizontalterm_toggle()<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>x",  "<cmd>lua _xplr_toggle(false)<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>d",  "<cmd>lua _xplr_toggle(true)<CR>", {noremap = true, silent = true}),
    vim.api.nvim_set_keymap("n", "<leader>nd", "<cmd>lua _discordo_toggle()<CR>", {noremap = true, silent = true}),


    vim.cmd(string.format("silent !touch %s", tmp_xplr_path)),
    --vim.cmd("silent !nohup ./listener.sh "..pid.." </dev/null &>/dev/null 2>&1"),

    vim.cmd("autocmd Signal SIGUSR1 lua on_xplr_close(false)"),
    vim.cmd("autocmd Signal SIGUSR2 lua on_xplr_close(true)"),
    vim.cmd("autocmd QuitPre * silent !rm " ..tmp_xplr_path)
})

local discordo = Terminal:new({
    cmd = "discordo",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
    },

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,

    on_close = function()
        vim.cmd("startinsert!")
    end,
})

local spotifytui = Terminal:new({
    cmd = "spt",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
    },

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,

    on_close = function()
        vim.cmd("startinsert!")
    end,

})

local btop = Terminal:new({
    cmd = "btop",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
    },

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<CR>", "<cmd>close<CR>", {noremap = true, silent = true})
    end,

    on_close = function(term)
        vim.cmd("startinsert!")
    end,

})

local lazygit = Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

local floatingterm = Terminal:new({
    cmd = "tmux",
    dir = "git_dir",
    direction = "float",
    float_opts = {},

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,

    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

local horizontalterm = Terminal:new({
    cmd = "tmux",
    dir = "git_dir",
    direction = "horizontal",
    float_opts = {},

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,

    on_close = function(term)
        vim.cmd("startinsert!")
    end,

})

function _xplr_toggle(quick_mode)
    if quick_mode then
        xplr_dir = "xplr " .. vim.fn.expand('%:p:h') .. " > " .. tmp_xplr_path
    else
        xplr_dir = "xplr $(git rev-parse --git-dir)/.. > " .. tmp_xplr_path
    end

    local xplr = Terminal:new({
    cmd = xplr_dir,
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "double",
    },
    close_on_exit = true,

    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        --vim.cmd("let enter_termcode = nvim_replace_termcodes(\"<CR>\", v:true, v:false, v:true)")
    end,
})
    xplr:toggle()
end

function _discordo_toggle()
    discordo:toggle()
end

function _spotifytui_toggle()
    spotifytui:toggle()
end

function _btop_toggle()
    btop:toggle()
end


function _lazygit_toggle()
    lazygit:toggle()
end

function _floatingterm_toggle()
    floatingterm:toggle()
end

function _horizontalterm_toggle()
    horizontalterm:toggle()
end
local function is_file_locked(lockfile)
    local file = io.open(lockfile, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

local lockfile = "~/tmp/xplr_lock" ..pid

function on_xplr_close(is_directory)
    while is_file_locked(lockfile) do
        print("[info]: Waiting for lock to be released...")
    end
    local file = io.popen("cat " ..tmp_xplr_path)
    if file then
        local data = file:read("*a")
        file:close()
        if is_directory then

        else
            print("[info]: File content:", data)
            if (is_directory == "true") then
                vim.api.nvim_set_current_dir(data);
                return
            else
                vim.cmd("e " .. data)
            end
        end
    else
        print("[error]: Unable to open file")
    end
end


return {
    _xplr_toggle = _xplr_toggle,
    _discordo_toggle = _discordo_toggle,
    _spotifytui_toggle = _spotifytui_toggle,
    _btop_toggle = _btop_toggle,
    _lazygit_toggle = _lazygit_toggle,
    _floatingterm_toggle = _floatingterm_toggle,
    _horizontalterm_toggle = _horizontalterm_toggle,
}
