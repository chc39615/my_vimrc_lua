local Util = require("myutil")
local map = Util.lazy_map
local vim_map = Util.map

return {
	-- file explorer
	{
		"kyazdani42/nvim-tree.lua",
		-- dependencies = { 'kyazdani42/nvim-web-devicons' },
		-- set keys will cause the plugins lazy load on these keys. we need nvim-tree to load on startup,
		-- so don't set key makp here.
		-- keys = {
		--    map("<leader>e", ":NvimTreeToggle<cr>", "n", "toggle nvim-tree")
		-- },
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			vim.opt.termguicolors = true

			local function nvimtree_on_attach(bufnr)
				local api = require("nvim-tree.api")

				-- local function opts(desc)
				-- 	return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				-- end

				api.config.mappings.default_on_attach(bufnr)

				-- vim.keymap.set("n", "j", "j", opts("reset j"))
				-- vim.keymap.set("n", "k", "k", opts("reset k"))
			end

			-- empty setup using defaults
			require("nvim-tree").setup()

			require("nvim-tree").setup({
				on_attach = nvimtree_on_attach,
				hijack_cursor = false,
				disable_netrw = true,
				hijack_netrw = true,
				open_on_tab = false,
				update_cwd = true,
				system_open = {
					cmd = nil,
					args = {},
				},
				renderer = {
					group_empty = true,
				},
				actions = {
					open_file = {
						quit_on_open = true,
					},
				},
			})

			local function open_nvim_tree(data)
				-- buffer is a directory
				local directory = vim.fn.isdirectory(data.file) == 1

				if not directory then
					return
				end

				-- change to the directory
				vim.cmd.cd(data.file)
				-- open the tree
				require("nvim-tree.api").tree.open()
			end

			vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

			-- open explore
			vim_map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")
			vim_map("n", "<leader>fe", "<cmd>NvimTreeFindFile<cr>")
		end,
	},

	-- telescope-ui-select
	{
		"nvim-telescope/telescope-ui-select.nvim",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
		},
	},

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")

			if Util.has("telescope-ui-select.nvim") then
				require("telescope").setup({
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown({}),
						},
					},
				})
				telescope.load_extension("ui-select")
			end

			if Util.has("nvim-notify") then
				telescope.load_extension("notify")
			end

			vim_map("n", "<leader>ff", Util.telescope("files"), { desc = "find files" })
			vim_map("n", "<leader>fg", Util.telescope("live_grep"), { desc = "live grep" })
			vim_map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "buffers" })
			vim_map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "search help" })

			vim_map(
				"n",
				"<leader>FF",
				':execute "Telescope find_files default_text=" . expand("<cWORD>")<cr>',
				{ desc = "find files of current word" }
			)
			vim_map(
				"n",
				"<leader>FG",
				':execute "Telescope live_grep default_text=" . expand("<cword>")<cr>',
				{ desc = "live grep of current word" }
			)
		end,
	},

	-- which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
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
				["<leader>c"] = { name = "+code" },
				["<leader>f"] = { name = "+file/find" },
				["<leader>g"] = { name = "+git" },
				["<leader>gh"] = { name = "+hunks" },
				["<leader>q"] = { name = "+quit/session" },
				["<leader>s"] = { name = "+search" },
				["<leader>u"] = { name = "+ui" },
				["<leader>w"] = { name = "+windows" },
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

	-- toggleterm
	{
		"akinsho/toggleterm.nvim",
		keys = {
			map("<C-Bslash>", "<cmd>lua Toggle_horizontal()<cr>", "n", "ToggleTerm"),
			map("<leader>gg", "<cmd>lua Toggle_lazygit()<cr>", "n", "Lazygit"),
			map("<leader>ft", "<cmd>lua Toggle_float()<cr>", "n", "FloatTerm"),
		},
		-- config = true,
		config = function()
			-- execute toggleterm
			require("toggleterm").setup()

			local Terminal = require("toggleterm.terminal").Terminal

			local lazygit = Terminal:new({
				cmd = "lazygit",
				direction = "float",
				hidden = true,
				close_on_exit = true,
			})

			function Toggle_lazygit()
				local has_lazygit = vim.fn.executable("lazygit") == 1
				if has_lazygit then
					lazygit:toggle()
				end
			end

			local horizontal = Terminal:new({
				direction = "horizontal",
				size = 20,
				on_open = function(term)
					local noremap = { noremap = true, silent = true }
					-- change terminal mode to normal
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)
				end,
			})
			function Toggle_horizontal()
				horizontal:toggle()
			end

			local floatterm = Terminal:new({
				direction = "float",
				hidden = true,
				close_on_exist = true,
			})
			function Toggle_float()
				floatterm:toggle()
			end
		end,
	},

	-- leap
	{
		"ggandor/leap.nvim",
		enabled = true,
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			-- { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
	},

	-- iron (repl tool)
	{
		"hkupty/iron.nvim",
		keys = {
			map("<leader>rs", "<cmd>lua IronStartCustom()<cr>", "n", "Start IronReplCustom"),
		},
		config = function(plugins, opts)
			local iron = require("iron.core")

			iron.setup({
				config = {
					-- Whether a repl should be discarded or not
					scratch_repl = true,
					-- Your repl definitions com here
					repl_definition = {
						python = {
							-- can be a table or a function that
							-- returns a table (see below)
							command = { "python" },
						},
					},

					-- How the repl window will be displayed
					-- See below fore more information
					repl_open_cmd = require("iron.view").split("40%"),
				},
				keymaps = {
					send_motion = "<leader>rc",
					visual_send = "<leader>rc",
					send_file = "<leader>rf",
					send_line = "<leader>rl",
					send_mark = "<leader>rm",
					mark_motion = "<leader>rmc",
					mark_visual = "<leader>rmc",
					remove_mark = "<leader>rmd",
					cr = "<leader>r<CR>",
					interrupt = "<leader>r<space>",
					exit = "<leader>rq",
					clear = "<leader>rx",
				},
				-- If the highlight is on, you can change how it looks
				-- for the available options, check nvim_set_hl
				highlight = {
					italic = true,
				},
				ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
			})

			-- customize start function
			function IronStartCustom()
				local ironcore = require("iron.core")
				local ironll = require("iron.lowlevel")
				local term = ironcore.repl_for(ironll.get_buffer_ft(0))

				-- set the keymap for terminal
				local noremap = { noremap = true, silent = true }
				-- change terminal mode to normal
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)
			end

			-- iron also has a list of commands, see :h iron-commands for all available commands
			-- vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<CR>")
			vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<CR>")
			vim.keymap.set("n", "<leader>rF", "<cmd>IronFocus<CR>")
			vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<CR>")
		end,
	},
}
