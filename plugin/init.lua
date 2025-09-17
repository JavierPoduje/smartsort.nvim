--- @class Options
--- @field args Args: the arguments to use

--- Sort the visually selected lines
--- @param opts Options: the options to use
vim.api.nvim_create_user_command('Smartsort', function(opts)
    --- @diagnostic disable-next-line: param-type-mismatch
    local args = vim.fn.split(opts.args, " \\s*")

    require('smartsort').sort({
        single_line_separator = args[1] or nil,
    })
end, {
    range = true,
    nargs = '?',
})

-- vim.api.nvim_create_user_command('SReload', function()
--     require('lazy.core.loader').reload('smartsort.nvim')
-- end, {
--     range = true,
--     nargs = '?',
-- })

-- vim.api.nvim_create_user_command('SmartsortRegion', function()
--     require('smartsort').region()
-- end, {
--     range = true,
--     nargs = '?',
-- })
