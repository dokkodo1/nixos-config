vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false

vim.o.tabstop = 2
vim.o.swapfile = false
vim.o.winborder = "rounded"

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', function()
  vim.cmd('source ~/configurations/modules/user/nvim/init.lua')
  print('Config reloaded from repo!')
end, { desc = 'Reload config from repo' })
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
-- buffers
vim.keymap.set('n', '<leader>n', ':bn<CR>')
vim.keymap.set('n', '<leader>p', ':bp<CR>')
vim.keymap.set('n', '<leader>d', ':bd<CR>')
vim.keymap.set('n', '<leader>ls', ':buffers<CR>')

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>b', ":Pick buffers<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.scrolloff = 3
vim.o.sidescrolloff = 4
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.pack.add({
  {src = "https://github.com/stevearc/oil.nvim"},
	{src = "https://github.com/neovim/nvim-lspconfig"},
	{src = "https://github.com/echasnovski/mini.pick"},
	{src = "https://github.com/nvim-treesitter/nvim-treesitter"},
})

require "mini.pick".setup()
require "oil".setup({
  view_options = {
    show_hidden = true,
  }
})

vim.lsp.enable({"lua_ls", "rust-analyzer", "clangd", "nixd"})
vim.cmd(":hi statusline guibg=NONE")
