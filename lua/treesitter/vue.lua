local css_definition = require('treesitter/css')
local f = require("funcs")
local scss_definition = require('treesitter/scss')
local typescript_definition = require('treesitter/typescript')
require('treesitter/types')

--- @type LanguageConfig
return {
    embedded_languages_queries = {
        {
            language = "typescript",
            query = [[
                (script_element
                  (start_tag
                    (
                      attribute (
                        quoted_attribute_value (attribute_value) @lang
                      ) (#eq? @lang "ts")
                    )
                  )
                ) @block
            ]]
        },
        {
            language = "javascript",
            query = [[ (script_element) @block ]]
        },
        {
            language = "scss",
            query = [[
                (style_element
                  (start_tag
                    (
                      attribute (
                        quoted_attribute_value (attribute_value) @lang
                      ) (#eq? @lang "scss")
                    )
                  )
                ) @block
            ]]
        },
        {
            language = "css",
            query = [[ (style_element) @block ]]
        }
    },
    end_chars = {
        {
            char = "/>",
            gap = {
                vertical_gap = 0,
                horizontal_gap = 0,
            },
            is_attached = false,
        }
    },
    handy_sortables = {},
    linkable = f.merge_arrays(
        {},
        css_definition.linkable,
        scss_definition.linkable,
        typescript_definition.linkable
    ),
    query_by_node = {
        script_element = [[ (script_element) @injection ]],
        directive_attribute = [[ (directive_attribute (directive_value) @identifier) @block ]],
    },
}
