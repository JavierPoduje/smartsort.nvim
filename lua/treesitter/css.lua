require('treesitter/types')

--- @type ChadLanguageConfig
return {
    end_chars = {},
    linkable = {
        "comment",
    },
    query_by_node = {
        declaration = [[ (declaration (property_name) @identifier) @block ]],
        rule_set = [[ (rule_set (selectors) @identifier) @block ]],
    },
    sortable = {
        "declaration",
        "rule_set",
    }
}
