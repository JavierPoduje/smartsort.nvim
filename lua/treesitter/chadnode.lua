local Region = require('region')
local f = require("funcs")

--- @class Chadnode
---
--- @field public comment_node Chadnode: the comment node. This is used to store the comment node that belongs to the node
--- @field public node TSNode: the node
--- @field public region Region: the region of the node
--- @field public sortable_idx string | nil: the index from which the node can be sorted
---
--- @field public debug fun(self: Chadnode, bufnr: number): table<any>
--- @field public set_comment fun(self: Chadnode, comment: Chadnode)
--- @field public gap fun(self: Chadnode, other: Chadnode): number
--- @field public get fun(self: Chadnode): TSNode
--- @field public next_sibling fun(self: Chadnode): Chadnode
--- @field public get_sortable_idx fun(self: Chadnode): string
--- @field public has_next_sibling fun(self: Chadnode): boolean
--- @field public is_sortable fun(self: Chadnode): boolean
--- @field public new fun(node: TSNode, sortable_idx: string | nil): Chadnode
--- @field public print fun(self: Chadnode, bufnr: number)
--- @field public to_string fun(self: Chadnode, bufnr: number): string
--- @field public to_string_preserve_indent fun(self: Chadnode, bufnr: number, target_row: number): string

local Chadnode = {}
Chadnode.__index = Chadnode

--- Create a new Chadnode
--- @param node TSNode: the node
--- @param sortable_idx string | nil: the index from which the node can be sorted
function Chadnode.new(node, sortable_idx)
    local self = setmetatable({}, Chadnode)

    assert(node ~= nil, "Can't create a Chadnode from this nil POS")

    local srow, scol, erow, ecol = node:range()

    self.comment_node = nil
    self.node = node
    self.region = Region.new(srow, scol, erow, ecol)
    self.sortable_idx = sortable_idx or nil
    return self
end

--- Set the comment node
--- @param self Chadnode: the node
--- @param comment Chadnode: the comment node
Chadnode.set_comment = function(self, comment)
    self.comment_node = comment
end

--- @param self Chadnode
--- @param bufnr number
Chadnode.debug = function(self, bufnr)
    return {
        node = self:to_string(bufnr),
        sortable_idx = self:get_sortable_idx(),
        comment_node = self.comment_node and self.comment_node:to_string(bufnr) or nil
    }
end

--- Print the human-readable representation of the current Chadnode
--- @param self Chadnode: the node
--- @param bufnr number: the buffer number
Chadnode.print = function(self, bufnr)
    print(vim.inspect(self:debug(bufnr)))
end

--- Get the node
--- @param self Chadnode: the node
--- @return TSNode: the node
Chadnode.get = function(self)
    return self.node
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
    local indented_lines = {}

    if self.comment_node ~= nil then
        indented_lines[1] = self.comment_node:to_string_preserve_indent(bufnr, self.comment_node.region.srow)
    end

    local first_line = f.if_else(
        self.comment_node == nil,
        function() return 1 end,
        function() return 2 end
    )
    for i, line in ipairs(lines) do
        if i == first_line then
            -- First line gets target indentation
            table.insert(indented_lines, target_indent .. line:gsub("^%s*", ""))
        else
            -- Subsequent lines maintain relative indentation
            local relative_indent = line:match("^" .. original_indent .. "(%s*)")
            table.insert(indented_lines, target_indent .. (relative_indent or "") .. line:gsub("^%s*", ""))
        end
    end

    return table.concat(indented_lines, "\n")
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
    local new_chad_node = Chadnode.new(next_sibling, nil)
    return new_chad_node
end

--- Calculate the "gap" between two nodes, where the gap is the number of rows between them.
--- @param self Chadnode: the first node
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    assert(self.region.erow < other.region.srow, "Node 1 is not before Node 2 or they're overlaping")
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

return Chadnode
