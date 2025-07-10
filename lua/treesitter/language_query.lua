local Config = require("config")
local R = require("ramda")
local f = require("funcs")

local css_node_types = require("treesitter.css.node_types")
local css_queries = require("treesitter.css.queries")

local go_node_types = require("treesitter.go.node_types")
local go_queries = require("treesitter.go.queries")

local javascript_node_types = require("treesitter.javascript.node_types")
local javascript_queries = require("treesitter.javascript.queries")

local lua_node_types = require("treesitter.lua.node_types")
local lua_queries = require("treesitter.lua.queries")

local scss_node_types = require("treesitter.scss.node_types")
local scss_queries = require("treesitter.scss.queries")

local twig_node_types = require("treesitter.twig.node_types")
local twig_queries = require("treesitter.twig.queries")

local typescript_node_types = require("treesitter.typescript.node_types")
local typescript_queries = require("treesitter.typescript.queries")

local vue_node_types = require("treesitter.vue.node_types")
local vue_queries = require("treesitter.vue.queries")

--- @class Gap
--- @field public horizontal_gap number: the vertical gap between the two nodes
--- @field public vertical_gap number: the vertical gap between the two nodes

--- @class LanguageQuery
---
--- @field public language string: the language to work with
--- @field public sortable_nodes string[]: the sortable nodes
--- @field public linkable_nodes string[]: the non-sortable nodes
---
--- @field public embedded_languages_queries fun(self: LanguageQuery): table
--- @field public get_end_chars fun(self: LanguageQuery): EndChar[]
--- @field public get_sortable_and_linkable_nodes fun(self: LanguageQuery): table
--- @field public is_linkable fun(self: LanguageQuery, node_type: string): boolean
--- @field public is_supported_node_type fun(self: LanguageQuery, node_type: string): boolean
--- @field public new fun(self: LanguageQuery, language: string): LanguageQuery
--- @field public query_by_node fun(self: LanguageQuery, node: TSNode): string
---
--- @field private _get_linkable_nodes_by_language fun(language: string): table
--- @field private _get_sortable_nodes_by_language fun(language: string): table

local LanguageQuery = {}

local _is_supported_language = function(language)
    return R.any(R.equals(language), Config.supported_languages)
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
    obj.linkable_nodes = LanguageQuery._get_linkable_nodes_by_language(language)
    obj.sortable_nodes = LanguageQuery._get_sortable_nodes_by_language(language)

    return obj
end

--- Returns a list of queries for the embedded languages
--- @param self LanguageQuery
--- @return EmbeddedLanguageQuery[]
LanguageQuery.embedded_languages_queries = function(self)
    --- TODO: all languages `queries` should have their method `embedded_languages_queries` defined
    if self.language == "vue" then
        return vue_queries.embedded_languages_queries()
    end
    return {}
end

--- Returns a list of queries for the embedded languages
--- @param self LanguageQuery
--- @return EndChar[]
LanguageQuery.get_end_chars = function(self)
    if self.language == "vue" then
        return vue_node_types.end_chars
    elseif self.language == "typescript" then
        return typescript_node_types.end_chars
    elseif self.language == "go" then
        return go_node_types.end_chars
    elseif self.language == "javascript" then
        return javascript_node_types.end_chars
    elseif self.language == "lua" then
        return lua_node_types.end_chars
    elseif self.language == "css" then
        return css_node_types.end_chars
    elseif self.language == "scss" then
        return scss_node_types.end_chars
    end
    return {}
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
--- @return string[]: list of strings with the sortable and non-sortable nodes merged
LanguageQuery.get_sortable_and_linkable_nodes = function(self)
    return f.merge_arrays(self.sortable_nodes, self.linkable_nodes)
end

--- @param self LanguageQuery
--- @param node_type string: the type of the node
--- @return boolean
LanguageQuery.is_supported_node_type = function(self, node_type)
    assert(node_type ~= nil, "node cannot be nil")
    return R.any(R.equals(node_type), self.sortable_nodes)
end

--- Returns a function that returns the query_by_node func for the given language
--- @param self LanguageQuery
--- @param node TSNode: the node
--- @return string: the query string
LanguageQuery.query_by_node = function(self, node)
    if self.language == "typescript" then
        return typescript_queries.query_by_node(node)
    elseif self.language == "javascript" then
        return javascript_queries.query_by_node(node)
    elseif self.language == "go" then
        return go_queries.query_by_node(node)
    elseif self.language == "lua" then
        return lua_queries.query_by_node(node)
    elseif self.language == "css" then
        return css_queries.query_by_node(node)
    elseif self.language == "scss" then
        return scss_queries.query_by_node(node)
    elseif self.language == "vue" then
        return vue_queries.query_by_node(node)
    elseif self.language == "twig" then
        return twig_queries.query_by_node(node)
    end

    error("Unsupported language: " .. self.language)
end

--- HELPERS

--- @param language string: the language to get the non-sortable nodes for
--- @return table: list of strings representing the non-sortable nodes
LanguageQuery._get_linkable_nodes_by_language = function(language)
    if language == "css" then
        return css_node_types.linkable
    elseif language == "lua" then
        return lua_node_types.linkable
    elseif language == "go" then
        return go_node_types.linkable
    elseif language == "scss" then
        return f.merge_arrays(
            scss_node_types.linkable,
            css_node_types.linkable)
    elseif language == "typescript" then
        return typescript_node_types.linkable
    elseif language == "javascript" then
        return javascript_node_types.linkable
    elseif language == "twig" then
        return twig_node_types.linkable
    elseif language == "vue" then
        return f.merge_arrays(
            vue_node_types.linkable,
            typescript_node_types.linkable,
            css_node_types.linkable,
            scss_node_types.linkable
        )
    end

    error("Unsupported language: " .. language)
end

--- @param language string: the language to get the sortable nodes for
--- @return table: list of strings representing the sortable nodes
LanguageQuery._get_sortable_nodes_by_language = function(language)
    if language == "css" then
        return css_node_types.sortable
    elseif language == "lua" then
        return lua_node_types.sortable
    elseif language == "go" then
        return go_node_types.sortable
    elseif language == "twig" then
        return twig_node_types.sortable
    elseif language == "scss" then
        return f.merge_arrays(
            scss_node_types.sortable,
            css_node_types.sortable)
    elseif language == "typescript" then
        return typescript_node_types.sortable
    elseif language == "javascript" then
        return javascript_node_types.sortable
    elseif language == "vue" then
        return f.merge_arrays(
            vue_node_types.sortable,
            typescript_node_types.sortable,
            css_node_types.sortable,
            scss_node_types.sortable)
    end

    error("Unsupported language: " .. language)
end

return LanguageQuery
