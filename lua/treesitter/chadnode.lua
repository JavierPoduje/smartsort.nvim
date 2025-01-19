local Region = require('region')

--- @class Chadnode
---
--- @field public node TSNode: the node
--- @field public sortable_idx string | nil: the index from which the node can be sorted
--- @field public range Region: the region of the node
---
--- @field public debug fun(self: Chadnode, bufnr: number): table<any>
--- @field public gap fun(self: Chadnode, other: Chadnode): number
--- @field public get fun(self: Chadnode): TSNode
--- @field public get_next_sibling fun(self: Chadnode): Chadnode
--- @field public get_sortable_idx fun(self: Chadnode): string
--- @field public new fun(node: TSNode, sortable_idx: string | nil): Chadnode
--- @field public to_string fun(self: Chadnode, bufnr: number): string

local Chadnode = {}
Chadnode.__index = Chadnode

--- Create a new Chadnode
--- @param node TSNode: the node
--- @param sortable_idx string | nil: the index from which the node can be sorted
function Chadnode.new(node, sortable_idx)
    local self = setmetatable({}, Chadnode)

    assert(node ~= nil, "Can't create a Chadnode from this nil POS")

    local srow, scol, erow, ecol = node:range()

    self.node = node
    self.sortable_idx = sortable_idx or nil
    self.range = Region.new(srow, scol, erow, ecol)
    return self
end

--- @param self Chadnode
--- @param bufnr number
Chadnode.debug = function(self, bufnr)
    return {
        node = self:to_string(bufnr),
        sortable_idx = self:get_sortable_idx()
    }
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

--- Return the node's sortable index
--- @param self Chadnode: the node
--- @return string
Chadnode.get_sortable_idx = function(self)
    return self.sortable_idx or ''
end

--- Get the next `Chadnode` sibling
--- @param self Chadnode: the node
--- @return Chadnode: the next sibling
Chadnode.get_next_sibling = function(self)
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
    assert(self.range.erow < other.range.srow, "Node 1 is not before Node 2 or they're overlaping")
    return other.range.srow - self.range.erow - 1
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
