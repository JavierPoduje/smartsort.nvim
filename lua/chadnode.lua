local Region = require('region')
local f = require("funcs")

-- @field public [x] end_character EndChar: The end character of the node.
-- @field public [x] attached_suffix_cnode Chadnode | nil: The node used to handle/represent the end_character if it exists and EndChar.is_attached is true.
-- @field public [] ts_node TSNode: The primary Tree-sitter syntax node.
-- @field public [wip] attached_prefix_node Chadnode | nil: A node that is attached to and precedes the current node, considered a companion for sorting and processing.
-- @field public [] region Region: The source code region of the node.
-- @field public [] sort_key string | nil: The key used for sorting this node.

--- @class Chadnode
---
--- @field public end_character EndChar: the end character of the node.
--- @field public attached_suffix_cnode Chadnode | nil: The node used to handle/represent the end_character if it exists and EndChar.is_attached is true.
--- @field public node TSNode: the node
--- @field public attached_prefix_cnode Chadnode: A node that is attached to and precedes the current node, considered a companion for sorting and processing.
--- @field public region Region: the region of the node
--- @field public sortable_idx string | nil: the index from which the node can be sorted
---
--- @field public calculate_horizontal_gap fun(self: Chadnode, other: Chadnode): number
--- @field public calculate_vertical_gap fun(self: Chadnode, other: Chadnode): number
--- @field public debug fun(self: Chadnode, bufnr: number, opts: table | nil): table<any>
--- @field public from_query_match fun(query: vim.treesitter.Query, match: table<integer, TSNode>, bufnr: number): Chadnode
--- @field public get fun(self: Chadnode): TSNode
--- @field public get_sortable_idx fun(self: Chadnode): string
--- @field public has_next_sibling fun(self: Chadnode): boolean
--- @field public is_endchar_node fun(self: Chadnode): boolean
--- @field public is_sortable fun(self: Chadnode): boolean
--- @field public new fun(self:Chadnode, node: TSNode, sortable_idx: string | nil): Chadnode
--- @field public parent_node fun(self: Chadnode): TSNode | nil
--- @field public print fun(self: Chadnode, bufnr: number, opts: table | nil)
--- @field public set_attached_prefix_cnode fun(self: Chadnode, attached_prefix_cnode: Chadnode)
--- @field public set_attached_suffix_cnode fun(self: Chadnode, attached_suffix_cnode: Chadnode)
--- @field public set_end_character fun(self: Chadnode, character: EndChar)
--- @field public stringify fun(self: Chadnode, bufnr: number, target_row: number): string
--- @field public to_string fun(self: Chadnode, bufnr: number): string
--- @field public type fun(self: Chadnode): string

local Chadnode = {}

function Chadnode:new(node, sortable_idx)
    Chadnode.__index = Chadnode
    local obj = {}
    setmetatable(obj, Chadnode)

    local srow, scol, erow, ecol = node:range()

    obj.end_character = nil
    obj.attached_suffix_cnode = nil
    obj.node = node
    obj.attached_prefix_cnode = nil
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
--- @param character EndChar: the end character
Chadnode.set_end_character = function(self, character)
    self.end_character = character
end

--- Create a new Chadnode from a query match
--- @param query vim.treesitter.Query: the query
--- @param match table<integer, TSNode>: the match
--- @param bufnr number: the buffer number
Chadnode.from_query_match = function(query, match, bufnr)
    --- @type TSNode
    local matched_node = nil
    --- @type string
    local matched_id = nil

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

    return Chadnode:new(matched_node, matched_id)
end

--- Set the attached_suffix_cnode node
--- @param self Chadnode: the node
--- @param attached_suffix_cnode Chadnode: the attached_suffix_cnode node
Chadnode.set_attached_suffix_cnode = function(self, attached_suffix_cnode)
    self.attached_suffix_cnode = attached_suffix_cnode
end

--- Set the previous node
--- @param self Chadnode: the node
--- @param attached_prefix_cnode Chadnode: the attached_prefix_cnode node
Chadnode.set_attached_prefix_cnode = function(self, attached_prefix_cnode)
    self.attached_prefix_cnode = attached_prefix_cnode
end

--- @param self Chadnode
--- @param bufnr number
--- @param opts table | nil
Chadnode.debug = function(self, bufnr, opts)
    opts = opts or {}

    local include_region = opts.include_region or false
    local include_end_char = opts.include_end_char or false
    local include_attached_suffix_cnode = opts.include_attached_suffix_cnode or false

    local output = {
        node = self:to_string(bufnr),
        sortable_idx = self:get_sortable_idx(),
        attached_prefix_cnode = self.attached_prefix_cnode and self.attached_prefix_cnode:to_string(bufnr) or nil,
    }

    if include_region then
        output = f.merge_tables(output, { region = self.region:tostr() })
    end

    if include_end_char then
        output = f.merge_tables(output, { end_char = vim.inspect(self.end_character) })
    end

    if include_attached_suffix_cnode and self.attached_suffix_cnode ~= nil then
        output = f.merge_tables(output, { attached_suffix_cnode = self.attached_suffix_cnode:to_string(bufnr) })
    end

    return output
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
Chadnode.stringify = function(self, bufnr, target_row)
    local text = vim.treesitter.get_node_text(self.node, bufnr)
    local lines = vim.split(text, "\n")

    local original_indent = f.get_line_indent(bufnr, self.region.srow)
    local target_indent = f.get_line_indent(bufnr, target_row)

    -- Adjust indentation for all lines
    local stringified_lines = {}

    if self.attached_prefix_cnode ~= nil then
        local stringified_comment = self.attached_prefix_cnode:stringify(bufnr, self.attached_prefix_cnode.region.srow)
        table.insert(stringified_lines, stringified_comment)
    end

    for _, line in ipairs(lines) do
        local relative_indent = line:match("^" .. original_indent .. "(%s*)")
        local relative_indent_str = relative_indent or ""
        table.insert(stringified_lines, target_indent .. relative_indent_str .. line:gsub("^%s*", ""))
    end

    return table.concat(stringified_lines, "\n")
end

--- Return the node's sortable index
--- @param self Chadnode: the node
--- @return string
Chadnode.get_sortable_idx = function(self)
    return self.sortable_idx or ''
end

--- Calculate the horizontal gap between two nodes, where the gap is the number of columns between them.
--- @param self Chadnode: the first node
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.calculate_horizontal_gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    return other.region.scol - self.region.ecol
end

--- TODO: change this function to `calculate_vertical_gap` to avoid confusion with `horizontal_gap`
--- Calculate the vertical gap between two nodes, where the gap is the number of rows between them.
--- @param self Chadnode: the first node
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.calculate_vertical_gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    assert(self.region.erow <= other.region.srow, "Node 1 is not before Node 2 or they're overlaping")

    -- If the other node has a comment node, we need to compare the other node's comment node to
    -- get the empty spaces
    while other.attached_prefix_cnode ~= nil do
        other = other.attached_prefix_cnode
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

--- Return true if the cnode is a end_char node, false otherwise.
--- @param self Chadnode
Chadnode.is_endchar_node = function(self)
    return self.end_character ~= nil
end

--- return the type of the chadnode
--- @param self Chadnode: the node
--- @return string
Chadnode.type = function(self)
    return self.node:type()
end

return Chadnode
