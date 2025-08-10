local Config = require("config")
local R = require("ramda")
local f = require("funcs")

local css_node_types = require("treesitter.css.node_types")
local css_definition = require('treesitter/css')

local go_node_types = require("treesitter.go.node_types")
local go_definition = require('treesitter/go')

local javascript_node_types = require("treesitter.javascript.node_types")
local javascript_definition = require('treesitter/javascript')

local lua_node_types = require("treesitter.lua.node_types")
local lua_queries = require("treesitter.lua.queries")

local scss_node_types = require("treesitter.scss.node_types")
local scss_queries = require("treesitter.scss.queries")

local twig_node_types = require("treesitter.twig.node_types")
local twig_queries = require("treesitter.twig.queries")

local typescript_node_types = require("treesitter.typescript.node_types")
local typescript_definition = require('treesitter/typescript')

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

local linkable_nodes_by_language = {
    css = css_node_types.linkable,
    lua = lua_node_types.linkable,
    go = go_node_types.linkable,
    scss = f.merge_arrays(scss_node_types.linkable, css_node_types.linkable),
    typescript = typescript_node_types.linkable,
    javascript = javascript_node_types.linkable,
    twig = twig_node_types.linkable,
    vue = f.merge_arrays(
        vue_node_types.linkable,
        typescript_node_types.linkable,
        css_node_types.linkable,
        scss_node_types.linkable
    )
}

local sortable_nodes_by_language = {
    css = css_node_types.sortable,
    lua = lua_node_types.sortable,
    go = go_node_types.sortable,
    twig = twig_node_types.sortable,
    scss = f.merge_arrays(scss_node_types.sortable, css_node_types.sortable),
    typescript = typescript_node_types.sortable,
    javascript = javascript_node_types.sortable,
    vue = f.merge_arrays(
        vue_node_types.sortable,
        typescript_node_types.sortable,
        css_node_types.sortable,
        scss_node_types.sortable
    )
}

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
    obj.linkable_nodes = linkable_nodes_by_language[language]
    obj.sortable_nodes = sortable_nodes_by_language[language]

    return obj
end

--- Returns a list of queries for the embedded languages
--- @param self LanguageQuery
--- @return EmbeddedLanguageQuery[]
LanguageQuery.embedded_languages_queries = function(self)
    if self.language == "vue" then
        return vue_queries.embedded_languages_queries
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
    --- @type string
    local query = nil
    local node_type = node:type()

    if self.language == "typescript" then
        -- Check if the node is an export statement. If so, get the type of the first child.
        if node_type == "export_statement" then
            node_type = node:child(1):type()
        end
        query = typescript_definition.query_by_node[node_type]
    elseif self.language == "javascript" then
        -- Check if the node is an export statement. If so, get the type of the first child.
        if node_type == "export_statement" then
            node_type = node:child(1):type()
        end
        query = javascript_definition.query_by_node[node_type]
    elseif self.language == "go" then
        query = go_definition.query_by_node[node_type]
    elseif self.language == "lua" then
        return lua_queries.query_by_node(node)
    elseif self.language == "css" then
        query = css_definition.query_by_node[node_type]
    elseif self.language == "scss" then
        return scss_queries.query_by_node(node)
    elseif self.language == "vue" then
        return vue_queries.query_by_node(node)
    elseif self.language == "twig" then
        return twig_queries.query_by_node(node)
    end

    assert(query ~= nil, "Unsupported node type: " .. node_type)

    return query
end

return LanguageQuery
