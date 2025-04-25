vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = true
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'

vim.opt.cursorline = true

vim.opt.scrolloff = 10

vim.opt.confirm = true

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    -- Set fold method to marker for Lua files
    vim.opt_local.foldmethod = 'marker'
    -- Define fold markers
    vim.opt_local.foldmarker = '{{{,}}}'
  end,
})
