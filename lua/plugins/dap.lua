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
			local pythons = {}

			local sysname = vim.loop.os_uname().sysname
			local is_windows = string.find(sysname:lower(), "window")
			if is_windows then
				table.insert(pythons, "\\venv\\Scripts\\python.exe")
			else
				table.insert(pythons, "/venv/bin/python")
				table.insert(pythons, "/venvl/bin/python")
			end

			for _, path in pairs(pythons) do
				if vim.fn.executable(cwd .. path) == 1 then
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
