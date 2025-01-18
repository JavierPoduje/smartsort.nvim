local M = {}

M.typescript_functions = function()
    return [[
        ([
          (lexical_declaration (variable_declarator (identifier) @arrow_function_name)) @arrow_function
          (function_declaration (identifier) @function_name) @function
        ])
    ]]
end


--- @param lang string: the language to query
--- @return vim.treesitter.Query
M.functions_query = function(lang)
    local query = vim.treesitter.query.parse(lang, M.typescript_functions())
    return query
end

M.get_nodes = function()
end

return M
