return {

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		build = (not jit.os:find("Windows"))
				and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
			or nil,
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				-- Dynamically get the path to friendly-snippets
				local friendly_snippets_path = vim.fn.stdpath("data") .. "/lazy/friendly-snippets"

				-- Load VSCode-like snippets from the dynamically obtained path
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = { friendly_snippets_path },
				})
				-- require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
	       -- stylua: ignore
	       keys = {
	           {
	               "<tab>",
	               function()
	                   return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
	               end,
	               expr = true, silent = true, mode = "i",
	           },
	           { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
	           { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
	       },
	},

	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"dmitmel/cmp-cmdline-history",
		},
		opts = function()
			local cmp = require("cmp")

			local cmdline_mapping = {
				["<Down>"] = {
					c = function()
						if cmp.visible() then
							cmp.select_next_item()
						else
							cmp.complete()
						end
					end,
				},
				["<Up>"] = {
					c = function()
						if cmp.visible() then
							cmp.select_prev_item()
						else
							cmp.complete()
						end
					end,
				},
				["<C-c>"] = {
					c = cmp.mapping.abort(),
				},
				["<C-f>"] = {
					c = cmp.mapping.confirm({ select = true }),
				},
			}

			-- use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore)
			---@diagnostic disable-next-line: missing-fields
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmdline_mapping,
				sources = {
					{ name = "buffer" },
				},
			})

			-- use cmdline & path source for ':' (if you enable `native_menu`, this won't work anymore)
			---@diagnostic disable-next-line: missing-fields
			cmp.setup.cmdline(":", {
				mapping = cmdline_mapping,
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
					{ name = "cmdline_history" },
				}),
			})

			-- copied from AstroNvim
			local border_opts = {
				border = "single",
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
			}

			return {
				preselect = require("cmp").PreselectMode.None,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(border_opts),
					documentation = cmp.config.window.bordered(border_opts),
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = { i = cmp.mapping.confirm({ select = false }) },
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				formatting = {
					format = function(_, item)
						local icons = require("config").icons.kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end
						return item
					end,
				},
				enabled = function()
					-- disable completion in comments
					local context = require("cmp.config.context")
					-- keep command mode completion enabled when cursor is in a comment
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
					end
				end,
				experimental = {
					-- ghost_text = {},
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
			}
		end,
		config = function(_, opts)
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			require("cmp").setup(opts)
		end,
	},

	-- auto pairs
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},

	{
		"echasnovski/mini.surround",
		version = "*",
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
		config = function(_, opts)
			-- use gz mappings instead of s to prevent conflict with leap
			require("mini.surround").setup(opts)
		end,
	},
}
