return {
	{
		"mfussenegger/nvim-dap",
		ft = "python",
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			require("dap-python").setup("./venvl/bin/python")
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
		},
		ft = "python",
		config = function()
			require("neotest").setup({
				require("neotest-python")({
					dap = { justMyCode = false },
				}),
				require("neotest-plenary"),
				require("neotest-vim-test")({
					ignore_file_types = { "python", "vim", "lua" },
				}),
			})
		end,
	},
	{
		"nvim-neotest/neotest-python",
		envent = "VeryLazy",
	},
	{
		"nvim-neotest/neotest-plenary",
		envent = "VeryLazy",
	},
	{
		"nvim-neotest/neotest-vim-test",
		envent = "VeryLazy",
	},
}
