local merge_tables = require("funcs").merge_tables
local javascript_queries = require("treesitter.javascript.queries")

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
M.sortable_group_by_node = function(node)
    --- @param node_type string: the type of the node
    --- @return string[]
    local get_query_names = function(node_type)
        --- @type string[]
        local query_names = {}
        for query_name, _ in pairs(M.query_by_node_as_table) do
            if string.find(query_name, node_type) ~= nil then
                table.insert(query_names, query_name)
            end
        end
        return query_names
    end

    --- @param query_names string[]: the names of the queries
    --- @return string[]: the sortable group
    local get_sortable_group = function(query_names)
        local sortable_group = nil
        for _, query_name in ipairs(query_names) do
            for _, group in ipairs(M.sortable_groups) do
                if vim.tbl_contains(group, query_name) then
                    sortable_group = group
                end

                if sortable_group ~= nil then
                    break
                end
            end

            if sortable_group ~= nil then
                break
            end
        end

        -- if no sortable group was found, return a table with the first query name
        if sortable_group == nil then
            sortable_group = { query_names[1] }
        end

        return sortable_group
    end

    local node_type = node:type()

    -- Check if the node is an export statement. If so, get the type of the first child.
    if node_type == "export_statement" then
        node_type = node:child(1):type()
    end

    local query_names = get_query_names(node_type)
    local sortable_group = get_sortable_group(query_names)

    assert(sortable_group ~= nil, "No sortable group found for node type: " .. node_type)
    return sortable_group
end

M.query_by_node_as_table = merge_tables(
    {
        interface_declaration = [[ [
           (interface_declaration (type_identifier) @identifier)
           (export_statement (interface_declaration (type_identifier) @identifier))
        ] @block ]],
        property_signature = [[ (property_signature (property_identifier) @identifier) @block ]],
    },
    javascript_queries.query_by_node_as_table
)

M.sortable_groups = merge_tables({}, javascript_queries.sortable_groups)

return M
