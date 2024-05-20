local Util = require("myutil")
local map = Util.map

return {
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
			map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "NvimTree Toggle")
			map("n", "<leader>fe", "<cmd>NvimTreeFindFile<cr>", "NvimTree Find File")
		end,
	},

	-- telescope-ui-select
	{
		"nvim-telescope/telescope-ui-select.nvim",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			telescope.load_extension("ui-select")
		end,
	},

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					mappings = {
						i = {
							["<left>"] = actions.results_scrolling_left,
							["<right>"] = actions.results_scrolling_right,
							["<PageUp>"] = actions.preview_scrolling_up,
							["<PageDown>"] = actions.preview_scrolling_down,
						},
						n = {
							["<left>"] = actions.results_scrolling_left,
							["<right>"] = actions.results_scrolling_right,
							["<PageUp>"] = actions.preview_scrolling_up,
							["<PageDown>"] = actions.preview_scrolling_down,
						},
					},
					path_display = {
						shorten = {
							len = 2,
							exclude = { 1, -1 },
						},
					},
				},
			}
		end,
		config = function(_, opts)
			-- local telescope = require("telescope")

			-- if Util.has("telescope-ui-select.nvim") then
			-- 	require("telescope").setup({
			-- 		extensions = {
			-- 			["ui-select"] = {
			-- 				require("telescope.themes").get_dropdown({}),
			-- 			},
			-- 		},
			-- 	})
			-- 	telescope.load_extension("ui-select")
			-- end

			-- if Util.has("nvim-notify") then
			-- 	telescope.load_extension("notify")
			-- end

			require("telescope").setup(opts)

			map("n", "<leader>ff", Util.telescope("files"), { desc = "find files" })
			map("n", "<leader>fg", Util.telescope("live_grep"), { desc = "live grep" })
			map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "buffers" })
			map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "search help" })

			map(
				"n",
				"<leader>FF",
				':execute "Telescope find_files default_text=" . expand("<cWORD>")<cr>',
				{ desc = "find files of current word" }
			)
			map(
				"n",
				"<leader>FG",
				':execute "Telescope live_grep default_text=" . expand("<cword>")<cr>',
				{ desc = "live grep of current word" }
			)
		end,
	},
}
