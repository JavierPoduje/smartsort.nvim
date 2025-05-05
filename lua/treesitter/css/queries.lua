local css_node_types = require("treesitter.css.node_types")

local M = {}

--- @param node_type string: the type of the node
--- @return boolean
M.is_supported_node_type = function(node_type)
    for _, supported_node_type in ipairs(css_node_types.sortable) do
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

    if node_type == "rule_set" then
        return M._rule_set_query()
    end

    error("Unsupported node type: " .. node_type)
end

M._rule_set_query = function()
    return [[
        (rule_set (selectors) @identifier) @block
    ]]
end

return M
