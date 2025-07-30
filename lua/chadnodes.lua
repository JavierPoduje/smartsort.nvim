local Chadnode = require("chadnode")
local Chadquery = require("chadquery")
local FileManager = require("file_manager")
local R = require("ramda")
local Region = require("region")
local f = require("funcs")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class Chadnodes
---
--- @field public container_node TSNode
--- @field public nodes Chadnode[]
--- @field public parser vim.treesitter.LanguageTree
---
--- @field public __tostring fun(self: Chadnodes): string
--- @field public add fun(self: Chadnodes, chadnode: Chadnode): self
--- @field public calculate_horizontal_gaps fun(self: Chadnodes): (number | nil)[]
--- @field public calculate_left_indentation_by_idx fun(self: Chadnodes): boolean[]
--- @field public calculate_vertical_gaps fun(self: Chadnodes): number[]
--- @field public cnode_is_sortable_by_idx fun(self): table<string, boolean>
--- @field public debug fun(self: Chadnodes, bufnr: number, opts: table | nil): table<any>
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public get_non_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public get_sortable_nodes fun(self: Chadnodes): Chadnode[]
--- @field public merge_sortable_nodes_with_adjacent_linkable_nodes fun(self: Chadnodes, region: Region, vertical_gaps?: number[]): Chadnodes
--- @field public new fun(self: Chadnodes, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public print fun(self: Chadnodes)
--- @field public sort fun(self: Chadnodes, config: SmartsortSetup): Chadnodes
--- @field public sort_sortable_nodes fun(self: Chadnodes, cnodes: Chadnode[]): Chadnodes
--- @field public stringified_cnodes fun(self: Chadnodes): string[]
--- @field public stringify_into_table fun(self: Chadnodes, vertical_gaps: number[], horizontal_gaps: number[], should_have_left_indentation_by_idx: boolean[]): string[]
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

--- Return a string representation of the Chadnodes
--- @param self Chadnodes
--- @return string
Chadnodes.__tostring = function(self)
    local output = ""
    for _, node in ipairs(self.nodes) do
        output = output .. tostring(node) .. "\n"
    end
    return output
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

--- Get the vertical gaps between the nodes. Each gap contains the distance between current
--- node at `n` and the previous node at `n-1`. It'll always have a length of `#nodes - 1`.
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

--- Get the horizontal gaps between the nodes. It'll always have a length of `#nodes - 1`.
--- @param self Chadnodes
--- @return (number | nil)[]
Chadnodes.calculate_horizontal_gaps = function(self)
    --- @type { previous_cnode: Chadnode | nil, gaps: (number | nil)[] }
    local acc = R.reduce(function(acc, cnode, idx)
        local previous_cnode, gaps = acc.previous_cnode, acc.gaps

        if idx == 1 then
            previous_cnode = cnode
        else
            assert(previous_cnode ~= nil, "Previous Chadnode not found")

            local vertical_gap = previous_cnode:calculate_vertical_gap(cnode)
            if vertical_gap == -1 then
                table.insert(gaps, previous_cnode:calculate_horizontal_gap(cnode))
            else
                table.insert(gaps, -1)
            end

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
    --- @type TSNode | nil
    local node = FileManager.get_node_at_row(bufnr, region, parser)
    if not node then
        error("No node found at the given region")
    end

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
--- @param vertical_gaps? number[]: the vertical gaps between the nodes
--- @return Chadnodes
Chadnodes.merge_sortable_nodes_with_adjacent_linkable_nodes = function(self, region, vertical_gaps)
    local chadquery = Chadquery:new(self.parser:lang(), { region = region })
    local cnodes = Chadnodes:new(self.parser)
    if not vertical_gaps then
        vertical_gaps = self:calculate_vertical_gaps()
    end

    for idx = 1, #vertical_gaps + 1 do
        local current_node = self:node_by_idx(idx)
        assert(current_node ~= nil, "Chadnode not found")

        local is_last_node = idx == #vertical_gaps + 1
        if is_last_node then
            if chadquery:is_special_end_char(current_node:type()) then
                local end_char = current_node.end_character
                local prev_node = self:node_by_idx(idx - 1)

                if prev_node ~= nil and end_char ~= nil then
                    if end_char.is_attached then
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
        local vertical_gap = vertical_gaps[idx]

        if vertical_gap == 0 and end_char ~= nil and prev_node ~= nil and end_char.is_attached then
            prev_node:add_attached_suffix_cnode(current_node)
        elseif vertical_gap <= 0 and chadquery:is_linkable(current_node:type()) and next_node ~= nil then
            next_node:add_attached_prefix_cnode(current_node)
        elseif chadquery:is_special_end_char(current_node:type()) and prev_node ~= nil then
            if current_node.end_character.is_attached then
                prev_node:add_attached_suffix_cnode(current_node)
            else
                cnodes:add(current_node)
            end
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
Chadnodes.print = function(self)
    print(vim.inspect(self:stringified_cnodes()))
end

--- Returns a list of strings where each item is the string representation of a `Chadnode`.
---
--- @param self Chadnodes
--- @return string[]
Chadnodes.stringified_cnodes = function(self)
    local output = {}
    for _, cnode in ipairs(self.nodes) do
        table.insert(output, cnode:__tostring())
    end
    return output
end

--- Returns a new `Chadnodes` object with the nodes sorted
--- @param self Chadnodes
--- @param config SmartsortSetup
--- @return Chadnodes
Chadnodes.sort = function(self, config)
    local non_sortables = self:get_non_sortable_nodes()
    local sortables = Chadnodes:sort_sortable_nodes(self:get_sortable_nodes())
    local output = Chadnodes:new(self.parser)

    if config.non_sortable_behavior == "preserve" then
        --- @type number
        local sortable_idx = 1
        --- @type number
        local non_sortable_idx = 1
        for _, is_sortable in pairs(self:cnode_is_sortable_by_idx()) do
            if is_sortable then
                local cnode = sortables:node_by_idx(sortable_idx)
                assert(cnode ~= nil, "Chadnode not found")
                output:add(cnode)
                sortable_idx = sortable_idx + 1
            else
                local cnode = non_sortables[non_sortable_idx]
                assert(cnode ~= nil, "Chadnode not found")
                output:add(cnode)
                non_sortable_idx = non_sortable_idx + 1
            end
        end
    elseif config.non_sortable_behavior == "above" then
        for _, cnode in ipairs(non_sortables) do output:add(cnode) end
        for _, cnode in ipairs(sortables.nodes) do output:add(cnode) end
    elseif config.non_sortable_behavior == "below" then
        for _, cnode in ipairs(sortables.nodes) do output:add(cnode) end
        for _, cnode in ipairs(non_sortables) do output:add(cnode) end
    end

    return output
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

Chadnodes.calculate_left_indentation_by_idx = function(self)
    return R.reduce(function(acc, cnode, idx)
        acc[idx] = cnode:is_first_node_in_row()
        return acc
    end, {}, self.nodes)
end

--- Return a list of strings where each item is a line of the string representation of the nodes.
--- @param self Chadnodes
--- @param vertical_gaps number[]: the vertical gaps between the nodes
--- @param horizontal_gaps number[]: the horizontal gaps between the nodes
--- @param should_have_left_indentation_by_idx boolean[]: table indicating if the node should have left indentation
--- @return string[]: the string representation of the nodes
Chadnodes.stringify_into_table = function(self, vertical_gaps, horizontal_gaps, should_have_left_indentation_by_idx)
    local nodes_as_str_table = {}

    for idx, cnode in ipairs(self.nodes) do
        if not cnode:is_endchar_node() then
            local has_left_indentation = should_have_left_indentation_by_idx[idx]

            local cnode_str = cnode:stringify(0, cnode.region.srow, not has_left_indentation)
            local endchar_as_str = cnode:stringify_first_suffix()
            local stringified_node_lines = vim.fn.split(cnode_str .. endchar_as_str, "\n")

            -- if the current node is in the same line of the previous node:
            -- 1. copy the first line of the current node and put it in the last line of the previous one
            -- 2. remove the first line of the current node, because it was added to the previous one
            local is_in_previous_node_line = idx > 1 and (idx - 1) <= #vertical_gaps and vertical_gaps[idx - 1] == -1
            local previous_node_exists = #nodes_as_str_table > 0
            local start_from_previous_node = is_in_previous_node_line and previous_node_exists and
                not has_left_indentation
            if start_from_previous_node then
                assert(R.last(nodes_as_str_table) ~= nil, "Previous node not found and trying to add a new node to it")

                -- append the first line of the current node to the last line of the previous one
                local gap = ""
                if horizontal_gaps[idx - 1] > 0 then
                    gap = string.rep(" ", horizontal_gaps[idx - 1])
                end

                nodes_as_str_table = f.replace_last_item(
                    nodes_as_str_table,
                    R.last(nodes_as_str_table) .. gap .. stringified_node_lines[1]
                )

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
            assert(R.last(nodes_as_str_table) ~= nil, "Previous node not found and trying to add a end_character to it")
            assert(idx == #self.nodes, "Trying to add a end_character to a node that is not the last one")
            assert(cnode.end_character ~= nil, "End character not found")

            nodes_as_str_table = f.replace_last_item(
                nodes_as_str_table,
                R.last(nodes_as_str_table) .. cnode.end_character:stringify()
            )
        end

        -- add vertical gap between the current node and the next one
        local last_node_exists = R.last(nodes_as_str_table) ~= nil
        local theres_a_horizontal_gap_to_add = idx > 1 and horizontal_gaps[idx - 1] ~= nil and
            horizontal_gaps[idx - 1] > 0

        if vertical_gaps[idx] ~= nil and vertical_gaps[idx] > 0 then
            for _ = 1, vertical_gaps[idx] do
                table.insert(nodes_as_str_table, "")
            end
        elseif last_node_exists and theres_a_horizontal_gap_to_add then
            nodes_as_str_table = f.replace_last_item(
                nodes_as_str_table,
                R.last(nodes_as_str_table) .. string.rep(" ", horizontal_gaps[idx - 1])
            )
        end
    end

    return nodes_as_str_table
end

return Chadnodes
