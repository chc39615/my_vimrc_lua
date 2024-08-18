return {
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },


    {
        "folke/lazydev.nvim",
        ft = { "lua", "vim" },
        cmd = "LazyDev",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    },
    -- Manage libuv types with lazy. Plugin will never be loaded
    { "Bilal2453/luvit-meta", lazy = true },
    -- Add lazydev source to cmp
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "lazydev", group_index = 0 })
        end,
    },
}
