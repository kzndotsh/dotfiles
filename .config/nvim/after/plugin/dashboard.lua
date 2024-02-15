local start = require("startup")
local toggleterm = require("toggleterm")
start.setup({
	header = {
		type = "text",
		oldfiles_directory = false,
		align = "center",
		fold_section = false,
		title = "Header",
		margin = 5,
		content = {
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "▄▄▄█████▓▓██   ██▓▄▄▄█████▓▄▄▄█████▓  ▄████   ▄████   █████▒▓█████▄   ██████ ▓█████▄ ▓█████▄   ▄████  ██░ ██ ",
            "▓  ██▒ ▓▒ ▒██  ██▒▓  ██▒ ▓▒▓  ██▒ ▓▒ ██▒ ▀█▒ ██▒ ▀█▒▓██   ▒ ▒██▀ ██▌▒██    ▒ ▒██▀ ██▌▒██▀ ██▌ ██▒ ▀█▒▓██░ ██▒",
            "▒ ▓██░ ▒░  ▒██ ██░▒ ▓██░ ▒░▒ ▓██░ ▒░▒██░▄▄▄░▒██░▄▄▄░▒████ ░ ░██   █▌░ ▓██▄   ░██   █▌░██   █▌▒██░▄▄▄░▒██▀▀██░",
            "░ ▓██▓ ░   ░ ▐██▓░░ ▓██▓ ░ ░ ▓██▓ ░ ░▓█  ██▓░▓█  ██▓░▓█▒  ░ ░▓█▄   ▌  ▒   ██▒░▓█▄   ▌░▓█▄   ▌░▓█  ██▓░▓█ ░██ ",
            "  ▒██▒ ░   ░ ██▒▓░  ▒██▒ ░   ▒██▒ ░ ░▒▓███▀▒░▒▓███▀▒░▒█░    ░▒████▓ ▒██████▒▒░▒████▓ ░▒████▓ ░▒▓███▀▒░▓█▒░██▓",
            "  ▒ ░░      ██▒▒▒   ▒ ░░     ▒ ░░    ░▒   ▒  ░▒   ▒  ▒ ░     ▒▒▓  ▒ ▒ ▒▓▒ ▒ ░ ▒▒▓  ▒  ▒▒▓  ▒  ░▒   ▒  ▒ ░░▒░▒",
            "    ░     ▓██ ░▒░     ░        ░      ░   ░   ░   ░  ░       ░ ▒  ▒ ░ ░▒  ░ ░ ░ ▒  ▒  ░ ▒  ▒   ░   ░  ▒ ░▒░ ░",
            "  ░       ▒ ▒ ░░    ░        ░      ░ ░   ░ ░ ░   ░  ░ ░     ░ ░  ░ ░  ░  ░   ░ ░  ░  ░ ░  ░ ░ ░   ░  ░  ░░ ░",
            "          ░ ░                             ░       ░            ░          ░     ░       ░          ░  ░  ░  ░",
            "          ░ ░                                                ░                ░       ░                      "
		},
		highlight = "",
		default_color = "#988BC7",
		oldfiles_amount = 0,
	},

	-- name which will be displayed and command
	body = {
		type = "mapping",
		oldfiles_directory = true,
		align = "center",
		fold_section = false,
		title = "Basic Commands",
		margin = 10,
		content = {
         -- TODO: change <C-e> to something that works
			{ "  Harpoon     ",    "Harpoon quick_menu",                    "Ctrl e" },
			{ "  File Browser",    "Telescope file_browser",                "SPC d" },
			{ "  New File    ",    "lua require'startup'.new_file()",       "SPC n f" },
            { "  Close Neovim",    "quit",                                  "SPC q" },
            { "🎧 Spotify     ",    "Spt",                                   "SPC s" }
		},
		highlight = "Title",
		default_color = "#988BC7",
		oldfiles_amount = 10,
	},

	footer = {
		type = "text",
		oldfiles_directory = false,
		align = "center",
		fold_section = false,
		title = "Footer",
		margin = 5,
		content = { "󱓞  The world might be on fire, but at least you have a nice Neovim config" },
		highlight = "MoreMsg",
		default_color = "#988BC7",
		oldfiles_amount = 0,
	},

	options = {
		mapping_keys = true,
		cursor_column = 0.37,
		empty_lines_between_mappings = true,
		disable_statuslines = false,
		paddings = { 1, 3, 1, 2 },
	},
	mappings = {
		execute_command = "<CR>",
		open_file = "o",
		open_file_split = "<c-o>",
		open_section = "<TAB>",
		open_help = "?",
	},
	colors = {
        background = "#1f222700",
		folded_section = "#988BC7",
	},
	parts = { "header", "body", "footer" },
})

local map = vim.api.nvim_set_keymap

map('n', '<leader>nf', ':lua require("startup").new_file()<CR>', { noremap = true, silent = true, desc = "create new file" })
