return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        -- vim.list_extend({ '<leader>ff', ':Telescope find_files<cr>', desc = "find files" }, {silent = true, noremap = true }),
        { '<leader>ff', ':Telescope find_files<cr>', desc = "find files", silent = true, noremap = true },
        { '<leader>fg', ':Telescope live_grep<cr>', desc = 'live grep' , silent = true, noremap = true },
        { '<leader>fb', ':Telescope buffers<cr>', desc = 'buffers', silent = true, noremap = true },
        { '<leader>fh', ':Telescope help_tags<cr>', desc = 'search help', silent = true, noremap = true },

        { '<leader>FF', ':execute "Telescope find_files default_text=" . expand("<cWORD>")<cr>', desc = 'find files of current word', silent = true, noremap = true },
        { '<leader>GG', ':execute "Telescope live_grep default_text=" . expand("<cword>")<cr>', desc = 'live grep of current word', silent = true, noremap = true },
    }
}
