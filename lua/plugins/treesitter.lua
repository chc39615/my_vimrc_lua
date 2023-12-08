return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- event = { "LazyFile", "VeryLazy" },
		event = { "BufReadPost", "BufNewfile", "VeryLazy" },
		init = function(plugin)
			-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
			-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
			-- no longer trigger the **nvim-treeitter** module to be loaded in time.
			-- Luckily, the only thins that those plugins need are the custom queries, which we make available
			-- during startup.
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				config = function()
					-- When in diff mode, we want to use the default
					-- vim text objects c & C instead of the treesitter ones.
					local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
					local configs = require("nvim-treesitter.configs")
					for name, fn in pairs(move) do
						if name:find("goto") == 1 then
							move[name] = function(q, ...)
								if vim.wo.diff then
									local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
									for key, query in pairs(config or {}) do
										if q == query and key:find("[%]%[][cC]") then
											vim.cmd("normal! " .. key)
											return
										end
									end
								end
								return fn(q, ...)
							end
						end
					end
				end,
				-- init = function()
				-- 	-- PERF: no need to load the plugin, if we only need its queries for mini.ai
				-- 	local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
				-- 	local opts = require("lazy.core.plugin").values(plugin, "opts", false)
				-- 	local enabled = false
				-- 	if opts.textobjects then
				-- 		for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
				-- 			if opts.textobjects[mod] and opts.textobjects[mod].enable then
				-- 				enabled = true
				-- 				break
				-- 			end
				-- 		end
				-- 	end
				--
				-- 	if not enabled then
				-- 		require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
				-- 	end
				-- end,
			},
		},
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},
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
			},
			indent = {
				enable = true,
				-- disable = { "python" },
			},
			context_commentstring = { enable = true, enable_autocmd = false },
			ensure_installed = {
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
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
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

			vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
				group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
				callback = function()
					vim.opt.foldlevel = 20
					vim.opt.foldmethod = "expr"
					vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
				end,
			})
		end,
	},
}
