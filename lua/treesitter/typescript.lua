local f = require("funcs")
local javascript_definition = require('treesitter/javascript')
require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = f.merge_tables({}, javascript_definition.end_chars),
    handy_sortables = f.merge_tables({}, javascript_definition.handy_sortables),
    linkable = f.merge_tables({}, javascript_definition.linkable),
    query_by_node = f.merge_tables(
        javascript_definition.query_by_node,
        {
            class_declaration = [[ [
              (export_statement (class_declaration (type_identifier) @identifier))
              (class_declaration (type_identifier) @identifier)
            ] @block ]],
            interface_declaration = [[
                [
                    (interface_declaration (type_identifier) @identifier)
                    (export_statement (interface_declaration (type_identifier) @identifier))
                ] @block
            ]],
            property_signature = [[ (property_signature (property_identifier) @identifier) @block ]],
            type_alias_declaration = [[
                [
                    (type_alias_declaration name: (type_identifier) @identifier)
                    (export_statement (type_alias_declaration name: (type_identifier) @identifier))
                ] @block
            ]],
        }
    ),
}
