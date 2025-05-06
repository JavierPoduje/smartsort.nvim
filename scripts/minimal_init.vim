set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../nvim-treesitter/

set rtp+=~/.local/share/nvim/lazy/plenary.nvim
set rtp+=~/.local/share/nvim/lazy/nvim-treesitter

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

runtime! plugin/init.lua

lua <<EOF
-- treesitter setup
local required_parsers = {'css','lua','scss','typescript'}
local installed_parsers = require'nvim-treesitter.info'.installed_parsers()
local to_install = vim.tbl_filter(function(parser)
  return not vim.tbl_contains(installed_parsers, parser)
end, required_parsers)
if #to_install > 0 then
  -- fixes 'pos_delta >= 0' error - https://github.com/nvim-lua/plenary.nvim/issues/52
  vim.cmd('set display=lastline')
  vim.cmd('set splitbelow=false')
  vim.cmd('set splitright=false')

  -- make "TSInstall*" available
  vim.cmd 'runtime! plugin/nvim-treesitter.vim'
  vim.cmd('TSInstallSync ' .. table.concat(to_install, ' '))
end
EOF
