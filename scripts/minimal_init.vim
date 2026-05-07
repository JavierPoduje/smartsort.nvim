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

-- vim.treesitter.language.add() no longer raises in nvim 0.12 when the
-- parser binary is absent, so check for the actual .so/.dylib on disk.
local function parser_binary_exists(lang)
    for _, ext in ipairs({ 'so', 'dylib', 'dll' }) do
        if #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.' .. ext, false) > 0 then
            return true
        end
    end
    return false
end

local missing = {}
for _, lang in ipairs(required_parsers) do
    if not parser_binary_exists(lang) then
        table.insert(missing, lang)
    end
end

if #missing > 0 then
    local ok, install = pcall(require, 'nvim-treesitter.install')
    if ok then
        install.prefer_git = false
    end
    -- TSInstallSync! = with_sync=true + ask_reinstall="force": blocks, never prompts
    vim.cmd('TSInstallSync! ' .. table.concat(missing, ' '))
end
EOF
