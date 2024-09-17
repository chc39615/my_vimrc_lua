return {

    -- iron (repl tool)
    {
        "hkupty/iron.nvim",
        keys = {
            { "<leader>rs", "<cmd>lua IronStartCustom()<cr>", mode = "n", desc = "Start IronReplCustom" }
        },
        opts = function()
            local config = {}
            config.config = {
                -- Whether a repl should be discarded or not
                scratch_repl = true,
                -- Your repl definitions com here
                repl_definition = {
                    python = {
                        -- can be a table or a function that
                        -- returns a table (see below)
                        command = { "python" },
                    },
                },

                -- How the repl window will be displayed
                -- See below fore more information
                repl_open_cmd = require("iron.view").split("40%"),
            }

            config.keymaps = {
                send_motion = "<leader>rc",
                visual_send = "<leader>rc",
                send_file = "<leader>rf",
                send_line = "<leader>rl",
                send_mark = "<leader>rm",
                mark_motion = "<leader>rmc",
                mark_visual = "<leader>rmc",
                remove_mark = "<leader>rmd",
                cr = "<leader>r<CR>",
                interrupt = "<leader>r<space>",
                exit = "<leader>rq",
                clear = "<leader>rx",
            }

            config.highlight = {
                italic = true,
            }

            config.ignore_blank_lines = true -- ignore blank lines when sending visual select lines

            return config
        end,
        config = function(_, opts)
            local iron = require("iron.core")

            iron.setup(opts)

            -- customize start function
            function IronStartCustom()
                local ironcore = require("iron.core")
                local ironll = require("iron.lowlevel")
                local term = ironcore.repl_for(ironll.get_buffer_ft(0))

                -- set the keymap for terminal
                local noremap = { noremap = true, silent = true }
                -- change terminal mode to normal
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)
            end

            -- iron also has a list of commands, see :h iron-commands for all available commands
            -- vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<CR>")
            vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<CR>")
            vim.keymap.set("n", "<leader>rF", "<cmd>IronFocus<CR>")
            vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<CR>")
        end,
    },
}
