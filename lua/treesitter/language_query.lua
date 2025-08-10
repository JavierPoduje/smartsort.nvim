local Config = require("config")
local R = require("ramda")
local f = require("funcs")

--- @class LanguageQuery
---
--- @field public language string: the language to work with
--- @field public linkable_nodes string[]: the non-sortable nodes
--- @field public sortable_nodes string[]: the sortable nodes
---
--- @field public embedded_languages_queries fun(self: LanguageQuery): table
--- @field public get_end_chars fun(self: LanguageQuery): EndChar[]
--- @field public get_sortable_and_linkable_nodes fun(self: LanguageQuery): table
--- @field public is_linkable fun(self: LanguageQuery, node_type: string): boolean
--- @field public is_supported_node_type fun(self: LanguageQuery, node_type: string): boolean
--- @field public new fun(self: LanguageQuery, language: string): LanguageQuery
--- @field public query_by_node fun(self: LanguageQuery, node: TSNode): string

local definition_by_language = {
    css = require('treesitter/css'),
    go = require('treesitter/go'),
    javascript = require('treesitter/javascript'),
    lua = require('treesitter/lua'),
    scss = require('treesitter/scss'),
    twig = require('treesitter/twig'),
    typescript = require('treesitter/typescript'),
    vue = require('treesitter/vue')
}

local LanguageQuery = {}

local _is_supported_language = function(language)
    return R.any(R.equals(language), Config.supported_languages)
end

--- Returns a list of queries for the embedded languages
--- @param self LanguageQuery
--- @return EmbeddedLanguageQuery[]
LanguageQuery.embedded_languages_queries = function(self)
    return definition_by_language[self.language] or {}
end

--- Returns a list of queries for the embedded languages
--- @param self LanguageQuery
--- @return EndChar[]
LanguageQuery.get_end_chars = function(self)
    return definition_by_language[self.language].end_chars or {}
end

--- @param self LanguageQuery
--- @return string[]: list of strings with the sortable and non-sortable nodes merged
LanguageQuery.get_sortable_and_linkable_nodes = function(self)
    return f.merge_arrays(self.sortable_nodes, self.linkable_nodes)
end

--- @param node_type string: the node type
--- @return boolean: true if the node type can be linked to another sortable node, false otherwise.
LanguageQuery.is_linkable = function(self, node_type)
    for _, node in ipairs(self.linkable_nodes) do
        if node == node_type then
            return true
        end
    end
    return false
end

--- @param self LanguageQuery
--- @param node_type string: the type of the node
--- @return boolean
LanguageQuery.is_supported_node_type = function(self, node_type)
    assert(node_type ~= nil, "node cannot be nil")
    return R.any(R.equals(node_type), self.sortable_nodes)
end

--- @param language string: the language to work with
--- @return LanguageQuery
function LanguageQuery:new(language)
    LanguageQuery.__index = LanguageQuery
    local obj = {}
    setmetatable(obj, LanguageQuery)

    assert(
        _is_supported_language(language),
        "Unsupported language: " .. language
    )

    obj.language = language
    obj.linkable_nodes = definition_by_language[language].linkable
    obj.sortable_nodes = definition_by_language[language].sortable

    return obj
end

--- Returns a function that returns the query_by_node func for the given language
--- @param self LanguageQuery
--- @param node TSNode: the node
--- @return string: the query string
LanguageQuery.query_by_node = function(self, node)
    --- @type string
    local query = nil
    local node_type = node:type()

    if self.language == "typescript" or self.language == "javascript" then
        -- Check if the node is an export statement.
        -- If so, get the type of the first child.
        if node_type == "export_statement" then
            node_type = node:child(1):type()
        end
        query = definition_by_language[self.language].query_by_node[node_type]
    else
        query = definition_by_language[self.language].query_by_node[node_type]
    end

    assert(query ~= nil, "Unsupported node type: " .. node_type)

    return query
end

return LanguageQuery
