local M = {}

--- @param node TSNode: the type of the node
--- @return string
M.query_by_node = function(node)
    local node_type = node:type()

    -- Check if the node is an export statement. If so, get the type of the first child.
    if node_type == "export_statement" then
        node_type = node:child(1):type()
    end

    local query = M.query_by_node_as_table[node_type]
    assert(query ~= nil, "Unsupported node type: " .. node_type)
    return query
end

--- @param node TSNode: the type of the node
--- @return string[]
M.queries_by_node = function(node)
    local node_type = node:type()

    -- Check if the node is an export statement. If so, get the type of the first child.
    if node_type == "export_statement" then
        node_type = node:child(1):type()
    end

    --- @type string[]
    local queries = {}

    for query_name, query in ipairs(M.query_by_node_as_table) do
        if string.find(query_name, node_type) ~= nil then
            table.insert(queries, query)
        end
    end

    return queries
end

--- @type table<JSQueryName, string>
M.query_by_node_as_table = {
    class_declaration = [[ [
        (export_statement (class_declaration (type_identifier) @identifier))
        (class_declaration (type_identifier) @identifier)
    ] @block ]],
    function_declaration = [[ [
        (export_statement (function_declaration (identifier) @identifier))
        (function_declaration (identifier) @identifier)
    ] @block ]],
    lexical_declaration = [[  [
       (export_statement (lexical_declaration (variable_declarator (identifier) @identifier)))
       (lexical_declaration (variable_declarator (identifier) @identifier))
    ] @block ]],
    lexical_declaration_function = [[ [
        (export_statement (lexical_declaration (variable_declarator (identifier) @identifier (arrow_function))))
        (lexical_declaration (variable_declarator (identifier) @identifier (arrow_function)))
    ] @block ]],
    -- probably, this query query can be simplified using `#not-eq?`.
    -- it didn't work for me the first time I tried it though... so f* it
    lexical_declaration_variable = [[ [
        (export_statement
            (lexical_declaration (variable_declarator (identifier) @identifier . [(number) (string) (object) (array) (call_expression) (new_expression) (member_expression)]))
        )
        (lexical_declaration (variable_declarator (identifier) @identifier . [(number) (string) (object) (array) (call_expression) (new_expression) (member_expression)]))
    ] @block ]],
    method_definition = [[ (method_definition (property_identifier) @identifier) @block ]],
    pair = [[ (pair (property_identifier) @identifier) @block ]],
}

--- @type table<number, table<number, JSQueryName>>
M.sortable_groups = {
    {
        "function_declaration",
        "lexical_declaration_function",
        "method_definition",
    }
}


return M
