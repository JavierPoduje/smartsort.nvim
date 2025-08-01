local Config = require("config")
local EndChar = require("end_char")
local LanguageQuery = require("treesitter.language_query")
local R = require("ramda")
local Region = require("region")

--- @class OptionsForEmbeddedLanguages
--- @field region? Region: the visually selected region
--- @field root_node? TSNode: the root node of the current buffer

--- @class Chadquery
---
--- @field public language string: the language to query
--- @field public query vim.treesitter.Query: the query
--- @field public language_query LanguageQuery: the language query
---
--- @field public build_query fun(self: Chadquery, node: TSNode): vim.treesitter.Query
--- @field public get_endchar_from_str fun(self: Chadquery, node: string): EndChar | nil
--- @field public is_linkable fun(self: Chadquery, node_type: string): boolean
--- @field public is_special_end_char fun(self: Chadquery, char: string): boolean
--- @field public is_supported_node_type fun(self: Chadquery, node: TSNode): boolean
--- @field public new fun(language: string, options: OptionsForEmbeddedLanguages): Chadquery
--- @field public sort_and_linkable_nodes fun(): table

local Chadquery = {}

local is_supported_language = function(language)
    return R.any(R.equals(language), Config.supported_languages)
end

--- @param language string: the language to query from
--- @param options OptionsForEmbeddedLanguages
--- @return Chadquery: a new Chadquery object
function Chadquery:new(language, options)
    options = options or {}
    Chadquery.__index = Chadquery
    local obj = {}
    setmetatable(obj, Chadquery)

    assert(is_supported_language(language), "Unsupported language: " .. language)

    local should_check_if_language_is_embedded = options and options.region and options.root_node
    if should_check_if_language_is_embedded then
        local embedded_language = Chadquery._get_language_to_work_with(options.region, options.root_node, language)
        obj.language = embedded_language
        obj.language_query = LanguageQuery:new(embedded_language)
    else
        obj.language = language
        obj.language_query = LanguageQuery:new(language)
    end

    return obj
end

--- Return a new Query object from the given land and node
--- @param self Chadquery
--- @param node TSNode: the node
--- @return vim.treesitter.Query: the query
Chadquery.build_query = function(self, node)
    assert(is_supported_language(self.language), "Unsupported language: " .. self.language)
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

--- Returns true if the character is a special end character for the given language
--- @param self Chadquery
--- @param char string: the character to check
--- @return boolean: true if the character is a special end character, false otherwise
Chadquery.is_special_end_char = function(self, char)
    local endchars = R.map(R.prop("char"), self.language_query:get_end_chars())
    return R.any(R.equals(char), endchars)
end

--- Returns the special end char for the given language if it's an special end char
--- @param self Chadquery
--- @param char string: the character to check
--- @return EndChar | nil
Chadquery.get_endchar_from_str = function(self, char)
    local end_chars = self.language_query:get_end_chars()
    for _, end_char in ipairs(end_chars) do
        if end_char.char == char then
            return EndChar:new(end_char.char, end_char.gap, end_char.is_attached)
        end
    end
    return nil
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
--- @return string[]: a list of strings representing the sortable and non-sortable nodes
Chadquery.sort_and_linkable_nodes = function(self)
    return self.language_query:get_sortable_and_linkable_nodes()
end

--- Returns the language that will be used to make queries
--- @param region Region: the region to query from
--- @param root_node TSNode: the root node of the current buffer
--- @param language string: the language to use
--- @return string: the language to use
Chadquery._get_language_to_work_with = function(region, root_node, language)
    local language_query = LanguageQuery:new(language)
    for _, elq_item in ipairs(language_query:embedded_languages_queries()) do
        local query = elq_item.query
        local embedded_language = elq_item.language

        local embedded_language_query = vim.treesitter.query.parse(language, query)
        for id, findings in embedded_language_query:iter_captures(root_node, 0) do
            local capture_name = embedded_language_query.captures[id]
            if capture_name == "block" then
                local block_node = findings
                local block_region = Region.from_node(block_node)
                if block_region:contains(region) then
                    return embedded_language
                end
            end
        end
    end

    return language
end

return Chadquery
