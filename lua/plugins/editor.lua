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

	-- hop
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			local hop = require("hop")

			hop.setup({
				keys = "stenriaovmfulpwycbkxdhgjzq",
				uppercase_labels = true,
			})

			local directions = require("hop.hint").HintDirection
			vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { noremap = true, silent = true, nowait = true })

			vim.keymap.set({ "n", "v" }, "f", function()
				hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
			end, { remap = true })
			vim.keymap.set({ "n", "v" }, "F", function()
				hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
			end, { remap = true })
			vim.keymap.set({ "n", "v" }, "t", function()
				hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
			end, { remap = true })
			vim.keymap.set({ "n", "v" }, "T", function()
				hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
			end, { remap = true })
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
				["gz"] = { name = "+surround" },
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
			wk.register(keymaps)
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		config = function()
			local map = vim.api.nvim_set_keymap
			local noremap = { noremap = true, silent = true }

			-- execute toggleterm
			require("toggleterm").setup()

			map("n", "<C-Bslash>", ":ToggleTerm<cr>", noremap)
			map("t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)

			-- only mapping for toggle term use term://*toggleterm#*
			local function set_terminal_keymaps()
				-- change terminal mode to normal
				vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<c-\><c-n>]], noremap)
				vim.api.nvim_buf_set_keymap(0, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
				vim.api.nvim_buf_set_keymap(0, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
				vim.api.nvim_buf_set_keymap(0, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
				vim.api.nvim_buf_set_keymap(0, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
			end

			local augroup = vim.api.nvim_create_augroup("toggletermKeymap", { clear = true })

			vim.api.nvim_create_autocmd({ "TermOpen" }, {
				pattern = { "term://*" },
				group = augroup,
				desc = "toggleterm keymaps",
				callback = set_terminal_keymaps,
			})
		end,
	},

	-- AnsiEsc
	-- Usage: :AnsiEsc - toggle Ansi escape sequence highlighting
	{ "powerman/vim-plugin-AnsiEsc" },
}
