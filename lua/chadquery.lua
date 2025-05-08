local css_nodes = require("treesitter.css.node_types")
local css_queries = require("treesitter.css.queries")

local lua_nodes = require("treesitter.lua.node_types")
local lua_queries = require("treesitter.lua.queries")

local scss_nodes = require("treesitter.scss.node_types")
local scss_queries = require("treesitter.scss.queries")

local typescript_nodes = require("treesitter.typescript.node_types")
local typescript_queries = require("treesitter.typescript.queries")

--- @class Chadquery
---
--- @field public lang string: the language to query
--- @field public query vim.treesitter.Query: the query
---
--- @field public build_query fun(lang: string, node: TSNode): Chadquery
--- @field public is_supported_node_type fun(lang: string, node: TSNode): boolean
--- @field public sort_and_non_sortable_nodes fun(lang: string): boolean
--- @field private _get_is_supported_node_type_callback fun(lang: string): fun(lang: string): boolean
--- @field private _get_query_by_node_callback fun(lang: string): fun(node: TSNode): string
--- @field private _get_sortable_and_non_sortable_callback fun(lang: string): fun(): table

local Chadquery = {}
Chadquery.__index = Chadquery

--- Return a new Query object from the given land and node
--- @param lang string: the language to query
--- @param node TSNode: the node
Chadquery.build_query = function(lang, node)
    assert(
        lang == "typescript" or
        lang == "lua" or
        lang == "css" or
        lang == "scss",
        "Unsupported language: " .. lang
    )
    local query_by_node_callback = Chadquery._get_query_by_node_callback(lang)
    local query_str = query_by_node_callback(node)
    assert(query_str ~= nil, "query_str cannot be nil")
    return vim.treesitter.query.parse(lang, query_str)
end

--- Returns true if the node_type is supported by the smartsort.nvim plugin
--- @param lang string: the language to query
--- @param node TSNode: the node
--- @return boolean
Chadquery.is_supported_node_type = function(lang, node)
    assert(node ~= nil, "node cannot be nil")
    return Chadquery._get_is_supported_node_type_callback(lang)(node:type())
end

--- @param lang string: the language to query
--- @param node_type string: the node type
--- @return boolean: true if the node type can be linked to another sortable node in the given
--- language, false otherwise.
Chadquery.is_linkable = function(lang, node_type)
    if lang == "typescript" then
        return typescript_nodes.is_linkable(node_type)
    elseif lang == "lua" then
        return lua_nodes.is_linkable(node_type)
    elseif lang == "css" then
        return css_nodes.is_linkable(node_type)
    elseif lang == "scss" then
        return scss_nodes.is_linkable(node_type)
    end
    error("Unsupported language: " .. lang)
end

--- Returns a list of the sortable and non-sortable nodes_types for the given language
--- @return table: a list of node types
Chadquery.sort_and_non_sortable_nodes = function(lang)
    assert(
        lang == "typescript" or
        lang == "lua" or
        lang == "css" or
        lang == "scss",
        "Unsupported language: " .. lang
    )
    return Chadquery._get_sortable_and_non_sortable_callback(lang)()
end

--- Returns the sortable_and_non_sortable function for the given language
--- @param lang string: the language to query
--- @return (fun(): table): a function that returns the sortable_and_non_sortable function
Chadquery._get_sortable_and_non_sortable_callback = function(lang)
    if lang == "typescript" then
        return typescript_nodes.sortable_and_non_sortable
    elseif lang == "lua" then
        return lua_nodes.sortable_and_non_sortable
    elseif lang == "css" then
        return css_nodes.sortable_and_non_sortable
    elseif lang == "scss" then
        return scss_nodes.sortable_and_non_sortable
    end
    error("Unsupported language: " .. lang)
end

--- Returns a function that checks if the node_type is supported by the smartsort.nvim plugin
--- @param lang string: the language to query
--- @return (fun(lang: string): boolean): a function that checks if the node_type is supported
Chadquery._get_is_supported_node_type_callback = function(lang)
    if lang == "typescript" then
        return typescript_queries.is_supported_node_type
    elseif lang == "lua" then
        return lua_queries.is_supported_node_type
    elseif lang == "css" then
        return css_queries.is_supported_node_type
    elseif lang == "scss" then
        return scss_queries.is_supported_node_type
    end

    error("Unsupported language: " .. lang)
end

--- Returns a function that returns the query_by_node func for the given language
--- @param lang string: the language to query
--- @return (fun(node: TSNode): string): a function that returns the query_by_node func
Chadquery._get_query_by_node_callback = function(lang)
    if lang == "typescript" then
        return typescript_queries.query_by_node
    elseif lang == "lua" then
        return lua_queries.query_by_node
    elseif lang == "css" then
        return css_queries.query_by_node
    elseif lang == "scss" then
        return scss_queries.query_by_node
    end

    error("Unsupported language: " .. lang)
end

return Chadquery
