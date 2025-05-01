local M = {}

--- Return the query for a lexical declaration
--- @return string
M.lexical_declaration_query = function()
    return [[
        (lexical_declaration (variable_declarator (identifier) @identifier)) @node
    ]]
end

--- Return the query for a function declaration
--- @return string
M.function_declaration_query = function()
    return [[
        (function_declaration (identifier) @name) @function
    ]]
end

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

M.test_query = function(lang)
    local query = vim.treesitter.query.parse(lang, M.test())
    return query
end

--- @param lang string: the language to query
--- @param query_str string: the query string
--- @return vim.treesitter.Query
M.build = function(lang, query_str)
    local query = vim.treesitter.query.parse(lang, query_str)
    return query
end

return M
