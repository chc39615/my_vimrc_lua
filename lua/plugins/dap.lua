return {
	{
		"mfussenegger/nvim-dap",
		ft = "python",
		config = function()
			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

			vim.keymap.set("n", "<F5>", require("dap").continue)
			vim.keymap.set("n", "<sc-F5>", require("dap").restart)
			vim.keymap.set("n", "<s-F5>", require("dap").terminate)

			vim.keymap.set("n", "<F10>", require("dap").step_over)
			vim.keymap.set("n", "<F11>", require("dap").step_into)
			vim.keymap.set("n", "<s-F11>", require("dap").step_out)

			-- have to set the Control Sequence Introducer Sequences (CSI)
			-- https://neovim.discourse.group/t/how-can-i-map-ctrl-shift-f5-ctrl-shift-b-ctrl-and-alt-enter/2133
			-- vim.keymap.set("n", "<s-F11>", [[<cmd>lua print("shift+F11")<cr>]])
			-- vim.keymap.set("n", "<sc-F5>", [[<cmd>lua print("ctrl+shift+F5")<cr>]])
			-- vim.keymap.set("n", "<s-F5>", [[<cmd>lua  print("shift+F5")<cr>]])

			vim.keymap.set("n", "<F9>", require("dap").toggle_breakpoint)
		end,
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

			require("dap-python").setup(cwd)
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = {
			{ "mfussenegger/nvim-dap" },
		},
		-- config = function()
		-- 	print("--- start dapui event hook ---")
		-- 	local dap, dapui = require("dap"), require("dapui")
		-- 	dap.listeners.after.event_initialized["dapui_config"] = function()
		-- 		dapui.open()
		-- 	end
		-- 	dap.listeners.before.event_terminated["dapui_config"] = function()
		-- 		dapui.close()
		-- 	end
		-- 	dap.listeners.before.event_exited["dapui_config"] = function()
		-- 		dapui.close()
		-- 	end
		-- end,
	},
	-- {
	-- 	"nvim-neotest/neotest",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"antoinemadec/FixCursorHold.nvim",
	-- 	},
	-- 	ft = "python",
	-- 	config = function()
	-- 		require("neotest").setup({
	-- 			require("neotest-python")({
	-- 				dap = { justMyCode = false },
	-- 			}),
	-- 			require("neotest-plenary"),
	-- 			require("neotest-vim-test")({
	-- 				ignore_file_types = { "python", "vim", "lua" },
	-- 			}),
	-- 		})
	-- 	end,
	-- },
	-- {
	-- 	"nvim-neotest/neotest-python",
	-- 	envent = "VeryLazy",
	-- },
	-- {
	-- 	"nvim-neotest/neotest-plenary",
	-- 	envent = "VeryLazy",
	-- },
	-- {
	-- 	"nvim-neotest/neotest-vim-test",
	-- 	envent = "VeryLazy",
	-- },
}
