-- Add runtime paths
vim.opt.rtp:append(".")
vim.opt.rtp:append("../plenary.nvim/")
vim.opt.rtp:append("../nvim-treesitter")
vim.opt.rtp:append(vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"))
vim.opt.rtp:append(vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter"))

-- Load plugin files
vim.cmd("runtime! plugin/plenary.vim")
vim.cmd("runtime! plugin/nvim-treesitter.lua")
vim.cmd("runtime! plugin/init.lua")

-- Setup treesitter
require('nvim-treesitter.configs').setup({
    ensure_installed = {}, -- Leave empty to avoid installing languages during tests
    sync_install = false,
    highlight = { enable = false },
})
