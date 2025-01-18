local Chadnode = require("treesitter.chadnode")
local f = require("funcs")
local Region = require("region")
local queries = require("treesitter.queries")
local ts_utils = require("nvim-treesitter.ts_utils")

--- @class Chadnodes
--- @field public nodes Chadnode[]
--- @field public add fun(self: Chadnodes, chadnode: Chadnode)
--- @field public from_region fun(bufnr: number, region: Region, parser: vim.treesitter.LanguageTree): Chadnodes
--- @field public node_by_idx fun(self: Chadnodes, idx: number): Chadnode | nil
--- @field public get fun(self: Chadnodes): Chadnode[]
--- @field public debug fun(self: Chadnodes)

local Chadnodes = {}
Chadnodes.__index = Chadnodes

--- Create a new Chadnodes
Chadnodes.new = function()
    local self = setmetatable({}, Chadnodes)
    self.nodes = {}
    return self
end

Chadnodes.debug = function(self)
    print(vim.inspect(self.nodes))
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

--- @param bufnr number: the buffer number
--- @param region Region: the region to get the nodes from
--- @param parser vim.treesitter.LanguageTree
--- @return Chadnodes
Chadnodes.from_region = function(bufnr, region, parser)
    local node = ts_utils.get_node_at_cursor()
    assert(node ~= nil, "No node found")

    --- @type Chadnodes
    local cnodes = Chadnodes.new()

    while node ~= nil do
        local match_found = false

        -- if the node is after the last line of the visually-selected area, stop
        if region.erow < Region.from_node(node).erow - 1 then
            break
        end

        local query = queries.functions_query(parser:lang())

        for _, matches in query:iter_matches(node, bufnr) do
            match_found = true
            local cnode = Chadnode.new(f.get_node(matches), f.get_function_name(matches))

            cnodes:add(cnode)

            if not cnode:has_next_sibling() then
                break
            end
        end

        if not match_found then
            local cnode = Chadnode.new(node, nil)
            cnodes:add(cnode)
        end

        node = node:next_sibling()
    end

    return cnodes
end


return Chadnodes
