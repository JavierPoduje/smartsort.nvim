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

-- ensure_installed relies on VimEnter which does not fire in headless mode,
-- so install any missing parsers explicitly before tests run
for _, lang in ipairs(required_parsers) do
    local ok = pcall(vim.treesitter.language.add, lang)
    if not ok then
        vim.cmd("TSInstallSync " .. lang)
    end
end
EOF
