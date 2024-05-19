return {

	-- lsp symbol navigation for lualine
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		init = function()
			vim.g.navic_silence = true
			require("myutil").on_attach(function(client, buffer)
				if client.server_capabilities.documentSymbolProvider then
					require("nvim-navic").attach(client, buffer)
				end
			end)
		end,
		opts = function()
			return {
				separator = " ",
				highlight = true,
				depth_limit = 5,
				icons = require("config").icons.kinds,
			}
		end,
	},

	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			{ "kyazdani42/nvim-web-devicons", opt = true },
		},
		event = "VeryLazy",
		enabled = true,
		opts = function()
			local icons = require("config").icons

			local function fg(name)
				return function()
					local lua_id = vim.api.nvim_get_hl_id_by_name(name)
					---@type {foreground?:number}?
					local hl = vim.api.nvim_get_hl(lua_id, {})
					return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
				end
			end

			return {
				options = {
					theme = "auto",
					globalstatus = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{
							"diagnostics",
							symbols = {
								error = icons.diagnostics.Error,
								warn = icons.diagnostics.Warn,
								info = icons.diagnostics.Info,
								hint = icons.diagnostics.Hint,
							},
						},
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{ "filename", path = 1, symbols = { modified = "  ", readonly = "  ", unnamed = "" } },
						-- stylua: ignore
						{
							function() return require("nvim-navic").get_location() end,
							cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
						},
					},
					lualine_x = {
						-- stylua: ignore
                        {
                            require("noice").api.status.command.get,
                            cond = require("noice").api.status.command.has,
                            color = fg("Statement"),
                        },
						{
							function()
								return require("noice").api.status.command.get()
							end,
							cond = function()
								return package.loaded["noice"] and require("noice").api.status.command.has()
							end,
							color = fg("Statement"),
						},
						-- stylua: ignore
                        {
                            require("noice").api.status.mode.get,
                            cond = require("noice").api.status.command.has,
                            color = fg("Constant"),
                        },
						{
							function()
								return require("noice").api.status.mode.get()
							end,
							cond = function()
								return package.loaded["noice"] and require("noice").api.status.mode.has()
							end,
							color = fg("Constant"),
						},
						{
							require("lazy.status").updates,
							cond = require("lazy.status").has_updates,
							color = fg("Special"),
						},
						{
							"diff",
							symbols = {
								added = icons.git.added,
								modified = icons.git.modified,
								removed = icons.git.removed,
							},
						},
					},
					lualine_y = {
						{ "progress", separator = " ", padding = { left = 1, right = 0 } },
						{ "location", padding = { left = 0, right = 1 } },
					},
				},
				extensions = { "lazy", "nvim-tree", "toggleterm" },
			}
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = true,
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)

			require("ibl").setup({
				enabled = false,
				indent = { highlight = highlight, char = "▏", priority = 100 },
				scope = {
					enabled = false,
				},
				exclude = { filetypes = { "help", "alpha", "dashboard", "nvim-tree", "Trouble", "lazy" } },
				whitespace = { remove_blankline_trail = true },
				-- space_char_blankline = " ",
			})

			vim.api.nvim_set_keymap("n", "<leader>ub", ":IBLToggle<cr>", { noremap = true, silent = true })
		end,
	},

	-- noice ui
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		enabled = true,
		dependencies = {
			"MunifTanjim/nui.nvim",
		},

		-- stylua: ignore
		keys = {
			{ "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
			{ "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
			{ "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
			{ "<leader>snc", function() require("noice").cmd("cleanhistory") end, desc = "Noice Clean History" },
			{ "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
			{ "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
			{ "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = {"i", "n", "s"} },
			{ "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = {"i", "n", "s"}},
		},

		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = false,
				lsp_doc_border = true,
			},
			routes = {
				{
					filter = { event = "msg_show", cmdline = "g/.+/?" },
					view = "split",
				},
			},
			commands = {
				cleanhistory = {
					view = "split",
					opts = { enter = true, format = "notify" },
					filter = {
						any = {
							{ event = "notify" },
							{ error = true },
							{ warning = true },
							{ event = "msg_show", kind = { "" } },
							{ event = "lsp", kind = "message" },
						},
					},
				},
			},
		},
	},
}
