local LanguageQuery = require("treesitter.language_query")

--- @class Chadquery
---
--- @field public language string: the language to query
--- @field public query vim.treesitter.Query: the query
--- @field public language_query LanguageQuery: the language query
---
--- @field public build_query fun(self: Chadquery, node: TSNode): vim.treesitter.Query
--- @field public is_linkable fun(self: Chadquery, node_type: string): boolean
--- @field public is_supported_node_type fun(self: Chadquery, node: TSNode): boolean
--- @field public new fun(language: string): Chadquery
--- @field public sort_and_non_sortable_nodes fun(): table

local Chadquery = {}

--- @param language string: the language to query from
--- @param region Region: the region to query from
--- @return Chadquery: a new Chadquery object
function Chadquery:new(language, region)
    Chadquery.__index = Chadquery
    local obj = {}
    setmetatable(obj, Chadquery)

    assert(
        language == "css" or
        language == "lua" or
        language == "scss" or
        language == "typescript" or
        language == "vue",
        "Unsupported language: " .. language
    )

    obj.language = language
    if language == "vue" then
        local embedded_language = Chadquery:_get_language_to_work_with(region)
        obj.language = embedded_language
        obj.language_query = LanguageQuery:new(embedded_language)
    end

    return obj
end

--- Return a new Query object from the given land and node
--- @param self Chadquery
--- @param node TSNode: the node
--- @return vim.treesitter.Query: the query
Chadquery.build_query = function(self, node)
    assert(
        self.language == "css" or
        self.language == "lua" or
        self.language == "scss" or
        self.language == "typescript" or
        self.language == "vue",
        "Unsupported language: " .. self.language
    )
    local query_str = self.language_query:query_by_node(node)
    assert(query_str ~= nil, "query_str cannot be nil")
    return vim.treesitter.query.parse(self.language, query_str)
end

--- @param self Chadquery
--- @param node_type string: the node type
--- @return boolean: true if the node type can be linked to another sortable node in the given language, false otherwise.
Chadquery.is_linkable = function(self, node_type)
    return self.language_query:is_linkable(node_type)
end

--- Returns true if the node_type is supported by the smartsort.nvim plugin
--- @param self Chadquery
--- @param node TSNode: the node
--- @return boolean
Chadquery.is_supported_node_type = function(self, node)
    return self.language_query:is_supported_node_type(node:type())
end

--- Returns a list of the sortable and non-sortable nodes_types for the given language
--- @param self Chadquery: the Chadquery object
--- @return table: a list of strings representing the sortable and non-sortable nodes
Chadquery.sort_and_non_sortable_nodes = function(self)
    return self.language_query:get_sortable_and_non_sortable_nodes()
end

--- Returns the language that will be used to make queries
--- @param self Chadquery
--- @param region Region: the region to query from
--- @return string: the language to use
Chadquery._get_language_to_work_with = function(self, region)
    --- TODO: implement this function properly
    return "typescript"
end

return Chadquery
