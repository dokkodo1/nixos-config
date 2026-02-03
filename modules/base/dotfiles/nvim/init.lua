local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
package.path = config_dir .. "/lua/?.lua;" .. package.path

require('plugins')
require('settings')
require('keymaps')

