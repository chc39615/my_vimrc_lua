return {

    -- codeium cmp source
    {
        "nvim-cmp",
        dependencies = {
            -- codeium
            {
                "Exafunction/codeium.nvim",
                cmd = "Codeium",
                build = ":Codeium Auth",
                opts = {
                    enable_chat = true,
                },
                config = function(_, opts)
                    require("codeium").setup(opts)
                end,
            },
        },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            table.insert(opts.sources, 1, {
                name = "codeium",
                group_index = 1,
                priority = 100,
            })
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        event = "VeryLazy",
        opts = function(_, opts)
            table.insert(opts.sections.lualine_x, 2, Myutil.lualine.cmp_source("codeium"))
        end,
    },
}
