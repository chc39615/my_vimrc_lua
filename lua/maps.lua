local map = vim.api.nvim_set_keymap


-- map the leader key
map('n', '<Space>', '', {})
vim.g.mapleader = ' ' -- 'vim.g sets global variables

local noremap = { noremap = true, silent = true }

-- clear highlight
map('n', '<leader><esc>', ':noh<cr>', noremap)

-- select after indent
map('v', '>', '>gv', noremap)
map('v', '<', '<gv', noremap)

-- go to the last character of the previously yanked text
map('v', 'y', 'y`]', noremap)

-- navigate between buffers
map('n', '<leader>n', ':bnext<cr>', noremap)
map('n', '<leader>p', ':bprev<cr>', noremap)

-- navigate between windows
map('n', '<c-j>', '<c-w>j', noremap)
map('n', '<c-k>', '<c-w>k', noremap)
map('n', '<c-h>', '<c-w>h', noremap)
map('n', '<c-l>', '<c-w>l', noremap)


-- resize window with arrows
map('n', '<c-up>', ':resize -2<cr>', noremap)
map('n', '<c-down>', ':resize +2<cr>', noremap)
map('n', '<c-left>', ':vertical resize -2<cr>', noremap)
map('n', '<c-right>', ':vertical resize +2<cr>', noremap)

-- open explore
map('n', '<leader>e', ':NvimTreeToggle<cr>', noremap)

-- telescope setting
map('n', '<leader>ff', ':Telescope find_files<cr>', noremap)
map('n', '<leader>fg', ':Telescope live_grep<cr>', noremap)
map('n', '<leader>fb', ':Telescope buffers<cr>', noremap)
map('n', '<leader>fh', ':Telescope help_tags<cr>', noremap)

-- insert tab
map('i', '<S-Tab>', '<c-v><Tab>', noremap)

-- toggleterm
map('n', '<C-Bslash>', ':ToggleTerm<cr>', noremap)
map('t', '<C-Bslash>', '<cmd>ToggleTerm<cr>', noremap)

-- only mapping for toggle term use term://*toggleterm#*
local function set_terminal_keymaps()
    -- change terminal mode to normal
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<c-\><c-n>]], noremap)
    vim.api.nvim_buf_set_keymap(0, 't', '<c-h>', [[<c-\><c-n><c-w>h]], noremap)
    vim.api.nvim_buf_set_keymap(0, 't', '<c-j>', [[<c-\><c-n><c-w>j]], noremap)
    vim.api.nvim_buf_set_keymap(0, 't', '<c-k>', [[<c-\><c-n><c-w>k]], noremap)
    vim.api.nvim_buf_set_keymap(0, 't', '<c-l>', [[<c-\><c-n><c-w>l]], noremap)
end

local augroup = vim.api.nvim_create_augroup("toggletermKeymap", { clear = true })

vim.api.nvim_create_autocmd({"TermOpen"}, {
    pattern = { 'term://*' },
    group = augroup,
    desc = "toggleterm keymaps",
    callback = set_terminal_keymaps
})
