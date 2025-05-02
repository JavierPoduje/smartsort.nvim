local parsers = require("nvim-treesitter.parsers")

--- @param buf_content string[]: the content of the buffer
--- @param filetype string: the filetype to set for the buffer
--- @return number, vim.treesitter.LanguageTree
local setup = function(buf_content, filetype)
    vim.cmd(":new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_content)

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    -- set filetype
    vim.bo[bufnr].filetype = filetype

    -- set parser
    local parser = parsers.get_parser(bufnr, filetype)
    if not parser then
        error("Parser not available for filetype: " .. filetype)
    end
    parser:parse()

    return bufnr, parser
end

return {
    setup = setup,
}
