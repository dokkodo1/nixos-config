-- General options
local opt = vim.opt

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
set_indent({ "lua", "javascript", "html", "css", "yaml", "json", "nix" }, 2)
set_indent({ "python", "c", "cpp", "java", "go", "rust", "sh", "bash", "zsh" }, 4)
set_indent({ "make" }, 8, true)

-- Leader
vim.g.mapleader = " "

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>w", vim.cmd.write, { desc = "Save buffer" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
map("n", "<leader>i", function() vim.cmd.edit("~/configurations/modules/user/nvim/init.lua") end,
  { desc = "Edit init.lua" })

map("n", "<leader>o", function()
  vim.cmd.source("~/configurations/modules/user/nvim/init.lua")
  vim.notify("Config reloaded from repo!")
end, { desc = "Reload config" })

-- Buffers
map("n", "<leader>n", vim.cmd.bnext, { desc = "Next buffer" })
map("n", "<leader>p", vim.cmd.bprevious, { desc = "Previous buffer" })
map("n", "<leader>d", vim.cmd.bdelete, { desc = "Delete buffer" })
map("n", "<leader>ls", vim.cmd.buffers, { desc = "List buffers" })

-- LSP core keymaps
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Plugins (mini.pick, oil)
map("n", "<leader>f", ":Pick files<CR>", { desc = "Pick files" })
map("n", "<leader>b", ":Pick buffers<CR>", { desc = "Pick buffers" })
map("n", "<leader>h", ":Pick help<CR>", { desc = "Pick help" })
map("n", "<leader>e", ":Oil<CR>", { desc = "Open Oil explorer" })

-- Navigation
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear highlights" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Add plugins via vim.pack
vim.notify("Loading plugins…")
vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Plugin setup
local ok, pick = pcall(require, "mini.pick")
if ok then pick.setup() end

ok, oil = pcall(require, "oil")
if ok then
  oil.setup({ view_options = { show_hidden = true } })
end

-- Treesitter
opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/treesitter")

local ts_ok, ts = pcall(require, "nvim-treesitter.configs")
if ts_ok then
  ts.setup {
    parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
    sync_install = false,
    auto_install = false, -- safer in offline environments
    ensure_installed = {
      "lua", "python", "rust", "c", "cpp", "javascript",
      "html", "css", "json", "yaml", "bash", "nix", "go", "java"
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  }
end

-- Treesitter helper commands
vim.api.nvim_create_user_command("TSClean", function()
  local parser_dir = vim.fn.stdpath("data") .. "/treesitter"
  vim.fn.delete(parser_dir, "rf")
  vim.notify("Cleaned Treesitter parsers. Run :TSInstall to reinstall.")
end, { desc = "Clean treesitter parsers" })

-- LSP setup
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_ok then
  local function setup_lsp(server_name, executable, config)
    if vim.fn.executable(executable) == 1 then
      lspconfig[server_name].setup(config or {})
      vim.notify("✓ LSP server loaded: " .. server_name)
    end
  end

  setup_lsp("lua_ls", "lua-language-server", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })

  setup_lsp("rust_analyzer", "rust-analyzer", {})
  setup_lsp("clangd", "clangd", { cmd = { "clangd", "--background-index" } })
  setup_lsp("nixd", "nixd")
  setup_lsp("basedpyright", "basedpyright")
end
