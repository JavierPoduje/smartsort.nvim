local Chadnode = require("chadnode")
local Chadquery = require("chadquery")
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
--- @field public debug fun(self: Chadnodes, bufnr: number, opts: table | nil): table<any>
--- @field public from_chadnodes fun(parser: vim.treesitter.LanguageTree, cnodes: Chadnodes): Chadnodes
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public get_non_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public get_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public merge_sortable_nodes_with_adjacent_non_sortable_nodes fun(self: Chadnodes, region: Region): Chadnodes
--- @field public new fun(self: Chadnodes, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public print fun(self: Chadnodes, bufnr: number, opts: table | nil)
--- @field public sort fun(self: Chadnodes): Chadnodes
--- @field public sort_sortable_nodes fun(self: Chadnodes, cnodes: Chadnode[]): Chadnodes
--- @field public stringify_into_table fun(self: Chadnodes, gaps: number[]): string[]
--- @field public vertical_gaps fun(self: Chadnodes): number[]
---
--- @field private _cnodes_by_idx fun(cnodes: Chadnode[]): table<string, Chadnode>
--- @field private _get_idxs fun(cnodes: Chadnode[]): string[]

local Chadnodes = {}

--- Create a new Chadnodes
--- @param self Chadnodes
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes
function Chadnodes:new(parser)
    Chadnodes.__index = Chadnodes
    local obj = {}
    setmetatable(obj, Chadnodes)

    obj.nodes = {}
    obj.container_node = nil
    obj.parser = parser

    return obj
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
        if cnode.end_character ~= nil and not cnode.end_character.is_attached then
            local previous_node_as_str = nodes_as_str_table[#nodes_as_str_table]
            assert(previous_node_as_str ~= nil, "Previous node not found and trying to add a end_character to it")
            assert(idx == #self.nodes, "Trying to add a end_character to a node that is not the last one")

            local gap_as_str = funcs.repeat_str(" ", cnode.end_character.gap.vertical_gap)
            if cnode.end_character.gap.vertical_gap == 0 and cnode.end_character.gap.horizontal_gap > 0 then
                gap_as_str = funcs.repeat_str(" ", cnode.end_character.gap.horizontal_gap)
            end

            local end_char = cnode.end_character.char
            local str_to_add = gap_as_str .. end_char
            previous_node_as_str = previous_node_as_str .. str_to_add
            nodes_as_str_table[#nodes_as_str_table] = previous_node_as_str
            break
        end

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
--- @param opts table | nil
Chadnodes.debug = function(self, bufnr, opts)
    local debug_tbl = {}
    for _, node in ipairs(self.nodes) do
        table.insert(debug_tbl, node:debug(bufnr, opts))
    end
    return debug_tbl
end

--- Print the string representation of the current Chadnodes
--- @param self Chadnodes
--- @param bufnr number
--- @param opts table | nil
Chadnodes.print = function(self, bufnr, opts)
    print(vim.inspect(self:debug(bufnr, opts)))
end

--- Get the gaps between the nodes. It'll always have a length of `#nodes - 1`.
--- @param self Chadnodes
--- @return number[]
Chadnodes.vertical_gaps = function(self)
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

--- Merge the sortable nodes with their adjacent non-sortable nodes.
--- @param self Chadnodes
--- @param region Region
--- @return Chadnodes
Chadnodes.merge_sortable_nodes_with_adjacent_non_sortable_nodes = function(self, region)
    local gaps = self:vertical_gaps()
    local cnodes = Chadnodes:new(self.parser)
    local chadquery = Chadquery:new(self.parser:lang(), {
        region = region,
    })

    for idx = 1, #gaps + 1 do
        local is_last_node = idx == #gaps + 1

        if is_last_node then
            local current_node = self:node_by_idx(idx)
            assert(current_node ~= nil, "Chadnode not found")

            if chadquery:is_special_end_char(current_node:type()) then
                local prev_node = self:node_by_idx(idx - 1)
                local end_char = current_node.end_character

                if prev_node ~= nil and end_char ~= nil then
                    if end_char.is_attached then
                        prev_node:set_end_character(end_char)
                    else
                        cnodes:add(current_node)
                    end
                end
            else
                cnodes:add(current_node)
            end

            break
        end

        local vertical_gaps = gaps[idx]
        local current_node = self:node_by_idx(idx)
        local next_node = self:node_by_idx(idx + 1)
        local prev_node = self:node_by_idx(idx - 1)

        assert(current_node ~= nil, "Chadnode not found")

        local end_char = chadquery:get_special_end_char(current_node:type())

        if vertical_gaps == 0 and end_char ~= nil and prev_node ~= nil and end_char.is_attached then
            prev_node:set_end_character(end_char)
        elseif vertical_gaps > 0 then
            cnodes:add(current_node)
        elseif chadquery:is_linkable(current_node:type()) and next_node ~= nil then
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
    local node = Chadnodes._get_node_at_row(bufnr, region, parser)
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        local root = parser:parse()[1]:root()
        parent = root
    end

    local processed_nodes = {}
    local chadquery = Chadquery:new(parser:lang(), {
        region = region,
        root_node = parser:parse()[1]:root(),
    })

    local cnodes = Chadnodes:new(parser)
    for child, _ in parent:iter_children() do
        -- if the node is after the last line of the visually-selected area, stop
        if Region.from_node(child).erow >= region.erow then
            break
        end

        local child_id = child:id()

        if Region.from_node(child).srow + 1 >= region.srow then
            if chadquery:is_supported_node_type(child) then
                local query = chadquery:build_query(child)
                local query_matches = query:iter_matches(
                    child,
                    bufnr,
                    child:start(),
                    child:end_() + 1,
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
                local cnode = Chadnode:new(child, nil)

                -- TODO: move this into it's own function later
                local end_char = chadquery:get_special_end_char(cnode:type())
                if end_char ~= nil then
                    local last_cnode = cnodes:node_by_idx(#cnodes.nodes)
                    assert(last_cnode ~= nil, "last_cnode not found and already looking for a special end character?")
                    end_char.gap.vertical_gap = last_cnode:gap(cnode)
                    if end_char.gap.vertical_gap == -1 then
                        end_char.gap.horizontal_gap = last_cnode:horizontal_gap(cnode)
                    end
                    cnode:set_end_character(end_char)
                end

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
    local sorted_nodes = Chadnodes:new(self.parser)

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

    local sorted_cnodes = Chadnodes:new(self.parser)
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
--- @param region Region
--- @param parser vim.treesitter.LanguageTree
--- @return TSNode | nil
Chadnodes._get_node_at_row = function(bufnr, region, parser)
    local row = region.srow
    local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    if #lines == 0 then
        return nil
    end

    local chadquery = Chadquery:new(parser:lang(), {
        region = region,
        root_node = parser:parse()[1]:root(),
    })

    local first_line = lines[1]
    local first_non_empty_char = first_line:find("%S") or 1

    -- Save cursor position
    local saved_cursor = vim.api.nvim_win_get_cursor(0)

    -- Move cursor to the position we want to check
    vim.api.nvim_win_set_cursor(0, { row, first_non_empty_char - 1 })

    -- Get the node at cursor (most indented node)
    local node_at_cursor = ts_utils.get_node_at_cursor(0, false)

    -- Walk up the tree to find a suitable block node
    if node_at_cursor then
        --- @type TSNode | nil
        local current = node_at_cursor
        local block_types = chadquery:sort_and_non_sortable_nodes()
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
