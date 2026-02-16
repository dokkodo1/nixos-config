-- General options
local opt = vim.opt

opt.guifont = "JetBrainsMono Nerd Font:h12"
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
]]
-- gruvbox may not be available on the very first run of a fresh install
-- (vim.pack.add needs to clone it first). Fall back gracefully and apply
-- the theme + custom highlights once it is available.
local function apply_theme()
  local ok = pcall(vim.cmd, 'colorscheme gruvbox')
  if ok then
    vim.cmd([[
      highlight LineNr ctermfg=white ctermbg=black
      highlight CursorLineNr ctermfg=yellow ctermbg=black cterm=bold
      highlight Comment ctermfg=yellow cterm=bold
      highlight Normal ctermbg=NONE
      highlight NonText ctermbg=NONE
      highlight NormalFloat ctermbg=black ctermfg=white
      highlight FloatBorder ctermfg=white ctermbg=NONE
    ]])
    return true
  end
  return false
end

if not apply_theme() then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      if not apply_theme() then
        vim.notify("gruvbox not yet available — restart nvim after plugins finish installing.", vim.log.levels.WARN)
      end
    end,
  })
end
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

