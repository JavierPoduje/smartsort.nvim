local Region = require('region')
local f = require("funcs")

--- @class Chadnode
---
--- @field public previous Chadnode: The previous node works as "attached" to the current node. So, it's not sortable by itself. It's more like a companion to the current node.
--- @field public node TSNode: the node
--- @field public region Region: the region of the node
--- @field public sortable_idx string | nil: the index from which the node can be sorted
--- @field public end_character string | nil: the end character of the node
---
--- @field public debug fun(self: Chadnode, bufnr: number, opts: table | nil): table<any>
--- @field public from_query_match fun(query: vim.treesitter.Query, match: table<integer, TSNode>, bufnr: number): Chadnode
--- @field public gap fun(self: Chadnode, other: Chadnode): number
--- @field public get fun(self: Chadnode): TSNode
--- @field public get_sortable_idx fun(self: Chadnode): string
--- @field public has_next_sibling fun(self: Chadnode): boolean
--- @field public is_sortable fun(self: Chadnode): boolean
--- @field public new fun(self:Chadnode, node: TSNode, sortable_idx: string | nil): Chadnode
--- @field public next_sibling fun(self: Chadnode): Chadnode
--- @field public parent_node fun(self: Chadnode): TSNode | nil
--- @field public print fun(self: Chadnode, bufnr: number, opts: table | nil)
--- @field public set_end_character fun(self: Chadnode, character: string)
--- @field public set_previous fun(self: Chadnode, previous_cnode: Chadnode)
--- @field public to_string fun(self: Chadnode, bufnr: number): string
--- @field public to_string_preserve_indent fun(self: Chadnode, bufnr: number, target_row: number): string
--- @field public type fun(self: Chadnode): string

local Chadnode = {}

function Chadnode:new(node, sortable_idx, end_character)
    Chadnode.__index = Chadnode
    local obj = {}
    setmetatable(obj, Chadnode)

    local srow, scol, erow, ecol = node:range()

    obj.end_character = end_character
    obj.node = node
    obj.previous = nil
    obj.region = Region.new(srow, scol, erow, ecol)
    obj.sortable_idx = sortable_idx or nil

    return obj
end

--- Get the parent node of the current node
--- @param self Chadnode: the node
--- @return TSNode | nil: the parent node
Chadnode.parent_node = function(self)
    if self.node == nil then
        return nil
    end
    return self.node:parent()
end

--- Set the end character of the chadnode
--- @param self Chadnode: the node
--- @param character string: the end character
Chadnode.set_end_character = function(self, character)
    self.end_character = character
end

--- Create a new Chadnode from a query match
--- @param query vim.treesitter.Query: the query
--- @param match table<integer, TSNode>: the match
--- @param bufnr number: the buffer number
Chadnode.from_query_match = function(query, match, bufnr)
    -- @type TSNode
    local matched_node = nil
    -- @type string
    local matched_id = nil
    -- @type string
    local end_character = nil

    for id, nodes in pairs(match) do
        local capture_name = query.captures[id]
        if capture_name == "identifier" then
            matched_id = vim.treesitter.get_node_text(nodes[1], bufnr)
        elseif capture_name == "block" then
            matched_node = nodes[1]
        end
    end

    assert(matched_node ~= nil, "The whole node can't be nil")
    assert(matched_id ~= nil, "The identifier can't be nil")

    return Chadnode:new(matched_node, matched_id, end_character)
end

--- Set the previous node
--- @param self Chadnode: the node
--- @param previous_cnode Chadnode: the previous node
Chadnode.set_previous = function(self, previous_cnode)
    self.previous = previous_cnode
end

