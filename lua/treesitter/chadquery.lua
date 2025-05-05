local typescript_nodes = require("treesitter.typescript.node_types")
local typescript_queries = require("treesitter.typescript.queries")

local lua_nodes = require("treesitter.lua.node_types")
local lua_queries = require("treesitter.lua.queries")

local css_nodes = require("treesitter.css.node_types")
local css_queries = require("treesitter.css.queries")


--- @class Chadquery
---
--- @field public lang string: the language to query
--- @field public query vim.treesitter.Query: the query
---
--- @field public build_query fun(lang: string, node: TSNode): Chadquery
--- @field public is_supported_node_type fun(lang: string, node: TSNode): boolean
--- @field public sort_and_non_sortable_nodes fun(lang: string): boolean

local Chadquery = {}
Chadquery.__index = Chadquery

--- Return a new Query object from the given land and node
--- @param lang string: the language to query
--- @param node TSNode: the node
Chadquery.build_query = function(lang, node)
    assert(lang == "typescript" or lang == "lua" or lang == "css", "Unsupported language: " .. lang)

    local query_str = nil
    if lang == "typescript" then
        query_str = typescript_queries.query_by_node(node)
    elseif lang == "lua" then
        query_str = lua_queries.query_by_node(node)
    elseif lang == "css" then
        query_str = css_queries.query_by_node(node)
    end

    assert(query_str ~= nil, "query_str cannot be nil")

    return vim.treesitter.query.parse(lang, query_str)
end


--- Returns true if the node_type is supported by the smartsort.nvim plugin
--- @param lang string: the language to query
--- @param node TSNode: the node
--- @return boolean
Chadquery.is_supported_node_type = function(lang, node)
    assert(node ~= nil, "node cannot be nil")

    if lang == "typescript" then
        return typescript_queries.is_supported_node_type(node:type())
    elseif lang == "lua" then
        return lua_queries.is_supported_node_type(node:type())
    elseif lang == "css" then
        return css_queries.is_supported_node_type(node:type())
    else
        return false
    end
end

--- Returns a list of the sortable and non-sortable nodes_types for the given language
--- @return table: a list of node types
Chadquery.sort_and_non_sortable_nodes = function(lang)
    assert(lang == "typescript" or lang == "lua" or lang == "css", "Unsupported language: " .. lang)

    if lang == "typescript" then
        return typescript_nodes.sortable_and_non_sortable()
    elseif lang == "lua" then
        return lua_nodes.sortable_and_non_sortable()
    elseif lang == "css" then
        return css_nodes.sortable_and_non_sortable()
    end

    error("Unsupported language: " .. lang)
end

return Chadquery
