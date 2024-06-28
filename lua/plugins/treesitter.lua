return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- event = { "LazyFile", "VeryLazy" },
		event = { "BufReadPre", "BufNewfile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		init = function(plugin)
			-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
			-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
			-- no longer trigger the **nvim-treeitter** module to be loaded in time.
			-- Luckily, the only thins that those plugins need are the custom queries, which we make available
			-- during startup.
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		---@type TSConfig
		opts = {
			modules = {},
			ignore_install = {},
			highlight = {
				-- `false` will disable the whole extension
				enable = true,
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time
				-- Set this true if youi depend on 'syntax' being enabled (like for indentation)
				-- Using this option may slow down your editor, and yoiu may see some duplicate highlights
				-- Instead of true it can also be a list of languades
				additional_vim_regex_highlighting = false,
				disable = function(ft, buf)
					return vim.b[buf].bigfile or vim.fn.win_gettype() == "command"
				end,
			},
			ensure_installed = {
				"vimdoc",
				"javascript",
				"html",
				"css",
				"json",
				"bash",
				"make",
				"ninja",
				"cpp",
				"c",
				"dockerfile",
				"comment",
				"python",
				"lua",
				"markdown",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<c-s>",
					node_incremental = "<c-s>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,
			-- Automatically install missing parsers when entering buffer
			auto_install = false,
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			-- vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
			-- 	group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
			-- 	callback = function()
			-- 		vim.opt.foldlevel = 99
			-- 		vim.opt.foldmethod = "expr"
			-- 		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			-- 	end,
			-- })
		end,
	},

	-- better text-objects
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		-- dependencies = { "nvim-treesitter-textobjects" },
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			-- register all text objects with which-key
			if require("myutil").has("which-key.nvim") then
				---@type table<string, string|table>
				local i = {
					[" "] = "Whitespace",
					['"'] = 'Balanced "',
					["'"] = "Balanced '",
					["`"] = "Balanced `",
					["("] = "Balanced (",
					[")"] = "Balanced ) including white-space",
					[">"] = "Balanced > including white-space",
					["<lt>"] = "Balanced <",
					["]"] = "Balanced ] including white-space",
					["["] = "Balanced [",
					["}"] = "Balanced } including white-space",
					["{"] = "Balanced {",
					["?"] = "User Prompt",
					_ = "Underscore",
					a = "Argument",
					b = "Balanced ), ], }",
					c = "Class",
					f = "Function",
					o = "Block, conditional, loop",
					q = "Quote `, \", '",
					t = "Tag",
				}
				local a = vim.deepcopy(i)
				for k, v in pairs(a) do
					a[k] = v:gsub(" including.*", "")
				end

				local ic = vim.deepcopy(i)
				local ac = vim.deepcopy(a)
				for key, name in pairs({ n = "Next", l = "Last" }) do
					i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
					a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
				end
				require("which-key").register({ mode = { "o", "x" }, i = i, a = a })
			end
		end,
	},

	-- comments: auto switch comment style by cursor position
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		config = function()
			require("ts_context_commentstring").setup({})
			vim.g.skip_ts_context_commentstring_module = true
		end,
	},

	{
		"echasnovski/mini.comment",
		version = "*",
		event = "VeryLazy",
		opts = {
			options = {
				-- Function to compute custom 'commentstring' (optional)
				custom_commentstring = function()
					return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
				end,

				-- Whether to ignore blank lines when commenting
				ignore_blank_line = false,

				-- Whether to recognize as comment only lines without indent
				start_of_line = false,

				-- Whether to force single space inner padding for comment parts
				pad_comment_parts = true,
			},
		},
		config = function(_, opts)
			require("mini.comment").setup(opts)
		end,
	},
}
