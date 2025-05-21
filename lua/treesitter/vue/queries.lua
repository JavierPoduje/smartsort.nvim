--- This module provides functions to build and manage queries for different node types in a tree-sitter parser.
--- All queries should have two matches:
--- * The first match is @block (the node itself), which is used to identify the node in the tree.
--- * The second match is the @identifier, which is later used to sort the block of code.

--- @class EmbeddedLanguageQuery
--- @field language string: the language of the query
--- @field query string: the query string

local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local query = M.query_by_node_as_table[node:type()]
    assert(query ~= nil, "Unsupported node type: " .. node:type())
    return query
end

--- Retuns a list of queries for the embedded languages
--- @return table: list of EmbeddedLanguageQuery
M.embedded_languages_queries = function()
    return {
        {
            language = "typescript",
            query = M._embedded_typescript_query(),
        },
    }
end

M._directive_attribute_query = function()
    return [[
        (directive_attribute (directive_value) @identifier) @block
    ]]
end

--- Return the query for a class_declaration
--- @return string
M._script_element_query = function()
    return [[
        (script_element) @injection
    ]]
end

M._embedded_typescript_query = function()
    return [[
        (script_element
          (start_tag
            (
              attribute (
                quoted_attribute_value (attribute_value) @lang
              ) (#eq? @lang "ts")
            )
          )
        ) @block
    ]]
end

M.query_by_node_as_table = {
    script_element = M._script_element_query(),
    directive_attribute = M._directive_attribute_query(),
}

return M
