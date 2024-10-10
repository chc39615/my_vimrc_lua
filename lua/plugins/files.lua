local myutil = require("myutil")
local map = myutil.map

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        keys = {
            {
                "<leader>fe",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = Myutil.root() })
                end,
                desc = "Explorer NeoTree (Root Dir)",
            },
            {
                "<leader>fE",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
                end,
                desc = "Explorer NeoTree (cwd)",
            },
            { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
            { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)",      remap = true },
            {
                "<leader>ge",
                function()
                    require("neo-tree.command").execute({ source = "git_status", toggle = true })
                end,
                desc = "Git Explorer",
            },
            {
                "<leader>be",
                function()
                    require("neo-tree.command").execute({ source = "buffers", toggle = true })
                end,
                desc = "Buffer Explorer",
            },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        -- init = function()
        --     -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
        --     -- because `cwd` is not set up properly.
        --     -- This autocmd will open Neotree when open a folder
        --     vim.api.nvim_create_autocmd("BufEnter", {
        --         group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        --         desc = "Start Neo-tree with directory",
        --         once = true,
        --         callback = function()
        --             if package.loaded["neo-tree"] then
        --                 return
        --             else
        --                 local stats = vim.uv.fs_stat(vim.fn.argv(0))
        --                 if stats and stats.type == "directory" then
        --                     require("neo-tree")
        --                 end
        --             end
        --         end,
        --     })
        -- end,
        opts = {
            sources = { "filesystem", "buffers", "git_status" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function()
                        require("neo-tree.command").execute({ action = "close" })
                    end,
                },
                {
                    event = "neo_tree_window_after_close",
                    handler = function(args)
                        if args.position == "left" or args.position == "right" then
                            vim.cmd("wincmd =")
                        end
                    end,
                },
                {
                    event = "neo_tree_window_after_open",
                    handler = function(args)
                        if args.position == "left" or args.position == "right" then
                            vim.cmd("wincmd =")
                        end
                    end,
                },
            },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ["F"] = "clear_filter",
                    },
                },
            },
            window = {
                position = "left",
                mappings = {
                    ["h"] = function(state)
                        local node = state.tree:get_node()
                        if node.type == "directory" and node:is_expanded() then
                            require("neo-tree.sources.filesystem").toggle_directory(state, node)
                        else
                            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                        end
                    end,
                    ["l"] = function(state)
                        local node = state.tree:get_node()
                        if node.type == "directory" then
                            if not node:is_expanded() then
                                require("neo-tree.sources.filesystem").toggle_directory(state, node)
                            elseif node:has_children() then
                                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                            end
                        end
                    end,
                    ["<space>"] = "none",
                    ["Y"] = {
                        function(state)
                            local node = state.tree:get_node()
                            local path = node:get_id()
                            vim.fn.setreg("+", path, "c")
                        end,
                        desc = "Copy Path to Clipboard",
                    },
                    ["O"] = {
                        function(state)
                            require("lazy.util").open(state.tree:get_node().path, { system = true })
                        end,
                        desc = "Open with System Application",
                    },
                    ["P"] = { "toggle_preview", config = { use_float = false } },
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                git_status = {
                    symbols = {
                        deleted = " ",
                        unstaged = "󰄱",
                        staged = "󰱒",
                    },
                },
            },
        },
        config = function(_, opts)
            local function on_move(data)
                Myutil.lsp.on_rename(data.source, data.destination)
            end

            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED,   handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
            })
            require("neo-tree").setup(opts)
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },
    -- {
    -- 	"kyazdani42/nvim-tree.lua",
    -- 	-- dependencies = { 'kyazdani42/nvim-web-devicons' },
    -- 	-- set keys will cause the plugins lazy load on these keys. we need nvim-tree to load on startup,
    -- 	-- so don't set key makp here.
    -- 	-- keys = {
    -- 	--    map("<leader>e", ":NvimTreeToggle<cr>", "n", "toggle nvim-tree")
    -- 	-- },
    -- 	config = function()
    -- 		vim.g.loaded_netrw = 1
    -- 		vim.g.loaded_netrwPlugin = 1
    -- 		vim.opt.termguicolors = true
    --
    -- 		local function nvimtree_on_attach(bufnr)
    -- 			local api = require("nvim-tree.api")
    --
    -- 			-- local function opts(desc)
    -- 			-- 	return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    -- 			-- end
    --
    -- 			api.config.mappings.default_on_attach(bufnr)
    --
    -- 			-- vim.keymap.set("n", "j", "j", opts("reset j"))
    -- 			-- vim.keymap.set("n", "k", "k", opts("reset k"))
    -- 		end
    --
    -- 		-- empty setup using defaults
    -- 		require("nvim-tree").setup()
    --
    -- 		require("nvim-tree").setup({
    -- 			on_attach = nvimtree_on_attach,
    -- 			hijack_cursor = false,
    -- 			disable_netrw = true,
    -- 			hijack_netrw = true,
    -- 			open_on_tab = false,
    -- 			update_cwd = true,
    -- 			system_open = {
    -- 				cmd = nil,
    -- 				args = {},
    -- 			},
    -- 			renderer = {
    -- 				group_empty = true,
    -- 			},
    -- 			actions = {
    -- 				open_file = {
    -- 					quit_on_open = true,
    -- 				},
    -- 			},
    -- 		})
    --
    -- 		local function open_nvim_tree(data)
    -- 			-- buffer is a directory
    -- 			local directory = vim.fn.isdirectory(data.file) == 1
    --
    -- 			if not directory then
    -- 				return
    -- 			end
    --
    -- 			-- change to the directory
    -- 			vim.cmd.cd(data.file)
    -- 			-- open the tree
    -- 			require("nvim-tree.api").tree.open()
    -- 		end
    --
    -- 		vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
    --
    -- 		-- open explore
    -- 		map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "NvimTree Toggle")
    -- 		map("n", "<leader>fe", "<cmd>NvimTreeFindFile<cr>", "NvimTree Find File")
    -- 	end,
    -- },
}
