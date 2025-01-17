vim.api.nvim_create_user_command('Smartsort', function()
    require('smartsort').sort()
end, {})

vim.api.nvim_create_user_command('Lang', function()
    require('treesitter').print_lang()
end, {})
