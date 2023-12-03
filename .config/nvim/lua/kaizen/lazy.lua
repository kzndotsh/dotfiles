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

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

---------------------------------------------------
--- LSP & COMPLETIONS
---------------------------------------------------	
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{
				"williamboman/mason.nvim",
				build = function()
					vim.cmd("MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
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
			{ 'folke/neodev.nvim' },
			{ 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
		},
	},

	{ "williamboman/mason.nvim" },

  { 'folke/which-key.nvim', opts = {} },

---------------------------------------------------
--- THEME, UI, COLORS
---------------------------------------------------	

	-- Theme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	-- Colorizer
	{ "NvChad/nvim-colorizer.lua" },

	{ 'nvim-lualine/lualine.nvim',
	opts = {
		theme = 'tokyonight'
	},
},

	{
		'stevearc/dressing.nvim',
		opts = {},
	},

	{'f-person/git-blame.nvim'},




---------------------------------------------------
--- MISC
---------------------------------------------------	

	-- Wakatime tracking
	{'wakatime/vim-wakatime'},

	-- Discord RPC
	{ 'andweeb/presence.nvim' },


	{"akinsho/toggleterm.nvim", version = "*", config = true},


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
			theme = 'tokyonight',
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


  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },


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
