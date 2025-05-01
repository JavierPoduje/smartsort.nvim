local M = {}

--- @param node_type string: the type of the node
--- @return boolean
M.is_supported_node_type = function(node_type)
    local supported_node_types = {
        "function_declaration",
        "lexical_declaration",
    }

    for _, supported_node_type in ipairs(supported_node_types) do
        if node_type == supported_node_type then
            return true
        end
    end

    return false
end

--- @param node_type string: the type of the node
--- @return string
M.query_by_node_type = function(node_type)
    assert(M.is_supported_node_type(node_type), "Unsupported node type: " .. node_type)

    if node_type == "function_declaration" then
        return M.function_declaration_query()
    elseif node_type == "lexical_declaration" then
        return M.lexical_declaration_query()
    else
        error("Unknown node type: " .. node_type)
    end
end

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
        (function_declaration (identifier) @identifier) @node
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

--- @param lang string: the language to query
--- @param query_str string: the query string
--- @return vim.treesitter.Query
M.build = function(lang, query_str)
    local query = vim.treesitter.query.parse(lang, query_str)
    return query
end

return M
