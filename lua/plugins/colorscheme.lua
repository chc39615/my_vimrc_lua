return {
	{
		"folke/tokyonight.nvim",
		lazy = true,
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
