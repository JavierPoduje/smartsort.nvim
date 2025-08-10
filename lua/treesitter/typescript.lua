local f = require("funcs")
local javascript_definition = require('treesitter/javascript')
require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = f.merge_tables({}, javascript_definition.end_chars),
    linkable = f.merge_tables({}, javascript_definition.linkable),
    query_by_node = f.merge_tables(
        {
            interface_declaration = [[ [
               (interface_declaration (type_identifier) @identifier)
               (export_statement (interface_declaration (type_identifier) @identifier))
            ] @block ]],
            property_signature = [[ (property_signature (property_identifier) @identifier) @block ]],
        },
        javascript_definition.query_by_node
    ),
    sortable = f.merge_arrays({
        "interface_declaration",
        "pair",
        "property_signature",
    }, javascript_definition.sortable)
}
