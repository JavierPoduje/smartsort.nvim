set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../nvim-treesitter/

set rtp+=~/.local/share/nvim/lazy/plenary.nvim
set rtp+=~/.local/share/nvim/lazy/nvim-treesitter

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua

runtime! plugin/init.lua

lua <<EOF
-- --clean strips stdpath('data')/site from rtp; add it back so installed parsers are findable
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")

local required_parsers = {'css','go','javascript','lua','python','scss','typescript','vue'}

local missing = {}
for _, lang in ipairs(required_parsers) do
    if not pcall(vim.treesitter.language.add, lang) then
        table.insert(missing, lang)
    end
end

if #missing > 0 then
    local ok, install = pcall(require, 'nvim-treesitter.install')
    if ok then
        -- prefer_git=false: download tarball instead of git clone (faster, no auth)
        -- ask_reinstall="force": never prompt; TSInstallSync command hangs in headless
        --   mode when nvim-treesitter's tracking says a parser is installed but it isn't
        --   in the current rtp (which --clean resets)
        install.prefer_git = false
        install.update({ with_sync = true, ask_reinstall = "force" })(table.unpack(missing))
    end
end
EOF
