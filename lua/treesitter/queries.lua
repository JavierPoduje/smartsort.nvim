local M = {}

M.typescript_functions = function()
    return [[
        ([
          (lexical_declaration (variable_declarator (identifier) @arrow_function_name)) @arrow_function
          (function_declaration (identifier) @function_name) @function
        ])
    ]]
end

return M
