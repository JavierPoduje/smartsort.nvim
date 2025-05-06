local Chadnode = require("treesitter.chadnode")
local Chadquery = require("treesitter.chadquery")
local Region = require("region")
local funcs = require("funcs")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class Chadnodes
---
--- @field public nodes Chadnode[]
--- @field public container_node TSNode
--- @field public parser vim.treesitter.LanguageTree
---
--- @field public _get_node_at_row fun(bufnr: number, row: number, parser: vim.treesitter.LanguageTree): TSNode
--- @field public add fun(self: Chadnodes, chadnode: Chadnode)
--- @field public cnode_is_sortable_by_idx fun(self): table<string, boolean>
--- @field public debug fun(self: Chadnodes, bufnr: number): table<any>
--- @field public from_chadnodes fun(parser: vim.treesitter.LanguageTree, cnodes: Chadnodes): Chadnodes
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public gaps fun(self: Chadnodes): number[]
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public get_non_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public get_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public merge_sortable_nodes_with_adjacent_non_sortable_nodes fun(self: Chadnodes): Chadnodes
--- @field public new fun(parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public print fun(self: Chadnodes, bufnr: number)
--- @field public sort fun(self: Chadnodes): Chadnodes
--- @field public sort_sortable_nodes fun(self: Chadnodes, cnodes: Chadnode[]): Chadnodes
--- @field public stringify_into_table fun(self: Chadnodes, gaps: number[]): string[]
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

--- Return a list of strings where each item is a line of the string representation of the nodes.
--- @param self Chadnodes
--- @param gaps number[]: the gaps between the nodes
--- @return string[]: the string representation of the nodes
Chadnodes.stringify_into_table = function(self, gaps)
    local nodes_as_str_table = {}
    for idx, cnode in ipairs(self.nodes) do
        local cnode_str = cnode:to_string_preserve_indent(0, cnode.region.srow)
        -- add the node to the table line by line
        for _, line in ipairs(vim.fn.split(cnode_str, "\n")) do
            table.insert(nodes_as_str_table, line)
        end
        -- add the gap, if any
        if idx <= #gaps then
            for _ = 1, gaps[idx] do
                table.insert(nodes_as_str_table, "")
            end
        end
    end
    return nodes_as_str_table
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

--- Merge the sortable nodes with their adjacent non-sortable nodes. currently, it only works with comments and the final ";".
--- @param self Chadnodes
--- @return Chadnodes
Chadnodes.merge_sortable_nodes_with_adjacent_non_sortable_nodes = function(self)
    local gaps = self:gaps()
    local cnodes = Chadnodes.new(self.parser)

    for idx = 1, #gaps + 1 do
        if idx > #gaps then
            local current_node = self:node_by_idx(idx)
            assert(current_node ~= nil, "Chadnode not found")

            if funcs.is_special_end_char(current_node:type()) then
                local prev_node = self:node_by_idx(idx - 1)
                if prev_node ~= nil then
                    prev_node:set_end_character(current_node:type())
                end
            else
                cnodes:add(current_node)
            end

            break
        end

        local gap = gaps[idx]
        local current_node = self:node_by_idx(idx)
        local next_node = self:node_by_idx(idx + 1)
        local prev_node = self:node_by_idx(idx - 1)

        assert(current_node ~= nil, "Chadnode not found")

        if gap == 0 and funcs.is_special_end_char(current_node:type()) and prev_node ~= nil then
            prev_node:set_end_character(current_node:type())
        elseif gap > 0 then
            cnodes:add(current_node)
        elseif Chadquery.is_linkable(self.parser:lang(), current_node:type()) and next_node ~= nil then
            next_node:set_previous(current_node)
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

--- Return a new `Chadnodes` object with the matched nodes in the given region and the parent node
--- of the node from the region selected.
--- @param bufnr number: the buffer number
--- @param region Region: the region to get the nodes from
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes, TSNode
Chadnodes.from_region = function(bufnr, region, parser)
    local node = Chadnodes._get_node_at_row(bufnr, region.srow, parser)
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    local processed_nodes = {}

    local cnodes = Chadnodes.new(parser)
    for child, _ in parent:iter_children() do
        -- if the node is after the last line of the visually-selected area, stop
        if Region.from_node(child).erow >= region.erow then
            break
        end

        local child_id = child:id()

        if Region.from_node(child).srow + 1 >= region.srow then
            if Chadquery.is_supported_node_type(parser:lang(), child) then
                local query = Chadquery.build_query(parser:lang(), child)
                local query_matches = query:iter_matches(
                    child,
                    bufnr,
                    child:start(),
                    node:end_(),
                    { max_start_depth = 1 }
                )

                for pattern, match, metadata in query_matches do
                    local cnode = Chadnode.from_query_match(query, match, bufnr)
                    if not processed_nodes[child_id] then
                        cnodes:add(cnode)
                        processed_nodes[child_id] = true
                    end
                end
            else
                local cnode = Chadnode.new(child, nil)
                if not processed_nodes[child_id] then
                    cnodes:add(cnode)
                    processed_nodes[child_id] = true
                end
            end
        end
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
--- @param parser vim.treesitter.LanguageTree
--- @return TSNode | nil
Chadnodes._get_node_at_row = function(bufnr, row, parser)
    local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    if #lines == 0 then
        return nil
    end

    local first_line = lines[1]
    local first_non_empty_char = first_line:find("%S") or 1

    -- Save cursor position
    local saved_cursor = vim.api.nvim_win_get_cursor(0)

    -- Move cursor to the position we want to check
    vim.api.nvim_win_set_cursor(0, { row, first_non_empty_char - 1 })

    -- Get the node at cursor (most indented node)
    local node_at_cursor = ts_utils.get_node_at_cursor()

    -- Walk up the tree to find a suitable block node
    if node_at_cursor then
        --- @type TSNode | nil
        local current = node_at_cursor
        local block_types = Chadquery.sort_and_non_sortable_nodes(parser:lang())
        assert(#block_types > 0, "No block types found")

        while current do
            local type = current:type()
            for _, block_type in ipairs(block_types) do
                if type == block_type then
                    -- Restore cursor position
                    vim.api.nvim_win_set_cursor(0, saved_cursor)
                    return current
                end
            end

            if current:parent() == nil then
                break
            else
                current = current:parent()
            end
        end

        node_at_cursor = current
    end

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(0, saved_cursor)

    return node_at_cursor
end

return Chadnodes
