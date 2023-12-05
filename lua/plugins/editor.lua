local Util = require("myutil")
local map = Util.lazy_map

return {
	-- file explorer
	{
		"kyazdani42/nvim-tree.lua",
		-- dependencies = { 'kyazdani42/nvim-web-devicons' },
		-- keys = {
		--     { '<leader>e', ':NvimTreeToggle<cr>', 'n', desc = "toggle nvim-tree" }
		-- },
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			vim.opt.termguicolors = true

			local function nvimtree_on_attach(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				api.config.mappings.default_on_attach(bufnr)

				vim.keymap.set("n", "j", "j", opts("reset j"))
				vim.keymap.set("n", "k", "k", opts("reset k"))
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
			vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<cr>", { noremap = true, silent = true })
		end,
	},

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			if Util.has("nvim-notify") then
				require("telescope").load_extension("notify")
			end
		end,
		keys = {
			map("<leader>ff", Util.telescope("files"), "n", "find files"),
			map("<leader>fg", Util.telescope("live_grep"), "n", "live grep"),
			map("<leader>fb", "<cmd>Telescope buffers<cr>", "n", "buffers"),
			map("<leader>fh", "<cmd>Telescope help_tags<cr>", "n", "search help"),

			map(
				"<leader>FF",
				':execute "Telescope find_files default_text=" . expand("<cWORD>")<cr>',
				"n",
				"find files of current word"
			),
			map(
				"<leader>FG",
				':execute "Telescope live_grep default_text=" . expand("<cword>")<cr>',
				"n",
				"live grep of current word"
			),
		},
	},
}
