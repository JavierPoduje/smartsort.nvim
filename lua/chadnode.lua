local R = require('ramda')
local Region = require('region')
local f = require("funcs")

--- @class Chadnode
---
--- @field public attached_prefix_cnodes Chadnode[]: Nodes that are attached to and precedes the current node, considered a companion for sorting and processing.
--- @field public attached_suffix_cnodes Chadnode[]: Nodes used to handle/represent the end_character if it exists and EndChar.is_attached is true.
--- @field public end_character EndChar: The end character properties of the node, if the node itself is an end-character.
--- @field public region Region: The source code region of the node.
--- @field public sort_key string | nil: The key used for sorting this node.
--- @field public ts_node TSNode: The primary Tree-sitter syntax node.
---
--- @field public __tostring fun(self: Chadnode): string
--- @field public add_attached_prefix_cnode fun(self: Chadnode, attached_prefix_cnode: Chadnode)
--- @field public add_attached_suffix_cnode fun(self: Chadnode, attached_suffix_cnode: Chadnode)
--- @field public calculate_horizontal_gap fun(self: Chadnode, other: Chadnode): number
--- @field public calculate_vertical_gap fun(self: Chadnode, other: Chadnode): number
--- @field public debug fun(self: Chadnode, bufnr: number, opts: table | nil): table<any>
--- @field public from_query_match fun(query: vim.treesitter.Query, match: table<integer, TSNode>, bufnr: number): Chadnode
--- @field public get fun(self: Chadnode): TSNode
--- @field public get_sort_key fun(self: Chadnode): string
--- @field public has_next_sibling fun(self: Chadnode): boolean
--- @field public is_endchar_node fun(self: Chadnode): boolean
--- @field public is_first_node_in_row fun(self: Chadnode): boolean
--- @field public is_sortable fun(self: Chadnode): boolean
--- @field public new fun(self:Chadnode, node: TSNode, sort_key: string | nil): Chadnode
--- @field public parent_node fun(self: Chadnode): TSNode | nil
--- @field public print fun(self: Chadnode, bufnr: number, opts: table | nil)
--- @field public set_end_character fun(self: Chadnode, character: EndChar)
--- @field public stringify fun(self: Chadnode, bufnr: number, target_row: number, trim: boolean): string
--- @field public stringify_first_suffix fun(self: Chadnode): string
--- @field public to_string fun(self: Chadnode, bufnr: number): string
--- @field public type fun(self: Chadnode): string

local Chadnode = {}

function Chadnode:new(node, sort_key)
    Chadnode.__index = Chadnode
    local obj = {}
    setmetatable(obj, Chadnode)

    obj.attached_prefix_cnodes = {}
    obj.attached_suffix_cnodes = {}

    obj.end_character = nil
    obj.region = Region.new(node:range())
    obj.sort_key = sort_key or nil
    obj.ts_node = node

    return obj
end

--- Calculate the horizontal gap between two nodes, where the gap is the number of columns between them.
--- @param self Chadnode
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.calculate_horizontal_gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    return other.region.scol - self.region.ecol
end

--- Return the string representation of the Chadnode, including its end character if it exists.
---
--- @param self Chadnode
--- @return string
Chadnode.__tostring = function(self)
    local cnode_str = self:stringify(0, self.region.srow, false)

    if self:is_endchar_node() then
        return cnode_str
    end

    local endchar_as_str = f.if_else(
        #self.attached_suffix_cnodes > 0 and self.attached_suffix_cnodes[1].end_character ~= nil,
        function() return self.attached_suffix_cnodes[1].end_character:stringify() end,
        function() return "" end
    )
    return cnode_str .. endchar_as_str
end

--- Calculate the vertical gap between two nodes, where the gap is the number of rows between them.
--- @param self Chadnode: the first node
--- @param other Chadnode: the second node
--- @return number: the gap between the two nodes
Chadnode.calculate_vertical_gap = function(self, other)
    assert(other ~= nil, "The given node can't be nil")
    assert(self.region.erow <= other.region.srow, "Node 1 is not before Node 2")

    -- If the other node has a comment node, we need to compare the other node's comment node to
    -- get the empty spaces
    local idx = 1
    while #other.attached_prefix_cnodes > 0 and other.attached_prefix_cnodes[idx] ~= nil do
        other = other.attached_prefix_cnodes[idx]
        idx = idx + 1
    end

    return other.region.srow - self.region.erow - 1
end

--- @param self Chadnode
--- @param bufnr number
--- @param opts table | nil
Chadnode.debug = function(self, bufnr, opts)
    opts = opts or {}

    local include_end_char = opts.include_end_char or false
    local include_region = opts.include_region or false
    local include_attached_suffix_cnodes = opts.include_attached_suffix_cnodes or false

    local output = {
        ts_node = self:to_string(bufnr),
        sort_key = self:get_sort_key(),
    }

    if #self.attached_prefix_cnodes > 0 then
        output = f.merge_tables(output, {
            attached_prefix_cnode = self.attached_prefix_cnodes[1]:to_string(bufnr),
        })
    end

    if include_region then
        output = f.merge_tables(output, {
            region = self.region,
        })
    end

    if include_end_char then
        output = f.merge_tables(output, {
            end_char = vim.inspect(self.end_character:debug()),
        })
    end

    if include_attached_suffix_cnodes and #self.attached_suffix_cnodes > 0 then
        output = f.merge_tables(output, {
            attached_suffix_cnodes = R.reduce(function(acc, cnode)
                table.insert(acc, cnode:debug(bufnr, opts))
                return acc
            end, {}, self.attached_suffix_cnodes),
        })
    end

    return output
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

