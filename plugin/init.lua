local R = require('ramda')

--- @class Options
--- @field args Args: the arguments to use


vim.api.nvim_create_user_command('SReload', function()
    require('lazy.core.loader').reload('smartsort.nvim')
end, {
    range = true,
    nargs = '?',
})

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

--- Sort the visually selected lines
--- @param opts Options: the options to use
vim.api.nvim_create_user_command('STest', function(opts)
    local anyIsD = R.any(R.eq)('b')
    print(anyIsD({ 'a', 'b', 'c' }))
end, {
    range = true,
    nargs = '?',
})

--- Print the selected region
vim.api.nvim_create_user_command('SmartsortRegion', function()
    require('smartsort').region()
end, {
    range = true,
    nargs = '?',
})
