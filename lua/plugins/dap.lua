return {
	{
		"mfussenegger/nvim-dap",
		ft = "python",
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		config = function()
			local cwd = vim.fn.getcwd()
			local pythons = { "/venv/Scripts/python", "venv/bin/python", "venvl/bin/python" }
			for _, path in pairs(pythons) do
				local exists = vim.fn.executable(cwd .. path)
				if exists then
					cwd = cwd .. path
					break
				end
			end

			print(cwd)

			require("dap-python").setup(cwd)
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
