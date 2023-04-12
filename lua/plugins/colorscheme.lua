return {
    'marko-cerovac/material.nvim',
    config = function()
        vim.g.material_style = 'oceanic'
        vim.cmd 'colorscheme material'
    end
}
