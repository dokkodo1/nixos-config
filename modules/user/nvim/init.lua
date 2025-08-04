vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.swapfile = false

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', function()
  vim.cmd('source ~/configurations/modules/user/nvim/init.lua')
  print('Config reloaded from repo!')
end, { desc = 'Reload config from repo' })
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.pack.add({
    {src = "https//github.com/vague2k/vague.nvim"},
})

vim.cmd("colorscheme vague")