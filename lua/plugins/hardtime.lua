return {
	-- lazy.nvim
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
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
			})
		end,
	},
}
