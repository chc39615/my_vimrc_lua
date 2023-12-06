local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"checkhealth",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- only mapping for toggle term use term://**
local function set_terminal_keymaps()
	local noremap = { noremap = true, silent = true }
	-- change terminal mode to normal
	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<c-\><c-n>]], noremap)
	vim.api.nvim_buf_set_keymap(0, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
	vim.api.nvim_buf_set_keymap(0, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
	vim.api.nvim_buf_set_keymap(0, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
	vim.api.nvim_buf_set_keymap(0, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)
end

vim.api.nvim_create_autocmd({ "TermOpen" }, {
	pattern = { "term://*" },
	group = augroup("terminalKeymapping"),
	desc = "windows navigator keymaps in terminal",
	callback = set_terminal_keymaps,
})
-- Function to check if a floating dialog exists and if not
-- then check for diagnostics under the cursor
-- function OpenDiagnosticIfNoFloat()
-- 	for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
-- 		if vim.api.nvim_win_get_config(winid).zindex then
-- 			return
-- 		end
-- 	end
-- 	-- THIS IS FOR BUILTIN LSP
-- 	vim.diagnostic.open_float(0, {
-- 		scope = "cursor",
-- 		focusable = false,
-- 		close_events = {
-- 			"CursorMoved",
-- 			"CursorMovedI",
-- 			"BufHidden",
-- 			"InsertCharPre",
-- 			"WinLeave",
-- 		},
-- 	})
-- end
-- -- Show diagnostics under the cursor when holding position
-- vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
-- vim.api.nvim_create_autocmd({ "CursorHold" }, {
-- 	pattern = "*",
-- 	command = "lua OpenDiagnosticIfNoFloat()",
-- 	group = "lsp_diagnostics_hold",
-- })
