-- Add plugins via vim.pack
vim.notify("Loading plugins…")
vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvimdev/indentmini.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/morhetz/gruvbox" },
  { src = "https://github.com/windwp/nvim-autopairs" },
})

-- Oil setup immediately after pack.add
local oil_ok, oil = pcall(require, "oil")
if oil_ok then
  oil.setup({
    columns = { "permissions", "size", "mtime" },
    view_options = { 
      show_hidden = true,
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, ".")
      end,
      natural_order = true,
      case_insensitive = false,
    },
    keymaps = {
      ["<CR>"] = "actions.select",
      -- smart run
      ["<C-r>"] = {
        callback = function()
          local entry = oil.get_cursor_entry()
          if not entry then return end
          local filepath = oil.get_current_dir() .. entry.name
          local ext = entry.name:match("%.([^%.]+)$")
          local basename = entry.name:match("(.+)%.")
          
          -- Check for archives
          local is_archive = false
          local archive_cmd = ""
          if entry.type == "file" and ext then
            if ext == "zip" then
              is_archive = true
              archive_cmd = "unzip " .. entry.name
            elseif ext == "tar" then
              is_archive = true
              archive_cmd = "tar -xf " .. entry.name
            elseif ext == "gz" and entry.name:match("%.tar%.gz$") then
              is_archive = true
              archive_cmd = "tar -xzf " .. entry.name
            elseif ext == "bz2" and entry.name:match("%.tar%.bz2$") then
              is_archive = true
              archive_cmd = "tar -xjf " .. entry.name
            elseif ext == "xz" and entry.name:match("%.tar%.xz$") then
              is_archive = true
              archive_cmd = "tar -xJf " .. entry.name
            elseif ext == "7z" then
              is_archive = true
              archive_cmd = "7z x " .. entry.name
            elseif ext == "rar" then
              is_archive = true
              archive_cmd = "unrar x " .. entry.name
            end
          end
          
          -- If it's an archive, prompt for unarchiving
          if is_archive then
            vim.ui.select({"Extract archive", "Custom command"}, {
              prompt = "Archive detected (" .. entry.name .. "):",
            }, function(choice)
              if choice == "Extract archive" then
                vim.cmd("terminal cd " .. oil.get_current_dir() .. " && " .. archive_cmd)
              elseif choice == "Custom command" then
                local command = vim.fn.input("Run: ", archive_cmd, "shellcmd")
                if command and command ~= "" then
                  vim.cmd("terminal cd " .. oil.get_current_dir() .. " && " .. command)
                end
              end
            end)
            return
          end
          
          -- Smart command suggestions based on file type (original logic)
          local default_cmd = ""
          if entry.type == "file" then
            if ext == "c" then
              default_cmd = "make " .. (basename or entry.name)
            elseif vim.fn.executable(filepath) == 1 then
              default_cmd = "./" .. entry.name
            elseif ext == "py" then
              default_cmd = "python " .. entry.name
            elseif ext == "js" then
              default_cmd = "node " .. entry.name
            else
              default_cmd = entry.name
            end
          end
          -- Prompt for command with smart default and shell completion
          local command = vim.fn.input("Run: ", default_cmd, "shellcmd")
          if command and command ~= "" then
            vim.cmd("terminal cd " .. oil.get_current_dir() .. " && " .. command)
          end
        end,
        desc = "Smart run command",
      },
      -- quick run executable
      ["<C-x>"] = {
        callback = function()
          local entry = oil.get_cursor_entry()
          if entry and entry.type == "file" then
            local filepath = oil.get_current_dir() .. entry.name
            if vim.fn.executable(filepath) == 1 then
              vim.cmd("terminal " .. filepath)
            else
              vim.notify("File is not executable: " .. entry.name)
            end
          end
        end,
        desc = "Execute file in terminal",
      },
      -- cd to current dir
      ["<C-c>"] = {
        callback = function()
          local current_dir = oil.get_current_dir()
          vim.cmd("cd " .. current_dir)
          vim.notify("Changed directory to: " .. current_dir)
        end,
        desc = "Change working directory to current Oil directory",
      },
      -- file permissions and ownership
      ["<C-b>"] = {
        callback = function()
          vim.notify("C-b pressed in Oil")
          local entry = oil.get_cursor_entry()
          if not entry then 
            vim.notify("No entry under cursor")
            return 
          end
          vim.notify("Working on: " .. entry.name)
          local filepath = oil.get_current_dir() .. entry.name
          local current_user = vim.fn.system("whoami"):gsub("%s+", "")
          
          local options = {
            "Make executable (chmod +x)",
            "Remove executable (chmod -x)",
            "Make read-only (chmod -w)",
            "Make writable (chmod +w)",
            "Custom chmod",
            "Change owner to " .. current_user .. " (sudo chown)",
            "Custom chown (sudo)",
            "View permissions (ls -la)"
          }
          
          vim.ui.select(options, {
            prompt = "File operations for: " .. entry.name,
          }, function(choice)
            if not choice then return end
            
            local command = ""
            if choice:match("Make executable") then
              command = "chmod +x " .. vim.fn.shellescape(filepath)
            elseif choice:match("Remove executable") then
              command = "chmod -x " .. vim.fn.shellescape(filepath)
            elseif choice:match("Make read%-only") then
              command = "chmod -w " .. vim.fn.shellescape(filepath)
            elseif choice:match("Make writable") then
              command = "chmod +w " .. vim.fn.shellescape(filepath)
            elseif choice:match("Custom chmod") then
              local permissions = vim.fn.input("chmod permissions: ", "755", "file")
              if permissions and permissions ~= "" then
                command = "chmod " .. permissions .. " " .. vim.fn.shellescape(filepath)
              end
            elseif choice:match("Change owner to") then
              if entry.type == "directory" then
                command = "sudo chown -R " .. current_user .. ":" .. current_user .. " " .. vim.fn.shellescape(filepath)
              else
                command = "sudo chown " .. current_user .. ":" .. current_user .. " " .. vim.fn.shellescape(filepath)
              end
            elseif choice:match("Custom chown") then
              local owner = vim.fn.input("chown owner:group: ", current_user .. ":" .. current_user, "user")
              if owner and owner ~= "" then
                if entry.type == "directory" then
                  local recursive = vim.fn.confirm("Apply recursively to directory?", "&Yes\n&No", 1)
                  if recursive == 1 then
                    command = "sudo chown -R " .. owner .. " " .. vim.fn.shellescape(filepath)
                  else
                    command = "sudo chown " .. owner .. " " .. vim.fn.shellescape(filepath)
                  end
                else
                  command = "sudo chown " .. owner .. " " .. vim.fn.shellescape(filepath)
                end
              end
            elseif choice:match("View permissions") then
              command = "ls -la " .. vim.fn.shellescape(filepath)
            end
            
            if command ~= "" then
              vim.cmd("terminal " .. command)
              vim.schedule(function()
                -- Refresh Oil buffer to show permission changes
                vim.cmd("edit")
              end)
            end
          end)
        end,
        desc = "File permissions and ownership operations",
      },
    },
  })
  vim.notify("Oil setup complete with columns and custom functions")
else
  vim.notify("Oil failed to load")
end


-- Plugin setup
local pick_ok, pick = pcall(require, "mini.pick")
if pick_ok then pick.setup() end


-- Indentmini
local indentmini_ok, indentmini = pcall(require, "indentmini")
if indentmini_ok then indentmini.setup{
  exclude = { "markdown"  },
  only_current = 1,
  min_level = 4
  }
end

-- Treesitter
local opt = vim.opt
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

-- Autopairs
local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
if autopairs_ok then
  autopairs.setup({
    check_ts = true,
    ts_config = {
      lua = {'string'},
      javascript = {'string', 'template_string'},
    }
  })
end

-- Lualine
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'auto',
    component_separators = '',
    section_separators = '',
  },
}
