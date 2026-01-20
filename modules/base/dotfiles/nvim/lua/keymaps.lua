-- Leader
vim.g.mapleader = " "

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>w", vim.cmd.write, { desc = "Save buffer" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
map("n", "<leader>i", function() vim.cmd.edit("~/configurations/modules/base/dotfiles/nvim/init.lua") end,
  { desc = "Edit init.lua" })
map("n", "<leader>o", function()
  -- Bypass module cache by using dofile directly
  local config_base = vim.fn.expand("~/configurations/modules/base/dotfiles/nvim/lua")

  package.loaded['settings'] = nil
  package.loaded['keymaps'] = nil
  package.loaded['plugins'] = nil

  dofile(config_base .. "/settings.lua")
  dofile(config_base .. "/keymaps.lua")
  dofile(config_base .. "/plugins.lua")

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

-- Plugins (mini.pick, oil, glow)
map("n", "<leader>f", ":Pick files<CR>", { desc = "Pick files" })
map("n", "<leader>t", ":Pick grep_live<CR>", { desc = "grep current directory" })
map("n", "<leader>b", ":Pick buffers<CR>", { desc = "Pick buffers" })
map("n", "<leader>h", ":Pick help<CR>", { desc = "Pick help" })
map("n", "<leader>e", function()
  vim.cmd("Oil")
end, { desc = "Open Oil explorer" })

-- Markdown previews
map("n", "<leader>md", ":Glow<CR>", { desc = "Preview markdown in terminal" })
map("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Preview markdown in browser" })
map("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop markdown preview" })

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

-- Helper function to refresh Oil buffers after git operations
local function refresh_oil_buffers()
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'oil' then
        vim.api.nvim_buf_call(buf, function() vim.cmd("edit") end)
      end
    end
  end)
end

-- Git workflow keymaps
map("n", "<leader>gs", ":terminal git status<CR>", { desc = "Git status" })
map("n", "<leader>ga", ":terminal git add .<CR>", { desc = "Git add all" })
map("n", "<leader>gc", function()
  local msg = vim.fn.input("Commit message: ")
  if msg ~= "" then
    vim.cmd("terminal git commit -m " .. vim.fn.shellescape(msg))
  end
end, { desc = "Git commit" })
map("n", "<leader>gp", ":terminal git push<CR>", { desc = "Git push" })
map("n", "<leader>gl", ":terminal git log --oneline -10<CR>", { desc = "Git log" })
map("n", "<leader>gb", function()
  -- Branch picker using mini.pick
  local pick_ok, pick = pcall(require, "mini.pick")
  if not pick_ok then return end

  local branches = vim.fn.systemlist("git branch -a --format='%(refname:short)'")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository")
    return
  end

  pick.start({
    source = {
      items = branches,
      name = "Git Branches",
      choose = function(branch)
        if branch then
          -- Silently checkout and capture output
          local output = vim.fn.system("git checkout " .. vim.fn.shellescape(branch))
          local exit_code = vim.v.shell_error

          if exit_code == 0 then
            vim.notify("Switched to branch: " .. branch, vim.log.levels.INFO)

            -- Reload all file buffers to reflect the branch change
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buftype') == '' then
                local bufname = vim.api.nvim_buf_get_name(buf)
                if bufname ~= "" and not vim.api.nvim_buf_get_option(buf, 'modified') then
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd('checktime')
                  end)
                end
              end
            end

            refresh_oil_buffers()
          else
            vim.notify("Failed to checkout: " .. vim.trim(output), vim.log.levels.ERROR)
          end
        end
      end,
    },
  })
end, { desc = "Git checkout branch" })

-- Diff and merge workflow
-- View diff of current file against another branch
map("n", "<leader>gd", function()
  local pick_ok, pick = pcall(require, "mini.pick")
  if not pick_ok then return end

  local branches = vim.fn.systemlist("git branch --format='%(refname:short)'")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository")
    return
  end

  pick.start({
    source = {
      items = branches,
      name = "Diff current file against branch",
      choose = function(branch)
        if branch then
          local current_file = vim.fn.expand("%:p")
          if current_file == "" then
            vim.notify("No file in current buffer", vim.log.levels.WARN)
            return
          end
          -- Open vertical split with diff against selected branch
          vim.cmd("Gvdiffsplit " .. vim.fn.shellescape(branch))
        end
      end,
    },
  })
end, { desc = "Diff current file vs branch" })

