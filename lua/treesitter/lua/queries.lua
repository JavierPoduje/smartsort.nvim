local lua_node_types = require("treesitter.lua.node_types")

local M = {}

--- @param node_type string: the type of the node
--- @return boolean
M.is_supported_node_type = function(node_type)
    for _, supported_node_type in ipairs(lua_node_types.sortable) do
        if node_type == supported_node_type then
            return true
        end
    end

    return false
end

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    assert(M.is_supported_node_type(node:type()), "Unsupported node type: " .. node:type())

    local node_type = node:type()

    if node_type == "assignment_statement" then
        return M._assignment_statement_query()
    elseif node_type == "function_declaration" then
        return M._function_declaration_query()
    elseif node_type == "variable_declaration" then
        return M._variable_declaration_query()
    end

    error("Unsupported node type: " .. node_type)
end


M._function_declaration_query = function()
    return [[
        (function_declaration (identifier) @identifier) @block
    ]]
end

M._assignment_statement_query = function()
    return [[
        (assignment_statement
          (variable_list
            (dot_index_expression
              field: (identifier) @identifier))
          ) @block
    ]]
end

M._variable_declaration_query = function()
    return [[
        (variable_declaration
            (assignment_statement
                (variable_list (identifier) @identifier)
            )
        ) @block
    ]]
end

--- @param lang string: the language to query
--- @param query_str string: the query string
--- @return vim.treesitter.Query
M.build = function(lang, query_str)
    local query = vim.treesitter.query.parse(lang, query_str)
    return query
end

return M
