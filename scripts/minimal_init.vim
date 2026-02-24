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
local required_parsers = {'css','go','javascript','lua','python','scss','typescript','vue'}

require("nvim-treesitter.configs").setup {
  ensure_installed = required_parsers,
  sync_install = true,
}

-- Force installation immediately when running headless tests
require("nvim-treesitter.install").prefer_git = false
require("nvim-treesitter.install").update({ with_sync = true })
EOF
