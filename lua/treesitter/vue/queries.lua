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

--- @type table: list of EmbeddedLanguageQuery
M.embedded_languages_queries = {
    {
        language = "typescript",
        query = [[
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
    },
    {
        language = "javascript",
        query = [[ (script_element) @block ]]
    },
    {
        language = "scss",
        query = [[
            (style_element
              (start_tag
                (
                  attribute (
                    quoted_attribute_value (attribute_value) @lang
                  ) (#eq? @lang "scss")
                )
              )
            ) @block
        ]]
    },
    {
        language = "css",
        query = [[ (style_element) @block ]]
    }
}

M.query_by_node_as_table = {
    script_element = [[ (script_element) @injection ]],
    directive_attribute = [[ (directive_attribute (directive_value) @identifier) @block ]],
}

return M