--- Get the ts_node
--- @param self Chadnode
--- @return TSNode: the node
Chadnode.get = function(self)
    return self.ts_node
end

--- Return the node's sortable index
--- @param self Chadnode: the node
--- @return string
Chadnode.get_sort_key = function(self)
    return self.sort_key or ''
end

--- Check if the node has a next sibling
--- @param self Chadnode
--- @return boolean: whether the node has a next sibling
Chadnode.has_next_sibling = function(self)
    return self.ts_node:next_sibling() ~= nil
end

--- Return true if the cnode is a end_char node, false otherwise.
--- @param self Chadnode
Chadnode.is_endchar_node = function(self)
    return self.end_character ~= nil
end

--- Return true if the node is sortable, false otherwise.
--- @param self Chadnode: the node
--- @return boolean: whether the node is sortable
Chadnode.is_sortable = function(self)
    return self.sort_key ~= nil
end

--- Get the parent node of the current node
--- @param self Chadnode
--- @return TSNode | nil: the parent node
Chadnode.parent_node = function(self)
    if self.ts_node == nil then
        return nil
    end
    return self.ts_node:parent()
end

--- Print the human-readable representation of the current Chadnode
--- @param self Chadnode
--- @param bufnr number: the buffer number
--- @param opts table | nil
Chadnode.print = function(self, bufnr, opts)
    print(vim.inspect(self:debug(bufnr, opts)))
end

--- Add an attached_prefix_cnode node
--- @param self Chadnode: the node
--- @param prefix_cnode_to_attach Chadnode: the attached_prefix_cnode node
Chadnode.add_attached_prefix_cnode = function(self, prefix_cnode_to_attach)
    table.insert(self.attached_prefix_cnodes, prefix_cnode_to_attach)
end

--- Add an attached_suffix_cnode node
--- @param self Chadnode: the node
--- @param suffix_cnode_to_attach Chadnode
Chadnode.add_attached_suffix_cnode = function(self, suffix_cnode_to_attach)
    table.insert(self.attached_suffix_cnodes, suffix_cnode_to_attach)
end

--- Set the end character of the chadnode
--- @param self Chadnode: the node
--- @param character EndChar: the end character
Chadnode.set_end_character = function(self, character)
    self.end_character = character
end

--- Check if the current node is the first node in its row
---
--- @param self Chadnode: the node
--- @return boolean: true if the node is the first node in its row, false otherwise
Chadnode.is_first_node_in_row = function(self)
    local tsnode = self.ts_node
    local srow, scol = tsnode:start()

    if scol == 0 then
        return true
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1]

    if line == nil then
        return false
    end

    local prefix = string.sub(line, 1, scol)

    return prefix:match("^%s*$") ~= nil
end

--- Return the string representation of a node, preserving the indent
--- @param self Chadnode
--- @param bufnr number: the buffer number
--- @param target_row number: the row to insert the node. The node will be indented to match this row's indentation.
--- @param trim boolean: whether to trim the leading whitespace from each line
--- @return string
Chadnode.stringify = function(self, bufnr, target_row, trim)
    trim = trim or false

    local text = vim.treesitter.get_node_text(self.ts_node, bufnr)
    local lines = vim.split(text, "\n")

    local original_indent = f.get_line_indent(bufnr, self.region.srow)
    local target_indent = f.get_line_indent(bufnr, target_row)

    -- Adjust indentation for all lines
    local stringified_lines = {}

    local idx = 1
    while #self.attached_prefix_cnodes > 0 and self.attached_prefix_cnodes[idx] ~= nil do
        local prefix_cnode = self.attached_prefix_cnodes[idx]
        local stringified_comment = prefix_cnode:stringify(bufnr, prefix_cnode.region.srow, trim)
        table.insert(stringified_lines, stringified_comment)
        idx = idx + 1
    end

    for _, line in ipairs(lines) do
        local relative_indent = line:match("^" .. original_indent .. "(%s*)")
        local relative_indent_str = relative_indent or ""
        local identation_str = f.if_else(
            trim,
            function() return "" end,
            function() return target_indent .. relative_indent_str end
        )
        table.insert(stringified_lines, identation_str .. line:gsub("^%s*", ""))
    end

    return table.concat(stringified_lines, "\n")
end

Chadnode.stringify_first_suffix = function(self)
    return f.if_else(
        #self.attached_suffix_cnodes > 0 and self.attached_suffix_cnodes[1].end_character ~= nil,
        function() return self.attached_suffix_cnodes[1].end_character:stringify() end,
        function() return "" end
    )
end

--- Return the string representation of a node
--- @param self Chadnode
--- @return string
Chadnode.to_string = function(self, bufnr)
    return vim.treesitter.get_node_text(self.ts_node, bufnr)
end

--- return the type of the chadnode
--- @param self Chadnode
--- @return string
Chadnode.type = function(self)
    return self.ts_node:type()
end

return Chadnode
