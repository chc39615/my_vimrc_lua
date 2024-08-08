local LazyUtil = require("lazy.core.util")

---@class myutil: LazyUtilCore
---@field config LazyVimConfig
---@field cmp myutil.cmp
---@field debug myutil.debug
---@field format myutil.format
---@field lsp myutil.lsp
---@field lualine myutil.lualine
---@field mini myutil.mini
---@field pick myutil.pick
---@field plugin myutil.plugin
---@field providers myutil.providers
---@field root myutil.root
---@field terminal myutil.terminal
---@field toggle myutil.toggle
---@field ui myutil.ui

local M = {}

setmetatable(M, {
    __index = function(t, k)
        if LazyUtil[k] then
            return LazyUtil[k]
        end
        ---@diagnostic disable-next-line: no-unknown
        t[k] = require("myutil." .. k)
        return t[k]
    end,
})

function M.is_win()
    return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param name string
function M.get_plugin(name)
    return require("lazy.core.config").spec.plugins[name]
end

---@param name string
---@param path string?
function M.get_plugin_path(name, path)
    local plugin = M.get_plugin(name)
    path = path and "/" .. path or ""
    return plugin and (plugin.dir .. path)
end

---@param plugin string
function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

---@param name string
function M.opts(name)
    local plugin = M.get_plugin(name)
    if not plugin then
        return {}
    end
    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
end

function M.deprecate(old, new)
    M.warn(("`%s` is deprecated. Please use `%s` instead"):format(old, new), {
        title = "LazyVim",
        once = true,
        stacktrace = true,
        stacklevel = 6,
    })
end

-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
    local notifs = {}
    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.uv.new_timer()
    local check = assert(vim.uv.new_check())

    local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)
    -- or if it took more than 500ms, then something went wrong
    timer:start(500, 0, replay)
end

function M.is_loaded(name)
    local Config = require("lazy.core.config")
    return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
    if M.is_loaded(name) then
        fn(name)
    else
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            callback = function(event)
                if event.data == name then
                    fn(name)
                    return true
                end
            end,
        })
    end
end

--
-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    local modes = type(mode) == "string" and { mode } or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (keys.have and keys:have(lhs, m))
    end, modes)

    -- do not create the keymap if a lazy keys handler exists
    if #modes > 0 then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        if opts.remap and not vim.g.vscode then
            ---@diagnostic disable-next-line: no-unknown
            opts.remap = nil
        end
        vim.keymap.set(modes, lhs, rhs, opts)
    end
end

-- remove duplicate elements from a list
---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
    local ret = {}
    local seen = {}
    for _, v in ipairs(list) do
        if not seen[v] then
            table.insert(ret, v)
            seen[v] = true
        end
    end
    return ret
end

-- create undo point
M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
    if vim.api.nvim_get_mode().mode == "i" then
        vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
    end
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
    pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
    local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
    opts = opts or {}
    opts.warn = opts.warn == nil and true or opts.warn
    path = path or ""
    local ret = root .. "/packages/" .. pkg .. "/" .. path
    if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
        M.warn(
            ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
                pkg,
                path
            )
        )
    end
    return ret
end

-- speed up the fn
local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
    return function(...)
        local key = vim.inspect({ ... })
        cache[fn] = cache[fn] or {}
        if cache[fn][key] == nil then
            cache[fn][key] = fn(...)
        end
        return cache[fn][key]
    end
end

---@param mode string
---@param desc string|table|nil
function M.map(mode, lhs, rhs, desc, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    -- do not create the keymap if a lazy keys handler exists
    local options = { silent = true, noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end

    if desc ~= nil then
        if type(desc) == "string" then
            options.desc = desc
        else
            options = vim.tbl_extend("keep", options, desc)
        end
    end

    -- opts = opts or { silent = true, noremap = true }
    if not keys.active[keys.parse({ lhs, mode = mode }).id] then
        options.silent = options.silent ~= false
        vim.keymap.set(mode, lhs, rhs, options)
    end
end

---@param plugin string
function M.has_plugin(plugin)
    local modname = plugin
    return vim.tbl_contains(require("lazy.core.config").spec.modules, modname)
end

---@param fn fun()
function M.on_very_lazy(fn)
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
            fn()
        end,
    })
end

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