--- @param self Chadnode
--- @param bufnr number
--- @param opts table | nil
Chadnode.debug = function(self, bufnr, opts)
    opts = opts or {}
    local include_region = opts.include_region or false
    if include_region then
        return {
            node = self:to_string(bufnr),
            sortable_idx = self:get_sortable_idx(),
            previous = self.previous and self.previous:to_string(bufnr) or nil,
            region = self.region:tostr(),
        }
    else
        return {
            node = self:to_string(bufnr),
            sortable_idx = self:get_sortable_idx(),
            previous = self.previous and self.previous:to_string(bufnr) or nil,
        }
    end
end

--- Get the node
--- @param self Chadnode: the node
--- @return TSNode: the node
Chadnode.get = function(self)
    return self.node
end

--- Print the human-readable representation of the current Chadnode
--- @param self Chadnode: the node
--- @param bufnr number: the buffer number
--- @param opts table | nil
Chadnode.print = function(self, bufnr, opts)
    print(vim.inspect(self:debug(bufnr, opts)))
end

--- Return the string representation of a node
--- @param self Chadnode: the node
--- @return string
Chadnode.to_string = function(self, bufnr)
    return vim.treesitter.get_node_text(self.node, bufnr)
end

--- Return the string representation of a node, preserving the indent
--- @param self Chadnode: the node
--- @param bufnr number: the buffer number
--- @param target_row number: the row to insert the node. The node will be indented to match this row's indentation.
--- @return string
Chadnode.to_string_preserve_indent = function(self, bufnr, target_row)
    local text = vim.treesitter.get_node_text(self.node, bufnr)
    local lines = vim.split(text, "\n")

    local original_indent = f.get_line_indent(bufnr, self.region.srow)
    local target_indent = f.get_line_indent(bufnr, target_row)

    -- Adjust indentation for all lines
    local stringified_lines = {}

    if self.previous ~= nil then
        local stringified_comment = self.previous:to_string_preserve_indent(bufnr, self.previous.region.srow)
        table.insert(stringified_lines, stringified_comment)
    end

    for idx, line in ipairs(lines) do
        local relative_indent = line:match("^" .. original_indent .. "(%s*)")

        local is_last_line = idx == #lines
        if is_last_line and self.end_character ~= nil then
            table.insert(stringified_lines,
                target_indent .. (relative_indent or "") .. line:gsub("^%s*", "") .. self.end_character)
        else
            table.insert(stringified_lines, target_indent .. (relative_indent or "") .. line:gsub("^%s*", ""))
        end
    end

    return table.concat(stringified_lines, "\n")
end

--- Return the node's sortable index
--- @param self Chadnode: the node
--- @return string
Chadnode.get_sortable_idx = function(self)
    return self.sortable_idx or ''
end

--- Get the next `Chadnode` sibling
--- @param self Chadnode: the node
--- @return Chadnode: the next sibling
Chadnode.next_sibling = function(self)
    local next_sibling = self.node:next_sibling()
    assert(next_sibling ~= nil, "The node has no next sibling")
    local new_chad_node = Chadnode:new(next_sibling, nil)
    return new_chad_node
end

--- Calculate the vertical gap between two nodes, where the gap is the number of rows between them.
--- @param self Chadnode: the first node
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    assert(self.region.erow <= other.region.srow, "Node 1 is not before Node 2 or they're overlaping")

    if self.region.erow == other.region.srow then
        return 0
    end

    -- If the other node has a comment node, we need to compare the other node's comment node to
    -- get the empty spaces
    while other.previous ~= nil do
        other = other.previous
    end

    return other.region.srow - self.region.erow - 1
end

--- Check if the node has a next sibling
--- @param self Chadnode: the node
--- @return boolean: whether the node has a next sibling
Chadnode.has_next_sibling = function(self)
    return self.node:next_sibling() ~= nil
end

--- Return tru if the node is sortable, false otherwise.
--- @param self Chadnode: the node
--- @return boolean: whether the node is sortable
Chadnode.is_sortable = function(self)
    return self.sortable_idx ~= nil
end

--- return the type of the chadnode
--- @param self Chadnode: the node
--- @return string
Chadnode.type = function(self)
    return self.node:type()
end

return Chadnode
