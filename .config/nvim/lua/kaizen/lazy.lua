local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

-- change leader key to space --
local g = vim.g
g.mapleader = " "
g.maplocalleader = " "

require("lazy").setup {
	-- lsp & completion --
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support --
			{ "neovim/nvim-lspconfig" },
			{
				"williamboman/mason.nvim",
				build = function()
					vim.cmd("MasonUpdate")
				end,
			},

			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion --
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{
				"L3MON4D3/LuaSnip",
				dependencies = {
					"rafamadriz/friendly-snippets",
					"saadparwaiz1/cmp_luasnip",
				},
			},
			{ "dcampos/nvim-snippy" },
			{ "dcampos/cmp-snippy" },
			{ "onsails/lspkind.nvim" },
		},
	},

	{ "williamboman/mason.nvim" },

	{'wakatime/vim-wakatime'},

	{"akinsho/toggleterm.nvim", version = "*", config = true},

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	{ 'nvim-lualine/lualine.nvim' },

	{
		'stevearc/dressing.nvim',
		opts = {},
	},

	{'f-person/git-blame.nvim'},

	-- Colorizer
	{ "NvChad/nvim-colorizer.lua" },

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		}
	},

	{ "lukas-reineke/indent-blankline.nvim" },

	{ "folke/todo-comments.nvim" },

	{ 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },

	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		opts = {
			-- configurations go here
		},
	},


	{
		'altermo/ultimate-autopair.nvim',
		event={'InsertEnter','CmdlineEnter'},
		branch='v0.6',
		opts={
			--Config goes here
		},
	},


	{ 'andweeb/presence.nvim' },

	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			require('dashboard').setup {
				theme = 'hyper',
				config = {
					week_header = {
						enable = true,
					},
					shortcut = {
						{ desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
						{
							icon = ' ',
							icon_hl = '@variable',
							desc = 'Files',
							group = 'Label',
							action = 'Telescope find_files',
							key = 'f',
						},
						{
							desc = ' Apps',
							group = 'DiagnosticHint',
							action = 'Telescope app',
							key = 'a',
						},
						{
							desc = ' dotfiles',
							group = 'Number',
							action = 'Telescope dotfiles',
							key = 'd',
						},
					},
				},

			}
		end,
		dependencies = { {'nvim-tree/nvim-web-devicons'}}
	}
}
