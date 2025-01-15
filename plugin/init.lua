vim.api.nvim_create_user_command('Smartsort', function ()
    require('smartsort').sort()
end, {})
