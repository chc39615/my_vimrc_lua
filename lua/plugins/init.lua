return {
    -- commentary.vim
    'tpope/vim-commentary',

    -- lualine
    {
        'nvim-lualine/lualine.nvim',
        -- dependencies = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'papercolor_dark'
                }
        } end
    },


    -- toggleterm
    {
        'akinsho/toggleterm.nvim',
        config = function()
            require('toggleterm').setup()
        end
    },


    -- hop
    {
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            require('hop').setup{
                keys = 'stenriaovmfulpwycbkxdhgjzq',
                uppercase_labels = true,
            }
        end
    },

    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
        config = function()
            require('nvim-treesitter.configs').setup {
            -- A list of parser names, or 'all'
            ensure_installed = {
                'javascript', 'html', 'css', 'json', 'bash',
                'make', 'ninja', 'cpp', 'c', 'dockerfile',
                'comment', 'python', 'lua', 'markdown',
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            auto_install = true,

            highlight = {
                -- `false` will disable the whole extension
                enable = true,
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time
                -- Set this true if youi depend on 'syntax' being enabled (like for indentation)
                -- Using this option may slow down your editor, and yoiu may see some duplicate highlights
                -- Instead of true it can also be a list of languades
                additional_vim_regex_highlighting = false,
            },

            indent = {
                enable = true, disable = { "python" },
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
    },

    -- language server (seqence order is matter )
    {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig'
    },

    -- completion engine
    {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
    },

    -- vsnip 
    {
        'hrsh7th/cmp-vsnip',
        'hrsh7th/vim-vsnip'
    },

    -- coq
    -- {
    --     'ms-jpq/coq_nvim',
    --     branch = 'coq',
    --     event = 'VimEnter',
    --     config = 'vim.cmd[[COQnow]]'
    -- },
    -- { 'ms-jpq/coq.artifacts', branch = 'artifacts' },

    -- auto pair
    'jiangmiao/auto-pairs',

    -- surround
    'tpope/vim-surround',

    -- bufonly
    -- delete all the buffers except the cursent buffer
    -- :Bonly, :BOnly, Bfonly
    'schickling/vim-bufonly',

    -- AnsiEsc
    -- Usage: :AnsiEsc - toggle Ansi escape sequence highlighting
    'powerman/vim-plugin-AnsiEsc',

    -- which-key
    {
        'folke/which-key.nvim',
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 1000
            require("which-key").setup{}
        end
    },

}
