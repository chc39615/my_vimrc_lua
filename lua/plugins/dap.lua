return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "nvim-neotest/nvim-nio" },
		},
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
			vim.keymap.set(
				"n",
				"<s-F9>",
				":lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
				{ silent = true }
			)
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		dependencies = {
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
		},
		ft = "python",
		config = function()
			require("neodev").setup({
				library = {
					plugins = { "nvim-dap-ui", types = true },
				},
			})

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

			table.insert(require("dap").configurations.python, {
				console = "integratedTerminal",
				name = "Launch file with all code",
				program = "${file}",
				request = "launch",
				type = "python",
				justMyCode = false,
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = {
			{ "mfussenegger/nvim-dap" },
		},
		config = function()
			require("dapui").setup()
			local settings = {
				layouts = {
					{
						elements = {
							{
								id = "stacks",
								size = 0.25,
							},
							{
								id = "breakpoints",
								size = 0.25,
							},
							{
								id = "watches",
								size = 0.25,
							},
							{
								id = "scopes",
								size = 0.25,
							},
						},
						position = "left",
						size = 0.25,
					},
					{
						elements = {
							{
								id = "console",
								size = 0.5,
							},
							{
								id = "repl",
								size = 0.5,
							},
						},
						position = "bottom",
						size = 0.3,
					},
				},
			}

			-- vim.api.nvim_create_autocmd("BufWinEnter", {
			-- 	pattern = "\\[dap-repl\\]",
			-- 	callback = vim.schedule_wrap(function(args)
			-- 		vim.api.nvim_set_current_win(vim.fn.bufwinid(args.buf))
			-- 	end),
			-- })

			local dap, dapui = require("dap"), require("dapui")
			dapui.setup(settings)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({ reset = true })
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set(
				{ "v", "n" },
				"<F8>",
				"<cmd>lua require('dapui').eval(nil, { enter = true })<cr>",
				{ silent = true }
			)
			vim.keymap.set(
				"n",
				"<F7>",
				"<cmd>lua require('dapui').float_element(nil, { enter = true })<cr>",
				{ silent = true }
			)
		end,
	},
}
