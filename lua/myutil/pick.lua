---@class myutil.pick
---@overload fun(command:string, opts?:myutil.pick.Opts): fun()
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.wrap(...)
	end,
})

---@class myutil.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class LazyPicker
---@field name string
---@field open fun(command:string, opts?:myutil.pick.Opts)
---@field commands table<string, string>

---@type LazyPicker?
M.picker = nil

---@param picker LazyPicker
function M.register(picker)
	-- this only happens when using :LazyExtras
	-- so allow to get the full spec
	if vim.v.vim_did_enter == 1 then
		return true
	end

	if M.picker and M.picker.name ~= M.want() then
		M.picker = nil
	end

	if M.picker and M.picker.name ~= picker.name then
		Myutil.warn(
			"`myutil.pick`: picker already set to `"
				.. M.picker.name
				.. "`,\nignoring new picker `"
				.. picker.name
				.. "`"
		)
		return false
	end
	M.picker = picker
	return true
end

function M.want()
	vim.g.mypicker = vim.g.mypicker or "auto"
	if vim.g.mypicker == "auto" then
		return Myutil.has_plugin("fzf-lua") and "fzf" or "telescope"
	end
	return vim.g.mypicker
end

---@param command? string
---@param opts? myutil.pick.Opts
function M.open(command, opts)
	if not M.picker then
		return Myutil.error("myutil: picker not set")
	end

	command = command or "auto"
	opts = opts or {}

	opts = vim.deepcopy(opts)

	if type(opts.cwd) == "boolean" then
		Myutil.warn("myutil: opts.cwd should be a string or nil")
		opts.cwd = nil
	end

	if not opts.cwd and opts.root ~= false then
		opts.cwd = Myutil.root({ buf = opts.buf })
	end

	local cwd = opts.cwd or vim.uv.cwd()
	if command == "auto" then
		command = "files"
		if
			vim.uv.fs_stat(cwd .. "/.git")
			and not vim.uv.fs_stat(cwd .. "/.ignore")
			and not vim.uv.fs_stat(cwd .. "/.rgignore")
		then
			command = "git_files"
			if opts.show_untracked == nil then
				opts.show_untracked = true
				opts.recurse_submodules = false
			end
		end
	end
	command = M.picker.commands[command] or command
	M.picker.open(command, opts)
end

---@param command? string
---@param opts? myutil.pick.Opts
function M.wrap(command, opts)
	opts = opts or {}
	return function()
		Myutil.pick.open(command, vim.deepcopy(opts))
	end
end

function M.config_files()
	return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
