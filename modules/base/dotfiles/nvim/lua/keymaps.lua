-- Leader
vim.g.mapleader = " "

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>w", vim.cmd.write, { desc = "Save buffer" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
map("n", "<leader>i", function() vim.cmd.edit("~/configurations/modules/base/dotfiles/nvim/init.lua") end,
  { desc = "Edit init.lua" })
map("n", "<leader>o", function()
  vim.cmd.source("~/configurations/modules/base/dotfiles/nvim/init.lua")
  vim.notify("Config reloaded from repo!")
end, { desc = "Reload config" })

-- Buffers
map("n", "<leader>n", vim.cmd.bnext, { desc = "Next buffer" })
map("n", "<leader>p", vim.cmd.bprevious, { desc = "Previous buffer" })
map("n", "<leader>d", vim.cmd.bdelete, { desc = "Delete buffer" })
map("n", "<leader>ls", vim.cmd.buffers, { desc = "List buffers" })

-- Tabs
map("n", "<leader>tn", vim.cmd.tabnext, { desc = "Next tab" })
map("n", "<leader>tp", vim.cmd.tabprevious, { desc = "Previous tab" })
map("n", "<leader>tc", vim.cmd.tabnew, { desc = "New tab" })
map("n", "<leader>td", vim.cmd.tabclose, { desc = "Delete tab" })
map("n", "<leader>tls", vim.cmd.tabs, { desc = "List tabs" })

-- Splits
map("n", "<leader>sv", vim.cmd.vsplit, { desc = "Vertical split" })
map("n", "<leader>sh", vim.cmd.split, { desc = "Horizontal split" })

-- LSP core keymaps
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
map('n', '<leader>ca', function()
  vim.lsp.buf.code_action()
end, { desc = 'Code action' })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Quickfix
map("n", "[q", '<cmd>cnext<CR>', { desc = "Prev qf item" })
map("n", "]q", '<cmd>cprev<CR>', { desc = "Next qf item" })
map("n", "<leader>co", '<cmd>copen<CR>', { desc = "Open qflist" })
map("n", "<leader>cc", '<cmd>cclose<CR>', { desc = "Close qflist" })

-- Plugins (mini.pick, oil)
map("n", "<leader>f", ":Pick files<CR>", { desc = "Pick files" })
map("n", "<leader>g", ":Pick grep_live<CR>", { desc = "grep current directory" })
map("n", "<leader>b", ":Pick buffers<CR>", { desc = "Pick buffers" })
map("n", "<leader>h", ":Pick help<CR>", { desc = "Pick help" })
map("n", "<leader>e", function() 
  vim.cmd("Oil")
end, { desc = "Open Oil explorer" })

-- Directory picker helper functions
local function get_directories_file()
  return vim.fn.expand("~/.config/nvim/directories.txt")
end

local function ensure_directories_file()
  local file = get_directories_file()
  local dir = vim.fn.fnamemodify(file, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  if vim.fn.filereadable(file) == 0 then
    local f = io.open(file, "w")
    if f then
      f:write(vim.fn.expand("~") .. "\n")
      f:close()
    end
  end
end

local function read_directories()
  ensure_directories_file()
  local file = get_directories_file()
  local directories = {}
  for line in io.lines(file) do
    line = line:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
    if line ~= "" and vim.fn.isdirectory(vim.fn.expand(line)) == 1 then
      table.insert(directories, line)
    end
  end
  return directories
end

local function write_directories(directories)
  local file = get_directories_file()
  local f = io.open(file, "w")
  if f then
    for _, dir_path in ipairs(directories) do
      f:write(dir_path .. "\n")
    end
    f:close()
  end
end

local function directory_picker()
  local directories = read_directories()
  if #directories == 0 then
    vim.notify("No directories found. Use <leader>ra to add some!")
    return
  end
  
  local pick_ok, pick = pcall(require, "mini.pick")
  if pick_ok then
    pick.start({
      source = {
        items = directories,
        name = "Directories",
      },
      mappings = {
        delete_entry = {
          char = "<C-d>",
          func = function()
            local current_item = pick.get_picker_matches().current
            if current_item then
              local filtered_dirs = {}
              for _, dir in ipairs(directories) do
                if dir ~= current_item then
                  table.insert(filtered_dirs, dir)
                end
              end
              write_directories(filtered_dirs)
              vim.notify("Removed: " .. current_item)
              
              -- Restart picker with updated list
              vim.schedule(function()
                directory_picker()
              end)
            end
          end,
        },
      },
    })
  else
    vim.notify("mini.pick not available")
  end
end

local function add_current_directory()
  local current_dir = vim.fn.getcwd()
  local directories = read_directories()
  
  -- Check if already exists
  for _, dir in ipairs(directories) do
    if dir == current_dir then
      vim.notify("Directory already in list: " .. current_dir)
      return
    end
  end
  
  table.insert(directories, current_dir)
  write_directories(directories)
  vim.notify("Added: " .. current_dir)
end

map("n", "<leader>r", directory_picker, { desc = "Pick directory to cd into" })
map("n", "<leader>ra", add_current_directory, { desc = "Add current dir to list" })

-- Navigation
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear highlights" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- URL opening
local function open_url_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  
  -- URL pattern (covers http/https URLs)
  local url_pattern = "https?://[%w%-%.%_%~%:%/%?%#%[%]%@%!%$%&%'%(%)%*%+%,%;%=]+"
  
  -- Find URL at or near cursor
  for url in line:gmatch(url_pattern) do
    local start_pos, end_pos = line:find(url, 1, true)
    if start_pos and end_pos and col >= start_pos and col <= end_pos then
      vim.fn.system({"xdg-open", url})
      vim.notify("Opening: " .. url)
      return
    end
  end
  
  vim.notify("No URL found under cursor")
end

map("n", "gx", open_url_under_cursor, { desc = "Open URL under cursor" })

-- Transformation
map("n", "<leader>m", function()
  local filename = vim.fn.expand("%:t:r")
  local pathname = vim.fn.expand("%:h")
  vim.cmd("!" .. "cd " .. pathname .. "&& " .. "make " .. filename)
end, { desc = "Make current buffer" })
