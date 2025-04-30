--- @class Options
--- @field args Args: the arguments to use

--- Sort the visually selected lines
--- @param opts Options: the options to use
vim.api.nvim_create_user_command('Smartsort', function(opts)
    --- @diagnostic disable-next-line: param-type-mismatch
    local args = vim.fn.split(opts.args, " \\s*")

    require('smartsort').sort({
        separator = args[1] or nil,
    })
end, {
    range = true,
    nargs = '?',
})
