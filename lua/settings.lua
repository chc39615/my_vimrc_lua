local opt = vim.opt

-- use swap file
opt.swapfile = true
-- swap file location
opt.dir = '/tmp'



-- line number settings
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false

-- last window always has status line
opt.laststatus = 2

-- show current mode
opt.showmode = false


-- search options
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true


-- keep 12 lines below
opt.scrolloff = 12

-- allow <BS> <DEL> CTRL-W CTRL-U in insert mode to delete
opt.backspace = 'indent,eol,start'

-- auto indent
opt.autoindent = true
opt.smartindent = true


-- a <Tab> in front of a line inserts blanks
opt.smarttab = true

-- use spaces to insert a <Tab>
opt.expandtab = true

-- (auto)indent spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 0

-- clipboard
opt.clipboard = 'unnamedplus'

-- listchars
opt.listchars = { eol = '↵', tab = '<->', extends = '»', precedes = '«', space = '␣' }

-- set colorscheme
vim.g.material_style = 'deep ocean'
vim.cmd 'colorscheme material'
