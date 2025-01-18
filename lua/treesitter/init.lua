local f = require("funcs")
local parsers = require("nvim-treesitter.parsers")
local queries = require("treesitter.queries")
local Chadnode = require("treesitter.chadnode")
local ts = vim.treesitter
local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

M.print_lang = function()
    local parser = parsers.get_parser()
    print(parser:lang())
end

--- Return the string representation of a node
--- @param node TSNode
--- @return string
M.node_to_string = function(node)
    return ts.get_node_text(node, 0)
end

--- @param region Region: the selected region to get the data from
--- @return table<string, TSNode>, TSNode[], number[], boolean[]
M.get_selection_data = function(region)
    local parser = parsers.get_parser()
    --- @type table<string, TSNode>
    local nodes_by_name = {}
    --- @type number[]
    local gap_between_nodes = {}
    --- @type boolean[]
    local node_is_sortable_by_idx = {}
    --- TODO: used it. It's not used in the current implementation
    --- @type TSNode[]
    local non_sortable_nodes = {}

    local node = ts_utils.get_node_at_cursor()
    assert(node ~= nil, "No node found")

    while node ~= nil do
        local match_found = false

        -- if the node is after the last line of the visually-selected area, stop
        local _, _, erow, _ = node:range()
        if erow > region.erow - 1 then
            break
        end

        local query = queries.functions_query(parser:lang())
        for _, matches in query:iter_matches(node, 0) do
            match_found = true
            local function_name = M._get_function_name(matches)
            local node_to_save = M._get_node(matches)

            nodes_by_name[function_name] = node_to_save
            table.insert(node_is_sortable_by_idx, true)

            local next_sibling = node_to_save:next_sibling()
            if next_sibling == nil then
                break
            end

            local cnode1 = Chadnode.new(node_to_save, function_name)
            local cnode2 = Chadnode.new(next_sibling, nil)

            table.insert(gap_between_nodes, cnode1:gap(cnode2))
        end

        if not match_found then
            table.insert(non_sortable_nodes, node)
        end

        node = node:next_sibling()
    end

    return nodes_by_name, non_sortable_nodes, gap_between_nodes, node_is_sortable_by_idx
end

--- @param bufnr number: the buffer number
--- @param region Region: the region to get the nodes from
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnode[]
M.get_nodes_from_range = function(bufnr, region, parser)
    local node = ts_utils.get_node_at_cursor()

    assert(node ~= nil, "No node found")

    --- @type Chadnode[]
    local chadnodes = {}

    while node ~= nil do
        local match_found = false

        -- if the node is after the last line of the visually-selected area, stop
        local _, _, erow, _ = node:range()
        if erow > region.erow - 1 then
            break
        end

        local query = queries.functions_query(parser:lang())

        for _, matches in query:iter_matches(node, bufnr) do
            match_found = true
            local cnode = Chadnode.new(M._get_node(matches), M._get_function_name(matches))

            table.insert(chadnodes, cnode)

            if not cnode:has_next_sibling() then
                break
            end
        end

        if not match_found then
            local cnode = Chadnode.new(node, nil)
            table.insert(chadnodes, cnode)
        end

        node = node:next_sibling()
    end

    return chadnodes
end

--- @param node TSNode
--- @return string
M._get_function_name = function(node)
    return f.if_else(
        f.contains(node, 1),
        function() return M.node_to_string(node[1]) end,
        function() return M.node_to_string(node[3]) end
    )
end

--- @param node TSNode
--- @return TSNode
M._get_node = function(node)
    return f.if_else(
        f.contains(node, 2),
        function() return node[2] end,
        function() return node[4] end
    )
end

return M
