local M = {}

local defaults = {
	-- colorscheme can be a string like `catppuccin` or a function that wiil load the colowscheme
	---@type string|fun()
	-- colorscheme = "tokyonight",
	colorscheme = function()
		require("tokyonight").setup({
			style = "storm",
			on_colors = function(colors)
				colors.border = "orange"
			end,
		})
		vim.cmd.colorscheme("tokyonight")
		-- require("material.functions").change_style("oceanic")
	end,
	-- load the default settings
	defaults = {
		autocmds = true,
		keymaps = true,
		options = true,
	},
	-- icons used by other plugins
	icons = {
		diagnostics = {
			Error = " ",
			Warn = " ",
			Hint = " ",
			Info = " ",
		},
		git = {
			added = " ",
			modified = " ",
			removed = " ",
		},
		kinds = {
			Array = " ",
			Boolean = " ",
			Class = " ",
			Color = " ",
			Constant = " ",
			Constructor = " ",
			Copilot = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = " ",
			Interface = " ",
			Key = " ",
			Keyword = " ",
			Method = " ",
			Module = " ",
			Namespace = " ",
			Null = " ",
			Number = " ",
			Object = " ",
			Operator = " ",
			Package = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			String = " ",
			Struct = " ",
			Text = " ",
			TypeParameter = " ",
			Unit = " ",
			Value = " ",
			Variable = " ",
		},
	},
}

local options

function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {})

	if vim.fn.argc(-1) == 0 then
		-- autocmds and keymaps can wait to load
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("LazyVim", { clear = true }),
			pattern = "VeryLazy",
			callback = function()
				M.load("autocmds")
				M.load("keymaps")
			end,
		})
	else
		-- load them now so they affect the opened buffers
		M.load("autocmds")
		M.load("keymaps")
	end

	require("lazy.core.util").try(function()
		if type(M.colorscheme) == "function" then
			M.colorscheme()
		else
			vim.cmd.colorscheme(M.colorscheme)
		end
	end, {
		msg = "Could not load your colorscheme",
		on_error = function(msg)
			require("lazy.core.util").error(msg)
			vim.cmd.colorscheme("habamax")
		end,
	})
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
	local Util = require("lazy.core.util")
	local function _load(mod)
		Util.try(function()
			require(mod)
		end, {
			msg = "Failed loading " .. mod,
			on_error = function(msg)
				local info = require("lazy.core.cache").find(mod)
				if info == nil or (type(info) == "table" and #info == 0) then
					return
				end
				Util.error(msg)
			end,
		})
	end

	if M.defaults[name] then
		_load("config." .. name)
	end
	if vim.bo.filetype == "lazy" then
		-- HACK: LazyVim my have overwritten options of the Lazy ui, so reset this here
		vim.cmd([[do VimResized]])
	end
end

M.did_init = false
function M.init()
	if not M.did_init then
		M.did_init = true
		-- delay notifications till vim.notify was replaced or after 500ms
		require("myutil").lazy_notify()

		-- load options here, before lazy init while sourcing plugin modules
		-- this is needed to make sure options will be correctly applied
		-- after installing missing plugins
		require("config.init").load("options")
	end
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		return options[key]
	end,
})

function M.get_device_name()
	local handle = io.popen("hostname")
	if handle then
		local hostname = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return hostname
	else
		return nil
	end
end

return M
