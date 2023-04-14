return {
    'akinsho/toggleterm.nvim',
    config = function()
        local map = vim.api.nvim_set_keymap
        local noremap = { noremap = true, silent = true }

        -- execute toggleterm
        require('toggleterm').setup()

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

        vim.api.nvim_create_autocmd({ "TermOpen" }, {
            pattern = { 'term://*' },
            group = augroup,
            desc = "toggleterm keymaps",
            callback = set_terminal_keymaps
        })
    end
}
