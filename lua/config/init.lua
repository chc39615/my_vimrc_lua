_G.Myutil = require("myutil")

---@class LazyVimConfig: LazyVimOptions
local M = {}

local LazyUtil = require("lazy.core.util")

Myutil.config = M
---@class LazyVimOptions
local defaults = {
	defaults = {
		autocmds = true,
		keymaps = true,
	},
	icons = {
		misc = {
			dots = "󰇘",
		},
		ft = {
			octo = "",
		},
		dap = {
			Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = " ",
			BreakpointCondition = " ",
			BreakpointRejected = { " ", "DiagnosticError" },
			LogPoint = ".>",
		},
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
			Boolean = "󰨙 ",
			Class = " ",
			Codeium = "󰘦 ",
			Color = " ",
			Control = " ",
			Collapsed = " ",
			Constant = "󰏿 ",
			Constructor = " ",
			Copilot = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = "󰊕 ",
			Interface = " ",
			Key = " ",
			Keyword = " ",
			Method = "󰊕 ",
			Module = " ",
			Namespace = "󰦮 ",
			Null = " ",
			Number = "󰎠 ",
			Object = " ",
			Operator = " ",
			Package = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			String = " ",
			Struct = "󰆼 ",
			TabNine = "󰏚 ",
			Text = " ",
			TypeParameter = " ",
			Unit = " ",
			Value = " ",
			Variable = "󰀫 ",
		},
	},
	---@type table<string, string[]|boolean>?
	kind_filter = {
		default = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Package",
			"Property",
			"Struct",
			"Trait",
		},
		markdown = false,
		help = false,
		-- you can specify a different filter for each filetype
		lua = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			-- "Package", -- remove package since luals uses it for control flow structures
			"Property",
			"Struct",
			"Trait",
		},
	},
}

local options
function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

	-- autocmds can be loaded lazily when not opening a file
	local lazy_autocmds = vim.fn.argc(-1) == 0
	if not lazy_autocmds then
		M.load("autocmds")
	end

	local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			if lazy_autocmds then
				M.load("autocmds")
			end
			M.load("keymaps")

			local format = require("myutil.format")
			format.setup()

			local health = require("lazy.health")
			vim.list_extend(health.valid, {
				"recommended",
				"desc",
				"vscode",
			})
		end,
	})
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
	local function _load(mod)
		if require("lazy.core.cache").find(mod)[1] then
			LazyUtil.try(function()
				require(mod)
			end, { msg = "Failed loading " .. mod })
		end
	end
	_load("config." .. name)
	if vim.bo.filetype == "lazy" then
		-- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
		vim.cmd([[do VimResized]])
	end

	local pattern = "Config" .. name:sub(1, 1):upper() .. name:sub(2)
	vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local ft = vim.bo[buf].filetype
	if M.kind_filter == false then
		return
	end
	if M.kind_filter[ft] == false then
		return
	end
	if type(M.kind_filter[ft]) == "table" then
		return M.kind_filter[ft]
	end
	---@diagnostic disable-next-line: return-type-mismatch
	return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

M.did_init = false
function M.init()
	if M.did_init then
		return
	end

	M.did_init = true
	M.load("options")

	Myutil.plugin.setup()
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		return options[key]
	end,
})

return M
