-- General options
local opt = vim.opt

opt.guifont = "JetBrainsMono Nerd Font:h12"
vim.cmd('colorscheme gruvbox')
-- Apply highlighting after plugins load
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd([[
      highlight LineNr ctermfg=white ctermbg=black
      highlight CursorLineNr ctermfg=yellow ctermbg=black cterm=bold
      highlight Comment ctermfg=yellow cterm=bold
      " Mini.pick selection highlighting - tmux compatible
      highlight MiniPickMatchCurrent ctermbg=236 ctermfg=15 cterm=bold
      highlight MiniPickMatchMarked ctermbg=22 ctermfg=15 cterm=bold
      highlight MiniPickBorder ctermfg=7 ctermbg=NONE
      highlight MiniPickPrompt ctermfg=15 ctermbg=NONE cterm=bold
      highlight MiniPickNormal ctermbg=235 ctermfg=15
      highlight Normal ctermbg=NONE
      highlight NormalFloat ctermbg=black ctermfg=white
      highlight FloatBorder ctermfg=white ctermbg=NONE
    ]])
  end,
})
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.scrolloff = 3
opt.sidescrolloff = 4
opt.wrap = false

opt.swapfile = false
opt.winborder = "rounded"

vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Transparent statusline
vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

-- Tabs (global defaults)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

-- Per-language indentation
local function set_indent(filetypes, size, use_tabs)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
      vim.opt_local.shiftwidth = size
      vim.opt_local.tabstop = size
      vim.opt_local.expandtab = not use_tabs
    end,
  })
end
set_indent({ "lua", "javascript", "html", "css", "yaml", "json", "nix", "haskell" }, 2)
set_indent({ "python", "c", "cpp", "java", "go", "rust", "sh", "bash", "zsh" }, 4)
set_indent({ "make" }, 8, true)
