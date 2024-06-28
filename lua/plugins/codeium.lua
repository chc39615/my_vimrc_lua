return {
	-- Codeium
	{
		"Exafunction/codeium.nvim",
		event = { "InsertEnter" },
		build = ":Codeium Auth",
		opts = {
			enable_chat = true,
		},
	},
}
