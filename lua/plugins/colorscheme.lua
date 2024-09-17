return {
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent"
            }
        },
        init = function()
            require("tokyonight").setup({
                style = "storm",
                -- on_colors = function(colors)
                -- 	colors.border = "#565f89"
                -- end,
            })
            vim.cmd.colorscheme("tokyonight")
            -- vim.g.tokyonight_colors = { border = "#565f89" }
            vim.cmd([[highlight WinSeparator guifg=orange]])
        end,
    },
}
