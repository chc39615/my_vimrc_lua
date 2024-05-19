local Util = require("myutil")

return {
	-- which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,
		opts = {
			plugins = { spelling = true },
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			local keymaps = {
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["gs"] = { name = "+surround" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader><tab>"] = { name = "+tabs" },
				["<leader>b"] = { name = "+buffer" },
				["<leader>s"] = { name = "+messages" },
				["<leader>f"] = { name = "+file/find" },
				["<leader>F"] = { name = "+file/find(current word)" },
				["<leader>c"] = { name = "+lsp" },
				["<leader>g"] = { name = "+git" },
				["<leader>q"] = { name = "+quit/session" },
				["<leader>u"] = { name = "+ui" },
				["<leader>x"] = { name = "+diagnostics/quickfix" },
			}
			if Util.has("noice.nvim") then
				keymaps["<leader>sn"] = { name = "+noice" }
			end

			if Util.has("iron.nvim") then
				keymaps["<leader>r"] = { name = "+irons" }
			end

			wk.register(keymaps)
		end,
	},
}