-- Merge branch into current branch
map("n", "<leader>gM", function()
  local pick_ok, pick = pcall(require, "mini.pick")
  if not pick_ok then return end

  local branches = vim.fn.systemlist("git branch --format='%(refname:short)'")
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository")
    return
  end

  pick.start({
    source = {
      items = branches,
      name = "Merge branch into current",
      choose = function(branch)
        if branch then
          local output = vim.fn.system("git merge " .. vim.fn.shellescape(branch))
          local exit_code = vim.v.shell_error

          if exit_code == 0 then
            vim.notify("Merged " .. branch .. " successfully", vim.log.levels.INFO)
            -- Reload buffers
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buftype') == '' then
                local bufname = vim.api.nvim_buf_get_name(buf)
                if bufname ~= "" and not vim.api.nvim_buf_get_option(buf, 'modified') then
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd('checktime')
                  end)
                end
              end
            end
            refresh_oil_buffers()
          else
            -- Merge conflict occurred
            vim.notify("Merge conflicts detected. Use <leader>gm to resolve", vim.log.levels.WARN)
            vim.cmd("cexpr system('git diff --name-only --diff-filter=U')")
            vim.cmd("copen")
          end
        end
      end,
    },
  })
end, { desc = "Merge branch into current" })

-- Open merge conflicts in quickfix and start resolving
map("n", "<leader>gm", function()
  local conflicts = vim.fn.systemlist("git diff --name-only --diff-filter=U")
  if vim.v.shell_error ~= 0 or #conflicts == 0 then
    vim.notify("No merge conflicts to resolve", vim.log.levels.INFO)
    return
  end

  -- Configure git to use nvimdiff
  vim.fn.system("git config merge.tool nvimdiff")
  vim.fn.system("git config merge.conflictstyle diff3")
  vim.fn.system("git config mergetool.nvimdiff.cmd 'nvim -d $LOCAL $BASE $REMOTE $MERGED -c \"wincmd w\" -c \"wincmd J\"'")

  -- Open first conflict file in 3-way diff
  vim.cmd("Gvdiffsplit!")
  vim.notify("Resolving conflicts. Use ]c/[c to navigate, :diffget //2 (ours) or //3 (theirs)", vim.log.levels.INFO)
end, { desc = "Resolve merge conflicts" })

-- List all conflicted files
map("n", "<leader>gC", function()
  local conflicts = vim.fn.systemlist("git diff --name-only --diff-filter=U")
  if #conflicts == 0 then
    vim.notify("No conflicts", vim.log.levels.INFO)
    return
  end

  local pick_ok, pick = pcall(require, "mini.pick")
  if not pick_ok then
    vim.notify("Conflicted files:\n" .. table.concat(conflicts, "\n"), vim.log.levels.INFO)
    return
  end

  pick.start({
    source = {
      items = conflicts,
      name = "Conflicted Files",
      choose = function(file)
        if file then
          vim.cmd("edit " .. vim.fn.fnameescape(file))
          vim.cmd("Gvdiffsplit!")
        end
      end,
    },
  })
end, { desc = "List merge conflicts" })

-- In diff mode: take changes from left window (LOCAL/ours)
map("n", "<leader>gh", ":diffget //2<CR>", { desc = "Get from LOCAL (ours)" })
-- In diff mode: take changes from right window (REMOTE/theirs)
map("n", "<leader>gl", ":diffget //3<CR>", { desc = "Get from REMOTE (theirs)" })

-- Abort merge
map("n", "<leader>gA", function()
  local confirm = vim.fn.input("Abort merge? (y/n): ")
  if confirm == "y" then
    vim.fn.system("git merge --abort")
    vim.notify("Merge aborted", vim.log.levels.INFO)
    vim.cmd("bufdo checktime")
  end
end, { desc = "Abort merge" })
