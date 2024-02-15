require("nvim-treesitter.configs").setup {
    -- import nvim-treesitter plugin
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    -- enable indentation
    indent = { enable = true },
    -- enable autotagging (w/ nvim-ts-autotag plugin)
    autotag = {
        enable = true,
    },
    -- ensure these language parsers are installed
    ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "rust",
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<M-w>",
            node_incremental = "<M-w>",
            scope_incremental = false,
            node_decremental = "<bs>",
        },
    },
    -- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
}
