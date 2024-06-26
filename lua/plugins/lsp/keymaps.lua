local M = {}

---@type PluginLspKeys
M._keys = nil

---@return (LazyKeysSpec|{has?:string})[]
function M.get()
	local format = require("plugins.lsp.format").format
	if not M._keys then
        ---@class PluginLspKeys
        -- stylua: ignore
        M._keys = {
            { "<leader>cd", vim.diagnostic.open_float, desc = "Line diagnostics" },
            { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
            { "gd", "<cmd>Telescop lsp_definitions<cr>", desc = "Goto Definition", has = "definition" },
            { "gr", "<cmd>Telescop lsp_references<cr>", desc = "References" },
            { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
            { "gI", "<cmd>Telescop lsp_implementations<cr>", desc = "Goto Implementation" },
            { "gt", "<cmd>Telescop lsp_type_definitions<cr>", desc = "Goto Type Definition" },
            { "K", vim.lsp.buf.hover, desc = "Hover" },
            -- { "gK", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
            -- { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
            { "]dn", M.diagnostic_goto(true), desc = "Next Diagnostic" },
            { "]dp", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
            { "]en", M.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
            { "]ep", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
            { "]wn", M.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
            { "]wp", M.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
            { "<leader>cf", format, desc = "Format Document", has = "documentFormatting" },
            { "<leader>cf", format, desc = "Format Range", mode = "v", has = "documentFormatting" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
            { "<leader>cA", function() vim.lsp.buf.code_action({
                    context = {
                        only = {
                            "source",
                        },
                        diagnostics = {},
                    },
                }) end,
                desc = "Source Action",
                has = "codeAction",
            }
        }

		if require("myutil").has("inc-rename.nvim") then
			M._keys[#M._keys + 1] = {
				"<f2>",
				function()
					require("inc_rename")
					return ":IncRename " .. vim.fn.expand("<cword>")
				end,
				expr = true,
				desc = "Rename",
				has = "rename",
			}
		else
			M._keys[#M._keys + 1] = { "<f2>", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
		end
	end
	return M._keys
end

function M.on_attach(client, buffer)
	local Keys = require("lazy.core.handler.keys")
	local keymaps = {} ---@type table<string,LazyKeys|{has?:string}>

	for _, value in ipairs(M.get()) do
		local keys = Keys.parse(value)
		if keys[2] == vim.NIL or keys[2] == false then
			keymaps[keys.id] = nil
		else
			keymaps[keys.id] = keys
		end
	end

	for _, keys in pairs(keymaps) do
		-- print("on_attach keymaps test")
		-- print(vim.inspect(keys))
		if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
			local opts = Keys.opts(keys)
			---@diagnostic disable-next-line: no-unknown
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer
			vim.keymap.set(keys.mode or "n", keys.lhs or keys[1], keys.rhs or keys[2], opts)
		end
	end
end

function M.diagnostic_goto(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

-- print(vim.inspect(M.get()))

-- local Keys = require("lazy.core.handler.keys")
-- for _, value in ipairs(M.get()) do
-- 	local keys = Keys.parse(value)
-- 	print(vim.inspect(value))
-- 	print(vim.inspect(keys))
-- end

return M
