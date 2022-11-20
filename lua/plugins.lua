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
        config = function() require("toggleterm").setup{} end
    }

    -- indent_blankline
    use {
        'lukas-reineke/indent-blankline.nvim',
    }

    -- treesitter
    use {
        'nvim-treesitter/nvim-treesitter', 
        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
        config = function() 
            require("nvim-treesitter.configs").setup {
            -- A list of parser names, or "all"
            ensure_installed = { 
                "javascript", "html", "css", "json", "bash",
                "make", "ninja", "cpp", "c", "dockerfile",
                "comment", "python", "lua", "markdown", 
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            auto_install = true,

            highlight = {
                -- `false` will disable the whole extension
                enable = true,
            },

            indent = {
                enable = true,
            },

        }

        vim.api.nvim_create_autocmd(
            {'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, 
            {
              group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
              callback = function()
                vim.opt.foldlevel      = 20
                vim.opt.foldmethod     = 'expr'
                vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
              end
            }
        ) end,
    }

    
    -- nvim-lsp-installer
    use { 
        'williamboman/nvim-lsp-installer',
        requires = {
            { 'neovim/nvim-lspconfig' }
        },
    }

    -- auto pair
    use 'jiangmiao/auto-pairs'

    -- surround
    use "tpope/vim-surround"

    -- bufonly
    -- delete all the buffers except the cursent buffer
    -- :Bonly, :BOnly, Bfonly
    use 'schickling/vim-bufonly'

    -- AnsiEsc
    -- Usage: :AnsiEsc - toggle Ansi escape sequence highlighting
    use 'powerman/vim-plugin-AnsiEsc'

    -- colorscheme material
    use {
        'marko-cerovac/material.nvim',
        config = function() 
            vim.g.material_style = "darker"
            vim.cmd 'colorscheme material'
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end

end)
