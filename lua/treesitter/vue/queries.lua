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
        {
            language = "javascript",
            query = M._embedded_javascript_query(),
        },
        {
            language = "scss",
            query = M._embedded_scss_query(),
        },
        {
            language = "css",
            query = M._embedded_css_query(),
        }
    }
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

M._embedded_javascript_query = function()
    return [[
        (script_element) @block
    ]]
end

M._embedded_scss_query = function()
    return [[
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
end

M._embedded_css_query = function()
    return [[
        (style_element) @block
    ]]
end

M.query_by_node_as_table = {
    script_element = [[ (script_element) @injection ]],
    directive_attribute = [[ (directive_attribute (directive_value) @identifier) @block ]],
}

return M
