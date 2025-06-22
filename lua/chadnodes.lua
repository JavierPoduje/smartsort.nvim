local Chadnode = require("chadnode")
local Chadquery = require("chadquery")
local FileManager = require("file_manager")
local R = require("ramda")
local Region = require("region")
local funcs = require("funcs")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class Chadnodes
---
--- @field public container_node TSNode
--- @field public nodes Chadnode[]
--- @field public parser vim.treesitter.LanguageTree
---
--- @field public add fun(self: Chadnodes, chadnode: Chadnode): self
--- @field public calculate_vertical_gaps fun(self: Chadnodes): number[]
--- @field public cnode_is_sortable_by_idx fun(self): table<string, boolean>
--- @field public debug fun(self: Chadnodes, bufnr: number, opts: table | nil): table<any>
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public get_non_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public get_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public merge_sortable_nodes_with_adjacent_linkable_nodes fun(self: Chadnodes, region: Region): Chadnodes
--- @field public new fun(self: Chadnodes, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public print fun(self: Chadnodes, bufnr: number, opts: table | nil)
--- @field public sort fun(self: Chadnodes): Chadnodes
--- @field public sort_sortable_nodes fun(self: Chadnodes, cnodes: Chadnode[]): Chadnodes
--- @field public stringify_into_table fun(self: Chadnodes, vertical_gaps: number[]): string[]
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

--- Map the `Chadnode`s by their sort_key
--- @param cnodes Chadnode[]
--- @return table<string, Chadnode>
Chadnodes._cnodes_by_idx = function(cnodes)
    return R.reduce(function(acc, node)
        acc[node:get_sort_key()] = node
        return acc
    end, {}, cnodes)
end

--- @param parser vim.treesitter.LanguageTree
Chadnodes._get_container_node = function(parser)
    local node = ts_utils.get_node_at_cursor()
    assert(node ~= nil, "No node found")

    local parent = node:parent()
    if parent == nil then
        parent = parser:parse()[1]:root()
    end
    return parent
end

--- Get the indexes of the given list of `Chadnode`s
--- @param cnodes Chadnode[]
--- @return string[]
Chadnodes._get_idxs = function(cnodes)
    return R.reduce(function(acc, node)
        table.insert(acc, node:get_sort_key())
        return acc
    end, {}, cnodes)
end

--- Add a Chadnode to the list of Chadnodes
--- @param self Chadnodes
--- @param chadnode Chadnode
--- @return self
Chadnodes.add = function(self, chadnode)
    table.insert(self.nodes, chadnode)
    return self
end

--- Get the gaps between the nodes. It'll always have a length of `#nodes - 1`.
--- @param self Chadnodes
--- @return number[]
Chadnodes.calculate_vertical_gaps = function(self)
    --- @type { previous_cnode: Chadnode | nil, gaps: number[] }
    local acc = R.reduce(function(acc, cnode, idx)
        local previous_cnode, gaps = acc.previous_cnode, acc.gaps

        if idx == 1 then
            previous_cnode = cnode
        else
            assert(previous_cnode ~= nil, "Previous Chadnode not found")
            table.insert(gaps, previous_cnode:calculate_vertical_gap(cnode))
            previous_cnode = cnode
        end

        return { previous_cnode = previous_cnode, gaps = gaps }
    end, { previous_cnode = nil, gaps = {} }, self.nodes)

    return acc.gaps
end

--- Return a table where the key is the original Chadnode's place in the buffer and the value is a
--- boolean that indicates if the node is sortable. This is used to sort the nodes considering
--- than the non-sortable nodes have to keep their position.
Chadnodes.cnode_is_sortable_by_idx = function(self)
    return R.map(function(node) return node:is_sortable() end, self.nodes)
end

--- Return a human-readable representation of the current Chadnodes
--- @param self Chadnodes
--- @param bufnr number
--- @param opts table | nil
Chadnodes.debug = function(self, bufnr, opts)
    return R.map(function(node) return node:debug(bufnr, opts) end, self.nodes)
end

--- Return a new `Chadnodes` object with the matched nodes in the given region and the parent node
--- of the node from the region selected.
--- @param bufnr number: the buffer number
--- @param region Region: the region to get the nodes from
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes, TSNode
Chadnodes.from_region = function(bufnr, region, parser)
    local node = FileManager.get_node_at_row(bufnr, region, parser)
    assert(node ~= nil, "No node found")

    local root_node = parser:parse()[1]:root()
    local parent = node:parent()
    if parent == nil then
        -- if the node has no parent, use the root node of the parser
        parent = root_node
    end

    local processed_nodes = {}
    local chadquery = Chadquery:new(parser:lang(), { region = region, root_node = root_node })

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

                for _, match, _ in query_matches do
                    local cnode = Chadnode.from_query_match(query, match, bufnr)
                    if not processed_nodes[child_id] then
                        cnodes:add(cnode)
                        processed_nodes[child_id] = true
                    end
                end
            else
                local current_cnode = Chadnode:new(child, nil)
                local end_char = chadquery:get_endchar_from_str(current_cnode:type())

                if end_char ~= nil then
                    local last_cnode = cnodes:node_by_idx(#cnodes.nodes)
                    assert(last_cnode ~= nil, "last_cnode not found and already looking for a special end character?")

                    end_char:set_gaps(current_cnode, last_cnode)
                    current_cnode:set_end_character(end_char)
                    if end_char.is_attached then
                        -- TODO: remove the following line later
                        last_cnode:set_attached_suffix_cnode(current_cnode)
                        last_cnode:add_attached_suffix_cnode(current_cnode)
                    end
                end

                if not processed_nodes[child_id] then
                    cnodes:add(current_cnode)
                    processed_nodes[child_id] = true
                end
            end
        end
    end

    return cnodes, parent
end

--- Get the nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get = function(self)
    return self.nodes
end


--- Get the linkable nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get_non_sortable_nodes = function(self)
    return R.filter(function(node) return not node:is_sortable() end, self.nodes)
end

--- Get the sortable nodes
--- @param self Chadnodes
--- @return Chadnode[]
Chadnodes.get_sortable_nodes = function(self)
    return R.filter(function(node) return node:is_sortable() end, self.nodes)
end

--- Merge the sortable nodes with their adjacent non-sortable nodes.
--- @param self Chadnodes
--- @param region Region
--- @return Chadnodes
Chadnodes.merge_sortable_nodes_with_adjacent_linkable_nodes = function(self, region)
    local chadquery = Chadquery:new(self.parser:lang(), { region = region })
    local cnodes = Chadnodes:new(self.parser)
    local gaps = self:calculate_vertical_gaps()

    for idx = 1, #gaps + 1 do
        local current_node = self:node_by_idx(idx)
        assert(current_node ~= nil, "Chadnode not found")

        local is_last_node = idx == #gaps + 1
        if is_last_node then
            if chadquery:is_special_end_char(current_node:type()) then
                local end_char = current_node.end_character
                local prev_node = self:node_by_idx(idx - 1)

                if prev_node ~= nil and end_char ~= nil then
                    if end_char.is_attached then
                        -- TODO: remove the following line later
                        prev_node:set_attached_suffix_cnode(current_node)
                        prev_node:add_attached_suffix_cnode(current_node)
                    else
                        cnodes:add(current_node)
                    end
                end
            else
                cnodes:add(current_node)
            end

            break
        end

        local end_char = chadquery:get_endchar_from_str(current_node:type())
        local prev_node, next_node = self:node_by_idx(idx - 1), self:node_by_idx(idx + 1)
        local vertical_gap = gaps[idx]

        if vertical_gap == 0 and end_char ~= nil and prev_node ~= nil and end_char.is_attached then
            prev_node:set_attached_suffix_cnode(current_node)
        elseif vertical_gap <= 0 and chadquery:is_linkable(current_node:type()) and next_node ~= nil then
            -- TODO: remove the following line later
            next_node:set_attached_prefix_cnode(current_node)
            next_node:add_attached_prefix_cnode(current_node)
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

--- Print the string representation of the current Chadnodes
--- @param self Chadnodes
--- @param bufnr number
--- @param opts table | nil
Chadnodes.print = function(self, bufnr, opts)
    print(vim.inspect(self:debug(bufnr, opts)))
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

--- Returns a new `Chadnodes` object with the given list of `Chadnode`s sorted
--- @param self Chadnodes
--- @param cnodes Chadnode[]: the list of nodes to sort
--- @return Chadnodes
Chadnodes.sort_sortable_nodes = function(self, cnodes)
    local cnodes_by_idx = Chadnodes._cnodes_by_idx(cnodes)
    local sorted_idx = Chadnodes._get_idxs(cnodes)

    table.sort(sorted_idx)

    return R.reduce(function(acc, idx)
        return acc:add(cnodes_by_idx[idx])
    end, Chadnodes:new(self.parser), sorted_idx)
end

--- Return a list of strings where each item is a line of the string representation of the nodes.
--- @param self Chadnodes
--- @param vertical_gaps number[]: the vertical gaps between the nodes
--- @return string[]: the string representation of the nodes
Chadnodes.stringify_into_table = function(self, vertical_gaps)
    local nodes_as_str_table = {}

    for idx, cnode in ipairs(self.nodes) do
        if not cnode:is_endchar_node() then
            local cnode_str = cnode:stringify(0, cnode.region.srow)
            local endchar_as_str = funcs.if_else(
                #cnode.attached_suffix_cnodes > 0 and cnode.attached_suffix_cnodes[1].end_character ~= nil,
                function() return cnode.attached_suffix_cnodes[1].end_character:stringify() end,
                function() return "" end
            )

            local stringified_node_lines = vim.fn.split(cnode_str .. endchar_as_str, "\n")

            -- if the current node is in the same line of the previous node:
            -- 1. copy the first line of the current node and put it in the last line of the previous one
            -- 2. remove the first line of the current node
            if idx <= #vertical_gaps and vertical_gaps[idx] == -1 and #nodes_as_str_table > 0 then
                local previous_node_as_str = nodes_as_str_table[#nodes_as_str_table]
                assert(previous_node_as_str ~= nil, "Previous node not found and trying to add a new node to it")

                -- append the first line of the current node to the last line of the previous one
                local gap = " " -- for now it'll be just a single space, but this needs to be calculated somehow
                previous_node_as_str = previous_node_as_str .. gap .. stringified_node_lines[1]
                nodes_as_str_table[#nodes_as_str_table] = previous_node_as_str

                -- remove the first line of the current node
                table.remove(stringified_node_lines, 1)
            end

            -- add the node and its end_char to the table, line by line, if there are any lines left
            if #stringified_node_lines > 0 then
                nodes_as_str_table = R.reduce(function(acc, line)
                    table.insert(acc, line)
                    return acc
                end, nodes_as_str_table, stringified_node_lines)
            end
        elseif cnode:is_endchar_node() and not cnode.end_character.is_attached then
            local previous_node_as_str = nodes_as_str_table[#nodes_as_str_table]
            assert(previous_node_as_str ~= nil, "Previous node not found and trying to add a end_character to it")
            assert(idx == #self.nodes, "Trying to add a end_character to a node that is not the last one")
            assert(cnode.end_character ~= nil, "End character not found")

            local str_to_add = cnode.end_character:stringify()
            previous_node_as_str = previous_node_as_str .. str_to_add
            nodes_as_str_table[#nodes_as_str_table] = previous_node_as_str
        end

        -- add vertical gap
        if idx <= #vertical_gaps and vertical_gaps[idx] > 0 then
            for _ = 1, vertical_gaps[idx] do table.insert(nodes_as_str_table, "") end
        end
    end

    return nodes_as_str_table
end

return Chadnodes
