local map_opts = { silent = true, noremap = true }
local function map(lhs, rhs, mode, desc, opts)
    mode = mode or "n"
    local lazyKeys = { lhs, rhs, mode }
    if type(desc) == "string" then
        lazyKeys.desc = desc
    end
    

    return vim.tbl_extend("keep", lazyKeys, opts)

end

return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        map('<leader>ff', ':Telescope find_files<cr>', 'n', 'find files', map_opts),
        map('<leader>fg', ':Telescope live_grep<cr>', 'n', 'live grep' , map_opts),
        map('<leader>fb', ':Telescope buffers<cr>', 'n', 'buffers' , map_opts),
        map('<leader>fh', ':Telescope help_tags<cr>', 'n', 'search help' , map_opts),

        map('<leader>FF', ':execute "Telescope find_files default_text=" . expand("<cWORD>")<cr>', 'n', 'find files of current word' , map_opts),
        map('<leader>GG', ':execute "Telescope live_grep default_text=" . expand("<cword>")<cr>', 'n', 'live grep of current word' , map_opts),
    }
}
