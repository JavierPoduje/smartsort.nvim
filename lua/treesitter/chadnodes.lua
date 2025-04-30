local Chadnode = require("treesitter.chadnode")
local Region = require("region")
local queries = require("treesitter.queries")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class Chadnodes
---
--- @field public nodes Chadnode[]
--- @field public container_node TSNode
--- @field public parser vim.treesitter.LanguageTree
---
--- @field public _get_node_at_row fun(bufnr: number, row: number): TSNode
--- @field public add fun(self: Chadnodes, chadnode: Chadnode)
--- @field public cnode_is_sortable_by_idx fun(self): table<string, boolean>
--- @field public debug fun(self: Chadnodes, bufnr: number): table<any>
--- @field public from_chadnodes fun(parser: vim.treesitter.LanguageTree, cnodes: Chadnodes): Chadnodes
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public gaps fun(self: Chadnodes): number[]
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public get_non_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public get_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public merge_sortable_nodes_with_their_comments fun(self: Chadnodes): Chadnodes
--- @field public new fun(parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public print fun(self: Chadnodes, bufnr: number)
--- @field public sort fun(self: Chadnodes): Chadnodes
--- @field public sort_sortable_nodes fun(self: Chadnodes, cnodes: Chadnode[]): Chadnodes
---
--- @field private _cnodes_by_idx fun(cnodes: Chadnode[]): table<string, Chadnode>
--- @field private _get_idxs fun(cnodes: Chadnode[]): string[]

local Chadnodes = {}
Chadnodes.__index = Chadnodes

--- Create a new Chadnodes
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes
Chadnodes.new = function(parser)
    local self = setmetatable({}, Chadnodes)
    self.nodes = {}
    self.container_node = nil
    self.parser = parser
    return self
end

--- Create a new Chadnodes from an existing Chadnodes
--- @param parser vim.treesitter.LanguageTree
--- @param cnodes Chadnodes
--- @return Chadnodes
Chadnodes.from_chadnodes = function(parser, cnodes)
    local self = setmetatable({}, Chadnodes)
    self.nodes = cnodes
    self.parser = parser
    self.container_node = self._get_container_node(parser)
    return self
end

--- Return a human-readable representation of the current Chadnodes
--- @param self Chadnodes
--- @param bufnr number
Chadnodes.debug = function(self, bufnr)
    local debug_tbl = {}
    for _, node in ipairs(self.nodes) do
        table.insert(debug_tbl, node:debug(bufnr))
    end
    return debug_tbl
end

--- Print the string representation of the current Chadnodes
--- @param self Chadnodes
--- @param bufnr number
Chadnodes.print = function(self, bufnr)
    print(vim.inspect(self:debug(bufnr)))
end

--- Get the gaps between the nodes. It'll always have a length of `#nodes - 1`.
--- @param self Chadnodes
--- @return number[]
Chadnodes.gaps = function(self)
    local gaps = {}
    --- @type Chadnode | nil
    local previous_cnode = nil
    for idx, cnode in ipairs(self.nodes) do
        if idx == 1 then
            previous_cnode = cnode
        else
            assert(previous_cnode ~= nil, "Previous Chadnode not found")
            table.insert(gaps, previous_cnode:gap(cnode))
            previous_cnode = cnode
        end
    end
    return gaps
end

--- Merge the sortable nodes with their comments
--- @param self Chadnodes
--- @return Chadnodes
Chadnodes.merge_sortable_nodes_with_their_comments = function(self)
    local gaps = self:gaps()
    local cnodes = Chadnodes.new(self.parser)

    for idx = 1, #gaps + 1 do
        if idx > #gaps then
            local current_node = self:node_by_idx(idx)
            assert(current_node ~= nil, "Chadnode not found")
            cnodes:add(current_node)
            break
        end

        local gap = gaps[idx]
        local current_node = self:node_by_idx(idx)
        local next_node = self:node_by_idx(idx + 1)

        assert(current_node ~= nil, "Chadnode not found")

        if gap > 0 then
            cnodes:add(current_node)
        elseif current_node:type() == 'comment' and next_node ~= nil then
            next_node:set_comment(current_node)
        else
            cnodes:add(current_node)
        end
    end

    return cnodes
end

--- Get the node by index
--- @param self Chadnodes
--- @param idx number
--- @return Chadnode | nil
Chadnodes.node_by_idx = function(self, idx)
    if idx < 1 or idx > #self.nodes then
        return nil
    end
    return self.nodes[idx]
end

--- Get the nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get = function(self)
    return self.nodes
end

--- Add a Chadnode to the list of Chadnodes
--- @param self Chadnodes
--- @param chadnode Chadnode
Chadnodes.add = function(self, chadnode)
    table.insert(self.nodes, chadnode)
end

-- Chadnodes.from_region = function(bufnr, region, parser)
--     local node = ts_utils.get_node_at_cursor()
--
--     assert(node ~= nil, "No node found")
--
--     local cnodes = Chadnodes.new(parser)
--
--     while node ~= nil do
--         local match_found = false
--
--         -- if the node is after the last line of the visually-selected area, stop
--         if region.erow < Region.from_node(node).erow then
--             break
--         end
--
--         local query = queries.functions_query(parser:lang())
--
--         for _, matches in query:iter_matches(node, bufnr) do
--             match_found = true
--             local cnode = Chadnode.new(f.get_node(matches), f.get_function_name(matches))
--             cnodes:add(cnode)
--
--             if not cnode:has_next_sibling() then
--                 break
--             end
--         end
--
--         if not match_found then
--             local cnode = Chadnode.new(node, nil)
--             cnodes:add(cnode)
--         end
--
--         node = node:next_sibling()
--     end
--
--     return cnodes
-- end

--- @param parser vim.treesitter.LanguageTree
Chadnodes._get_container_node = function(parser)
    local node = ts_utils.get_node_at_cursor()
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    return parent
end

--- Return a new `Chadnodes` object with the nodes sorted and the parent node of the node from
--- the region selected
--- @param bufnr number: the buffer number
--- @param region Region: the region to get the nodes from
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes, TSNode
Chadnodes.from_region = function(bufnr, region, parser)
    local node = Chadnodes._get_node_at_row(bufnr, region.srow)
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    local cnodes = Chadnodes.new(parser)
    for child, _ in parent:iter_children() do
        -- if the node is after the last line of the visually-selected area, stop
        if region.erow < Region.from_node(child).erow then
            break
        end

        if child:type() == 'function_declaration' then
            local query = queries.build(parser:lang(), queries.function_declaration_query())
            for _, matches in query:iter_matches(child, bufnr) do
                local function_name = vim.treesitter.get_node_text(matches[1][1], bufnr)
                local matched_node = matches[2][1]

                cnodes:add(Chadnode.new(matched_node, function_name))
            end
        elseif child:type() == 'lexical_declaration' then
            local query = vim.treesitter.query.parse(parser:lang(), queries.lexical_declaration_query())
            for _, matches in query:iter_matches(child, bufnr) do
                local function_name = vim.treesitter.get_node_text(matches[1][1], bufnr)
                local matched_node = matches[2][1]

                cnodes:add(Chadnode.new(matched_node, function_name))
            end
        else
            local cnode = Chadnode.new(child, nil)
            cnodes:add(cnode)
        end

        cnodes:debug(bufnr)
    end

    return cnodes, parent
end

--- Returns a new `Chadnodes` object with the nodes sorted
--- @param self Chadnodes
--- @return Chadnodes
Chadnodes.sort = function(self)
    local non_sortables = self:get_non_sortable_nodes()
    local sortables = Chadnodes:sort_sortable_nodes(self:get_sortable_nodes())
    local sorted_nodes = Chadnodes.new(self.parser)

    --- @type number
    local sortable_idx = 1
    --- @type number
    local non_sortable_idx = 1
    for _, is_sortable in pairs(self:cnode_is_sortable_by_idx()) do
        if is_sortable then
            local cnode = sortables:node_by_idx(sortable_idx)
            assert(cnode ~= nil, "Chadnode not found")
            sorted_nodes:add(cnode)
            sortable_idx = sortable_idx + 1
        else
            local cnode = non_sortables[non_sortable_idx]
            assert(cnode ~= nil, "Chadnode not found")
            sorted_nodes:add(cnode)
            non_sortable_idx = non_sortable_idx + 1
        end
    end

    return sorted_nodes
end

--- Get the sortable nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get_sortable_nodes = function(self)
    local sortable_nodes = {}
    for _, node in ipairs(self.nodes) do
        if node:is_sortable() then
            table.insert(sortable_nodes, node)
        end
    end
    return sortable_nodes
end

--- Get the non-sortable nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get_non_sortable_nodes = function(self)
    local sortable_nodes = {}
    for _, node in ipairs(self.nodes) do
        if not node:is_sortable() then
            table.insert(sortable_nodes, node)
        end
    end
    return sortable_nodes
end

--- Return a table where the key is the original Chadnode's place in the buffer and the value is a
--- boolean that indicates if the node is sortable. This is used to sort the nodes considering
--- than the non-sortable nodes have to keep their position.
Chadnodes.cnode_is_sortable_by_idx = function(self)
    local sortable_by_idx = {}
    for idx, node in ipairs(self.nodes) do
        sortable_by_idx[idx] = node:is_sortable()
    end
    return sortable_by_idx
end

--- Returns a new `Chadnodes` object with the given list of `Chadnode`s sorted
--- @param self Chadnodes
--- @param cnodes Chadnode[]: the list of nodes to sort
--- @return Chadnodes
Chadnodes.sort_sortable_nodes = function(self, cnodes)
    local sorted_idx = Chadnodes._get_idxs(cnodes)
    local cnodes_by_idx = Chadnodes._cnodes_by_idx(cnodes)

    table.sort(sorted_idx)

    local sorted_cnodes = Chadnodes.new(self.parser)
    for _, idx in ipairs(sorted_idx) do
        sorted_cnodes:add(cnodes_by_idx[idx])
    end

    return sorted_cnodes
end

--- Get the indexes of the given list of `Chadnode`s
--- @param cnodes Chadnode[]: the list of nodes to get the indexes from
--- @return string[]
Chadnodes._get_idxs = function(cnodes)
    local idxs = {}
    for _, node in ipairs(cnodes) do
        table.insert(idxs, node:get_sortable_idx())
    end
    return idxs
end

--- Map the `Chadnode`s by their sortable_idx
--- @param cnodes Chadnode[]
--- @return table<string, Chadnode>
Chadnodes._cnodes_by_idx = function(cnodes)
    local cnodes_by_idx = {}
    for _, node in ipairs(cnodes) do
        cnodes_by_idx[node:get_sortable_idx()] = node
    end
    return cnodes_by_idx
end

--- Get the node at the given row
--- @param bufnr number
--- @param row number
--- @return TSNode | nil
Chadnodes._get_node_at_row = function(bufnr, row)
    local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    if #lines == 0 then
        return nil
    end

    local first_line = lines[1]
    local first_non_empty_char = first_line:find("%S") or 1
    return ts_utils.get_root_for_position(1, first_non_empty_char)
end

return Chadnodes
