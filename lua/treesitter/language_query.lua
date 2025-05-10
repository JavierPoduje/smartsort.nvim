local css_node_types = require("treesitter.css.node_types")
local lua_node_types = require("treesitter.lua.node_types")
local scss_node_types = require("treesitter.scss.node_types")
local typescript_node_types = require("treesitter.typescript.node_types")

--- @class LanguageQuery
---
--- @field public language string: the language to work with
--- @field public sortable_nodes table: the sortable nodes
--- @field public non_sortable_nodes table: the non-sortable nodes
---
--- @field public get_sortable_and_non_sortable_nodes fun(self: LanguageQuery): table
--- @field public is_linkable fun(self: LanguageQuery, node_type: string): boolean
--- @field public new fun(self: LanguageQuery, language: string): LanguageQuery
---
--- @field private _get_non_sortable_nodes_by_language fun(language: string): table
--- @field private _get_sortable_nodes_by_language fun(language: string): table

local LanguageQuery = {}

--- @param language string: the language to work with
--- @return LanguageQuery
function LanguageQuery:new(language)
    LanguageQuery.__index = LanguageQuery
    local obj = {}
    setmetatable(obj, LanguageQuery)

    assert(
        language == "typescript" or
        language == "lua" or
        language == "css" or
        language == "scss",
        "Unsupported language: " .. language
    )

    obj.language = language
    obj.non_sortable_nodes = LanguageQuery._get_non_sortable_nodes_by_language(language)
    obj.sortable_nodes = LanguageQuery._get_sortable_nodes_by_language(language)

    return obj
end

--- @param node_type string: the node type
--- @return boolean: true if the node type can be linked to another sortable node, false otherwise.
LanguageQuery.is_linkable = function(self, node_type)
    for _, node in ipairs(self.non_sortable) do
        if node == node_type then
            return true
        end
    end
    return false
end


--- @param self LanguageQuery
--- @return table: list of strings with the sortable and non-sortable nodes merged
LanguageQuery.get_sortable_and_non_sortable_nodes = function(self)
    local nodes = {}

    for _, node in ipairs(self.sortable_nodes) do
        table.insert(nodes, node)
    end
    for _, node in ipairs(self.non_sortable_nodes) do
        table.insert(nodes, node)
    end
    return nodes
end

--- HELPERS

--- @param language string: the language to get the non-sortable nodes for
--- @return table: list of strings representing the non-sortable nodes
LanguageQuery._get_non_sortable_nodes_by_language = function(language)
    if language == "css" then
        return css_node_types.non_sortable
    elseif language == "lua" then
        return lua_node_types.non_sortable
    elseif language == "scss" then
        return scss_node_types.non_sortable
    elseif language == "typescript" then
        return typescript_node_types.non_sortable
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
    elseif language == "scss" then
        return scss_node_types.sortable
    elseif language == "typescript" then
        return typescript_node_types.sortable
    end

    error("Unsupported language: " .. language)
end

return LanguageQuery
