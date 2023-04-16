local map = vim.api.nvim_set_keymap

-- map the leader key
-- because lazy.nvim need to initial after map leader key
-- move this to mypacker.lua
-- map('n', '<Space>', '', {})
-- vim.g.mapleader = ' ' -- 'vim.g sets global variables

local noremap = { noremap = true, silent = true }


-- scroll screen horizontal
map('n', 'j', '<c-d>', noremap)
map('n', 'k', '<c-u>', noremap)
map('n', 'h', '10zh', noremap)
map('n', 'l', '10zl', noremap)


