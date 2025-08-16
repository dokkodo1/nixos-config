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
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
require "mini.pick".setup()
require "oil".setup()
require "lspconfig".rnix.setup()

vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
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
				{src = "https://github.com/vague2k/vague.nvim"},
				{src = "https://github.com/stevearc/oil.nvim"},
				{src = "https://github.com/echasnovski/mini.pick"},
				{src = "https://github.com/neovim/nvim-lspconfig"},
})

vim.lsp.enable({"lua_ls", "rust-analyzer", "clangd"})
vim.cmd(":hi statusline guibg=NONE")
-- Tokyo Night colors for Neovim
vim.cmd([[
  hi Normal guifg=#a9b1d6 guibg=#1a1b26 ctermfg=15 ctermbg=0
  hi Comment guifg=#565f89 ctermfg=8
  hi Constant guifg=#f7768e ctermfg=1
  hi String guifg=#73daca ctermfg=2
  hi Function guifg=#7aa2f7 ctermfg=4
  hi Keyword guifg=#bb9af7 ctermfg=5
  hi Type guifg=#e0af69 ctermfg=3
  hi Special guifg=#7dcfff ctermfg=6
]])
