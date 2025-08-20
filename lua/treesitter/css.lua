require('treesitter/types')

--- @type LanguageConfig
return {
    end_chars = {},
    handy_sortables = {},
    linkable = {
        "comment",
    },
    query_by_node = {
        declaration = [[ (declaration (property_name) @identifier) @block ]],
        rule_set = [[ (rule_set (selectors) @identifier) @block ]],
    },
}
