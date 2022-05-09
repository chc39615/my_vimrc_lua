local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
end



return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- commentary.vim
    use 'tpope/vim-commentary'

    -- lualine
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function() require('lualine').setup{
            options = { theme = 'papercolor_dark' }
        } end
    }

    -- nvim-tree
    use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function() require('nvim-tree').setup{} end
    }

    -- telescope
    use { 
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    -- toggleterm
    use {
        'akinsho/toggleterm.nvim',
        tag = 'v1.*',
        config = function() require("toggleterm").setup{} end
    }

    -- AnsiEsc
    use 'powerman/vim-plugin-AnsiEsc'

    -- colorscheme material
    use 'marko-cerovac/material.nvim'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end

end)
