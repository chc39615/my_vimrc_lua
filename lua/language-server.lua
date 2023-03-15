------------------ install language servers ------------------
require("mason").setup()
require("mason-lspconfig").setup {
    -- a list of servers to automatically install if they're not already installed
    ensure_installed = { "lua_ls", "pyright" }
}

------------------ config nvim-cmp ------------------
local cmp = require("cmp")

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

if cmp ~= nil or cmp ~= '' then
    cmp.setup({
        snippet = {
            --REQUIRED - you must specify a snippet engine
            expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users
            end,
        },
        mapping =  cmp.mapping.preset.insert({
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },
            ['<Tab>'] = cmp.mapping(
                function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif vim.fn["vsnip#available"](1) == 1 then
                        feedkey("<Plug>(vsnip-expand-or-jump)", "")
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`
                    end
                end, {'i', 's'}),
            ['<S-Tab>'] = cmp.mapping(
                function()
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif vim.fn["vsnip#jumpble"](-1) == 1 then
                        feedkey("<Plug>(vsnip-jump-prev)", "")
                    end
                end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'vsnip' }, -- fir `vsnip` users
            }, {
                { name = 'buffer' },
            })
    })

    -- use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore)
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- use cmdline & path source for ':' (if you enable `native_menu`, this won't work anymore)
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

end




------------------ config lsp-config ------------------
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- This function gets run when an LSP connects to a particular buffer
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    -- In this case, we create a function that lets us more easily define mappinds specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function (keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[Code] [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('gr', require("telescope.builtin").lsp_references)
    nmap('<leader>ds', require("telescope.builtin").lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require("telescope.builtin").lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    -- in terminal ctrl+f and ctrl+F will send the same code ^F (ASCII code 0x06),
    -- so vim cannot distinguish them, use <c-k> for move between windows
    -- nmap('<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder]')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,'[W]orkspace [L]ist Folders')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        if vim.lsp.buf.format then
            vim.lsp.buf.format()
        elseif vim.lsp.buf.formatting then
            vim.lsp.buf.formatting()
        end
    end, { desc = 'Format current buffer with LSP' })

end

local lspconfig = require("lspconfig")

-- make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                globals = { 'vim', }
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
            },
        }
    }
}

