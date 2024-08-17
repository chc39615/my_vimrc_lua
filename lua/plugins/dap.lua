return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "nvim-neotest/nvim-nio" },
            { "theHamsta/nvim-dap-virtual-text" },
            { "rcarriga/nvim-dap-ui" }
        },
        keys = {
            -- start/stop
            { "<F5>",    function() require("dap").continue() end,                                             mode = "n", desc = "Continue" },
            { "<sc-F5>", function() require("dap").restart() end,                                              mode = "n", desc = "Restart" },
            { "<s-F5>",  function() require("dap").terminate() end,                                            mode = "n", desc = "Terminate" },
            -- step
            { "<F10>",   function() require("dap").step_over() end,                                            mode = "n", desc = "Step Over" },
            { "<F11>",   function() require("dap").step_into() end,                                            mode = "n", desc = "Step Into" },
            { "<s-F11>", function() require("dap").step_out() end,                                             mode = "n", desc = "Step Out" },
            -- set breakpoints
            { "<F9>",    function() require("dap").toggle_breakpoint() end,                                    mode = "n", desc = "Toggle Breakpoint" },
            { "<s-F9>",  function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, mode = "n", desc = "Breakpoint Condition" }
        },
        config = function()
            vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

            -- have to set the Control Sequence Introducer Sequences (CSI)
            -- https://neovim.discourse.group/t/how-can-i-map-ctrl-shift-f5-ctrl-shift-b-ctrl-and-alt-enter/2133
            -- vim.keymap.set("n", "<s-F11>", [[<cmd>lua print("shift+F11")<cr>]])
            -- vim.keymap.set("n", "<sc-F5>", [[<cmd>lua print("ctrl+shift+F5")<cr>]])
            -- vim.keymap.set("n", "<s-F5>", [[<cmd>lua  print("shift+F5")<cr>]])

            if Myutil.has("mason-nvim-dap.nvim") then
                require("mason-nvim-dap").setup(Myutil.opts("mason-nvim-dap.nvim"))
            end

            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            for name, sign in pairs(Myutil.config.icons.dap) do
                sign = type(sign) == "table" and sign or { sign }
                vim.fn.sign_define(
                    "Dap" .. name,
                    { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
                )
            end
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = {
            { "mfussenegger/nvim-dap" },
        },
        opts = {
            layouts = {
                {
                    elements = {
                        {
                            id = "stacks",
                            size = 0.25,
                        },
                        {
                            id = "breakpoints",
                            size = 0.25,
                        },
                        {
                            id = "watches",
                            size = 0.25,
                        },
                        {
                            id = "scopes",
                            size = 0.25,
                        },
                    },
                    position = "left",
                    size = 0.25,
                },
                {
                    elements = {
                        {
                            id = "console",
                            size = 0.5,
                        },
                        {
                            id = "repl",
                            size = 0.5,
                        },
                    },
                    position = "bottom",
                    size = 0.3,
                },
            },

        },
        config = function(_, opts)
            -- vim.api.nvim_create_autocmd("BufWinEnter", {
            -- 	pattern = "\\[dap-repl\\]",
            -- 	callback = vim.schedule_wrap(function(args)
            -- 		vim.api.nvim_set_current_win(vim.fn.bufwinid(args.buf))
            -- 	end),
            -- })
            --
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup(opts)
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({ reset = true })
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set(
                { "v", "n" },
                "<F8>",
                "<cmd>lua require('dapui').eval(nil, { enter = true })<cr>",
                { silent = true }
            )
            vim.keymap.set(
                "n",
                "<F7>",
                "<cmd>lua require('dapui').float_element(nil, { enter = true })<cr>",
                { silent = true }
            )


            -- local function get_window_filetypes()
            --     local win_filetypes = {}
            --     for _, winid in ipairs(vim.api.nvim_list_wins()) do
            --         local bufid = vim.api.nvim_win_get_buf(winid)
            --         local filetype = vim.bo[bufid].filetype
            --         table.insert(win_filetypes, { winid = winid, filetype = filetype })
            --     end
            --     return win_filetypes
            -- end

            -- Create a command to execute the function
            -- vim.api.nvim_create_user_command('GetWindowFiletypes', function()
            --     local filetypes = get_window_filetypes()
            --     for _, win in ipairs(filetypes) do
            --         print("Window ID:", win.winid, "Filetype:", win.filetype)
            --     end
            -- end, {})

            local function reset_dapui_if_open()
                local found_dapui = false
                for _, winid in ipairs(vim.api.nvim_list_wins()) do
                    local bufid = vim.api.nvim_win_get_buf(winid)
                    local filetype = vim.bo[bufid].filetype
                    if filetype:find("dapui") then
                        found_dapui = true
                        break
                    end
                end
                if found_dapui then
                    dapui.close()
                    dapui.open({ reset = true })
                end
            end

            vim.api.nvim_create_user_command("ResetDapuiIfOpen", function()
                reset_dapui_if_open()
            end, {})


            --Below works for when buffers are created and destroyed but not for buffers that are:
            --                                          --> hidden or                               (aka ToggleTerm)
            --                                              --> resized!                            (When resizing splits)

            -- vim.api.nvim_create_augroup("DAP_UI_RESET", { clear = true })

            -- local bufferNames = {}

            -- vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            --     group = "DAP_UI_RESET",
            --     pattern = "*",
            --     callback = function()
            --         local bufferName = vim.fn.expand("%")
            --
            --         if dap.session() and bufferName ~= "DAP Watches"
            --             and bufferName ~= "DAP Stacks"
            --             and bufferName ~= "DAP Breakpoints"
            --             and bufferName ~= "DAP Scopes"
            --             and bufferName ~= "DAP Console"
            --             and not string.find(bufferName, "%[dap%-repl%-", 1) and bufferName ~= "DAP Hover" then
            --             table.insert(bufferNames, bufferName)
            --
            --             dapui.open({ reset = true })
            --         end
            --     end
            -- })

            -- vim.api.nvim_create_autocmd({ "BufUnload" }, {
            --     group = "DAP_UI_RESET",
            --     pattern = "*",
            --     callback = function()
            --         if dap.session() then
            --             for i = 1, #bufferNames do
            --                 local index = -1
            --
            --                 for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            --                     if bufferNames[i] == vim.api.nvim_buf_get_name(buf) then
            --                         index = vim.api.nvim_buf_get_number(buf)
            --                         break
            --                     end
            --                 end
            --
            --                 vim.schedule(function()
            --                     if not vim.api.nvim_buf_is_loaded(index) then
            --                         table.remove(bufferNames, i)
            --                         dapui.open({ reset = true })
            --                     end
            --                 end)
            --             end
            --         end
            --     end
            --
            -- })

            -- vim.api.nvim_create_autocmd("WinClosed", {
            --     callback = function(event)
            --         if dap.session() then
            --             vim.schedule(function()
            --                 dapui.close()
            --                 dapui.open({ reset = true })
            --             end)
            --             -- dapui.close()
            --             -- dapui.open({ reset = true })
            --         end
            --
            --         -- print(vim.bo[closed_bufid].filetype)
            --         -- Get the buffer id of the closed window
            --         -- local closed_bufid = tonumber(vim.fn.expand("<afile"))
            --         -- local closed_filetype = vim.bo[closed_bufid].filetype
            --         --
            --         -- if closed_filetype:find("dapui") then
            --         --     return
            --         -- end
            --
            --         -- local found_dapui = false
            --         -- for _, winid in ipairs(vim.api.nvim_list_wins()) do
            --         --     local bufid = vim.api.nvim_win_get_buf(winid)
            --         --     local filetype = vim.bo[bufid].filetype
            --         --     if filetype:find("dapui") then
            --         --         found_dapui = true
            --         --         break
            --         --     end
            --         -- end
            --         -- if found_dapui then
            --         --     dapui.close()
            --         --     dapui.open({ reset = true })
            --         -- end
            --     end
            -- })
        end,
    },
    -- mason.nvim integration
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
            },
        },
        -- mason-nvim-dap is loaded when nvim-dap loads
        config = function() end,
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
        },
        ft = "python",
        config = function()
            require("neodev").setup({
                library = {
                    plugins = { "nvim-dap-ui", types = true },
                },
            })

            local cwd = vim.fn.getcwd()
            local pythons = {}

            local sysname = vim.loop.os_uname().sysname
            local is_windows = string.find(sysname:lower(), "window")
            if is_windows then
                table.insert(pythons, "\\venv\\Scripts\\python.exe")
            else
                table.insert(pythons, "/venv/bin/python")
                table.insert(pythons, "/venvl/bin/python")
            end

            for _, path in pairs(pythons) do
                if vim.fn.executable(cwd .. path) == 1 then
                    cwd = cwd .. path
                    break
                end
            end

            require("dap-python").setup(cwd)

            table.insert(require("dap").configurations.python, {
                console = "integratedTerminal",
                name = "Launch file with all code",
                program = "${file}",
                request = "launch",
                type = "python",
                justMyCode = false,
            })
        end,
    },
}
