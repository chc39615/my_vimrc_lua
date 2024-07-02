return {
	-- lazy.nvim
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
		-- enabled = false,
		config = function()
			require("hardtime").setup({
				disable_mouse = false,
				-- allow arrow key in input mode
				disabled_keys = {
					["<Up>"] = { "", "n" },
					["<Down>"] = { "", "n" },
					["<Left>"] = { "", "n" },
					["<Right>"] = { "", "n" },
				},
				disabled_filetypes = {
					"NvimTree*",
					"TelescopePrompt",
					"aerial",
					"alpha",
					"checkhealth",
					"dapui*",
					"Diffview*",
					"Dressing*",
					"help",
					"httpResult",
					"lazy",
					"Neogit*",
					"mason",
					"neotest-summary",
					"minifiles",
					"neo-tree*",
					"netrw",
					"noice",
					"notify",
					"prompt",
					"qf",
					"oil",
					"undotree",
					"Trouble",
					"dap-repl",
				},
			})
		end,
	},
}
