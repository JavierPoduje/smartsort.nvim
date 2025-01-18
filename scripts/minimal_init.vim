set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../nvim-treesitter/

set rtp+=~/.local/share/nvim/lazy/plenary.nvim
set rtp+=~/.local/share/nvim/lazy/nvim-treesitter

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

runtime! plugin/init.lua
